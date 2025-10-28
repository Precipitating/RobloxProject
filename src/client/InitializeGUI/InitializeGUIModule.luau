local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local StarterPlayer = game:GetService("StarterPlayer")
local MovementHandler = require(StarterPlayer.StarterPlayerScripts.Client.MovementHandler)
local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)
local UIHelperFunctions = require(StarterPlayer.StarterPlayerScripts.Client.UIHelperFunctions)
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:FindFirstChildOfClass("Animator")
local Mouse = Player:GetMouse()
local GeneralRemotes = ReplicatedStorage.Remotes
local MissionRemotes = ReplicatedStorage.Missions.Events
local GUILocation = ReplicatedStorage.GUI
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Events = ReplicatedStorage.Missions.Events
local CutsceneClientHandler = require(StarterPlayer.StarterPlayerScripts.Client.CutsceneScripts.CutsceneClientHandler)
local InitializeGUIModule = {}
local Connections = {}

function InitializeGUIModule.DisconnectAll(name)
	if not Connections[name] then
		warn("Disconnect failed, key doesn't exist")
		return
	end
	for _, conn in pairs(Connections[name]) do
		if typeof(conn) == "RBXScriptConnection" then
			conn:Disconnect()
		end
	end

	table.clear(Connections[name])

	print(`Disconnected {name}!`)
end

local function trackConnect(name, signal, callback)
	-- initialize table for this key
	if not Connections[name] then
		Connections[name] = {}
	end

	local conn = signal:Connect(callback)
	table.insert(Connections[name], conn)
	return conn
end

local function BounceOpenFrame(targetSize: UDim2, frameRef: Frame)
	frameRef.Visible = false
	frameRef.Size = UDim2.new(0, 0, 0, 0)
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local goal = { Size = targetSize }
	local tween = TweenService:Create(frameRef, tweenInfo, goal)
	frameRef.Visible = true
	tween:Play()
	tween.Completed:Wait()
end

local function BounceCloseFrame(frameRef: Frame)
	local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local goal = { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }
	local tween = TweenService:Create(frameRef, tweenInfo, goal)
	tween:Play()
	tween.Completed:Wait()
	frameRef.Visible = false
end

InitializeGUIModule["BosnianRoulette"] = function()
	local GUI = PlayerGui:WaitForChild("BosnianRouletteGUI")
	local decrementButton = GUI:WaitForChild("DecrementInput"):WaitForChild("TextButton")
	local negateFiveButton = GUI:WaitForChild("NegateFiveInput"):WaitForChild("TextButton")
	local input = GUI:WaitForChild("InputFrame"):WaitForChild("Number")
	local incrementButton = GUI:WaitForChild("IncrementInput"):WaitForChild("TextButton")
	local addFiveButton = GUI:WaitForChild("AddFiveInput"):WaitForChild("TextButton")

	local submitButton = GUI:WaitForChild("SubmitFrame"):WaitForChild("TextButton")

	-- handle adding/subtracting timer
	local function Process(val)
		local currentNum = tonumber(input.Text) or 0
		local newNum = currentNum + val

		if newNum < 1 then
			newNum = 1
		end

		input.Text = tostring(newNum)
	end

	trackConnect("BosnianRoulette", decrementButton.MouseButton1Click, function()
		Process(-1)
	end)

	trackConnect("BosnianRoulette", negateFiveButton.MouseButton1Click, function()
		Process(-5)
	end)

	trackConnect("BosnianRoulette", incrementButton.MouseButton1Click, function()
		Process(1)
	end)

	trackConnect("BosnianRoulette", addFiveButton.MouseButton1Click, function()
		Process(5)
	end)

	trackConnect("BosnianRoulette", submitButton.MouseButton1Click, function()
		GeneralRemotes.GlitcherMission.SubmitBombTimeReduction:FireServer(tonumber(input.Text))
		input.Text = "1"
	end)
end

