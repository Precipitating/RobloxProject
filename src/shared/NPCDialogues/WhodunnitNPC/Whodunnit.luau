local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local GetMoneyRemote = ReplicatedStorage.Remotes.GetCurrentMoney

local function StartDialogue()
	local cash = GetMoneyRemote:InvokeServer()
	if cash >= 100 then
		return {
			Name = "Adam",
			Portrait = "rbxassetid://36301142",
			Dialogue = "Hello sir, would you like a tour of the game i made",
			VoiceId = "7",
			Pitch = -1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "OldTimerTheme",
			Responses = {
				{
					Text = "100 Great British Pounds...<br/>For a tour..?",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "No.",
					Type = "Close",
				},
			},
		}
	else
		return {
			Name = "Adam",
			Portrait = "rbxassetid://36301142",
			Dialogue = "I can smell that you can't afford this.<br/>Come back when you can eh?",
			VoiceId = "7",
			Pitch = -1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "OldTimerTheme",
			Responses = {
				{
					Text = "You judged a book<br/>BY ITS COVER!",
					Type = "Close",
				},
				{
					Text = "OI...",
					Type = "Close",
				},
			},
		}
	end
end

return {
	Nodes = {
		Whodunnit = StartDialogue,
		One = {
			Name = "Adam",
			Portrait = "rbxassetid://14723079797",
			Dialogue = "It's worth it mate.<br/>It's an ancient forgotten history of a feature called personal servers mate.<br/>It was popular and my 1k robux admin commands was selling like hot pockets!",
			Responses = {
				{
					Text = "Why not I guess",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "Nah you scam, you scam.<br/>Bye.",
					Type = "Close",
				},
			},
		},
		Two = {
			Name = "Adam",
			Portrait = "rbxassetid://5317216871",
			Dialogue = "Excellent, let me describe who I am and the context to this tour firstly before we go to the place of where horrors occured.",
			Responses = {
				{
					Text = "Explain in 3 minutes bro.",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "...",
					Type = "NextMessage",
					NextId = "Three",
				},
			},
		},

		Three = {
			Name = "Adam",
			Portrait = "rbxassetid://127110909372919",
			Dialogue = "It started on the day ROBLOX announced the feature called personal servers.<br/>A server that never ends.<br/>A server that automatically saves changes.<br/>A place where creativity thrives.",
			Responses = {
				{
					Text = "Right...",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "Ok...",
					Type = "NextMessage",
					NextId = "Four",
				},
			},
		},

		Four = {
			Name = "Adam",
			Portrait = "rbxassetid://5547048597",
			Dialogue = "Of course the mighty me jumped on this, not letting this chance go to earn some serious robux.<br/>To create a game called Whodunnit.<br/>A game where you have to find out who the killer is through clues and so forth.",
			Responses = {
				{
					Text = "Interesting...",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = "Go on...",
					Type = "NextMessage",
					NextId = "Five",
				},
			},
		},
		Five = {
			Name = "Adam",
			Portrait = "rbxassetid://401846955",
			Dialogue = "The idea stolen from ps1player, the first issue was presented. I can't script.<br/>No problem, i'll host manually and use some admin commands to help me out.<br/>Secondly, I need some help building the map.",
			Responses = {
				{
					Text = "I guess you hired some...?",
					Type = "NextMessage",
					NextId = "Six",
				},
				{
					Text = "Right...",
					Type = "NextMessage",
					NextId = "Six",
				},
			},
		},
		Six = {
			Name = "Adam",
			Portrait = "rbxassetid://129411508",
			Dialogue = "Luck has it that I can get free sl- I mean helpers if I just promised any random joining passerby admin commands if they helped build.<br/><b>Problem solved.</b>",
			Responses = {
				{
					Text = "...Wow.",
					Type = "NextMessage",
					NextId = "Seven",
				},
				{
					Text = "You nasty man!",
					Type = "NextMessage",
					NextId = "Seven",
				},
			},
		},
		Seven = {
			Name = "Adam",
			Portrait = "rbxassetid://141747284",
			Dialogue = "With the help of RecruitDragon5, Ligtard123, AlexTheDisarmer12 and DiabeticGamer as builder and helper, I accumulated enough players to start my first host.",
			Responses = {
				{
					Text = "It's been 4 months, hurry up.",
					Type = "NextMessage",
					NextId = "Eight",
				},
				{
					Text = "Ok...",
					Type = "NextMessage",
					NextId = "Eight",
				},
			},
		},
		Eight = {
			Name = "Adam",
			Portrait = "rbxassetid://189694289",
			Dialogue = "You will now be in the POV of an average player, and experience what happens in a round of Whodunnit by iZzap",
			Responses = {
				{
					Text = "Finally..",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "WhodunnitStart",
				},
				{
					Text = "Good.",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "WhodunnitStart",
				},
			},
		},
	},
}
