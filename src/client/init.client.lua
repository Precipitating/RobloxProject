local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local GeneralRemotes = ReplicatedStorage.Remotes
local player = game.Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local PlayerGui = player:WaitForChild("PlayerGui")
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")
local MovementHandler = require(script:WaitForChild("MovementHandler"))
local SoundModule = require(script:WaitForChild("SoundModule"))
local UIHelperFunctions = require(script:WaitForChild("UIHelperFunctions"))
local CutsceneModule = require(script:WaitForChild("CutsceneScripts"):WaitForChild("CutsceneClientHandler"))
local InitializeGUIModule = require(script.InitializeGUI.InitializeGUIModule)
local ShopBasketModule = require(ReplicatedStorage.NPCs.Cashier.ShopBasketModule)
local TextToSpeech = require(ReplicatedStorage.TextToSpeech)
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local SetMonitorPicture = require(script.NPCs.PsychoMantis.SetMonitorPicture)
local CameraFollowConnection = nil
local R2DPlayerHealth = nil
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ClientHelperFunctions = require(script.ClientHelperFunctions)
local WeatherVisualizer = require(script.Weather.WeatherVisualizer)
-- disable respawn button
local coreCall
do
	local MAX_RETRIES = 8
	function coreCall(method, ...)
		local result = {}
		for _ = 1, MAX_RETRIES do
			result = { pcall(StarterGui[method], StarterGui, ...) }
			if result[1] then
				break
			end
			RunService.Stepped:Wait()
		end
		return unpack(result)
	end
end
coreCall("SetCore", "ResetButtonCallback", false)

-- handle general remotes
GeneralRemotes.DisableControls.OnClientEvent:Connect(function(caller)
	print(`Client received disable controls from server: {caller}`)
	MovementHandler.DisableControls(caller)
end)

GeneralRemotes.EnableControls.OnClientEvent:Connect(function(caller)
	print(`Client received enable controls from server: {caller}`)
	MovementHandler.EnableControls(caller)
end)

GeneralRemotes.PlayAnimation.OnClientEvent:Connect(function(animId)
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. animId
	local animTrack = Animator:LoadAnimation(anim)
	animTrack:Play()
	print("Animation playing...")
end)

GeneralRemotes.ChangeFOV.OnClientEvent:Connect(function(val)
	local cam = workspace.CurrentCamera
	cam.FieldOfView = val
end)

GeneralRemotes.Trip.OnClientEvent:Connect(function()
	print("Tripped!")
	local rootPart = Character.PrimaryPart
	Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
	rootPart.AssemblyLinearVelocity += rootPart.CFrame.LookVector * 50 + vector.create(0, 25, 0)
end)

GeneralRemotes.Blur.OnClientEvent:Connect(function(time, blurTarget)
	UIHelperFunctions.AdjustBlur(time, blurTarget)
end)

GeneralRemotes.BlackFade.OnClientEvent:Connect(function(time, transparencyTarget)
	UIHelperFunctions.AdjustBlackScreen(time, transparencyTarget)
end)

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

GeneralRemotes.PlayTheme.OnClientEvent:Connect(function(name)
	SoundModule.PlayTheme(name)
end)
GeneralRemotes.PlaySound.OnClientInvoke = function(name, parent)
	return SoundModule.PlaySound(name, parent)
end
GeneralRemotes.StopAllMusic.OnClientInvoke = function()
	SoundModule.StopAllSounds()
	return true
end

GeneralRemotes.Rejoin.OnClientEvent:Connect(function(waitTime)
	task.wait(waitTime)
	TeleportService:Teleport(game.PlaceId, player)
end)
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

GeneralRemotes.ChangeCameraSubject.OnClientEvent:Connect(function(partPosition)
	ClientHelperFunctions.ChangeCameraSubject(partPosition)
end)

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

GeneralRemotes.CameraLookAtDisconnect.OnClientEvent:Connect(function()
	if CameraFollowConnection then
		CameraFollowConnection:Disconnect()
	end
end)
GeneralRemotes.InvertControls.OnClientEvent:Connect(function(invert)
	local thisPlayer = Players.LocalPlayer
	local playerScripts = thisPlayer:WaitForChild("PlayerScripts")
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	local movementController = playerModule:GetControls()
	if invert then
		movementController.moveFunction = function(player_, direction, relative)
			thisPlayer.Move(player_, -direction, relative)
		end
	else
		movementController.moveFunction = thisPlayer.Move
	end
end)

-- PsychoMantis
local onFocusLostRemoteConnection
local textBoxFocusLostConnection
local textBox
local isCleaningUp = false
local currentWord

-- Cleanup TypingCompetition function
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

onFocusLostRemoteConnection = GeneralRemotes.PsychoMantis.OnFocusLostConnect.OnClientEvent:Connect(function(startWord)
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

	-- Make sure we never connect twice
	if textBoxFocusLostConnection then
		textBoxFocusLostConnection:Disconnect()
	end

	textBoxFocusLostConnection = textBox.FocusLost:Connect(function()
		if isCleaningUp then
			return
		end -- If ending, don't refocus
		local result = textBox.Text:gsub("%s+", "")

		textBox:CaptureFocus() -- Keep focus until end

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
end)

GeneralRemotes.PlayCutscene.OnClientEvent:Connect(function(name)
	-- disable bp
	local StarterGui = game:GetService("StarterGui")

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

	CutsceneModule.Play(name)
end)

-- GUI

PlayerGui.ChildAdded:Connect(function(child)
	if child.Name == "R2DHealthGUI" then
		R2DPlayerHealth = child:WaitForChild("Health")
	end
end)
GeneralRemotes.InitializeGUI.OnClientEvent:Connect(function(name)
	if InitializeGUIModule[name] then
		InitializeGUIModule[name]()
	end
end)

GeneralRemotes.DisconnectGUI.OnClientEvent:Connect(function(name)
	InitializeGUIModule.DisconnectAll(name)
end)

-- Cashier
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

-- Pumpkin Boss
GeneralRemotes.CupcakeLover.DamagePlayer.OnClientEvent:Connect(function(dmg)
	if R2DPlayerHealth then
		R2DPlayerHealth.Value = math.max(0, R2DPlayerHealth.Value - dmg)
	end
end)

-- Currency
ReplicatedStorage.Remotes.UpdateMoneyGUI.OnClientEvent:Connect(function(currentCash)
	local cashGUI = PlayerGui:WaitForChild("MoneyScreen")
	if not cashGUI then
		warn("CashGui not found!")
		return
	end
	local cashLabel = cashGUI:WaitForChild("MoneyLabel")
	cashLabel.Text = `£{tostring(currentCash)}`
end)

-- MoneyBait
GeneralRemotes.MoneyBait.DeleteQuickTimeGUI.OnClientEvent:Connect(function()
	local exists = PlayerGui:FindFirstChild("QuickTimeGUI")

	if exists then
		exists:Destroy()
	end
end)

-- Weather
GeneralRemotes.UpdateWeather.OnClientEvent:Connect(function(nextWeather)
	WeatherVisualizer.Process(nextWeather)
end)

-- play main theme
SoundModule.PlayTheme("Main")
SetMonitorPicture.Set()

--GeneralRemotes.AddMoney:FireServer(10000)
