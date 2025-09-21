local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local ServerTools = ServerStorage.Tools
local ServerHelperFunctions = {}

-- clone a tool from ServerStorage to player backpack
-- data[1] = toolName
-- data[2] = only one allowed
function ServerHelperFunctions.GiveTool(player, data)
	if data[2] ~= nil and data[2] == true then
		ServerHelperFunctions.RemoveTools(player, { data[1] }, nil)
		print("ONLY ONE TOOL OF THIS TYPE ALLOWED IN BP")
	end
	local tool = ServerTools:FindFirstChild(data[1])
	if not tool then
		error("Tool not found:", data[1])
		return
	end
	local clone = tool:Clone()
	clone.Parent = player.Backpack

	print(data[1] .. " should be in your backpack")
end

-- remove tools, should a player own it (they should)
-- goes thru backpack each iteration incase you have a duplicate (somehow)
-- also checks player model as they may have equipped it already

function ServerHelperFunctions.RemoveTools(player, toolsStringList, tag)
	local function removeFromContainer(container)
		for _, item in pairs(container:GetChildren()) do
			if item:IsA("Tool") then
				if tag and CollectionService:HasTag(item, tag) then
					item:Destroy()
				end

				if not tag and toolsStringList and table.find(toolsStringList, item.Name) then
					item:Destroy()
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

-- spawn a list of models (pos already set)
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

function ServerHelperFunctions.RemoveEquippedTool(player)
	if player.Character then
		for _, item in pairs(player.Character:GetChildren()) do
			if item:IsA("Tool") then
				item:Destroy()
			end
		end
	end
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

return ServerHelperFunctions
