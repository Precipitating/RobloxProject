local TShirtChecker = require(script.Parent.TShirtChecker)
local Players = game:GetService("Players")
local Player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
local Character = Player.Character or Player.CharacterAdded:Wait()
local VIPDoor = workspace:FindFirstChild("West"):FindFirstChild("VIPRoom"):FindFirstChild("VIP")
local Password = "Rebels Over Lads"
local Debounce = false

VIPDoor.Touched:Connect(function(hit)
	if Debounce then
		return
	end
	local isPlayer = hit:FindFirstAncestorOfClass("Model")

	if isPlayer and game.Players:GetPlayerFromCharacter(isPlayer) then
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
	end
end)

-- incase they somehow die, atleast we get updated T-Shirt name
Player.CharacterAdded:Connect(function(newChar)
	Character = newChar
end)
