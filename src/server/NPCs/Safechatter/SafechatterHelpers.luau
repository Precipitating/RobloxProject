local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local BadgeHandler = require(ServerScriptService.Server.BadgeHandler)
local NPCModule = require(ServerScriptService.Server.NPCs.NPCModule)
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local TalkModuleHelpers = require(ServerScriptService.Server.TalkModuleHelpers)
local GeneralRemotes = ReplicatedStorage.Remotes
local SafechatterHelpers = {}

function SafechatterHelpers.ResetGuestHorrorEnvironment(player)
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	Lighting.ClockTime = 12
	GeneralRemotes.EnableClickToMove:FireClient(player, false)
	GeneralRemotes.ChangeFOV:FireClient(player, 20)
end

function SafechatterHelpers.ResetPlayerState(hrp, humanoid)
	hrp.Velocity = vector.zero
	hrp.RotVelocity = vector.zero
	hrp.AssemblyLinearVelocity = vector.zero
	hrp.AssemblyAngularVelocity = vector.zero

	if humanoid then
		for _, track in pairs(humanoid.Animator:GetPlayingAnimationTracks()) do
			track:Stop()
		end
	end
end

function SafechatterHelpers.ResetCamera(player)
	player.CameraMaxZoomDistance = 60
	player.CameraMinZoomDistance = 0.5
	GeneralRemotes.ChangeFOV:FireClient(player, 70)
end

function SafechatterHelpers.InitializeGuestHorrorMode(player)
	-- handle camera settings
	player.CameraMaxZoomDistance = 20
	player.CameraMinZoomDistance = 20
	GeneralRemotes.ChangeFOV:FireClient(player, 20)

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
	local pathModel = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Safechatter", "InvisiblePaths", nil)
	if not pathModel then
		warn("Failed to spawn pathModel")
		return
	end

	-- teleport player
	local spawnLoc = pathModel:FindFirstChild("SpawnLoc")
	local prevPlayerPos = character.PrimaryPart.CFrame
	if spawnLoc and character and character.PrimaryPart then
		character:PivotTo(spawnLoc.CFrame)
	else
		warn("Missing SpawnLoc or character PrimaryPart")
	end

	-- enable old ROBLOX green circle click to move
	GeneralRemotes.EnableClickToMove:FireClient(player, true)

	-- teleport NPC
	local prevEnemyPos
	if safeChatterModel and safeChatterModel.PrimaryPart then
		prevEnemyPos = safeChatterModel.PrimaryPart.CFrame
		local safeChatterSpawnLoc = pathModel:FindFirstChild("SafechatterSpawnLoc")
		if safeChatterSpawnLoc then
			safeChatterModel:PivotTo(safeChatterSpawnLoc.CFrame)
		else
			warn("SafechatterSpawnLoc not found")
		end

		TalkModuleHelpers.SetCanTalk(false)
		NPC:SetMode("Angel")
		NPC:SetWalkspeed(10)
	else
		warn("safeChatterModel missing or has no PrimaryPart")
	end

	return light, pathModel, prevPlayerPos, prevEnemyPos
end

function SafechatterHelpers.HandleGuestHorrorModeFail(pathModel, light, player)
	-- handle falling out of obby
	local NPC = NPCModule:GetNPC("Safechatter")
	local character = player.Character
	local failPart = pathModel:FindFirstChild("FailPart")
	local failed
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not failPart then
		return
	end
	failed = failPart.Touched:Connect(function(hit)
		if hit.Parent == character and hit.Parent:FindFirstChild("Humanoid") then
			failed:Disconnect()
			GeneralRemotes.BlackFade:FireClient(player, 0, 0)
			GeneralRemotes.DisableControls:FireClient(player, "Cutscene")
			-- spawn cutscene model
			local prodRoom =
				ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Safechatter", "ProductionRoom", nil)

			-- disable events
			GeneralRemotes.EnableClickToMove:FireClient(player, false)
			GeneralRemotes.EnableCameraLookDetection:FireClient(player, false)
			NPC:DisconnectAllConnections() -- disable the onTouch trip player

			-- -- stop all player physics movement
			SafechatterHelpers.ResetPlayerState(hrp, humanoid)

			hrp.Anchored = true

			-- change to guest clothes
			GeneralRemotes.ChangeClothes:FireClient(player, "rbxassetid://17380206", "rbxassetid://1069842201")

			-- tp to cutscene spot
			local playerCutsceneLoc = prodRoom:FindFirstChild("SpawnLoc")

			if playerCutsceneLoc then
				character:PivotTo(playerCutsceneLoc.CFrame)
			else
				warn("prodRoom player spawn loc is missing!")
			end

			-- stop all music
			GeneralRemotes.StopAllMusic:InvokeClient(player)

			BadgeHandler.awardBadge(player, 2723844059823653)

			-- back to day and remove player light
			SafechatterHelpers.ResetGuestHorrorEnvironment(player)
			light:Destroy()
			task.wait(3)
			GeneralRemotes.PlayCutscene:FireClient(player, "SafechatterFailedObby")
			GeneralRemotes.BlackFade:FireClient(player, 1, 1)
			workspace:FindFirstChild("InvisiblePaths"):Destroy()
		end
	end)
end

function SafechatterHelpers.HandleGuestHorrorModeWin(pathModel, player, prevPlayerPos, prevEnemyPos)
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
				GeneralRemotes.BlackFade:FireClient(player, 0, 0)
				-- disconnect all related events
				GeneralRemotes.EnableClickToMove:FireClient(player, false)
				GeneralRemotes.EnableCameraLookDetection:FireClient(player, false)
				NPC:DisconnectAllConnections() -- disable the onTouch trip player

				-- reset player velocity etc
				SafechatterHelpers.ResetPlayerState(hrp, humanoid)
				SafechatterHelpers.ResetGuestHorrorEnvironment(player)

				-- reset music to main
				local hasAllSoundsStopped = GeneralRemotes.StopAllMusic:InvokeClient(player)

				-- reset camera settings
				SafechatterHelpers.ResetCamera(player)

				-- tp back to original position before obby
				safeChatterModel:PivotTo(prevEnemyPos)
				character:PivotTo(prevPlayerPos)
				if hasAllSoundsStopped then
					GeneralRemotes.PlayTheme:FireClient(player, "Main")
				else
					print("All sounds not stopped yet, Main theme not played")
				end

				-- set new NPC dialogue
				ServerHelperFunctions.SetNPCDialogueFile({ SafechatterNameTag = "SafechatterEscaped" })
				NPC:SetMode("Interacting")
				TalkModuleHelpers.SetCanTalk(true)
				GeneralRemotes.DisableControls:FireClient(player, "UI")

				GeneralRemotes.BlackFade:FireClient(player, 1, 1)
			end
		end)
	end
end

return SafechatterHelpers
