-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
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

local UIHelperFunctions = require(StarterPlayer.StarterPlayerScripts.Client.UIHelperFunctions)
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

local function Speak(ttsHandle, voices, who, text)
	TextToSpeech.UpdateVoiceConfig(voices[who])
	if TextToSpeech.Speak(text) then
		ttsHandle.Ended:Wait()
	end
end

CutsceneClientHandler.KeyframeHandler = {

	PsychoMantisWin = function(instruction, _, _)
		if instruction == 1 then
			task.wait(2)
			SoundFolder.Laugh:Play()
		elseif instruction == 6 then
			task.wait(5)
			SoundFolder.PsychoMantisWinEnd:Play()
		end
	end,

	PsychoMantisFailTruth = function(instruction, _, _)
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

	PsychoMantisFailLie = function(instruction, _, _)
		if instruction == 1 then
			SoundFolder.Knock:Play()
		elseif instruction == 4 then
			SpawnModelFromServer:FireServer("PsychoMantis", "HallwayOder", nil)
			if SoundFolder.Knock.IsPlaying then
				SoundFolder.Knock:Stop()
			end
		end
	end,

	RoadmanFail = function(instruction, _, _)
		if instruction > 2 then
			if instruction == 8 then
				SoundFolder.Maccies:Play()
			else
				SoundFolder.License:Play()
			end
		end
	end,

	RoadmanMugged = function(instruction, _, _)
		if instruction == 3 then
			task.wait(3)
			SoundFolder.License:Play()
		end
	end,

	RoadmanWin = function(instruction, _, _)
		if instruction == 1 then
			SoundFolder.BlocklandBan:Play()
		end
	end,

	GlitcherWin = function(instruction, _, _)
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

	CashierAngerEnd = function(instruction, _, _)
		if instruction == 6 then
			task.wait(4)
			SoundModule.PlaySound("CashierCustomerTroll")
		elseif instruction == 7 then
			local config = {}
			config.VoiceId = "5"
			config.Pitch = 5
			config.Speed = 1
			config.Volume = 3
			TextToSpeech.UpdateVoiceConfig(config)
			task.wait(6)
			TextToSpeech.Speak("What did you just say....")
		end
	end,

	CashierScammed = function(instruction, _, _)
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
				Homeless = { VoiceId = "3", Pitch = 1, Speed = 1, Volume = 1 },
				Cashier = { VoiceId = "5", Pitch = -12, Speed = 1, Volume = 1 },
			}

			-- talk
			Speak(ttsHandle, voices, "Homeless", "Did you get it?")
			Speak(
				ttsHandle,
				voices,
				"Cashier",
				"Yeah, got the blox card details and doubled the victim's price as well.What a jackpot!"
			)
			Speak(
				ttsHandle,
				voices,
				"Homeless",
				"This homeless man gimmick to get people to buy items is working spendidly, we're getting RICH baby!"
			)
			Speak(
				ttsHandle,
				voices,
				"Cashier",
				"Yeah. Even the fake slow machine tactic is making them willingly disregard obvious issues, meaning bling bling bling. GAH HAH HAH HAH HAAAAAH"
			)
			Speak(
				ttsHandle,
				voices,
				"Homeless",
				"Did you see what I told that donkey to buy? 10 Rebel Colas you know? Got greedy and threw in some random stuff. JEE-HEE-HEE-HEE-HAAAH"
			)
			Speak(
				ttsHandle,
				voices,
				"Cashier",
				"Why do you always ask for massive quantities, Dan?, we just needed him to scan his card onto the skimmer. These boxes are full of Rebel Colas bro."
			)
			Speak(
				ttsHandle,
				voices,
				"Homeless",
				"Nothing wrong with some free snacks after we dunk the victim of their cold, hard earned, Great British Pounds. Im I right Shayden?"
			)
			Speak(
				ttsHandle,
				voices,
				"Cashier",
				"You're right bro, lets just say it was a two for one meal deal.GAH HAH HAH HAH HAAAAAH"
			)
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

	DrivingTestFailed = function(instruction, _, _)
		if instruction == 1 then
			local bus =
				GeneralRemotes.SpawnServerStorageModel:InvokeServer("MissionModels", "DrivingInstructor", "Bus", nil)

			local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Linear)
			local goalCFrame = CFrame.new(130, 3.138, -65.8)

			local tween = TweenService:Create(bus.PrimaryPart, tweenInfo, { CFrame = goalCFrame })
			tween:Play()
		elseif instruction == 5 then
			Demo:Pause()
			-- dialogue
			local ttsHandle = TextToSpeech.GetHandle()
			local voices = {
				Player = { VoiceId = "8", Pitch = 1, Speed = 1, Volume = 1 },
				Driver = { VoiceId = "7", Pitch = 6, Speed = 1, Volume = 1 },
			}
			Speak(ttsHandle, voices, "Player", "One single to Bosnia please. A laptop must be delivered.")
			Speak(ttsHandle, voices, "Driver", "Six trillion marks please. Fee is adjusted due to it being a war zone.")
			Speak(ttsHandle, voices, "Player", "ARE YOU KIDDING ME? YOU CAN FEED A COUNTRY WITH THAT MONEY!")
			Speak(ttsHandle, voices, "Driver", "You can get your own car and drive there yourself then. Oh wait.")
			Speak(ttsHandle, voices, "Player", "It's free after nine o clock isn't it?")
			Speak(ttsHandle, voices, "Driver", "Yeah, for the elderly. Clearly you're not.")
			Speak(
				ttsHandle,
				voices,
				"Player",
				"Oh my back hurts so much whippersnapper, back in those days, we used to use a tool for vehicles and pressed Y to start it."
			)
			Speak(
				ttsHandle,
				voices,
				"Driver",
				"Fine, we're running late on schedule, hurry up, i'll let it go just once."
			)
			Demo:Resume()
		elseif instruction == 7 then
			local bus = workspace:WaitForChild("Bus")
			task.wait(2)

			-- after cutscene finish camera should stick to the bus whilst moving
			local cam = workspace.CurrentCamera
			cam.CameraType = Enum.CameraType.Follow
			cam.CameraSubject = bus:WaitForChild("CameraPos")
			Players.LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson

			-- move bus
			local tweenInfo = TweenInfo.new(20, Enum.EasingStyle.Linear)
			local goalCFrame = CFrame.new(530, 3.138, -65.8)
			local tween = TweenService:Create(bus.PrimaryPart, tweenInfo, { CFrame = goalCFrame })
			tween:Play()
			UIHelperFunctions.AdjustBlackScreen(5, 0)
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
