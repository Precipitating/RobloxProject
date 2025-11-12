local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local GeneralRemotes = ReplicatedStorage.Remotes
local player = Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local PlayerGui = player:WaitForChild("PlayerGui")
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")
local SoundModule = require(script.Parent:WaitForChild("SoundModule"))
local MovementHandler = require(script.Parent:WaitForChild("MovementHandler"))
local UIHelperFunctions = require(script.Parent:WaitForChild("UIHelperFunctions"))
local CutsceneModule = require(script.Parent:WaitForChild("CutsceneScripts"):WaitForChild("CutsceneClientHandler"))
local InitializeGUIModule = require(script.Parent.InitializeGUI.InitializeGUIModule)
local ShopBasketModule = require(ReplicatedStorage.NPCs.Cashier.ShopBasketModule)
local TextToSpeech = require(ReplicatedStorage.TextToSpeech)
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
local Camera = require(script.Parent.Camera)
local SetMonitorPicture = require(StarterPlayer.StarterPlayerScripts.Client.NPCs.PsychoMantis.SetMonitorPicture)
local SimulateTVCapture = require(StarterPlayer.StarterPlayerScripts.Client.Rooms.Home.SimulateTVCapture)
local CameraFollowConnection = nil
local ClientHelperFunctions = require(script.Parent.ClientHelperFunctions)
local GreenCircle = require(script.Parent.GreenCircle)
local WeatherVisualizer = require(script.Parent.Weather.WeatherVisualizer)

-- CupcakeLover
local R2DPlayerHealth = nil

-- PsychoMantis
local onFocusLostRemoteConnection
local textBoxFocusLostConnection
local textBox
local isCleaningUp = false
local currentWord

-- TVHome
local SleepMeterGUI = nil
local CurrentSleepVal = nil

-- Cutscene
local CutsceneRan = false

local ClientRemotes = {}

