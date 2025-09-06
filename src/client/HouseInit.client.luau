local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local UIHelperFunctions = require(script.Parent.UIHelperFunctions)
local HouseRemote = ReplicatedStorage.Shared.Remotes.House.HouseDoorInteracted
local Debounce = false

local RoomExitFunctions = {
	ShopExit = function()
		GeneralRemotes.RemoveAllToolsOfTag:FireServer("ShopItem")
	end,
}

game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt, _)
	if not CollectionService:HasTag(prompt.Parent, "HouseDoor") then
		return
	end

	local houseName = prompt:FindFirstChild("HouseName").Value

	if not houseName then
		error("Door has no string value")
		return
	end

	if Debounce then
		return
	end
	local modelName
	local isEnter = string.find(houseName, "Enter")
	local isExit = string.find(houseName, "Exit")

	if not (isEnter or isExit) then
		warn("Door string value has no 'Enter' or 'Exit' included")
		return
	end

	print(houseName)

	if isEnter then
		Debounce = true
		modelName = string.sub(houseName, 1, isEnter - 1)
		print(`Entering room {modelName}`)
		HouseRemote:FireServer("Enter", modelName)
		task.wait(2)
		Debounce = false
	elseif isExit then
		Debounce = true
		modelName = string.sub(houseName, 1, isExit - 1)
		print(`Leaving room {modelName}`)
		HouseRemote:FireServer("Exit", modelName)
		if RoomExitFunctions[houseName] then
			RoomExitFunctions[houseName]()
		end
		task.wait(2)
		Debounce = false
	end
end)
