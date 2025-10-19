local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerStorage = game:GetService("ServerStorage")
local ServerTools = ServerStorage.Tools
local GeneralRemotes = ReplicatedStorage.Remotes
local ServerHelperFunctions = {}

function ServerHelperFunctions.AlreadyOwnsTool(player, name)
	local toolLocs = { player.Backpack, player.Character }

	for _, container in pairs(toolLocs) do
		if container then
			for _, tool in ipairs(container:GetChildren()) do
				if tool:IsA("Tool") and tool.Name == name then
					print("Found tool:", tool.Name)
					return true
				end
			end
		end
	end

	return false
end

-- clone a tool from ServerStorage to player backpack
-- data[1] = toolName
-- data[2] = only one allowed
function ServerHelperFunctions.GiveTool(player, data)
	if data[2] then
		if ServerHelperFunctions.AlreadyOwnsTool(player, data[1]) then
			print(`You already own {data[1]}!`)
			return false
		end
	end
	local tool = ServerTools:FindFirstChild(data[1])
	if not tool then
		error("Tool not found:", data[1])
		return false
	end
	local clone = tool:Clone()
	clone.Parent = player.Backpack
	GeneralRemotes.PlaySound:InvokeClient(player, "Rustle")
	print(data[1] .. " should be in your backpack")
	return true
end

-- remove tools, should a player own it (they should)
-- goes thru backpack each iteration incase you have a duplicate (somehow)
-- also checks player model as they may have equipped it already
function ServerHelperFunctions.RemoveTools(player, toolsStringList, tag)
	local found = false
	local function removeFromContainer(container)
		for _, item in pairs(container:GetChildren()) do
			if item:IsA("Tool") then
				if tag and CollectionService:HasTag(item, tag) then
					item:Destroy()

					if not found then
						found = true
					end
				end

				if not tag and toolsStringList and table.find(toolsStringList, item.Name) then
					item:Destroy()

					if not found then
						found = true
					end
				end
			end
		end
	end

	-- Remove from backpack
	if player.Backpack then
		removeFromContainer(player.Backpack)
	end

	-- Remove from character
	if player.Character then
		removeFromContainer(player.Character)
	end

	return found
end

function ServerHelperFunctions.ConsumeTool(player, toolName, amount)
	if ServerHelperFunctions.OwnsXAmountOf(player, toolName, amount) then
		return ServerHelperFunctions.DeleteXAmountOf(player, toolName, amount)
	end
	return false
end
function ServerHelperFunctions.OwnsXAmountOf(player, toolName, targetAmount)
	ServerHelperFunctions.ForceUnEquip(player)
	task.wait()
	local amount = 0
	for _, tool in ipairs(player.Backpack:GetChildren()) do
		if tool:IsA("Tool") and tool.Name == toolName then
			amount += 1
			if amount >= targetAmount then
				return true
			end
		end
	end

	return false
end
function ServerHelperFunctions.DeleteXAmountOf(player, toolName, amount)
	ServerHelperFunctions.ForceUnEquip(player)
	task.wait()
	for _, tool in ipairs(player.Backpack:GetChildren()) do
		if tool:IsA("Tool") and tool.Name == toolName then
			tool:Destroy()
			amount -= 1
			if amount <= 0 then
				return true
			end
		end
	end

	return false
end

-- spawn a model
function ServerHelperFunctions.SpawnModelAtPosition(storageFolderName, folderName, modelName, pos)
	local serverStorageFolder = storageFolderName
	local model =
		ServerStorage:FindFirstChild(serverStorageFolder):FindFirstChild(folderName):FindFirstChild(modelName):Clone()
	if model then
		model.Parent = workspace
		if pos then
			model:MoveTo(pos)
		end

		return model
	else
		error("Cannot find model to spawn")
		return nil
	end
end

