-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local CodesOtaku = ReplicatedStorage.Shared.CodesOtaku
local CutsceneModule = CodesOtaku:WaitForChild("CutsceneModule")

-- Wait for camera
if not workspace.CurrentCamera then
	repeat
		task.wait()
	until workspace.CurrentCamera
end

-- Constructor
local Camera = workspace.CurrentCamera
local Looping = false
local Speed = 1
local FreezeControls = false

-- Loading
local CutsceneFolderRoot = ReplicatedStorage.Shared.Cutscenes
local Destroy = true
local NoYield = false
local SafeMode = true

local TextToSpeech = require(ReplicatedStorage.Shared.TextToSpeech)
local Cutscene = require(CutsceneModule)
local Demo = Cutscene.new(Camera, Looping, Speed, FreezeControls)
local SoundFolder = ReplicatedStorage.Shared.Sounds

local Player = Players.LocalPlayer
local ProtectTheCharacterWhilePlaying = true
local CharacterProtector = script:FindFirstChild("CharacterProtector")
local Music = Instance.new("Sound")
Music.Parent = script
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local SpawnModelFromServer = GeneralRemotes.SpawnServerStorageModel
local SoundModule = require(script.Parent.Parent.SoundModule)

local bin = true -- prevents multiple plays at once
local currentRenderStepped

-- Wait alternative
local function wait_time(duration)
	local start = tick()
	repeat
		RunService.Heartbeat:Wait()
	until tick() - start >= duration
	return tick() - start
end

-- Play cutscene safely
local function PlayCutscene()
	if not bin then
		return
	end
	bin = false

	if Music then
		Music:Play()
	end

	if ProtectTheCharacterWhilePlaying and Player.Character and CharacterProtector then
		CharacterProtector.Parent = Player.Character
	end

	Demo:Play()
end

local function CameraShake(duration, intensity, zoomAmount)
	local startTime = tick()
	local conn

	local originalCF = Camera.CFrame

	conn = RunService.RenderStepped:Connect(function()
		local elapsed = tick() - startTime
		if elapsed >= duration then
			conn:Disconnect()
			Camera.CFrame = originalCF
			return
		end

		-- Random small shake offsets
		local xOffset = (math.random() - 0.5) * intensity
		local yOffset = (math.random() - 0.5) * intensity
		local zOffset = (math.random() - 0.5) * intensity

		-- In/out zoom effect
		local zoomOffset = math.sin(elapsed * 25) * zoomAmount

		Camera.CFrame = originalCF * CFrame.new(xOffset, yOffset, zOffset + zoomOffset)
	end)
end

local CutsceneClientHandler = {}