InitializeGUIModule["Terminal"] = function()
	local GUI = GUILocation.Glitcher.TerminalGUI
	local tool = Player.Backpack:FindFirstChild("Terminal")
	local playerGUI = Player:WaitForChild("PlayerGui")
	local existingGUI = playerGUI:FindFirstChild("TerminalGUI")
	local password = "toxicsalt"
	local inputPassword = ""

	if GUI and tool then
		-- show GUI on equip
		trackConnect("Terminal", tool.Equipped, function()
			if not existingGUI then
				existingGUI = GUI:Clone()
				existingGUI.Parent = playerGUI

				trackConnect("Terminal", existingGUI.SubmitFrame.TextButton.MouseButton1Click, function()
					inputPassword = string.lower(existingGUI.MainFrame.PasswordInput.Text)

					if inputPassword == password then
						print("Correct!")
						SoundModule.PlaySound("Keypad")
						InitializeGUIModule.DisconnectAll("Terminal")
						existingGUI:Destroy()
						tool:Destroy()
						MissionRemotes.ExecuteScenarioEvent:FireServer("GlitcherTerminalUnlocked")
					else
						SoundModule.PlaySound("Error")
						print("Wrong password")
					end
				end)
			else
				existingGUI.Enabled = true
			end
		end)

		trackConnect("Terminal", tool.Unequipped, function()
			if existingGUI then
				existingGUI.Enabled = false
			end
		end)
	end
end

InitializeGUIModule["Cashier"] = function()
	local submitButton = CollectionService:GetTagged("CashierSubmitButton")[1]
	local priceInput = CollectionService:GetTagged("CashierEnterPrice")[1]
	local timeLeft = CollectionService:GetTagged("CashierTimeLeft")[1]
	local cardSkimmerText = CollectionService:GetTagged("CashierCardSkimmer")[1]
	local canClick = true

	local function fail()
		SoundModule.PlaySound("Error")
		local textToNum = tonumber(timeLeft.Text)
		local increased = math.max(0, textToNum + 10)
		timeLeft.Text = tostring(increased)

		-- failed
		print(increased)
		if increased >= 100 then
			GeneralRemotes.Cashier.NextCustomer:FireServer(increased, true)
		else
			GeneralRemotes.Cashier.NextCustomer:FireServer(increased, false)
		end
	end

	local function correct()
		local textToNum = tonumber(timeLeft.Text) or 0
		local decreaseAmount = cardSkimmerText.Visible and math.max(5, math.floor(textToNum / 2)) or 5

		SoundModule.PlaySound("Correct")

		local decreased = math.max(0, textToNum - decreaseAmount)

		timeLeft.Text = tostring(decreased)
		GeneralRemotes.Cashier.NextCustomer:FireServer(decreased, false)
	end

	trackConnect("Cashier", submitButton.MouseButton1Click, function()
		if not canClick then
			return
		end

		submitButton.Active = false
		submitButton.Interactable = false
		canClick = false

		local correctPrice = GeneralRemotes.Cashier.CheckPrice:InvokeServer()
		if not correctPrice then
			warn("Shopping list empty!")
			fail()
			task.wait(3)
			canClick = true
			return
		end

		local userInputToNum = tonumber(priceInput.Text)
		print(`Actual price: {correctPrice}`)

		if not userInputToNum then
			warn("Invalid price input: Ensure its the correct format")
			fail()
		else
			if cardSkimmerText.Visible then
				if userInputToNum == (correctPrice * 2) then
					correct()
				else
					fail()
				end
			elseif userInputToNum == correctPrice then
				correct()
			else
				fail()
			end
		end

		task.wait(3)
		canClick = true
	end)
end

InitializeGUIModule["BulletGuesser"] = function()
	print("Client initialize BulletGuesser GUI")
	local GUI = GUILocation.BulletGuesser.RevolverScreen
	local exists = PlayerGui:FindFirstChild("RevolverScreen")
	if exists then
		exists:Destroy()
	end
	if GUI then
		local clonedGUI = GUI:Clone()
		clonedGUI.Parent = PlayerGui
		BounceOpenFrame(GUI.RevolverImage.Size, clonedGUI.RevolverImage)
		local buttons = clonedGUI:WaitForChild("Buttons"):GetChildren()
		if #buttons > 0 then
			for i, button in ipairs(buttons) do
				trackConnect("BulletGuesser", button.Activated, function()
					print("Clicked button" .. i)
					BounceCloseFrame(clonedGUI.RevolverImage)
					clonedGUI:Destroy()
					UIHelperFunctions.AdjustBlackScreen(1, 0)
					SoundModule.StopAllSounds()
					task.wait(1)
					local function GoodChoice()
						SoundModule.PlaySound("RevolverShot")
						task.wait(1)
						SoundModule.PlaySound("Correct2")
						GeneralRemotes.AddMoney:FireServer(1337)
						UIHelperFunctions.AdjustBlackScreen(1, 1)
						MovementHandler.EnableControls(nil)
					end

					local BadChoice = function()
						local currMoney = GeneralRemotes.GetCurrentMoney:InvokeServer()
						SoundModule.PlaySound("RevolverEmpty")
						task.wait(1)
						SoundModule.PlaySound("FailTrombone")
						GeneralRemotes.ReduceMoney:FireServer(currMoney)
						UIHelperFunctions.AdjustBlackScreen(1, 1)
						MovementHandler.EnableControls(nil)
					end
					local bulletHoleIndex = GeneralRemotes.Gamba.BulletGuesser.GetBulletIndex:InvokeServer()
					-- picks hole with bullet
					if tonumber(button.Name) == bulletHoleIndex then
						GoodChoice()
					else
						warn(`Chosen {button.Name} when it should be {bulletHoleIndex}`)
						BadChoice()
					end
					InitializeGUIModule.DisconnectAll("BulletGuesser")
					GeneralRemotes.EnableAllNPCPrompts:FireServer(true)
					GeneralRemotes.Gamba.BulletGuesser.ResetBulletIndex:FireServer()
				end)
			end
		end
	end
