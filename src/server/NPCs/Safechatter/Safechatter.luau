local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local BadgeHandler = require(ServerScriptService.Server.BadgeHandler)
local NPCModule = require(ServerScriptService.Server.NPCs.NPCModule)
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local TalkModuleHelpers = require(ServerScriptService.Server.TalkModuleHelpers)
local GeneralRemotes = ReplicatedStorage.Remotes
local DelayHandle = nil
local HitEventConnected = false
local TouchedDebounce = false
local SafechatterHorrorEvent = false

local Safechatter = {}

function Safechatter.ResetGuestHorrorEnvironment(player)
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	Lighting.ClockTime = 12
	GeneralRemotes.EnableClickToMove:FireClient(player, false)
	GeneralRemotes.ChangeFOV:FireClient(player, 20)
end

function Safechatter.ResetPlayerState(hrp, humanoid)
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

function Safechatter.ResetCamera(player)
	player.CameraMaxZoomDistance = 60
	player.CameraMinZoomDistance = 0.5
	GeneralRemotes.ChangeFOV:FireClient(player, 70)
end
function Safechatter.IsSafechatterHorrorEvent()
	return SafechatterHorrorEvent
end
function Safechatter.InitializeGuestHorrorMode(player)
	SafechatterHorrorEvent = true
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

function Safechatter.HandleGuestHorrorModeFail(pathModel, light, player)
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
			SafechatterHorrorEvent = false
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
			Safechatter.ResetPlayerState(hrp, humanoid)

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
			Safechatter.ResetGuestHorrorEnvironment(player)
			light:Destroy()
			task.wait(3)
			GeneralRemotes.PlayCutscene:FireClient(player, "SafechatterFailedObby")
			GeneralRemotes.BlackFade:FireClient(player, 1, 1)
			workspace:FindFirstChild("InvisiblePaths"):Destroy()
		end
	end)
end

function Safechatter.HandleGuestHorrorModeWin(pathModel, player, prevPlayerPos, prevEnemyPos)
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
				SafechatterHorrorEvent = false
				GeneralRemotes.BlackFade:FireClient(player, 0, 0)
				-- disconnect all related events
				GeneralRemotes.EnableClickToMove:FireClient(player, false)
				GeneralRemotes.EnableCameraLookDetection:FireClient(player, false)
				NPC:DisconnectAllConnections() -- disable the onTouch trip player

				-- reset player velocity etc
				Safechatter.ResetPlayerState(hrp, humanoid)
				Safechatter.ResetGuestHorrorEnvironment(player)

				-- reset music to main
				local hasAllSoundsStopped = GeneralRemotes.StopAllMusic:InvokeClient(player)

				-- reset camera settings
				Safechatter.ResetCamera(player)

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

-- camera related functions
function Safechatter.IsTouchDebounce()
	return TouchedDebounce
end
function Safechatter.SetTouchDebounce(val)
	TouchedDebounce = val
end
function Safechatter.HitEventConnected()
	return HitEventConnected
end

function Safechatter.SetHitEventConnected(val)
	HitEventConnected = val
end

function Safechatter.WeepingAngelMode(player, isLooking)
	local SafeChatterRef = NPCModule:GetNPC("Safechatter")
	if isLooking then
		--player is looking: cancel any delayed move and stop movement
		if DelayHandle ~= nil then
			task.cancel(DelayHandle)
			DelayHandle = nil
		end
		SafeChatterRef:ForceStopMovement()
	else
		-- player is NOT looking: start delay before movement
		if player and player.Character then
			DelayHandle = task.delay(2, function()
				-- Double-check character still exists
				if player.Character then
					SafeChatterRef:StartPathing(player.Character:GetPivot())
					print("Path resume")
				end
				DelayHandle = nil
			end)
		end
	end
end

return Safechatter
