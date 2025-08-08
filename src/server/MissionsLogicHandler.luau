local HelperFunctions = require(script.Parent.HelperFunctions)
local BadgeHandler = require(script.Parent.BadgeHandler)
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)
local cutsceneRemotes = ReplicatedStorage.Shared.Cutscenes
local generalRemotes = ReplicatedStorage.Shared.Remotes
local NPCModule = require(script.Parent.NPCs.NPCModule)

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
	BadgeHandler.awardBadge(player, 4119036600108215)
	-- call cutscene
	cutsceneRemotes.PlayRoadmanFail:FireClient(player)
end

MissionEventHandlers["RoadmanWin"] = function(player)
	-- stop movement
	--generalRemotes.DisableControls:FireClient(player, "Cutscene")

	HelperFunctions.SpawnModelAtPosition("Roadman", "PC", nil)

	-- award badge
	BadgeHandler.awardBadge(player, 126301904067129)

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
		BadgeHandler.awardBadge(player, 1658087564169818)

		-- load beg animation
		generalRemotes.PlayAnimation:FireClient(player, "107485474814421")

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

local function ResetPlayerState(hrp, humanoid)
	hrp.Velocity = Vector3.zero
	hrp.RotVelocity = Vector3.zero
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero

	if humanoid then
		for _, track in pairs(humanoid.Animator:GetPlayingAnimationTracks()) do
			track:Stop()
		end
	end
end

local function ResetCamera(player)
	player.CameraMaxZoomDistance = 60
	player.CameraMinZoomDistance = 0.5
	generalRemotes.ChangeFOV:FireClient(player, 70)
end

local function InitializeGuestHorrorMode(player)
	local safeChatterModel = CollectionService:GetTagged("Safechatter")[1]
	local NPC = NPCModule:GetNPC("Safechatter")
	local character = player.Character
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
	local prevPlayerPos = character.PrimaryPart.CFrame
	if spawnLoc and character and character.PrimaryPart then
		character:SetPrimaryPartCFrame(spawnLoc.CFrame)
	else
		warn("Missing SpawnLoc or character PrimaryPart")
	end

	-- enable old ROBLOX green circle click to move
	generalRemotes.EnableClickToMove:FireClient(player, true)

	-- teleport NPC
	local prevEnemyPos
	if safeChatterModel and safeChatterModel.PrimaryPart then
		prevEnemyPos = safeChatterModel.PrimaryPart.CFrame
		local safeChatterSpawnLoc = pathModel:FindFirstChild("SafechatterSpawnLoc")
		if safeChatterSpawnLoc then
			safeChatterModel:SetPrimaryPartCFrame(safeChatterSpawnLoc.CFrame)
		else
			warn("SafechatterSpawnLoc not found")
		end

		NPC:EnableProximityChat(false)
		NPC:SetMode("Angel", player)
		NPC:SetWalkspeed(10)
	else
		warn("safeChatterModel missing or has no PrimaryPart")
	end

	-- handle camera settings
	player.CameraMaxZoomDistance = 20
	player.CameraMinZoomDistance = 20
	generalRemotes.ChangeFOV:FireClient(player, 20)

	return light, pathModel, prevPlayerPos, prevEnemyPos
end

local function HandleGuestHorrorModeFail(pathModel, light, player)
	-- handle falling out of obby
	local NPC = NPCModule:GetNPC("Safechatter")
	local character = player.Character
	local failPart = pathModel:FindFirstChild("FailPart")
	local failed
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if failPart then
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

					-- disable events
					generalRemotes.EnableClickToMove:FireClient(player, false)
					generalRemotes.EnableCameraLookDetection:FireClient(player, false)
					NPC:DisconnectAllConnections() -- disable the onTouch trip player

					-- -- stop all player physics movement
					ResetPlayerState(hrp, humanoid)

					hrp.Anchored = true

					-- change to guest clothes
					generalRemotes.ChangeClothes:FireClient(player, "rbxassetid://17380206", "rbxassetid://1069842201")

					-- tp to cutscene spot
					local playerCutsceneLoc = prodRoom:FindFirstChild("SpawnLoc")

					if playerCutsceneLoc then
						character:SetPrimaryPartCFrame(playerCutsceneLoc.CFrame)
					else
						warn("prodRoom player spawn loc is missing!")
					end

					-- stop all music
					generalRemotes.StopAllMusic:InvokeClient(player)

					BadgeHandler.awardBadge(player, 2723844059823653)

					-- back to day and remove player light
					ResetGuestHorrorEnvironment(player)
					light:Destroy()

					task.wait(3)

					-- unblur
					generalRemotes.Blur:FireClient(player, 1, 0)
					cutsceneRemotes.PlaySafechatterFailedObby:FireClient(player)
				end
			end
		end)
		return failed
	else
		error("FailPart not found")
	end