function ClientRemotes.GeneralRemotes()
	-- handle general remotes
	GeneralRemotes.DisableControls.OnClientEvent:Connect(function(caller)
		print(`Client received disable controls from server: {caller}`)
		MovementHandler.DisableControls(caller)
	end)

	-- enable controls
	GeneralRemotes.EnableControls.OnClientEvent:Connect(function(caller)
		print(`Client received enable controls from server: {caller}`)
		MovementHandler.EnableControls(caller)
	end)

	-- play animation
	GeneralRemotes.PlayAnimation.OnClientEvent:Connect(function(animId)
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. animId
		local animTrack = Animator:LoadAnimation(anim)
		animTrack:Play()
		print("Animation playing...")
	end)

	-- FOV changer
	GeneralRemotes.ChangeFOV.OnClientEvent:Connect(function(val)
		local cam = workspace.CurrentCamera
		cam.FieldOfView = val
	end)

	-- player trip
	GeneralRemotes.Trip.OnClientEvent:Connect(function()
		print("Tripped!")
		local rootPart = Character.PrimaryPart
		Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
		rootPart.AssemblyLinearVelocity += rootPart.CFrame.LookVector * 50 + vector.create(0, 25, 0)
	end)

	-- blur player: duration, transparency target
	GeneralRemotes.Blur.OnClientEvent:Connect(function(time, blurTarget)
		UIHelperFunctions.AdjustBlur(time, blurTarget)
	end)

	-- fade to black: duration, transparency target
	GeneralRemotes.BlackFade.OnClientEvent:Connect(function(time, transparencyTarget)
		UIHelperFunctions.AdjustBlackScreen(time, transparencyTarget)
	end)

	-- change player shirt and clothes, removes T-Shirt
	GeneralRemotes.ChangeClothes.OnClientEvent:Connect(function(shirt, pants)
		local hasTShirt = Character:FindFirstChild("Shirt Graphic")

		if hasTShirt then
			hasTShirt:Remove()
		end

		if shirt then
			local hasShirt = Character:FindFirstChildOfClass("Shirt")
			if hasShirt then
				hasShirt.ShirtTemplate = shirt
			end
			local hasPants = Character:FindFirstChildOfClass("Pants")
			if hasPants then
				hasPants.PantsTemplate = pants
			end
		end
	end)

	-- play sound theme
	GeneralRemotes.PlayTheme.OnClientEvent:Connect(function(name)
		SoundModule.PlayTheme(name)
	end)

	-- play one shot sound
	GeneralRemotes.PlaySound.OnClientInvoke = function(name, parent, waitUntilDone)
		return SoundModule.PlaySound(name, parent, waitUntilDone)
	end

	-- stop all one shots & theme
	GeneralRemotes.StopAllMusic.OnClientInvoke = function()
		return SoundModule.StopAllSounds()
	end

	-- rejoin server
	GeneralRemotes.Rejoin.OnClientEvent:Connect(function(waitTime)
		task.wait(waitTime)
		TeleportService:Teleport(game.PlaceId, player)
	end)

	-- play text to speech: text and voice config
	GeneralRemotes.PlayTTS.OnClientInvoke = function(text, config)
		if config then
			TextToSpeech.UpdateVoiceConfig(config)
		end

		local success = TextToSpeech.Speak(text)

		if success then
			local handle = TextToSpeech.GetHandle()
			if handle then
				return handle.TimeLength
			end
		end
		return nil
	end

	-- change camera subject to a part position
	GeneralRemotes.ChangeCameraSubject.OnClientEvent:Connect(function(partPosition)
		ClientHelperFunctions.ChangeCameraSubject(partPosition)
	end)

	-- camera constant look at on target
	GeneralRemotes.CameraLookAt.OnClientEvent:Connect(function(target)
		local camera = workspace.CurrentCamera
		camera.CameraType = Enum.CameraType.Scriptable
		target = workspace:WaitForChild(target)

		local followPart
		if target:IsA("Model") then
			followPart = target.PrimaryPart or target:FindFirstChild("HumanoidRootPart")
		else
			followPart = target
		end

		CameraFollowConnection = RunService.RenderStepped:Connect(function()
			if followPart then
				camera.CFrame = CFrame.lookAt(camera.CFrame.Position, followPart.Position)
			end
		end)
	end)

	-- disconnect CameraLookAt function
	GeneralRemotes.CameraLookAtDisconnect.OnClientEvent:Connect(function()
		if CameraFollowConnection then
			CameraFollowConnection:Disconnect()
		end
	end)

	-- invert player controls
	GeneralRemotes.InvertControls.OnClientEvent:Connect(function(invert)
		local playerScripts = player:WaitForChild("PlayerScripts")
		local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
		local movementController = playerModule:GetControls()
		if invert then
			movementController.moveFunction = function(player_, direction, relative)
				player.Move(player_, -direction, relative)
			end
		else
			movementController.moveFunction = player.Move
		end
	end)

	-- play cutscene
	-- > disable core GUI
	-- > disable all custom GUIS
	-- > disable road events
	-- > disable NPCS proximity prompts
	-- > disable mouse icon
	GeneralRemotes.PlayCutscene.OnClientEvent:Connect(function(name)
		if CutsceneRan then
			return
		end
		if WeatherVisualizer.GetWeather() == "Rain" then
			RunService:UnbindFromRenderStep("rain")
		end
		CutsceneModule.Play(name)
		CutsceneRan = true
	end)
end