end

InitializeGUIModule["BakeryCashier"] = function()
	if PlayerGui:FindFirstChild("BakeryShopGUI") then
		warn("Bakery shop GUI already open")
		return
	end
	print("Attempting to create new instance of bakery shop GUI")
	-- clone GUI to player's GUI
	local GUI = GUILocation:FindFirstChild("BakeryCashier"):FindFirstChild("BakeryShopGUI")
	if not GUI then
		error("Missing bakery shop GUI")
	end
	local GUIInstance = GUI:Clone()
	GUIInstance.Parent = PlayerGui
	local baseFrame = GUIInstance:FindFirstChild("Base")
	-- open shop greeting
	SoundModule.PlaySound("GirlGreeting")

	BounceOpenFrame(GUI.Base.Size, baseFrame)

	-- handle exit button
	local exitButton = baseFrame:FindFirstChild("Exit")
	if not exitButton then
		error("Missing exitButton reference from bakery shop GUI")
	end
	trackConnect("BakeryCashier", exitButton.MouseButton1Click, function()
		BounceCloseFrame(baseFrame)
		GUIInstance:Destroy()
		MovementHandler.EnableControls(nil)
		GeneralRemotes.EnableAllNPCPrompts:FireServer(true)
		InitializeGUIModule.DisconnectAll("BakeryCashier")
	end)

	-- handle buy item buttons
	local items = baseFrame:FindFirstChild("MenuBase"):FindFirstChild("Items")
	if items then
		items = items:GetChildren()
	else
		error("Can't get bakery items reference")
	end

	-- connect all item buy buttons
	for _, item in ipairs(items) do
		if not item:IsA("Frame") then
			continue
		end
		if not item:FindFirstChild("BuyButton") then
			error("Not every item in bakery item has a BuyButton")
		end
		local buyButton = item.BuyButton
		trackConnect("BakeryCashier", buyButton.MouseButton1Click, function()
			local price = buyButton:FindFirstChild("Price")
			if not price then
				error(`{item.Name} has no price value`)
			end
			local currentMoney = GeneralRemotes.GetCurrentMoney:InvokeServer()

			-- exit early if can't afford item
			if currentMoney < price.Value then
				warn(`Can't afford {item.Name}, which costs {price.Value}`)
				SoundModule.PlaySound("Error")
				return
			end

			-- can afford, give tool and reduce money
			GeneralRemotes.ReduceMoney:FireServer(price.Value)
			MissionRemotes.GiveToolEvent:InvokeServer({ item.Name, false })
		end)
	end
	print("success")
end

