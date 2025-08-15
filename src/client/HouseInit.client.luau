local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HouseRemote = ReplicatedStorage.Shared.Remotes.House.HouseDoorInteracted
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

	if isEnter then
		modelName = string.sub(houseName, 1, isEnter - 1)
		print(`Entering room {modelName}`)
		HouseRemote:FireServer("Enter", modelName)
	elseif isExit then
		modelName = string.sub(houseName, 1, isExit - 1)
		print(`Leaving room {modelName}`)
		HouseRemote:FireServer("Exit", modelName)
	end
end)
