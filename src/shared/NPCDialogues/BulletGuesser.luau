local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local GeneralRemotes = ReplicatedStorage.Remotes
local function Dialogue()
	local money = GeneralRemotes.GetCurrentMoney:InvokeServer()

	if money >= 50 then
		return {
			Name = "Ohulot!",
			Portrait = "rbxassetid://7254475046",
			Dialogue = "Here's the deal.<br/>One chance.<br/>One bullet.<br/>6 holes.<br/>Guess which hole the bullet will be in.<br/>You win, you get £250<br/>You lose?<br/>You lose all your money.",
			VoiceId = "3",
			Pitch = 2,
			Speed = 1,
			Volume = 1,
			PlayTheme = "HighStakes",
			Responses = {
				{
					Text = "Go on.",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "BulletGuesser",
				},
				{
					Text = "NO...",
					Type = "Close",
				},
			},
		}
	else
		return {
			Name = "Ohulot!",
			Portrait = "rbxassetid://7254475046",
			Dialogue = "You can't afford this. Scram.",
			VoiceId = "3",
			Pitch = 2,
			Speed = 1,
			Volume = 1,
			PlayTheme = "HighStakes",
			Responses = {
				{
					Text = "Grrrr...",
					Type = "Close",
				},
				{
					Text = "NOOOO.",
					Type = "Close",
				},
			},
		}
	end
end

return {
	Nodes = {
		BulletGuesser = Dialogue,
	},
}
