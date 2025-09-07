local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)
local HelperFunctions = require(script.Parent.HelperFunctions)
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local PositionBeforeEntering = nil
local SpawnedRoom = nil
local RoomHandler = {}

-- CFrame
function RoomHandler.SetPositionBeforeEntering(CFrame)
	PositionBeforeEntering = CFrame
end

local function OpenDoor(player, character, spawnLoc)
	GeneralRemotes.BlackFade:FireClient(player, 0.5, 0)
	SoundModule.PlaySound("OpenDoor")
	task.wait(1)
	character:SetPrimaryPartCFrame(spawnLoc)
	GeneralRemotes.BlackFade:FireClient(player, 0.5, 1)
end

function RoomHandler.SpawnRoomAndEnter(player, name, enter)
	SpawnedRoom = workspace:FindFirstChild(name)
	if SpawnedRoom then
		SpawnedRoom:Destroy()
	end
	SpawnedRoom = HelperFunctions.SpawnModelAtPosition("Rooms", name, name, nil)

	if SpawnedRoom and enter then
		local spawnLoc = SpawnedRoom:FindFirstChild("SpawnLoc")
		local character = player.Character

		if character then
			PositionBeforeEntering = character:FindFirstChild("HumanoidRootPart").CFrame
			OpenDoor(player, character, spawnLoc.CFrame)
		else
			warn("CHARACTER NOT FOUND (ROOM HANDLER SPAWN ROOM)")
		end
	end
end

function RoomHandler.LeaveRoom(player)
	local character = player.Character
	if character then
		OpenDoor(player, character, PositionBeforeEntering)
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