function ClientRemotes.PsychoMantisRemotes()
	-- cleanup TypingCompetition function
	local function CleanupGame()
		if isCleaningUp then
			return
		end
		isCleaningUp = true

		if onFocusLostRemoteConnection then
			onFocusLostRemoteConnection:Disconnect()
			onFocusLostRemoteConnection = nil
		end
		if textBoxFocusLostConnection then
			textBoxFocusLostConnection:Disconnect()
			textBoxFocusLostConnection = nil
		end
		if textBox and textBox.Parent then
			textBox:ReleaseFocus()
		end
		textBox = nil

		print("Client disconnected competition events!")
	end

	GeneralRemotes.PsychoMantis.PsychoMantisEventCleanup.OnClientEvent:Connect(CleanupGame)

	-- handle textbox results and focus on TypeCompetition
	onFocusLostRemoteConnection = GeneralRemotes.PsychoMantis.OnFocusLostConnect.OnClientEvent:Connect(
		function(startWord)
			textBox = workspace
				:WaitForChild("ExamRoom")
				:WaitForChild("PlayerLaptop")
				:WaitForChild("Screen")
				:WaitForChild("SurfaceGui")
				:WaitForChild("TextBox")

			if not textBox:IsA("TextBox") then
				warn("Invalid TextBox received in OnFocusLostConnect")
				return
			end

			currentWord = startWord
			textBox:CaptureFocus()

			-- make sure we never connect twice
			if textBoxFocusLostConnection then
				textBoxFocusLostConnection:Disconnect()
			end

			textBoxFocusLostConnection = textBox.FocusLost:Connect(function()
				if isCleaningUp then
					return
				end -- if ending, don't refocus
				local result = textBox.Text:gsub("%s+", "")

				textBox:CaptureFocus() -- keep focus until end

				if result == currentWord then
					local newResult = GeneralRemotes.PsychoMantis.GetNextWord:InvokeServer()
					currentWord = newResult
					SoundModule.PlaySound("Correct")
				else
					if result ~= "" then
						SoundModule.PlaySound("Wrong")
					end
				end
			end)
		end
	)

	CollectionService:GetInstanceAddedSignal("PsychoMantisLaptopDecal"):Connect(function(decal)
		print("Psychomantis monitor decal tag detected!")
		SetMonitorPicture.Set(decal)
	end)
end

function ClientRemotes.GUIRemotes()
	-- GUI
	-- Get GUI references when added
	PlayerGui.ChildAdded:Connect(function(child)
		if child.Name == "R2DHealthGUI" then
			R2DPlayerHealth = child:WaitForChild("Health")
		elseif child.Name == "SleepMeter" then
			SleepMeterGUI = child
			CurrentSleepVal = SleepMeterGUI:WaitForChild("BG"):WaitForChild("Meter"):WaitForChild("CurrentSleepVal")
		end
	end)

	-- initialize GUI on client via dictionary name (InitializeGUIModule)
	GeneralRemotes.InitializeGUI.OnClientEvent:Connect(function(name)
		if InitializeGUIModule[name] then
			InitializeGUIModule[name]()
		end
	end)

	-- disconnect all connections on a specific GUI (InitializeGUIModule)
	GeneralRemotes.DisconnectGUI.OnClientEvent:Connect(function(name)
		InitializeGUIModule.DisconnectAll(name)
	end)
end

function ClientRemotes.CashierRemotes()
	-- Cashier
	-- handle the next items display on screen and whether it's a skimmer option
	GeneralRemotes.Cashier.UpdateScreen.OnClientEvent:Connect(function(itemList, priceList)
		local submitButton = CollectionService:GetTagged("CashierSubmitButton")[1]
		local cardSkimmerLabel = CollectionService:GetTagged("CashierCardSkimmer")[1]
		local itemListLabel = CollectionService:GetTagged("CashierItemsLabel")[1]
		local itemListPriceLabel = CollectionService:GetTagged("CashierItemsPriceLabel")[1]
		if not itemListLabel or not itemListPriceLabel then
			error("Cashier item/price label ref not found!")
		end

		itemListLabel.Text = itemList
		itemListPriceLabel.Text = priceList

		cardSkimmerLabel.Visible = math.random() < 0.5
		submitButton.Active = true
		submitButton.Interactable = true
	end)

	GeneralRemotes.Cashier.ClearBasket.OnClientEvent:Connect(function()
		ShopBasketModule.ClearBasket()
	end)

	GeneralRemotes.Cashier.GetClientBasketItems.OnClientInvoke = function()
		return ShopBasketModule.GetItemsInBasket()
	end
end

function ClientRemotes.CupcakeLoverRemotes()
	-- Pumpkin Boss
	-- custom health GUI damage
	GeneralRemotes.CupcakeLover.DamagePlayer.OnClientEvent:Connect(function(dmg)
		if R2DPlayerHealth then
			R2DPlayerHealth.Value = math.max(0, R2DPlayerHealth.Value - dmg)
		end
	end)
