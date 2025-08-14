local HelperFunctions = {}
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local ServerTools = ServerStorage.Tools

-- force equip a tool, should a player own it (they should)
function HelperFunctions.ForceEquip(player, name)
	local tool = player.Backpack:FindFirstChild(name)
	if tool then
		player.Character.Humanoid:EquipTool(tool)
	else
		warn(`{name} not in backpack, probably equipped it already`)
	end
end

-- remove tools, should a player own it (they should)
-- goes thru backpack each iteration incase you have a duplicate (somehow)
-- also checks player model as they may have equipped it already

function HelperFunctions.RemoveTools(player, toolsStringList)
	for _, toolName in pairs(toolsStringList) do
		-- check backpack
		for _, item in pairs(player.Backpack:GetChildren()) do
			if item:IsA("Tool") and item.Name == toolName then
				item:Destroy()
			end
		end

		-- check character (equipped tools)
		if player.Character then
			for _, item in pairs(player.Character:GetChildren()) do
				if item:IsA("Tool") and item.Name == toolName then
					item:Destroy()
				end
			end
		end
	end
end

-- switch dialogue file for an NPC (NPC must have string component called "NPCName" with a tag )
function HelperFunctions.SetNPCDialogueFile(fromToTable)
	print(`Setting dialogue file...`)
	local dialogueRef, newName = next(fromToTable[1])
	print(dialogueRef .. newName)
	if dialogueRef then
		local convoTag = CollectionService:GetTagged(dialogueRef)[1]
		if convoTag then
			convoTag.Value = newName
			print(`Succesfully set dialogue file to {newName}`)
		end
	end
end

-- spawn a model
function HelperFunctions.SpawnModelAtPosition(folderName, modelName, pos)
	local model =
		ServerStorage:FindFirstChild("MissionModels"):FindFirstChild(folderName):FindFirstChild(modelName):Clone()
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
function HelperFunctions.SpawnMissionPositionedModels(folderName, keyWords)
	local missionsModels = ServerStorage:FindFirstChild("MissionModels")

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

-- clone a tool from ServerStorage to player backpack
function HelperFunctions.GiveTool(player, name)
	local tool = ServerTools:FindFirstChild(name)
	if not tool then
		error("Tool not found:", name)
		return
	end
	local clone = tool:Clone()
	clone.Parent = player.Backpack

	print(name .. " should be in your backpack")
end

-- set a tagged mesh visible/invisible with collision/no collison
-- mesh must be tagged
function HelperFunctions.SetMeshVisibility(meshTagList)
	print("Setting visibility on server...")
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

function HelperFunctions.DestroyObject(objectTagList)
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

return HelperFunctions
