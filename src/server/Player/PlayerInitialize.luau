local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local BadgeHandler = require(ServerScriptService.Server.BadgeHandler)
local PlayerBadgeDisplayer = require(ServerScriptService.Server.PlayerBadgeDisplayer)
local RoomHandler = require(ServerScriptService.Server.RoomHandler)
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local PlayerInitialize = {}

function PlayerInitialize.SetupAchievements(player)
	PlayerBadgeDisplayer.GetObtainedBadges(player)
end

function PlayerInitialize.GiveSpeedCoil(player)
	if MarketplaceService:UserOwnsGamePassAsync(player.UserId, 1492720359) then
		ServerHelperFunctions.GiveTool(player, { "SpeedCoil", true })
	end
end

function PlayerInitialize.SquatterActivate(player, home)
	local canSquat = BadgeHandler.HasBadge(player, 1297814770331368)

	if canSquat then
		-- disable frankenstein's room, already completed
		local roomDoor = CollectionService:GetTagged("FrankensteinDoor")[1]
		if roomDoor.Enabled then
			roomDoor.Enabled = false
		end
		-- spawn frankenstein room in your house and himself
		local squatRoom =
			ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Frankenstein", "FrankensteinAtHome", nil)
		squatRoom.Parent = home

		local randomSquatterActivity = ServerStorage.MissionModels.Frankenstein.FrankensteinSquatModels:GetChildren()
		local randomPose = randomSquatterActivity[math.random(1, #randomSquatterActivity)]
		randomPose:Clone()
		randomPose.Parent = home

		return true
	end

	return false
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

	return spawnLocation
end

function PlayerInitialize.TeleportHome(character, spawnLoc)
	if spawnLoc then
		local hrp = character:WaitForChild("HumanoidRootPart")

		-- Give physics a moment to register
		task.wait(0.1)

		-- Teleport player above SpawnLocation
		hrp.CFrame = spawnLoc.CFrame + vector.create(0, 5, 0)
	else
		warn("No SpawnLocation found in spawn model!")
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
