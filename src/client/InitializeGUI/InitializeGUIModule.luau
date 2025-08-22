local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local MissionRemotes = ReplicatedStorage.Shared.Missions.Events
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
	local GUI = ReplicatedStorage.Shared.GUI.Glitcher.TerminalGUI
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

return InitializeGUIModule
