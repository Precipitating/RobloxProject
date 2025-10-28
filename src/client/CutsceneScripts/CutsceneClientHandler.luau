-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

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

local Player = Players.LocalPlayer
local ProtectTheCharacterWhilePlaying = true
local CharacterProtector = script:FindFirstChild("CharacterProtector")
local Music = Instance.new("Sound")
Music.Parent = script
Music.Looped = true
local GeneralRemotes = ReplicatedStorage.Remotes
local SpawnModelFromServer = GeneralRemotes.SpawnServerStorageModel
local SoundModule = require(script.Parent.Parent.SoundModule)
local TTSHandle = TextToSpeech.GetHandle()

local bin = true -- prevents multiple plays at once
local currentRenderStepped

local voices = {
	Bosnian = { VoiceId = "1", Pitch = 5, Speed = 1, Volume = 3 },
	Dad = { VoiceId = "1", Pitch = -5, Speed = 1, Volume = 3 },
	Homeless = { VoiceId = "3", Pitch = 1, Speed = 1, Volume = 3 },
	Cashier = { VoiceId = "5", Pitch = -3, Speed = 1, Volume = 3 },
	Driver = { VoiceId = "7", Pitch = 6, Speed = 1, Volume = 3 },
	Player = { VoiceId = "5", Pitch = 1, Speed = 1, Volume = 3 },
	Thief = { VoiceId = "5", Pitch = -1, Speed = 1, Volume = 3 },
	Sheep = { VoiceId = "1", Pitch = 1, Speed = 1, Volume = 3 },
	Mom = { VoiceId = "4", Pitch = 1, Speed = 1, Volume = 3 },
	Damon = { VoiceId = "1", Pitch = 2, Speed = 1, Volume = 3 },
	CitizenGirl = { VoiceId = "6", Pitch = 1, Speed = 1, Volume = 3 },
	Director = { VoiceId = "3", Pitch = -6, Speed = 1, Volume = 3 },
}

local function TweenLookAtCamera(duration, part)
	local tween = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {
		CFrame = CFrame.lookAt(part.Position, Camera.CFrame.Position),
	}
	local tweenPlayer = TweenService:Create(part, tween, goal):Play()

	return tweenPlayer
end

local function TweenToCamera(duration, part)
	local tween = TweenInfo.new(duration, Enum.EasingStyle.Linear)
	local goal = {
		Position = Camera.CFrame.Position,
	}
	local tweenPlayer = TweenService:Create(part, tween, goal):Play()

	return tweenPlayer
end
local function ScaleTween(duration, part, size)
	local tween = TweenInfo.new(duration, Enum.EasingStyle.Linear)
	local goal = {
		Size = vector.create(size, size, size),
	}
	local tweenPlayer = TweenService:Create(part, tween, goal):Play()

	return tweenPlayer
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

local function Speak(who, text)
	TextToSpeech.UpdateVoiceConfig(voices[who])
	if TextToSpeech.Speak(text) then
		TTSHandle.Ended:Wait()
	else
		warn("TTS FAILED")
	end
end

-- Stops the cutscene from continuing to next instruction until action is finished
local function RunCutsceneAction(action)
	-- pause the cutscene
	Demo.NextInstruction = 9999
	action()
	Demo.NextInstruction = 0
end

