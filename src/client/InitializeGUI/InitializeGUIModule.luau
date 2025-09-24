local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local StarterPlayer = game:GetService("StarterPlayer")
local ClientHelperFunctions = require(StarterPlayer.StarterPlayerScripts.Client.ClientHelperFunctions)
local MovementHandler = require(StarterPlayer.StarterPlayerScripts.Client.MovementHandler)
local TextToSpeech = require(ReplicatedStorage.TextToSpeech)
local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)
local UIHelperFunctions = require(StarterPlayer.StarterPlayerScripts.Client.UIHelperFunctions)
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GeneralRemotes = ReplicatedStorage.Remotes
local MissionRemotes = ReplicatedStorage.Missions.Events
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
	local GUI = ReplicatedStorage.GUI.Glitcher.TerminalGUI
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
	local GUI = ReplicatedStorage.GUI.BulletGuesser.RevolverScreen
	local exists = PlayerGui:FindFirstChild("RevolverScreen")
	if exists then
		exists:Destroy()
	end
	if GUI then
		local clonedGUI = GUI:Clone()
		clonedGUI.Parent = PlayerGui
		local buttons = clonedGUI:WaitForChild("Buttons"):GetChildren()
		if #buttons > 0 then
			for i, button in ipairs(buttons) do
				trackConnect("BulletGuesser", button.Activated, function()
					print("Clicked button" .. i)
					clonedGUI:Destroy()
					UIHelperFunctions.AdjustBlackScreen(1, 0)
					SoundModule.StopAllSounds()
					task.wait(1)
					local function GoodChoice()
						SoundModule.PlaySound("RevolverShot")
						task.wait(1)
						SoundModule.PlaySound("Correct2")
						GeneralRemotes.AddMoney:FireServer(250)
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
					ClientHelperFunctions.EnableAllNPCPrompts(true)
					GeneralRemotes.Gamba.BulletGuesser.ResetBulletIndex:FireServer()
				end)
			end
		end
	end
end
return InitializeGUIModule