end

local function HandleGuestHorrorModeWin(pathModel, player, failed, prevPlayerPos, prevEnemyPos)
	local safeChatterModel = CollectionService:GetTagged("Safechatter")[1]
	local NPC = NPCModule:GetNPC("Safechatter")
	local character = player.Character
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	local exit = pathModel:FindFirstChild("Exit")
	local winPart
	if exit then
		winPart = exit:FindFirstChild("ExitPart")
	else
		warn("Exit model missing from pathModel")
	end

	local winConnection
	if winPart then
		winConnection = winPart.Touched:Connect(function(hit)
			if hit.Parent == character and hit.Parent:FindFirstChild("Humanoid") then
				winConnection:Disconnect()
				generalRemotes.Blur:FireClient(player, 1, 100)

				-- disconnect all related events
				failed:Disconnect()
				generalRemotes.EnableClickToMove:FireClient(player, false)
				generalRemotes.EnableCameraLookDetection:FireClient(player, false)
				NPC:DisconnectAllConnections() -- disable the onTouch trip player

				-- reset player velocity etc
				ResetPlayerState(hrp, humanoid)
				ResetGuestHorrorEnvironment(player)

				-- reset music to main
				local hasAllSoundsStopped = generalRemotes.StopAllMusic:InvokeClient(player)

				-- reset camera settings
				ResetCamera(player)

				-- tp back to original position before obby
				safeChatterModel:SetPrimaryPartCFrame(prevEnemyPos)
				character:SetPrimaryPartCFrame(prevPlayerPos)
				if hasAllSoundsStopped then
					SoundModule.PlayTheme("Main")
				else
					print("All sounds not stopped yet, Main theme not played")
				end

				-- set new NPC dialogue
				HelperFunctions.SetNPCDialogueFile({ { SafechatterNameTag = "SafechatterEscaped" } })
				NPC:SetMode("Interacting", player)
				NPC:EnableProximityChat(true)
				generalRemotes.DisableControls:FireClient(player, "UI")

				generalRemotes.Blur:FireClient(player, 1, 0)
			end
		end)
	end
end

MissionEventHandlers["GuestHorrorMode"] = function(player)
	local light, pathModel, prevPlayerPos, prevEnemyPos = InitializeGuestHorrorMode(player)

	-- handle fail obby
	local failed = HandleGuestHorrorModeFail(pathModel, light, player)

	-- handle touching the portal
	HandleGuestHorrorModeWin(pathModel, player, failed, prevPlayerPos, prevEnemyPos)
end

MissionEventHandlers["GuestPwn"] = function(player)
	generalRemotes.Blur:FireClient(player, 1, 100)
	local character = player.Character
	local alley = HelperFunctions.SpawnModelAtPosition("Safechatter", "Alleyway")
	character:SetPrimaryPartCFrame(alley:FindFirstChild("SpawnLoc").CFrame)
	generalRemotes.PlayAnimation:FireClient(player, "73806503045226")
	BadgeHandler.awardBadge(player, 550797482323175)
	cutsceneRemotes.PlayGuestPwn:FireClient(player)
	generalRemotes.Blur:FireClient(player, 1, 0)
end

MissionEventHandlers["GuestComplete"] = function(player)
	local character = player.Character
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local hallway = HelperFunctions.SpawnModelAtPosition("Safechatter", "BrainwashHallway", nil)
	rootPart.CFrame = hallway:FindFirstChild("SpawnLoc").CFrame
	BadgeHandler.awardBadge(player, 3791811322299538)
	generalRemotes.PlayAnimation:FireClient(player, "135338300387862")
	cutsceneRemotes.PlayGuestMissionComplete:FireClient(player)

	-- make pitch black
	Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
	Lighting.ClockTime = 0
end

-- Guest

return MissionEventHandlers