InitializeGUIModule["R2DPumpkinBoss"] = function()
	if PlayerGui:FindFirstChild("R2DBossHealthGUI") and PlayerGui:FindFirstChild("R2DHealthGUI") then
		warn("R2D Boss GUIs already open")
		return
	end

	local playerHPGUI = GUILocation:FindFirstChild("CupcakeLover"):FindFirstChild("R2DHealthGUI"):Clone()
	local playerHPBar = playerHPGUI:WaitForChild("HPBarBot"):WaitForChild("HPBarTop")
	local playerHPLabel = playerHPGUI:WaitForChild("HPBarBot"):WaitForChild("HealthValueLabel")
	local playerHPVal = playerHPGUI:WaitForChild("Health")

	local bossHPGUI = GUILocation:FindFirstChild("CupcakeLover"):FindFirstChild("R2DBossHealthGUI"):Clone()
	local bossModel = workspace:WaitForChild("PumpkinMap"):WaitForChild("PumpkinBoss")
	local bossHP = bossModel:WaitForChild("Health")
	local bossHPBar = bossHPGUI:WaitForChild("HPBarBot"):WaitForChild("HPBarTop")
	local bossHPVal = bossHPGUI:WaitForChild("HPBarBot"):WaitForChild("HealthValueLabel")
	local maxBossHP = bossHP.Value

	local minigunGUI = GUILocation:FindFirstChild("CupcakeLover"):FindFirstChild("R2DMinigunGUI"):Clone()
	local minigunAmmo = minigunGUI:WaitForChild("Base"):WaitForChild("Ammo")
	local minigunStacks = minigunGUI:WaitForChild("Base"):WaitForChild("Stacks")
	local minigunAmmoLabel = minigunGUI:WaitForChild("Base"):WaitForChild("AmmoLabel")
	local minigunStacksLabel = minigunGUI:WaitForChild("Base"):WaitForChild("StacksLabel")

	local minigunTool = Player.Backpack:WaitForChild("Minigun")
	local handle = minigunTool:WaitForChild("Handle")
	local shootPos = handle:WaitForChild("Main")
	local revSound = handle:WaitForChild("Rev")
	local shootSound = handle:WaitForChild("Shoot")
	local stopSound = handle:WaitForChild("Stop")
	local reloadSound = handle:WaitForChild("Reload")

	playerHPGUI.Parent = PlayerGui
	bossHPGUI.Parent = PlayerGui
	minigunGUI.Parent = PlayerGui

	local idleAnim = Instance.new("Animation")
	idleAnim.AnimationId = `rbxassetid://{93585226172859}`
	local idleTrack = nil
	local equipped = false
	local holding = false
	local spinningUp = false
	local spinCanceled = false
	local reloading = false
	local reloadThread -- reference to the current reload coroutine
	local startShootingThread
	local finished = false

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = { Character }
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true

	-- game finished, boss or player dead
	local function Finished(bossDead)
		if finished then
			return
		end
		finished = true
		UIHelperFunctions.AdjustBlackScreen(1, 0)
		InitializeGUIModule.DisconnectAll("R2DPumpkinBoss")
		SoundModule.UnlockTheme()
		SoundModule.StopTheme()
		playerHPGUI:Destroy()
		bossHPGUI:Destroy()

		-- disable minigun
		minigunGUI:Destroy()
		idleTrack:Stop()
		idleTrack:Destroy()
		idleTrack = nil
		Player:GetMouse().Icon = ""
		MissionRemotes.RemoveToolsEvent:InvokeServer({ "Minigun" })

		task.wait(1)

		GeneralRemotes.CupcakeLover.Finished:FireServer(bossDead)

		if bossDead then
			print("boss ded")
			SoundModule.PlayTheme("Main")
		else
			MovementHandler.DisableControls()
			print("you ded")
		end
	end

	local function StopAllMinigunSounds()
		stopSound:Stop()
		revSound:Stop()
		shootSound:Stop()
	end

	local function createBulletTrace(startPos, endPos)
		local randomOffset = vector.create(math.random(-1, 1), math.random(-1, 1), 0)
		endPos = endPos + randomOffset
		local distance = 700
		local direction = vector.normalize(endPos - startPos)

		-- shoot collision
		local result = workspace:Raycast(startPos, direction * distance, rayParams)
		if result and CollectionService:HasTag(result.Instance, "PumpkinBoss") then
			print("hit boss")
			GeneralRemotes.CupcakeLover.EnemyHit:FireServer("Boss")
		elseif result and CollectionService:HasTag(result.Instance, "SoulFetcher") then
			print("hit soul")
			GeneralRemotes.CupcakeLover.EnemyHit:FireServer("SoulFetcher", result.Instance:GetAttribute("Id"))
		end

		local beam = Instance.new("Part")
		beam.Size = vector.create(0.2, 0.2, distance)
		beam.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
		beam.Anchored = true
		beam.CanCollide = false
		beam.Material = Enum.Material.SmoothPlastic
		beam.Color = Color3.fromRGB(255, 200, 50)
		beam.Parent = workspace

		Debris:AddItem(beam, 0.1)
	end

	-- boss hp events handler
	trackConnect("R2DPumpkinBoss", bossHP:GetPropertyChangedSignal("Value"), function()
		bossHPVal.Text = `{tostring(bossHP.Value)} HP`
		local ratio = math.clamp(bossHP.Value / maxBossHP, 0, 1)
		bossHPBar.Size = UDim2.fromScale(ratio, 1)

		if bossHP.Value <= 0 then
			Finished(true)
		end
	end)

	-- player hp events handler
	trackConnect("R2DPumpkinBoss", playerHPVal:GetPropertyChangedSignal("Value"), function()
		playerHPLabel.Text = `{tostring(playerHPVal.Value)} hp`
		local ratio = math.clamp(playerHPVal.Value / 100, 0, 1)
		playerHPBar.Size = UDim2.fromScale(ratio, 1)

		if playerHPVal.Value <= 0 then
			Finished(false)
		end
	end)

	-- minigun ammo handler
	trackConnect("R2DPumpkinBoss", minigunAmmo:GetPropertyChangedSignal("Value"), function()
		if minigunAmmo.Value >= 0 then
			minigunAmmoLabel.Text = tostring(minigunAmmo.Value)
		end
	end)

	-- ammo stacks
	trackConnect("R2DPumpkinBoss", minigunStacks:GetPropertyChangedSignal("Value"), function()
		minigunAmmo.Value = 120
		minigunStacksLabel.Text = tostring(minigunStacks.Value)
	end)

	-- minigun equip
	trackConnect("R2DPumpkinBoss", minigunTool.Equipped, function()
		equipped = true
		idleTrack = Animator:LoadAnimation(idleAnim)
		idleTrack:Play()
		minigunGUI.Enabled = true
		Mouse.Icon = "rbxasset://textures/GunCursor.png"
		Humanoid.WalkSpeed = 17
	end)

	-- minigun unequipped
	trackConnect("R2DPumpkinBoss", minigunTool.Unequipped, function()
		equipped = false
		if idleTrack then
			idleTrack:Stop()

			minigunGUI.Enabled = false
			Player:GetMouse().Icon = ""
			Humanoid.WalkSpeed = 25

			stopSound:Stop()
			revSound:Stop()
			shootSound:Stop()
			reloadSound:Stop()
			if reloadThread and coroutine.status(reloadThread) ~= "dead" then
				coroutine.close(reloadThread)
			end
			reloading = false
			spinCanceled = true
		end
	end)

	-- reload minigun
	local function startReload()
		if reloading or not equipped then
			return
		end
		if minigunAmmo.Value > 0 or minigunStacks.Value <= 0 then
			return
		end

		reloading = true
		reloadSound:Play()

		-- cancel any previous reload coroutine if it’s still running
		if reloadThread and coroutine.status(reloadThread) ~= "dead" then
			coroutine.close(reloadThread)
		end

		reloadThread = coroutine.create(function()
			task.wait(4)
			if not reloading or not equipped then
				return
			end

			if minigunStacks.Value > 0 then
				minigunStacks.Value = math.max(0, minigunStacks.Value - 1)
			end

			reloading = false
		end)

		coroutine.resume(reloadThread)
	end

	trackConnect("R2DPumpkinBoss", Mouse.Button1Down, function()
		if not equipped or holding or spinningUp then
			return
		end

		if minigunAmmo.Value <= 0 then
			startReload()
			return
		end

		holding, spinningUp, spinCanceled = true, true, false
		StopAllMinigunSounds()
		revSound:Play()

		-- cancel previous firing thread if still active
		if startShootingThread and coroutine.status(startShootingThread) ~= "dead" then
			coroutine.close(startShootingThread)
		end

		-- Spin-up + firing logic
		startShootingThread = coroutine.create(function()
			task.wait(1.5) -- spin-up delay
			if spinCanceled then
				return
			end
			spinningUp = false

			if not holding then
				revSound:Stop()
				stopSound:Play()
				return
			end

			-- Firing loop
			while equipped and holding and minigunAmmo.Value > 0 and not spinCanceled do
				if not shootSound.IsPlaying then
					shootSound:Play()
				end

				minigunAmmo.Value -= 1
				createBulletTrace(shootPos.Position, Mouse.Hit.Position)
				task.wait(0.04)
			end

			stopSound:Play()
			shootSound:Stop()
		end)
		coroutine.resume(startShootingThread)
	end)

	trackConnect("R2DPumpkinBoss", Mouse.Button1Up, function()
		holding = false

		if spinningUp then
			spinningUp = false
			spinCanceled = true
		end

		if revSound.IsPlaying then
			revSound:Stop()
		end
		if shootSound.IsPlaying then
			shootSound:Stop()
		end
	end)

	print("success")
