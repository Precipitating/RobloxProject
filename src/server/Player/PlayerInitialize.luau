local ServerScriptService = game:GetService("ServerScriptService")
local PlayerBadgeDisplayer = require(ServerScriptService.Server.PlayerBadgeDisplayer)
local RoomHandler = require(ServerScriptService.Server.RoomHandler)
local PlayerInitialize = {}

function PlayerInitialize.SetupAchievements(player)
	PlayerBadgeDisplayer.GetObtainedBadges(player)
end

-- returns spawn location
function PlayerInitialize.SpawnHome()
	local room = workspace:FindFirstChild("Home")

	if not room then
		room = RoomHandler.SpawnRoomAndEnter(nil, "Home", false)
	end

	RoomHandler.SetPositionBeforeEntering(CFrame.new(-108.23, 6.73, 28.83))
	-- Wait until SpawnLocation exists inside the room
	local spawnLocation = workspace:FindFirstChild("Home"):WaitForChild("SpawnLocation", 5)

	PlayerBadgeDisplayer.SetObtainedBadgesToAchievements()
	return spawnLocation
end

function PlayerInitialize.TeleportHome(character, spawnLoc)
	if spawnLoc then
		local hrp = character:WaitForChild("HumanoidRootPart")

		-- Give physics a moment to register
		task.wait(0.1)

		-- Teleport player above SpawnLocation
		hrp.CFrame = spawnLoc.CFrame + Vector3.new(0, 5, 0)
	else
		warn("⚠️ No SpawnLocation found in spawn model!")
	end
end

function PlayerInitialize.SetCollisionGroup(character)
	-- set player's collision group
	for _, descendant in pairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "Player"
		end
	end
end
return PlayerInitialize