CutsceneClientHandler.KeyframeHandler = {

	PsychoMantisWin = function(instruction, _, _)
		if instruction == 1 then
			task.wait(2)
			SoundModule.PlaySound("Laugh")
		elseif instruction == 6 then
			task.wait(5)
			SoundModule.PlaySound("PsychoMantisWinEnd")
		end
	end,

	PsychoMantisFailTruth = function(instruction, _, _)
		if instruction == 1 then
			task.wait(5)
			SoundModule.PlaySound("PsychoMantisTruthDialogue1")
		elseif instruction == 3 then
			task.wait(3)
			SoundModule.PlaySound("PsychoMantisTruthDialogue2")
		elseif instruction == 5 then
			SoundModule.PlaySound("FBI")
		elseif instruction == 6 then
			SoundModule.PlaySound("GlassBreak")
		end
	end,

	PsychoMantisFailLie = function(instruction, _, _)
		if instruction == 1 then
			SoundModule.PlaySound("Knock")
		elseif instruction == 4 then
			SpawnModelFromServer:InvokeServer("MissionModels", "PsychoMantis", "HallwayOder", nil)
			SoundModule.StopSound("Knock")
		end
	end,

	RoadmanFail = function(instruction, _, _)
		if instruction > 2 then
			if instruction == 8 then
				SoundModule.PlayTheme("Maccies")
			else
				SoundModule.PlaySound("License")
			end
		end
	end,

	RoadmanMugged = function(instruction, _, _)
		if instruction == 3 then
			task.wait(3)
			SoundModule.PlaySound("License")
		end
	end,

	RoadmanWin = function(instruction, _, _)
		if instruction == 1 then
			SoundModule.PlaySound("BlocklandBan")
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
			RunCutsceneAction(function()
				task.wait(5)
				local pos1 = warehouse:WaitForChild("MovePos1").Position
				-- yields until MoveTo is finished
				GeneralRemotes.HumanoidMoveTo:InvokeServer(homeless, pos1, true)
				-- open door
				local door = warehouse:WaitForChild("Door")
				local openPos = door:WaitForChild("OpenPos").CFrame
				local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				local tween = TweenService:Create(door, tweenInfo, { CFrame = openPos })
				tween:Play()
				tween.Completed:Wait()
			end)
		elseif instruction == 5 then
			RunCutsceneAction(function()
				-- go inside warehouse
				local pos2 = warehouse:WaitForChild("MovePos2").Position
				GeneralRemotes.HumanoidMoveTo:InvokeServer(homeless, pos2, true)
				task.wait(1)
			end)
		elseif instruction == 6 then
			RunCutsceneAction(function()
				-- move to mastermind
				local pos3 = warehouse:WaitForChild("MovePos3").Position
				GeneralRemotes.HumanoidMoveTo:InvokeServer(homeless, pos3, true)
				print("6")
				task.wait(1)
				Speak("Homeless", "Did you get it?")
				Speak(
					"Cashier",
					"Yeah, got the deets and doubled bro's price as well.What a donkey that robloxian was!"
				)
				Speak(
					"Homeless",
					"This homeless man gimmick to get people to buy items is working spendidly, we're getting RICH baby!"
				)
				Speak(
					"Cashier",
					"Yeah. Even the fake slow machine tactic is making them willingly disregard obvious issues, meaning bling bling bling. GAH HAH HAH HAH HAAAAAH"
				)
				Speak(
					"Homeless",
					"Did you see what I told that donkey to buy? 10 Rebel Colas you know? Got greedy and threw in some random stuff. JEE-HEE-HEE-HEE-HAAAH"
				)
				Speak(
					"Cashier",
					"Why do you always request for massive quantities, Dan?, we just needed him to scan his card onto the skimmer. These boxes are full of Rebel Colas bro."
				)
				Speak(
					"Homeless",
					"Nothing wrong with some free snacks after we dunk the victim of their cold, hard earned, Great British Pounds. Im I right Shayden?"
				)
				Speak(
					"Cashier",
					"You're right bro, lets just say it was a two for one meal deal.GAH HAH HAH HAH HAAAAAH"
				)
			end)
		elseif instruction == 7 then
			task.wait(1)
			SoundModule.PlaySound("EvilLaugh")
		end
	end,

	DrivingTestFailed = function(instruction, _, _)
		if instruction == 1 then
			RunCutsceneAction(function()
				UIHelperFunctions.AdjustBlackScreen(1, 1)
				GeneralRemotes.SpawnServerStorageModel:InvokeServer("MissionModels", "DrivingInstructor", "Bus", nil)
			end)
		elseif instruction == 2 then
			RunCutsceneAction(function()
				print("2")
				local bus = workspace:WaitForChild("Bus")
				bus:WaitForChild("Base")
				local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Linear)
				local goalCFrame = CFrame.new(130, 3.138, -65.8)

				local tween = TweenService:Create(bus.PrimaryPart, tweenInfo, { CFrame = goalCFrame })
				tween:Play()
				print("tween should play")
				tween.Completed:Wait()
			end)
		elseif instruction == 4 then
			RunCutsceneAction(function()
				task.wait(3)
				print("4")
				-- dialogue
				Speak("Player", "One single to Bosnia please. A laptop must be delivered.")
				Speak("Driver", "Six trillion marks please. Fee is adjusted due to it being a war zone.")
				Speak("Player", "ARE YOU KIDDING ME? YOU CAN FEED A COUNTRY WITH THAT MONEY!")
				Speak("Driver", "You can get your own car and drive there yourself then. Oh wait.")
				Speak("Player", "It's free after nine o clock isn't it?")
				Speak("Driver", "Yeah, for the elderly. Clearly you're not.")
				Speak(
					"Player",
					"Oh my back hurts so much whippersnapper, back in those days, we used to use a tool for vehicles and pressed Y to start it."
				)
				Speak("Driver", "Fine, we're running late on schedule, hurry up, i'll let it go just once.")
				Speak("Player", "Thank you young man.")
			end)
		elseif instruction == 7 then
			local bus = workspace:WaitForChild("Bus")
			task.wait(2)
			-- after cutscene finish camera should stick to the bus whilst moving
			repeat
				task.wait()
				Camera.CameraType = Enum.CameraType.Follow
			until Camera.CameraType == Enum.CameraType.Follow
			Camera.CameraSubject = bus:WaitForChild("CameraPos")
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

			repeat
				wait()
				Camera.CameraType = Enum.CameraType.Follow
			until Camera.CameraType == Enum.CameraType.Follow
			Camera.CameraSubject = car:WaitForChild("CameraPos")
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
			Speak(
				"Player",
				"Always wanted to go here after I got my license. Next stop: Clan-vire-pool-gwin-gill-go-ger-uh-kwern-dro-bool-clan-tuh-sill-yo-go-go-goch"
			)
			Speak("Sheep", "I believe this town is called:")
			Demo:Resume()
		elseif instruction == 3 then
			task.wait(1)
			local townName = SoundModule.PlaySound("Llanfair")
			townName.Ended:Wait()
			task.delay(0.5, function()
				SoundModule.PlaySound("WhatDogDoin")
			end)
			UIHelperFunctions.AdjustBlackScreen(3, 0)
		end
	end,
	BosnianComplete = function(instruction, _, _)
		local room, dad, laptop
		if instruction >= 4 then
			room = workspace:WaitForChild("BosnianRoom"):WaitForChild("BosnianRoom")
			dad = room:WaitForChild("BosnianDad2")
			laptop = room:FindFirstChild("Newtop") -- some instructions use laptop
		end

		if instruction == 1 then
			RunCutsceneAction(function()
				warn("1")
				GeneralRemotes.SpawnServerStorageModel:InvokeServer("MissionModels", "Bosnian", "BosnianRoom", nil)
				Speak(
					"Bosnian",
					"Oh my god. Finally I installed Linux Ubuntu Arch Sarajevo Edition Three Point Five Two. I am excited finally utilize this monster of a contraption to play the game I dreamed of, Minesweeper."
				)
				warn("done")
			end)
		elseif instruction == 2 then
			RunCutsceneAction(function()
				warn("2")
				Speak(
					"Bosnian",
					"The days have finally passed of me using this trashtop. Days of agony trying to play Roblox Six Siege at 10fps on a 140 pixel resolution. Sayanora."
				)
				warn("done")
			end)
		elseif instruction == 3 then
			RunCutsceneAction(function()
				warn("3")
				Speak(
					"Bosnian",
					`This future proof £5000 beast will serve me so well. Thank you so much {Player.DisplayName}`
				)
				Speak("Dad", `Did you say 11268 marks?`)
				warn("done")
			end)
		elseif instruction == 4 then
			RunCutsceneAction(function()
				warn("4")
				Speak("Dad", "I'm your Otac, not 'him', so where did you get that without my permission?")
				dad:PivotTo(dad:GetPivot() + vector.create(0, 4, 0))
				if laptop then
					laptop:WaitForChild("WeldConstraint").Enabled = true
					laptop.Anchored = false
				end
				Speak(
					"Bosnian",
					"It's a donation from the Bosniak Bango charity organisation. You promised me, but you lied, so I took matters in my own hands."
				)
				Speak(
					"Dad",
					"I told you before that I will handle it, I'm the man of the house! Give me that laptop, I will deliver on my promises using my own money! We don't rely on handouts! We're the El Bosniaks!"
				)
				Speak("Bosnian", "No, it's mine now, leave please.")
				warn("done")
			end)
		elseif instruction == 5 then
			RunCutsceneAction(function()
				warn("5")
				Speak(
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
			RunCutsceneAction(function()
				warn("6")
				SoundModule.PlayTheme("ManCry")
				UIHelperFunctions.AdjustBlackScreen(3, 0)
				warn("done")
			end)
		end
	end,
	BosnianFailed = function(instruction, _, _)
		if instruction == 1 then
			RunCutsceneAction(function()
				GeneralRemotes.SpawnServerStorageModel:InvokeServer(
					"MissionModels",
					"Bosnian",
					"BosnianRoomFailed",
					nil
				)
				Speak(
					"Bosnian",
					`Finally, a new strong laptop donated by the {Player.DisplayName} foundation. That fake wallpaper is funny, but it'll disappear when I power on, surely... surely it will... surely.`
				)
				Speak("Dad", `Is that the trashtop I sold to some random robloxian?`)
			end)
		elseif instruction == 2 then
			RunCutsceneAction(function()
				task.wait(1)
				Speak("Dad", `Ha ha ha it is as well, it came full circle huh? `)
				Speak(
					"Bosnian",
					"I was supposed to get a new laptop today, but you didn't step up, dad. I had to beg for one and got lucky. You think this is a joke? It's all your fault!"
				)
				Speak(
					"Dad",
					"No idea what you said, but look at the drip i've acquired, bought it from the auction thanks to that laptop you have there harr harr dee harr. Antique Clan Point merch goes crazy."
				)
				Speak("Bosnian", `Make haste as once dad!`)
			end)
		elseif instruction == 3 then
			local laptop =
				workspace:WaitForChild("BosnianRoomFailed"):WaitForChild("BosnianRoom"):WaitForChild("Trashtop")

			RunCutsceneAction(function()
				task.wait(1)
				Speak(
					"Bosnian",
					"Now with the distractions out of the way, time to power on this masterpiece and become the best gamer ever to exist."
				)
				SoundModule.PlaySound("PCPowerOn").Ended:Wait()
				SoundModule.PlaySound("ElectricExplosion")

				local function Explode()
					for _, obj in ipairs(laptop:GetDescendants()) do
						if obj:IsA("ParticleEmitter") then
							obj.Enabled = true
						end
					end
					local explosion = Instance.new("Explosion")
					explosion.Position = laptop:GetPivot().Position
					explosion.BlastRadius = 8
					explosion.BlastPressure = 150000
					explosion.DestroyJointRadiusPercent = 0
					explosion.Parent = workspace
				end
				Explode()

				task.wait(2)
				SoundModule.PlayTheme("ManCry")
				task.wait(5)
				Speak("Mom", "It's ok son.")
				SoundModule.StopTheme()
			end)
		elseif instruction == 4 then
			RunCutsceneAction(function()
				SoundModule.PlayTheme("AngelTheme")
				task.wait(1)
				Speak(
					"Mom",
					"I am the mother who stepped up. I have secretly accumulated money to afford this BeastTop 9000 for you. Happy Bosnia day son."
				)
				Speak("Bosnian", "Mummy")
				UIHelperFunctions.AdjustBlackScreen(5, 0)
			end)
		end
	end,
	CupcakeLoverBossDefeated = function(instruction, _, _)
		if instruction == 1 then
			RunCutsceneAction(function()
				UIHelperFunctions.AdjustBlackScreen(1, 1)
			end)
		elseif instruction == 2 then
			RunCutsceneAction(function()
				SoundModule.PlaySound("CupcakeLoverGossip").Ended:Wait()
				Speak("Player", "Nam-ahh-stay, Damon, Nam-ahh-stay")
				SoundModule.PlaySound("EvilLaugh")
			end)
			UIHelperFunctions.AdjustBlackScreen(6, 0)
		end
	end,

	CupcakeLoverBossFailed = function(instruction, _, _)
		local cupcakeLoverHead = workspace
			:WaitForChild("NPCs")
			:WaitForChild("CupcakeLover")
			:WaitForChild("CupcakeLover")
			:WaitForChild("Head")
		local brainwashedPlayerHead = workspace:WaitForChild("BossFailedPlayer"):WaitForChild("Head")

		if instruction == 2 then
			RunCutsceneAction(function()
				task.wait(9)
				SoundModule.PlaySound("Oi")
				Music:Stop()
				task.wait(0.5)
				SoundModule.PlaySound("RecordScratch").Ended:Wait()
			end)
		elseif instruction == 3 then
			RunCutsceneAction(function()
				task.wait(1)
				TweenLookAtCamera(1, cupcakeLoverHead)
				Speak("Damon", "I know you looked at my famous face. Come here.")
			end)
		elseif instruction == 4 then
			RunCutsceneAction(function()
				SoundModule.PlayTheme("Mysterious")
				task.wait(3)
				TweenLookAtCamera(1, cupcakeLoverHead)
				task.wait(5)
				TweenLookAtCamera(1, brainwashedPlayerHead)
				Speak(
					"Player",
					"WELL? AREN'T YOU GOING TO GREET THE MOST FAMOUS DEVELOPER WHO CONTRIBUTED TO OVER 100 TRILLION VISITS YOU PAGAN!"
				)
				Speak("CitizenGirl", "What do you want? who are you?")
				Speak(
					"Player",
					"YOU DON'T KNOW? YOU DOING A PATRICK UNDER A ROCK COSPLAY? HES THE MOST FAMOUS DEVELOPER OF FLOPARIA, BROSKI"
				)
				Speak("CitizenGirl", "That one game where you had to morse code a flicking light?")
				Speak("Damon", "Yeah. I was part of that as well, scripted that myself. That was me and only me buddy.")
				SoundModule.PlaySound("Error")
				Speak("Player", "Error Error Error he said he was only a card developer")
				Speak("CitizenGirl", "Is that guy alright? ")
				Speak("Damon", `Sorry hold on. :fix {Player.DisplayName}`)
				SoundModule.PlaySound("Correct")
				Speak(
					"Player",
					`EXACTLY, HE IS BASICALLY FLOPARIA HIMSELF. HE IS THE BACKBONE OF FLOPARIA. WAKE UP WOMAN`
				)
				Speak("CitizenGirl", "I barely know you sir, I only play dress to unimpress! what game that is!")
				Speak("Damon", `...Wait, you think that game's more famous and better than mine?`)
				Speak("CitizenGirl", "Yes! that game is absolutely delightful")
				SoundModule.PlayTheme("ScaryAmbience")
				Speak(
					"Damon",
					`Sorry I misspoke, let me say it again:You think that game's more famous and better than mine?`
				)
				Speak("CitizenGirl", "Yes!")
				Speak("Player", "DID YOU JUST DISRESPECT THE GREATEST DEVELOPER OF ALL TIME DAMON JAY?")
				Speak("CitizenGirl", "No sir that is my opinion")
				Speak("Damon", `One more time.You think that game's more famous and better than mine?`)
				Speak("CitizenGirl", "Yes!")
				SoundModule.StopTheme()
				task.wait(5)
				SoundModule.PlaySound("Jumpscare")
				TweenToCamera(1, brainwashedPlayerHead)
				ScaleTween(0.5, brainwashedPlayerHead, 2)
				task.wait(0.7)
				UIHelperFunctions.AdjustBlackScreen(0, 0)
			end)
		end
	end,

	MoneyBaitCaught = function(instruction, _, _)
		local hand = workspace:WaitForChild("ElectricChairRoom"):WaitForChild("Hand")
		if instruction == 1 then
			RunCutsceneAction(function()
				UIHelperFunctions.AdjustBlackScreen(1, 1)
				task.wait(math.random(10, 20))
				Music:Stop()
				local handMoveTween = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
				local pullHandleGoal = { Position = hand.Position - vector.create(0, 2, 0) }
				local executeTween = TweenService:Create(hand, handMoveTween, pullHandleGoal)
				executeTween:Play()
				executeTween.Completed:Wait()
				SoundModule.PlaySound("Electrocution")
				UIHelperFunctions.AdjustBlackScreen(0, 0)
			end)
		end
	end,

	MoneyBaitEscaped = function(instruction, _, _)
		if instruction == 1 then
			UIHelperFunctions.AdjustBlackScreen(1, 1)
		elseif instruction == 2 then
			RunCutsceneAction(function()
				task.wait(13)
				print("2 end")
			end)
		elseif instruction == 5 then
			RunCutsceneAction(function()
				task.wait(1)
				SoundModule.PlaySound("Spotted")
				SoundModule.PlaySound("Oi")
				Music:Stop()
				task.wait(1)
				print("3 end")
			end)
		elseif instruction == 6 then
			SoundModule.PlayTheme("Running")
		elseif instruction == 9 then
			RunCutsceneAction(function()
				task.wait(2)
				local alley = workspace:WaitForChild("Alleyway")
				if not alley then
					error("Missing alley ref")
				end
				local director = alley:WaitForChild("Director")
				local endPos = alley:WaitForChild("DirectorEndPos")
				director:PivotTo(endPos.CFrame)
				SoundModule.PlayTheme("Scary")
			end)
		elseif instruction == 10 then
			RunCutsceneAction(function()
				SoundModule.PlaySound("Spotted")
				Speak(
					"Director",
					`You really thought you could escape without my permission, huh, {Player.DisplayName} `
				)
				Speak(
					"Director",
					`You actually stole my method of escaping blox river, the toilet, the elevator, everything.`
				)
				Speak(
					"Director",
					`You will pay the price for this as I, Michael Rofield will not stand for copy merchants on my show`
				)
				Speak(
					"Director",
					`You will be reconstructed into Venom Michael and become me. You will be forced to escape every prison in the world and be milked dry by the show directors`
				)
				Speak(
					"Director",
					`You saw the fall off during season 5, now you'll enjoy 1000 more seasons, as me. As me.`
				)
				Speak("Director", `Get some shut eye, you'll need it`)
				SoundModule.PlaySound("BoneSnap")
				UIHelperFunctions.AdjustBlackScreen(0, 0)
				task.wait(2)
				SoundModule.PlaySound("EvilLaugh")
			end)
		end
	end,

	ThiefFailed = function(instruction, _, _)
		local tweenInfo = TweenInfo.new(25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local goal = { PlaybackSpeed = 0.03 }
		local tween = TweenService:Create(Music, tweenInfo, goal)
		tween:Play()
		UIHelperFunctions.AdjustBlackScreen(1, 1)
	end,

	ThiefSuccess = function(instruction, _, _)
		if instruction == 1 then
			RunCutsceneAction(function()
				UIHelperFunctions.AdjustBlackScreen(1, 1)
				task.wait(1)
				Speak("Thief", "Hello sir, I have this 100 inch OLED TV to pawn off, how much")
				Speak(
					"Driver",
					"Is it new? whats MSRP for this thing? do I need to get my 100 inch tv guy to take a look at this?"
				)
				Speak(
					"Thief",
					"No need, i'm here to make a quick sale for quick cash. It's new and MSRP is twenty thousand robux, I reckon 10 kay is reasonable?"
				)
				Speak(
					"Driver",
					"Firstly, I see cola stains on the TV. Secondly, I see wood chips stuck in there. 5000 robux at best."
				)
				Speak("Thief", "These can easily be cleaned off sir, 8000 robux is my lowest offer")
				Speak(
					"Driver",
					"I just noticed it's the lad brand, thats going to be hard to sell, I can do 2500 robux at best, you won't get any better elsewhere."
				)
				Speak(
					"Thief",
					"What do you mean? lads over rebels man... Fine.. 5000 robux. You're going to get so much profit, leave some for me please man"
				)
				Speak(
					"Driver",
					"Looks like it only has one channel, and it's the display case only one. 500 robux and i'll keep this quiet."
				)
				Speak("Thief", "Stop lying, it has many channels, let me prove it.")
				SoundModule.PlaySound("Electrocution").Ended:Wait()
				local vid = workspace
					:WaitForChild("ThiefSuccessShop")
					:WaitForChild("RealTV")
					:WaitForChild("SurfaceGui")
					:WaitForChild("Video")
				vid.Video = "rbxassetid://5608411652"
				task.wait(1)
				Speak("Driver", "50 robux")
				Speak("Thief", "100")
				Speak("Driver", "30")
				Speak("Thief", "50")
				Speak("Driver", "50")
				Speak("Thief", "5")
				Speak("Driver", "Ok we agree, 5 robux it is!")
				SoundModule.PlaySound("Censor").Ended:Wait()
			end)
		elseif instruction == 2 then
			UIHelperFunctions.AdjustBlackScreen(7, 0)
		end
	end,
}

CutsceneClientHandler.CutsceneFinishedHandler = {
	PsychoMantisFailLie = function()
		CameraShake(999, 0.1, 0.5)
		SoundModule.PlaySound("Jumpscare")
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
		Music.SoundId = "rbxassetid://1846970342"
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
	CupcakeLoverBossDefeated = function()
		Music.SoundId = "rbxassetid://6362185620"
		Music.Volume = 0.1
	end,
	CupcakeLoverBossFailed = function()
		Music.SoundId = "rbxassetid://1841476350"
		Music.Volume = 0.1
	end,
	MoneyBaitCaught = function()
		Music.SoundId = "rbxassetid://1841797920"
		Music.Volume = 0.3
	end,

	MoneyBaitEscaped = function()
		Music.SoundId = "rbxassetid://128736659673417"
		Music.Volume = 0.1
	end,

	ThiefFailed = function()
		Music.SoundId = "rbxassetid://138685528021514"
		Music.Volume = 1
		Music.PlaybackSpeed = 0.01
	end,

	ThiefSuccess = function()
		Music.SoundId = "rbxassetid://106495808773197"
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
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	-- disable custom GUI
	for _, gui in ipairs(PlayerGui:GetChildren()) do
		if gui:IsA("ScreenGui") and gui.Name ~= "BlackScreen" then
			gui.Enabled = false
		end
	end
	GeneralRemotes.EnableRoadEvents:FireServer(false)
	UserInputService.MouseIconEnabled = false
	GeneralRemotes.EnableAllNPCPrompts:FireServer(false)

	-- Reset state
	bin = true
	SoundModule.StopAllSounds()
	SoundService:SetListener(Enum.ListenerType.Camera)
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
