local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local UIHelperFunctions = require(script.Parent.UIHelperFunctions)
local HouseRemote = ReplicatedStorage.Shared.Remotes.House.HouseDoorInteracted

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

	local modelName
	local isEnter = string.find(houseName, "Enter")
	local isExit = string.find(houseName, "Exit")

	if not (isEnter or isExit) then
		warn("Door string value has no 'Enter' or 'Exit' included")
		return
	end

	print(houseName)

	if isEnter then
		modelName = string.sub(houseName, 1, isEnter - 1)
		print(`Entering room {modelName}`)
		UIHelperFunctions.AdjustBlur(0.1, 100)
		HouseRemote:FireServer("Enter", modelName)
	elseif isExit then
		modelName = string.sub(houseName, 1, isExit - 1)
		print(`Leaving room {modelName}`)
		UIHelperFunctions.AdjustBlur(0.1, 100)
		HouseRemote:FireServer("Exit", modelName)
		if RoomExitFunctions[houseName] then
			RoomExitFunctions[houseName]()
		end
	end
end)
