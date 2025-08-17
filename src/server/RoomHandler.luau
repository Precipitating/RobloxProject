local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)
local HelperFunctions = require(script.Parent.HelperFunctions)
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local PositionBeforeEntering = nil
local SpawnedRoom = nil
local RoomHandler = {}
local Debounce = false

function RoomHandler.SpawnRoomAndEnter(player, name)
	if Debounce then
		return
	end
	SpawnedRoom = HelperFunctions.SpawnModelAtPosition("Rooms", name, name, nil)
	if SpawnedRoom then
		local spawnLoc = SpawnedRoom:FindFirstChild("SpawnLoc")
		local character = player.Character

		if character then
			Debounce = true
			PositionBeforeEntering = character:FindFirstChild("HumanoidRootPart").CFrame
			SoundModule.PlaySound("OpenDoor")
			character:SetPrimaryPartCFrame(spawnLoc.CFrame)
			GeneralRemotes.Blur:FireClient(player, 0.5, 0)
			task.wait(0.5)
			Debounce = false
		else
			warn("CHARACTER NOT FOUND (ROOM HANDLER SPAWN ROOM)")
		end
	end
end

function RoomHandler.LeaveRoom(player)
	if Debounce then
		return
	end
	local character = player.Character
	if character then
		Debounce = true
		SoundModule.PlaySound("OpenDoor")
		character:SetPrimaryPartCFrame(PositionBeforeEntering)
		GeneralRemotes.Blur:FireClient(player, 0.5, 0)
		task.wait(0.5)
		Debounce = false
	else
		warn("Room leave character not found")
	end
	if SpawnedRoom then
		SpawnedRoom:Destroy()
	else
		warn("SpawnedRoom reference not found")
	end

	SpawnedRoom = nil
end

return RoomHandler
