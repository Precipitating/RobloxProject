local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local PlayerBadgeDisplayer = require(script.Parent.PlayerBadgeDisplayer)
local ServerHelperFunctions = require(script.Parent.ServerHelperFunctions)
local GeneralRemotes = ReplicatedStorage.Remotes
local PositionBeforeEntering = nil
local SpawnedRoom = nil
local RoomHandler = {}

-- CFrame
function RoomHandler.SetPositionBeforeEntering(CFrame)
	PositionBeforeEntering = CFrame
end

local function OpenDoor(player, character, spawnLoc)
	GeneralRemotes.BlackFade:FireClient(player, 0.5, 0)
	GeneralRemotes.PlaySound:InvokeClient(player, "OpenDoor")
	task.wait(1)
	character:SetPrimaryPartCFrame(spawnLoc)
	GeneralRemotes.BlackFade:FireClient(player, 0.5, 1)
end

function RoomHandler.SpawnRoomAndEnter(player, name, enter)
	SpawnedRoom = workspace:FindFirstChild(name)
	if SpawnedRoom then
		SpawnedRoom:Destroy()
	end

	SpawnedRoom = ServerHelperFunctions.SpawnModelAtPosition("Rooms", name, name, nil)
	if name == "Home" then
		PlayerBadgeDisplayer.SetObtainedBadgesToAchievements()
	end

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
