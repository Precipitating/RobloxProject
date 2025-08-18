local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local InitializeGUIModule = {}

InitializeGUIModule["BosnianRouletteGUI"] = function()
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

	decrementButton.MouseButton1Click:Connect(function()
		Process(-1)
	end)

	negateFiveButton.MouseButton1Click:Connect(function()
		Process(-5)
	end)

	incrementButton.MouseButton1Click:Connect(function()
		Process(1)
	end)

	addFiveButton.MouseButton1Click:Connect(function()
		Process(5)
	end)

	submitButton.MouseButton1Click:Connect(function()
		GeneralRemotes.GlitcherMission.SubmitBombTimeReduction:FireServer(tonumber(input.Text))
		input.Text = "1"
	end)
end

return InitializeGUIModule