end

InitializeGUIModule["ClimbRopeQuickTime"] = function()
	if PlayerGui:FindFirstChild("QuickTimeGUI") then
		warn("QuickTime GUI already open")
		return
	end

	local guiLoc = GUILocation:WaitForChild("MoneyBait")
	if not guiLoc then
		error("Missing MoneyBait GUI Folder ref")
	end
	local gui = guiLoc:WaitForChild("QuickTimeGUI")

	local guiButton = guiLoc:WaitForChild("ClickOrFallButton")

	-- setup initial GUI
	local guiClone = gui:Clone()
	guiClone.Parent = PlayerGui
	local frame = guiClone:WaitForChild("Frame")

	-- spawn buttons randomly
	local running = true

	guiClone.AncestryChanged:Once(function()
		running = false
		guiClone:Destroy()
		print("Client detected QuickTimeGUI destroyed!")
		SoundModule.StopTheme()
	end)

	task.spawn(function()
		while running do
			-- decimal between 1 to 3.0
			task.wait((math.random() * 2.5) + 0.5)
			local cloneButton: TextButton = guiButton:Clone()
			-- setup random colours & scale
			cloneButton.BackgroundColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
			local uiScale = cloneButton:WaitForChild("UIScale")
			if uiScale then
				uiScale.Scale = (math.random() * 2.5) + 0.5
			end
			cloneButton.Position = UDim2.fromScale((math.random()), math.random())
			cloneButton.Parent = frame

			cloneButton.Activated:Once(function()
				cloneButton:Destroy()
				SoundModule.PlaySound("OldSplat")
			end)

			-- tween to 0 scale
			local tweenInfo = TweenInfo.new(math.random(3, 6), Enum.EasingStyle.Linear)

			local goal = { Scale = 0 }
			local tween = TweenService:Create(uiScale, tweenInfo, goal)
			tween:Play()

			tween.Completed:Once(function(state)
				if state == Enum.PlaybackState.Completed then
					running = false
					GeneralRemotes.MoneyBait.FailedRope:FireServer()
					guiClone:Destroy()
				end
			end)
		end
	end)
