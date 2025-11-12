local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local MissionsHandler = require(script.MissionsHandler)
local Glitcher = require(script.NPCs.Glitcher.Glitcher)
local NPCModule = require(script.NPCs.NPCModule)
local PlayerInitialize = require(script.Player.PlayerInitialize)
local RoadEvents = require(script.RoadEvents.RoadEvents)
local ServerRemotes = require(script.ServerRemotes)
local TrafficLightModule = require(script.TrafficLightModule)
local WeatherHandler = require(script.WeatherHandler)
local MaxDistBeforeTP = -400

-- handles player spawning
Players.PlayerAdded:Connect(function(player)
	MissionsHandler.Initialize()
	PlayerInitialize.SetupAchievements(player)
	local safePosition = nil

	local function setupCharacter(character)
		local spawnPos = PlayerInitialize.SpawnHome()
		PlayerInitialize.TeleportHome(character, spawnPos)

		local humanoid = character:WaitForChild("Humanoid")
		local hrp = character:WaitForChild("HumanoidRootPart")

		PlayerInitialize.SetCollisionGroup(character)
		PlayerInitialize.GiveSpeedCoil(player)
		PlayerInitialize.SquatterActivate(player, workspace:FindFirstChild("Home"))

		local function isOnGround()
			local root = character:FindFirstChild("HumanoidRootPart")
			if not root then
				return false
			end

			local rayOrigin = root.Position
			local rayDirection = vector.create(0, -3, 0)

			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = { character }
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude

			return workspace:Raycast(rayOrigin, rayDirection, raycastParams)
		end

		-- update safe position periodically
		task.spawn(function()
			while character.Parent do
				task.wait(2)
				local groundPos = isOnGround()
				if groundPos then
					safePosition = groundPos.Position
				end
			end
		end)

		-- teleport if fallen below -400 Y
		task.spawn(function()
			while character.Parent do
				task.wait(0.1)
				if hrp.Position.Y <= MaxDistBeforeTP and safePosition then
					character:MoveTo(safePosition)
				end
			end
		end)

		humanoid.Died:Connect(function()
			task.wait(3)
			player:LoadCharacter()
		end)
	end

	-- First spawn
	player.CharacterAdded:Connect(setupCharacter)
	player:LoadCharacter()

	-- all remote connections
	ServerRemotes.Initialize(player)

	-- initialize a NPC class for each NPC tag
	NPCModule:Init()

	-- weather
	WeatherHandler.Start()

	-- road events
	RoadEvents.SpawnLoop()

	-- traffic lights initialization
	for _, model in ipairs(CollectionService:GetTagged("TrafficLight")) do
		TrafficLightModule.StartTrafficLight(model)
	end

	-- start glitcher movement
	Glitcher.Initialize()
end)
