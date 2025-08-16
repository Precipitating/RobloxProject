local TShirtChecker = require(script.Parent.TShirtChecker)
local Players = game:GetService("Players")
local Player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
local Character = Player.Character or Player.CharacterAdded:Wait()
local VIPDoor = workspace:FindFirstChild("VIPRoom"):FindFirstChild("VIP")
local Password = "Rebels Over Lads"
local Debounce = false

VIPDoor.Touched:Connect(function()
	if Debounce then
		return
	end
	Debounce = true
	local shirtName = TShirtChecker.GetPlayersTShirtName(Character)
	if shirtName then
		if shirtName == Password then
			TShirtChecker.SetTShirtMethodActivated(true)
			VIPDoor.CanCollide = false
			task.wait(1)
			VIPDoor.CanCollide = true
			Debounce = false
			return
		end
	end
	task.wait(1)
	Debounce = false
end)

-- incase they somehow die, atleast we get updated T-Shirt name
Player.CharacterAdded:Connect(function(newChar)
	Character = newChar
end)