CutsceneClientHandler.KeyframeHandler = {

	PsychoMantisWin = function(instruction, nextInstruction, X)
		if instruction == 1 then
			task.wait(2)
			SoundFolder.Laugh:Play()
		elseif instruction == 6 then
			task.wait(5)
			SoundFolder.PsychoMantisWinEnd:Play()
		end
	end,

	PsychoMantisFailTruth = function(instruction, nextInstruction, X)
		if instruction == 1 then
			task.wait(5)
			SoundFolder.PsychoMantisTruthDialogue1:Play()
		elseif instruction == 3 then
			task.wait(3)
			SoundFolder.PsychoMantisTruthDialogue2:Play()
		elseif instruction == 5 then
			SoundFolder.FBI:Play()
		elseif instruction == 6 then
			SoundFolder.GlassBreak:Play()
		end
	end,

	PsychoMantisFailLie = function(instruction, nextInstruction, X)
		if instruction == 1 then
			SoundFolder.Knock:Play()
		elseif instruction == 4 then
			SpawnModelFromServer:FireServer("PsychoMantis", "HallwayOder", nil)
			if SoundFolder.Knock.IsPlaying then
				SoundFolder.Knock:Stop()
			end
		end
	end,

	RoadmanFail = function(instruction, nextInstruction, X)
		if instruction > 2 then
			if instruction == 8 then
				SoundFolder.Maccies:Play()
			else
				SoundFolder.License:Play()
			end
		end
	end,

	RoadmanMugged = function(instruction, nextInstruction, X)
		if instruction == 3 then
			task.wait(1)
			SoundFolder.License:Play()
		end
	end,

	RoadmanWin = function(instruction, nextInstruction, X)
		if instruction == 1 then
			SoundFolder.BlocklandBan:Play()
		end
	end,

	GlitcherWin = function(instruction, nextInstruction, X)
		if instruction == 4 then
			SoundModule.PlaySound("Surprise")
			Music:Stop()
			Music.SoundId = "rbxassetid://9041777446"
			Music.Volume = 0.3
			Music:Play()
			task.wait(1)
			SoundModule.PlaySound("Bruh")
		end
	end,

	GlitcherRealVIP = function(instruction, nextInstruction, X)
		if instruction == 3 then
			SoundModule.PlaySound("Land")
		elseif instruction == 5 then
			SoundModule.PlaySound("Jackpot")
		elseif instruction == 13 then
			task.wait(8)
			SoundModule.PlaySound("SoGood")
		end
	end,

	CashierAngerEnd = function(instruction, nextInstruction, X)
		if instruction == 6 then
			task.wait(4)
			SoundModule.PlaySound("CashierCustomerTroll")
		elseif instruction == 7 then
			TextToSpeech.UpdateVoiceConfig(5, -12, 1, 3)
			task.wait(6)
			TextToSpeech.Speak("What did you just say....")
		end
	end,

	CashierScammed = function(instruction, nextInstruction, X)
		local player = Players.LocalPlayer.Character
		local warehouse = workspace:WaitForChild("Warehouse")
		local homeless = warehouse:WaitForChild("HomelessWarehouse")
		if instruction == 1 then
			task.wait(1)
			player.Humanoid:MoveTo(warehouse:WaitForChild("PlayerMovePos").Position)
		elseif instruction == 4 then
			-- homeless move to door
			task.wait(5)
			local pos1 = warehouse:WaitForChild("MovePos1").Position
			GeneralRemotes.HumanoidMoveTo:FireServer(homeless.Humanoid, pos1)

			-- open door
			task.wait(3)
			local door = warehouse:WaitForChild("Door")
			local openPos = door:WaitForChild("OpenPos").CFrame
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local tween = TweenService:Create(door, tweenInfo, { CFrame = openPos })
			tween:Play()
		elseif instruction == 5 then
			task.wait(4)
			local pos2 = warehouse:WaitForChild("MovePos2").Position
			GeneralRemotes.HumanoidMoveTo:FireServer(homeless.Humanoid, pos2)
		elseif instruction == 6 then
			local ttsHandle = TextToSpeech.GetHandle
			task.wait(2)
			local pos3 = warehouse:WaitForChild("MovePos3").Position
			GeneralRemotes.HumanoidMoveTo:FireServer(homeless.Humanoid, pos3)
			task.wait(3)
			local voices = {
				Homeless = { 3, 1, 1, 1 },
				Cashier = { 5, -12, 1, 1 },
			}

			local function Speak(who, text)
				TextToSpeech.UpdateVoiceConfig(unpack(voices[who]))
				if TextToSpeech.Speak(text) then
					ttsHandle().Ended:Wait()
				end
			end

			-- talk
			Speak("Homeless", "Did you get it?")
			Speak("Cashier", "Yeah, got the blox card details and doubled the victim's price as well.What a jackpot!")
			Speak(
				"Homeless",
				"This homeless honeypot gimmick to get people to buy items is working spendidly, we're getting RICH baby!"
			)
			Speak(
				"Cashier",
				"Yeah. Even the fake slow machine tactic is making them willingly disregard obvious issues, meaning bling bling bling. GAH HAH HAH HAH HAAAAAH"
			)
			Speak(
				"Homeless",
				"Did you see what I told that donkey to buy? 10 Rebel colas ya know? Got greedy and threw in some random stuff. JEE-HEE-HEE-HEE-HAAAH"
			)
			Speak(
				"Cashier",
				"Why do you always ask for outrageous quantities Dan?, we just needed him to scan his card onto the skimmer. You're the reason we have so much stored rebel colas, man!"
			)
			Speak(
				"Homeless",
				"Nothing wrong with some free snacks after we dunk the victim of their cold, hard earned, Great British Pounds. Im I right Shayden?"
			)
			Speak("Cashier", "You're right bro, lets just say it was a two for one meal deal.GAH HAH HAH HAH HAAAAAH")
			Demo:Resume()
		elseif instruction == 7 then
			Demo:Pause()
			local resumeEvent
			resumeEvent = Demo.EResume.Event:Connect(function()
				SoundModule.PlaySound("EvilLaugh")
				resumeEvent:Disconnect()
			end)
		end
	end,
}