end

function ClientRemotes.CurrencyRemotes()
	ReplicatedStorage.Remotes.UpdateMoneyGUI.OnClientEvent:Connect(function(currentCash)
		local cashGUI = PlayerGui:WaitForChild("MoneyScreen")
		if not cashGUI then
			warn("CashGui not found!")
			return
		end
		local cashLabel = cashGUI:WaitForChild("MoneyLabel")
		cashLabel.Text = `£{tostring(currentCash)}`
	end)
end

function ClientRemotes.MoneyBaitRemotes()
	-- infirmary rope walking minigame delete
	GeneralRemotes.MoneyBait.DeleteQuickTimeGUI.OnClientEvent:Connect(function()
		local exists = PlayerGui:FindFirstChild("QuickTimeGUI")

		if exists then
			exists:Destroy()
		end
	end)
end

function ClientRemotes.WeatherRemotes()
	-- called via server every random x seconds to change weather locally
	GeneralRemotes.UpdateWeather.OnClientEvent:Connect(function(nextWeather)
		WeatherVisualizer.Process(nextWeather)
	end)
end

function ClientRemotes.TVHomeRemotes()
	GeneralRemotes.TVHome.HitCan.OnClientEvent:Connect(function(decreaseVal)
		if not SleepMeterGUI then
			error("Missing Sleep Meter GUI")
		end
		if not CurrentSleepVal then
			error("CurrentSleepVal missing ref on client")
		end
		CurrentSleepVal.Value = math.max(0, CurrentSleepVal.Value - decreaseVal)
	end)
end

function ClientRemotes.FrankensteinRemotes()
	GeneralRemotes.Frankenstein.FrankensteinPuzzle.OnClientEvent:Connect(function()
		InitializeGUIModule["FrankensteinPuzzle"]()
	end)
end

function ClientRemotes.WhodunnitRemotes()
	GeneralRemotes.Whodunnit.Speak3D.OnClientInvoke = function(ttsHandle, text)
		return TextToSpeech.Speak3D(ttsHandle, text, 0)
	end
end

function ClientRemotes.HatDroppingKey()
	UserInputService.InputBegan:Connect(function(inputObject, gameProcessedEvent)
		if not gameProcessedEvent then
			if inputObject.KeyCode == Enum.KeyCode.Equals then
				GeneralRemotes.DropHats:FireServer()
			end
		end
	end)
end

function ClientRemotes.HomeRemotes()
	SimulateTVCapture.Initialize()
end

function ClientRemotes.CameraRemotes()
	GeneralRemotes.EnableCameraLookDetection.OnClientEvent:Connect(function(enabled, partToFind)
		if enabled then
			Camera.StartLooking(partToFind)
			print("Camera look enabled!")
		else
			Camera.DisconnectRenderStepConn()
		end
	end)
end

function ClientRemotes.GreenCircleRemotes()
	GeneralRemotes.EnableClickToMove.OnClientEvent:Connect(function(val)
		GreenCircle.SetEnabled(val)

		if GreenCircle.IsEnabled() then
			GreenCircle.StartClickToMove()
		else
			GreenCircle.DisconnectAll()
		end
	end)
end

function ClientRemotes.Initialize()
	ClientRemotes.HatDroppingKey()
	ClientRemotes.GeneralRemotes()
	ClientRemotes.HomeRemotes()
	ClientRemotes.PsychoMantisRemotes()
	ClientRemotes.GUIRemotes()
	ClientRemotes.CameraRemotes()
	ClientRemotes.GreenCircleRemotes()
	ClientRemotes.CashierRemotes()
	ClientRemotes.CupcakeLoverRemotes()
	ClientRemotes.CurrencyRemotes()
	ClientRemotes.MoneyBaitRemotes()
	ClientRemotes.WeatherRemotes()
	ClientRemotes.TVHomeRemotes()
	ClientRemotes.FrankensteinRemotes()
	ClientRemotes.WhodunnitRemotes()
end

return ClientRemotes
