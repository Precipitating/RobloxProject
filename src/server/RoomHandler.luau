local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HelperFunctions = require(script.Parent.HelperFunctions)
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local PositionBeforeEntering = nil
local SpawnedRoom = nil
local RoomHandler = {}

function RoomHandler.SpawnRoomAndEnter(player, name)
	SpawnedRoom = HelperFunctions.SpawnModelAtPosition("Rooms", name, name, nil)
	if SpawnedRoom then
		local spawnLoc = SpawnedRoom:FindFirstChild("SpawnLoc")
		local character = player.Character

		if character then
			PositionBeforeEntering = character:FindFirstChild("HumanoidRootPart").CFrame
			GeneralRemotes.Blur:FireClient(player, 1, 100)
			character:SetPrimaryPartCFrame(spawnLoc.CFrame)
			GeneralRemotes.Blur:FireClient(player, 1, 0)
		else
			warn("CHARACTER NOT FOUND (ROOM HANDLER SPAWN ROOM)")
		end
	end
end

function RoomHandler.LeaveRoom(player)
	GeneralRemotes.Blur:FireClient(player, 1, 100)
	local character = player.Character
	if character then
		character:SetPrimaryPartCFrame(PositionBeforeEntering)
	else
		warn("Room leave character not found")
	end
	if SpawnedRoom then
		SpawnedRoom:Destroy()
	else
		warn("SpawnedRoom reference not found")
	end

	SpawnedRoom = nil
	GeneralRemotes.Blur:FireClient(player, 1, 0)
end

return RoomHandler
