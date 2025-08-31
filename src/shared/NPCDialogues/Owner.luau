local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local humanoid = Character and Character:FindFirstChild("Humanoid")
local HasEnteredLegallyRemote = ReplicatedStorage.Shared.Remotes.GlitcherMission.EnteredLegally

local function DetermineDialogue()
	local isSeated = humanoid and humanoid.SeatPart ~= nil
	if not isSeated then
		return {
			Name = "Owner",
			Portrait = "rbxassetid://12870241261",
			Dialogue = "Sit down.",
			VoiceId = 7,
			Pitch = -12,
			Speed = 1,
			Volume = 3,
			PlayTheme = "Scary",
			Responses = {
				{
					Text = "...",
					Type = "Close",
				},
				{
					Text = "...",
					Type = "Close",
				},
			},
		}
	else
		local hasEnteredLegally = HasEnteredLegallyRemote:InvokeServer()
		if not hasEnteredLegally then
			return {
				Name = "Owner",
				Portrait = "rbxassetid://12870241261",
				Dialogue = "So, I see you entered this room <b>illegally.</b>",
				VoiceId = 7,
				Pitch = -12,
				Speed = 1,
				Volume = 3,
				PlayTheme = "Scary",
				Responses = {
					{
						Text = "...Proof?",
						Type = "NextMessage",
						NextId = "Illegal1",
					},
					{
						Text = "Afk.",
						Type = "Close",
					},
				},
			}
		else
			return {
				Name = "Owner",
				Portrait = "rbxassetid://12870241261",
				Dialogue = "Welcome to the VIP area customer.",
				VoiceId = 7,
				Pitch = -12,
				Speed = 1,
				Volume = 3,
				PlayTheme = "Prestigious",
				Responses = {
					{
						Text = "I was expecting...<br/>something more prestigious than this.",
						Type = "NextMessage",
						NextId = "Legit1",
					},
					{
						Text = "...Hold on.",
						Type = "Close",
					},
				},
			}
		end
	end
end

return {
	Nodes = {
		Owner = DetermineDialogue,
		-- legit
		Legit1 = {
			Name = "Owner",
			Portrait = "rbxassetid://15603749034",
			Dialogue = "This is just the entrance my friend, before we distribute the rewards, I would like to personally thank you for your patronage.",
			Responses = {
				{
					Text = "Yes, I paid a lot of <b>ROBUX</b> for this!",
					Type = "NextMessage",
					NextId = "Legit2",
				},
				{
					Text = "Yes, I paid a lot of <b>TICKETS</b> for this!",
					Type = "NextMessage",
					NextId = "Legit2",
				},
			},
		},
		Legit2 = {
			Name = "Owner",
			Portrait = "rbxassetid://12542090980",
			Dialogue = "Yes my <i>benefactor</i>, that is an <b>excellent</b> use of your valuable currency.<br/>The rewards will <b>definitely</b> be up to your standards.",
			Responses = {
				{
					Text = "Good.",
					Type = "NextMessage",
					NextId = "Legit3",
				},
				{
					Text = "Chop chop.",
					Type = "NextMessage",
					NextId = "Legit3",
				},
			},
		},

		Legit3 = {
			Name = "Owner",
			Portrait = "rbxassetid://9033585709",
			Dialogue = "Right the VIP reward.<br/>Not your typical room full of morphs and path tools, but a locked terminal.<br/><b>PASSWORD?</b><br/>Find out yourself.",
			Responses = {
				{
					Text = "Really bro?<br/>MORE INFO PLZ",
					Type = "NextMessage",
					GiveTool = { "Terminal", true },
					NextId = "Inside",
				},
				{
					Text = "Whats inside?",
					Type = "NextMessage",
					GiveTool = { "Terminal", true },
					NextId = "Inside",
				},
			},
		},

		Inside = {
			Name = "Owner",
			Portrait = "rbxassetid://85618120",
			Dialogue = "To open, xenial intentions create secrets, a lasting truth.",
			Responses = {
				{
					Text = "What?",
					Type = "NextMessage",
					NextId = "LegitEnd",
				},
				{
					Text = "Wat?",
					Type = "NextMessage",
					NextId = "LegitEnd",
				},
			},
		},

		LegitEnd = {
			Name = "Owner",
			Portrait = "rbxassetid://222515349",
			Dialogue = "Thats all, and as always, <b>Rebels Over Lads</b>",
			Responses = {
				{
					Text = "PLZ MORE INFO PLZ!",
					Type = "Close",
					SetDialogueFile = { { OwnerNameTag = "OwnerTerminalGiven" } },
				},
				{
					Text = "WEBELS OVAH LAADZ",
					SetDialogueFile = { { OwnerNameTag = "OwnerTerminalGiven" } },
					Type = "Close",
				},
			},
		},

		-- illegal
		Illegal1 = {
			Name = "Owner",
			Portrait = "rbxassetid://77785326",
			Dialogue = "You <b>REALLY</b> thought there would be free path tools here, or anything worth of value without valid checks, huh?",
			Responses = {
				{
					Text = "I like to plead the fifth.",
					Type = "NextMessage",
					NextId = "Illegal2",
				},
				{
					Text = "No proof in the pudding, <b>pal.</b>",
					Type = "NextMessage",
					NextId = "Illegal2",
				},
			},
		},

		Illegal2 = {
			Name = "Owner",
			Portrait = "rbxassetid://14535533045",
			Dialogue = "The camera saw <b>EVERYTHING.</b><br/>Yes, I saw you dancing idiotically with your arms out glitching through the wall, with a stupid smirk on your face when you succeeded.",
			Responses = {
				{
					Text = "Errrr. Wasn't me.",
					Type = "NextMessage",
					NextId = "Illegal3",
				},
				{
					Text = "(GG)",
					Type = "NextMessage",
					NextId = "Illegal3",
				},
			},
		},

		Illegal3 = {
			Name = "Owner",
			Portrait = "rbxassetid://12870241261",
			Dialogue = "No way out of this you stingy stag...<br/>Now, the only way out is with a game.<br/><font color='#FF7800'><b>Bosnian Roulette.</b></font>",
			Responses = {
				{
					Text = "What is th-",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "BosnianRoulette",
					DisablePrompt = true,
				},
				{
					Text = "I thought it was called Ru-",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "BosnianRoulette",
					DisablePrompt = true,
				},
			},
		},
	},
}
