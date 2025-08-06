local HelperFunctions = require(script.Parent.HelperFunctions)
local BadgeHandler = require(script.Parent.BadgeHandler)
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local cutsceneRemotes = ReplicatedStorage.Shared.Cutscenes
local generalRemotes = ReplicatedStorage.Shared.Remotes
local NPCModule = require(script.Parent.NPCs.NPCModule)
local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)

local MissionEventHandlers = {}
-- handle all game events

-- Roadman
MissionEventHandlers["StealPhone"] = function()
	-- spawn the next NPC that progresses this mission
	local pos = Vector3.new(math.random(-360, 360), 5.23, -26.1)
	HelperFunctions.SpawnModelAtPosition("Roadman", "PhoneVictim", pos)
end

MissionEventHandlers["RoadmanCaught"] = function(player)
	-- stop movement
	--generalRemotes.DisableControls:FireClient(player, "Cutscene")
	-- spawn surrounding cops around player
	HelperFunctions.SpawnModelAtPosition("Roadman", "Cops", nil)

	-- award badge
	BadgeHandler.awardBadge(player, 3145652566759102)
	-- call cutscene
	cutsceneRemotes.PlayRoadmanFail:FireClient(player)
end

MissionEventHandlers["RoadmanWin"] = function(player)
	-- stop movement
	--generalRemotes.DisableControls:FireClient(player, "Cutscene")

	HelperFunctions.SpawnModelAtPosition("Roadman", "PC", nil)

	-- award badge
	BadgeHandler.awardBadge(player, 2251989026476496)

	-- call cutscene
	cutsceneRemotes.PlayRoadmanWin:FireClient(player)
end

MissionEventHandlers["RoadmanMugged"] = function(player)
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoid and rootPart then
		-- disable movement
		--generalRemotes.DisableControls:FireClient(player, "Cutscene")

		-- spawn signs
		local signs = HelperFunctions.SpawnModelAtPosition("Roadman", "MuggedSigns", nil)

		-- award badge
		BadgeHandler.awardBadge(player, 3689591686016157)

		-- load pose animation
		generalRemotes.PlayAnimation:FireClient(player, "133648952317027")

		-- teleport player to sign's MoveLoc
		rootPart.CFrame = signs.MoveLoc.CFrame

		-- trigger cutscene for this player
		cutsceneRemotes.PlayRoadmanMugged:FireClient(player)
	else
		warn("Humanoid or HumanoidRootPart missing for", player.Name)
	end
end

-- Safechatter
MissionEventHandlers["GuestMoney"] = function(player)
	print("GUEST MISSIO NBEGIN")
	HelperFunctions.SpawnMissionPositionedModels("Safechatter", "Mission")
end

local function ResetGuestHorrorEnvironment(player)
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	Lighting.ClockTime = 12
	generalRemotes.EnableClickToMove:FireClient(player, false)
	generalRemotes.ChangeFOV:FireClient(player, 20)
end

MissionEventHandlers["GuestHorrorMode"] = function(player)
	local safeChatterRef = CollectionService:GetTagged("Safechatter")[1]
	-- set dark lighting
	Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
	Lighting.ClockTime = 0

	-- give player light
	local head = player.Character:FindFirstChild("Head")
	local light = Instance.new("PointLight")
	light.Name = "PersonalLight"
	light.Brightness = 2
	light.Range = 15
	light.Color = Color3.new(1, 1, 1) -- white light
	light.Parent = head

	-- spawn obby
	local pathModel = HelperFunctions.SpawnModelAtPosition("Safechatter", "InvisiblePaths", nil)
	if not pathModel then
		warn("Failed to spawn pathModel")
		return
	end

	-- teleport player
	local spawnLoc = pathModel:FindFirstChild("SpawnLoc")
	local character = player.Character
	if spawnLoc and character and character.PrimaryPart then
		character:SetPrimaryPartCFrame(spawnLoc.CFrame)
	else
		warn("Missing SpawnLoc or character PrimaryPart")
	end

	-- enable old ROBLOX green circle click to move
	generalRemotes.EnableClickToMove:FireClient(player, true)

	-- teleport NPC

	if safeChatterRef and safeChatterRef.PrimaryPart then
		local safeChatterSpawnLoc = pathModel:FindFirstChild("SafechatterSpawnLoc")
		if safeChatterSpawnLoc then
			safeChatterRef:SetPrimaryPartCFrame(safeChatterSpawnLoc.CFrame)
		else
			warn("SafechatterSpawnLoc not found")
		end

		local NPC = NPCModule:GetNPC("Safechatter")
		NPC:EnableProximityChat(false)
		NPC:SetMode("Angel", player)
		NPC:SetWalkspeed(10)
	else
		warn("safeChatterRef missing or has no PrimaryPart")
	end

	-- handle falling out of obby
	local failPart = pathModel:FindFirstChild("FailPart")
	local failed

	if failPart then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		failed = failPart.Touched:Connect(function(hit)
			if hit.Parent == character and hit.Parent:FindFirstChild("Humanoid") then
				failed:Disconnect()
				local blur = Lighting:FindFirstChild("Blur")
				if blur then
					-- blur player
					generalRemotes.Blur:FireClient(player, 2, 100)
					generalRemotes.DisableControls:FireClient(player, "Cutscene")
					-- spawn cutscene model
					local prodRoom = HelperFunctions.SpawnModelAtPosition("Safechatter", "ProductionRoom", nil)
					-- local hrp = character:FindFirstChild("HumanoidRootPart")
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					-- disable click to move
					generalRemotes.EnableClickToMove:FireClient(player, false)
					-- -- stop all player physics movement
					hrp.Velocity = Vector3.zero
					hrp.RotVelocity = Vector3.zero
					hrp.AssemblyLinearVelocity = Vector3.zero
					hrp.AssemblyAngularVelocity = Vector3.zero
					if humanoid then
						for _, track in pairs(humanoid.Animator:GetPlayingAnimationTracks()) do
							track:Stop()
						end
					end
					hrp.Anchored = true

					-- change to guest clothes
					generalRemotes.ChangeClothes:FireClient(player, "rbxassetid://17380206", "rbxassetid://1069842201")

					-- tp to cutscene spot
					character:SetPrimaryPartCFrame(prodRoom:FindFirstChild("SpawnLoc").CFrame)

					-- stop all music
					SoundModule.StopAllSounds()

					-- award badge
					BadgeHandler.awardBadge(player, 3874162608974588)

					-- back to day and remove player light
					ResetGuestHorrorEnvironment(player)
					light:Remove()

					task.wait(3)

					-- unblur
					generalRemotes.Blur:FireClient(player, 1, 0)
					cutsceneRemotes.PlaySafechatterFailedObby:FireClient(player)
				end

				-- handle fail logic here
			end
		end)
	else
		warn("FailPart not found")
	end

	-- handle camera settings
	player.CameraMaxZoomDistance = 20
	player.CameraMinZoomDistance = 20
	generalRemotes.ChangeFOV:FireClient(player, 20)
end

MissionEventHandlers["GuestComplete"] = function(player)
	local character = player.Character
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local hallway = HelperFunctions.SpawnModelAtPosition("Safechatter", "BrainwashHallway", nil)
	rootPart.CFrame = hallway:FindFirstChild("SpawnLoc").CFrame
	BadgeHandler.awardBadge(player, 844789406145883)
	generalRemotes.PlayAnimation:FireClient(player, "90079565164200")
	cutsceneRemotes.PlayGuestMissionComplete:FireClient(player)

	-- make pitch black
	Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
	Lighting.ClockTime = 0
end

-- Guest

return MissionEventHandlers