CutsceneClientHandler.CutsceneFinishedHandler = {
	PsychoMantisFailLie = function()
		CameraShake(999, 0.1, 0.5)
		SoundFolder.Jumpscare:Play()
		task.wait(7)
		print("Rejoining")
		TeleportService:Teleport(game.PlaceId, Player)
	end,
	PsychoMantisWin = function()
		task.wait(9)
		print("Rejoining")
		TeleportService:Teleport(game.PlaceId, Player)
	end,
}

CutsceneClientHandler.Initialize = {

	GuestMissionComplete = function()
		Music.SoundId = "rbxassetid://108841455819405"
		Music.Volume = 0.5
	end,

	GuestPwn = function()
		Music.SoundId = "rbxassetid://6477407899"
		Music.Volume = 0.5
	end,

	PsychoMantisFailLie = function()
		Music.SoundId = "rbxassetid://9119386571"
		Music.Volume = 0.5
	end,

	PsychoMantisFailTruth = function()
		Music.SoundId = "rbxassetid://9119386571"
		Music.Volume = 0.5
	end,

	PsychoMantisWin = function()
		Music.SoundId = "rbxassetid://1845341094"
		Music.Volume = 0.3
	end,

	RoadmanFail = function()
		Music.SoundId = "rbxassetid://9041777446"
		Music.Volume = 0.3
		Speed = 3
	end,

	RoadmanMugged = function()
		Music.SoundId = "rbxassetid://129621410079272"
		Music.Volume = 0.5
	end,

	RoadmanWin = function()
		Music.SoundId = "rbxassetid://93143593034012"
		Music.Volume = 0.5
	end,

	SafechatterFailedObby = function()
		Music.SoundId = "rbxassetid://122447840112621"
		Music.Volume = 0.5
	end,

	GlitcherFail = function()
		Music.SoundId = "rbxassetid://7084812679"
		Music.Volume = 0.3
	end,

	GlitcherWin = function()
		Music.SoundId = "rbxassetid://87594944283000"
		Music.Volume = 0.3
	end,

	GlitcherRealVIP = function()
		Music.SoundId = "rbxassetid://1836157888"
		Music.Volume = 0.3
	end,

	CashierAngerEnd = function()
		Music.SoundId = "rbxassetid://9048856967"
		Music.Volume = 0.3
	end,

	CashierScammed = function()
		Music.SoundId = "rbxassetid://1838969178"
		Music.Volume = 0.3
	end,
}

-- Load a cutscene by name
function CutsceneClientHandler.LoadCutscene(name)
	local folder = CutsceneFolderRoot:WaitForChild(name)
	if not folder then
		warn("Cutscene not found:", name)
		return
	end
	Demo:Load(folder, Destroy, NoYield, SafeMode)
	if CutsceneClientHandler.Initialize[name] then
		CutsceneClientHandler.Initialize[name]()
	end
end

-- Play a cutscene with optional per-keyframe function
function CutsceneClientHandler.Play(name)
	-- Reset state
	bin = true

	-- Disconnect previous RenderStepped if exists
	if currentRenderStepped then
		currentRenderStepped:Disconnect()
		currentRenderStepped = nil
	end

	CutsceneClientHandler.LoadCutscene(name)

	-- Connect EStop once
	Demo.EStop.Event:Connect(function()
		if not CutsceneClientHandler.CutsceneFinishedHandler[name] then
			task.wait(7)
			print("Rejoining")
			TeleportService:Teleport(game.PlaceId, Player)
		else
			CutsceneClientHandler.CutsceneFinishedHandler[name]()
		end
	end)

	-- Update cutscene every frame
	currentRenderStepped = RunService.RenderStepped:Connect(function(delta)
		Demo:Update(delta)
	end)

	-- Custom per-keyframe logic
	if CutsceneClientHandler.KeyframeHandler[name] then
		Demo.ENextKeyframe.Event:Connect(function(instruction, nextInstruction, X)
			CutsceneClientHandler.KeyframeHandler[name](instruction, nextInstruction, X)
		end)
	end

	-- Start playback
	PlayCutscene()
end

return CutsceneClientHandler