-- spawn a list of models inside a folder that matches keyWords (pos already set)
function ServerHelperFunctions.SpawnMissionPositionedModels(storageFolderName, folderName, keyWords)
	local missionsModels = ServerStorage:FindFirstChild(storageFolderName)

	if not missionsModels then
		warn("MissionModels folder not found in ServerStorage")
		return
	end

	local folder = missionsModels:FindFirstChild(folderName)
	if not folder then
		warn("Folder named " .. folderName .. " not found inside MissionModels")
		return
	end

	local models = folder:GetChildren()
	if models then
		for _, model in pairs(models) do
			if string.find(model.Name:lower(), keyWords:lower()) then
				model:Clone()
				model.Parent = workspace
			end
		end
	else
		error("Empty models folder. Check name")
	end
end

-- force equip a tool, should a player own it (they should)
function ServerHelperFunctions.ForceEquip(player, name)
	local tool = player.Backpack:FindFirstChild(name)
	if tool then
		player.Character.Humanoid:EquipTool(tool)
	else
		warn(`{name} not in backpack, probably equipped it already`)
	end
end

function ServerHelperFunctions.ForceUnEquip(player)
	player.Character.Humanoid:UnequipTools()
end

function ServerHelperFunctions.RemoveEquippedTool(player)
	if player.Character then
		for _, item in pairs(player.Character:GetChildren()) do
			if item:IsA("Tool") then
				item:Destroy()
			end
		end
	end
end
function ServerHelperFunctions.IsEquippingToolCalled(player, name)
	if player.Character then
		for _, item in pairs(player.Character:GetChildren()) do
			if item:IsA("Tool") and item.Name == name then
				return true
			end
		end
	end

	return false
end

-- switch dialogue file for an NPC (NPC must have string component called "NPCName" with a tag )
function ServerHelperFunctions.SetNPCDialogueFile(fromToTable)
	print("Setting dialogue file...")

	local dialogueRef, newName = next(fromToTable)
	print(dialogueRef, "->", newName)

	if dialogueRef then
		local tagged = CollectionService:GetTagged(dialogueRef)
		local success = false

		for _, inst in ipairs(tagged) do
			if inst:IsA("StringValue") then
				if inst.Value ~= newName then
					inst.Value = newName
					print(`Successfully set {dialogueRef} value to {newName}`)
					success = true
				else
					print(`Already set to {newName}`)
					success = true
				end
			end
		end

		if not success then
			warn(`No StringValue found for tag {dialogueRef}`)
		end
	end
end

function ServerHelperFunctions.DestroyObject(objectTagList)
	for _, tagName in pairs(objectTagList) do
		local tagList = CollectionService:GetTagged(tagName)
		if #tagList > 0 then
			for _, instance in pairs(tagList) do
				instance:Destroy()
				print(`{tagName} destroyed`)
			end
		else
			print(`No objects found with the tag {tagName} to destroy.`)
		end
	end
end
function ServerHelperFunctions.DestroyObjectByName(name)
	local obj = workspace:FindFirstChild(name, true)
	if obj then
		obj:Destroy()
	end
end
-- set a tagged mesh visible/invisible with collision/no collison
-- mesh must be tagged
function ServerHelperFunctions.SetMeshVisibility(meshTagList)
	print("Setting mesh visibility")
	for _, table in pairs(meshTagList) do
		for key, visible in pairs(table) do
			local meshList = CollectionService:GetTagged(key)
			if not visible then
				print(`Setting {key} invisible`)
				for _, instance in pairs(meshList) do
					instance.Transparency = 1
					instance.CanCollide = false
				end
			else
				for _, instance in pairs(meshList) do
					print(`Setting {key} visible`)
					instance.Transparency = 0
					instance.CanCollide = true
				end
			end
		end
	end
end

-- get only tagged none duplicates from dir
function ServerHelperFunctions.GetTaggedOfDirectory(dir: Instance, tag: string)
	local tagged = CollectionService:GetTagged(tag)
	local valid = {}
	local seen = {}

	for _, inst in ipairs(tagged) do
		if inst and inst:IsDescendantOf(dir) and not seen[inst] then
			seen[inst] = true
			table.insert(valid, inst)
		end
	end

	return valid
end

return ServerHelperFunctions
