-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local CodesOtaku = ReplicatedStorage.CodesOtaku
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
local CutsceneFolderRoot = ReplicatedStorage.Cutscenes
local Destroy = true
local NoYield = false
local SafeMode = true

local UIHelperFunctions = require(StarterPlayer.StarterPlayerScripts.Client.UIHelperFunctions)
local TextToSpeech = require(ReplicatedStorage.TextToSpeech)
local Cutscene = require(CutsceneModule)
local Demo = Cutscene.new(Camera, Looping, Speed, FreezeControls)
local SoundFolder = ReplicatedStorage.Sounds

local Player = Players.LocalPlayer
local ProtectTheCharacterWhilePlaying = true
local CharacterProtector = script:FindFirstChild("CharacterProtector")
local Music = Instance.new("Sound")
Music.Parent = script
Music.Looped = true
local GeneralRemotes = ReplicatedStorage.Remotes
local SpawnModelFromServer = GeneralRemotes.SpawnServerStorageModel
local SoundModule = require(script.Parent.Parent.SoundModule)

local bin = true -- prevents multiple plays at once
local currentRenderStepped

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
	else
		warn("TTS FAILED")
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
			SpawnModelFromServer:InvokeServer("MissionModels", "PsychoMantis", "HallwayOder", nil)
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

	GlitcherRealVIP = function(instruction, _, _)
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
			config.Pitch = -3
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
			local ttsHandle = TextToSpeech.GetHandle()
			task.wait(2)
			local pos3 = warehouse:WaitForChild("MovePos3").Position
			GeneralRemotes.HumanoidMoveTo:FireServer(homeless.Humanoid, pos3)
			task.wait(3)
			local voices = {
				Homeless = { VoiceId = "3", Pitch = 1, Speed = 1, Volume = 1 },
				Cashier = { VoiceId = "5", Pitch = -3, Speed = 1, Volume = 1 },
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
			UIHelperFunctions.AdjustBlackScreen(1, 1)
			GeneralRemotes.SpawnServerStorageModel:InvokeServer("MissionModels", "DrivingInstructor", "Bus", nil)

			local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Linear)
			local goalCFrame = CFrame.new(130, 3.138, -65.8)

			local tween =
				TweenService:Create(workspace:WaitForChild("Bus").PrimaryPart, tweenInfo, { CFrame = goalCFrame })
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
			Speak(ttsHandle, voices, "Player", "Thank you young man.")
			Demo:Resume()
		elseif instruction == 7 then
			local bus = workspace:WaitForChild("Bus")
			task.wait(2)

			-- after cutscene finish camera should stick to the bus whilst moving
			local cam = workspace.CurrentCamera
			repeat
				wait()
				cam.CameraType = Enum.CameraType.Follow
			until cam.CameraType == Enum.CameraType.Follow
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

	DrivingTestPassed = function(instruction, _, _)
		if instruction == 1 then
			Demo:Pause()
			local car = GeneralRemotes.SpawnServerStorageModel:InvokeServer(
				"MissionModels",
				"DrivingInstructor",
				"CutsceneCar",
				nil
			)

			local cam = workspace.CurrentCamera
			repeat
				wait()
				cam.CameraType = Enum.CameraType.Follow
			until cam.CameraType == Enum.CameraType.Follow
			cam.CameraSubject = car:WaitForChild("CameraPos")
			Players.LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
			UIHelperFunctions.AdjustBlackScreen(1, 1)

			local tweenInfo = TweenInfo.new(20, Enum.EasingStyle.Linear)
			local goalCFrame = CFrame.new(-9.32, 3.538, -324.215) * car.PrimaryPart.CFrame.Rotation

			local tween = TweenService:Create(car.PrimaryPart, tweenInfo, { CFrame = goalCFrame })
			tween:Play()
			tween.Completed:Wait()

			Demo:Resume()
		elseif instruction == 2 then
			Demo:Pause()
			local car = workspace:WaitForChild("CutsceneCar")
			local sheep = car:WaitForChild("Car"):WaitForChild("Sheep")
			sheep.Transparency = 0
			local ttsHandle = TextToSpeech.GetHandle()
			local voices = {
				Player = { VoiceId = "5", Pitch = 1, Speed = 1, Volume = 1 },
				Sheep = { VoiceId = "1", Pitch = 1, Speed = 1, Volume = 1 },
			}
			Speak(
				ttsHandle,
				voices,
				"Player",
				"Always wanted to go here after I got my license. Next stop: Clan-vire-pool-gwin-gill-go-ger-uh-kwern-dro-bool-clan-tuh-sill-yo-go-go-goch"
			)
			Speak(ttsHandle, voices, "Sheep", "I believe this town is called:")
			Demo:Resume()
		elseif instruction == 3 then
			task.wait(1)
			local townName = SoundModule.PlaySound("Llanfair")
			townName.Ended:Wait()
			task.delay(1, function()
				SoundModule.PlaySound("WhatDogDoin")
			end)
			UIHelperFunctions.AdjustBlackScreen(3, 0)
		end
	end,
	BosnianComplete = function(instruction, _, _)
		local ttsHandle = TextToSpeech.GetHandle()
		local voices = {
			Bosnian = { VoiceId = "1", Pitch = 5, Speed = 1, Volume = 1 },
			Dad = { VoiceId = "1", Pitch = -8, Speed = 1, Volume = 3 },
		}

		local function runCutsceneAction(action)
			Demo.NextInstruction = 999
			action()
			Demo.NextInstruction = 0
		end

		local room, dad, laptop
		if instruction >= 4 then
			room = workspace:WaitForChild("BosnianRoom"):WaitForChild("BosnianRoom")
			dad = room:WaitForChild("BosnianDad2")
			laptop = room:FindFirstChild("Newtop") -- some instructions use laptop
		end

		if instruction == 1 then
			runCutsceneAction(function()
				warn("1")
				GeneralRemotes.SpawnServerStorageModel:InvokeServer("MissionModels", "Bosnian", "BosnianRoom", nil)
				Speak(
					ttsHandle,
					voices,
					"Bosnian",
					"Oh my god. Finally I installed Linux Ubuntu Arch Sarajevo Edition Three Point Five Two. I am excited finally utilize this monster of a contraption to play the game I dreamed of, Minesweeper."
				)
				warn("done")
			end)
		elseif instruction == 2 then
			runCutsceneAction(function()
				warn("2")
				Speak(
					ttsHandle,
					voices,
					"Bosnian",
					"The days have finally passed of me using this trashtop. Days of agony trying to play Roblox Six Siege at 10fps on a 140 pixel resolution. Sayanora."
				)
				warn("done")
			end)
		elseif instruction == 3 then
			runCutsceneAction(function()
				warn("3")
				Speak(
					ttsHandle,
					voices,
					"Bosnian",
					`This future proof £5000 beast will serve me so well. Thank you so much {Player.DisplayName}`
				)
				Speak(ttsHandle, voices, "Dad", `Did you say 11268 marks?`)
				warn("done")
			end)
		elseif instruction == 4 then
			runCutsceneAction(function()
				warn("4")
				dad:PivotTo(dad:GetPivot() + Vector3.new(0, 4, 0))
				if laptop then
					laptop:WaitForChild("WeldConstraint").Enabled = true
					laptop.Anchored = false
				end
				Speak(
					ttsHandle,
					voices,
					"Dad",
					"I'm your Otac, not 'him', so where did you get that without my permission?"
				)
				Speak(
					ttsHandle,
					voices,
					"Bosnian",
					"It's a donation from the Bosniak Bango charity organisation. You promised me, but you lied, so I took matters in my own hands."
				)
				Speak(
					ttsHandle,
					voices,
					"Dad",
					"I told you before that I will handle it, I'm the man of the house! Give me that laptop, I will deliver on my promises using my own money! We don't rely on handouts! We're the El Bosniaks!"
				)
				Speak(ttsHandle, voices, "Bosnian", "No, it's mine now, leave please.")
				warn("done")
			end)
		elseif instruction == 5 then
			runCutsceneAction(function()
				warn("5")
				Speak(
					ttsHandle,
					voices,
					"Dad",
					"I need some money for electricity rent. I'll be confiscating this young man. Hope the auction house is open."
				)

				local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
				local tween = TweenService:Create(
					dad.PrimaryPart,
					tweenInfo,
					{ CFrame = dad.PrimaryPart.CFrame * CFrame.new(0, 0, 10) }
				)
				tween:Play()
				tween.Completed:Wait()
				warn("done")
			end)
		elseif instruction == 6 then
			runCutsceneAction(function()
				warn("6")
				SoundModule.PlaySound("ManCry")
				UIHelperFunctions.AdjustBlackScreen(3, 0)
				warn("done")
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
		Music.Volume = 0.1
	end,

	CashierScammed = function()
		Music.SoundId = "rbxassetid://1838969178"
		Music.Volume = 0.3
	end,

	DrivingTestPassed = function()
		Music.SoundId = "rbxassetid://1840684529"
		Music.Volume = 0.1
	end,

	DrivingTestFailed = function()
		Music.SoundId = "rbxassetid://1838635121"
		Music.Volume = 0.05
	end,

	BosnianComplete = function()
		Music.SoundId = "rbxassetid://9120526794"
		Music.Volume = 0.1
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
	SoundModule.StopAllSounds()
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