end

InitializeGUIModule["TVHomeGUI"] = function()
	if PlayerGui:FindFirstChild("SleepMeter") then
		warn("SleepMeter GUI already open")
		return
	end

	local guiLoc = GUILocation:WaitForChild("TVHome")
	if not guiLoc then
		error("Missing TVHome GUI Folder ref")
	end
	local gui = guiLoc:WaitForChild("SleepMeter")
	if not gui then
		error("Missing SleepMeter GUI")
	end

	local guiClone = gui:Clone()
	guiClone.Parent = PlayerGui
	local bg = guiClone:WaitForChild("BG")

	BounceOpenFrame(bg.Size, bg)

	local meter = bg:WaitForChild("Meter")
	local sleepVal = meter:WaitForChild("CurrentSleepVal")

	if not sleepVal or not meter then
		error("Missing TVHome sleepVal/meter references")
	end

	local currentTween = nil
	local failed = false

	trackConnect("TVHomeGUI", sleepVal:GetPropertyChangedSignal("Value"), function()
		if currentTween then
			currentTween:Cancel()
		end

		print(sleepVal.Value)
		local goal = { Size = UDim2.fromScale(math.clamp(sleepVal.Value, 0, 1), 1) }
		currentTween =
			TweenService:Create(meter, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)

		currentTween:Play()

		-- failed minigame
		-- 1e-6 due to floating precision errors occuring, so its close to 0 basically.
		if sleepVal.Value <= 1e-6 and not failed then
			failed = true
			SoundModule.PlaySound("Oi")
			UIHelperFunctions.AdjustBlackScreen(1, 0)
			InitializeGUIModule.DisconnectAll("TVHomeGUI")
			guiClone:Destroy()
			MovementHandler.DisableControls()
			Events.ExecuteScenarioEvent:FireServer("StealTVModeFailed")
			CutsceneClientHandler.Play("ThiefFailed")
		end
	end)
end

return InitializeGUIModule
