local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Thief = require(ReplicatedStorage.NPCs.Thief.Thief)
local function StopDancing()
	Thief.SetDanceState(false)

	return {
		Name = "Dan Foe",
		Portrait = "rbxassetid://1100390363",
		Dialogue = "...",
		PlaySound = "GoodMorningVietnam",
		PlayTheme = "VietnamSong",
		Responses = {
			{
				Text = "MY EARS",
				Type = "NextMessage",
				NextId = "Four",
			},
			{
				Text = "AHHHHH",
				Type = "NextMessage",
				NextId = "Four",
			},
		},
	}
end

local function Run()
	workspace.NPCs.Thief:Destroy()
	return {
		Name = "Dan Foe",
		Portrait = "rbxassetid://9525535512",
		Dialogue = "...",
		PlaySound = "CartoonRun",
		Responses = {
			{
				Text = "SON OF TELAMON!",
				Type = "Close",
				ExecuteScenarioEvent = "ThiefSuccess",
			},
			{
				Text = ".....Bruh.",
				Type = "Close",
				ExecuteScenarioEvent = "ThiefSuccess",
			},
		},
	}
end
return {
	Nodes = {
		ThiefCompleted = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://10851325055",
			Dialogue = "DUNNO WHAT I WAS FINKIN LEEAVIN THAT TV BEHAIIND...",
			VoiceId = "5",
			Pitch = -1,
			Speed = 1,
			Volume = 3,
			PlayTheme = "Aerobics",
			Responses = {
				{
					Text = "I got it bro",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "...",
					Type = "Close",
				},
			},
		},
		One = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://17094394552",
			Dialogue = "Where is it?",
			Responses = {
				{
					Text = "Its in my invisible subspace",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "Here.",
					Type = "NextMessage",
					NextId = "Two",
				},
			},
		},
		Two = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://9479217777",
			Dialogue = "Loy ngwin dah duhk zai.",
			Responses = {
				{
					Text = "Mi scusi?",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "What the...",
					Type = "NextMessage",
					NextId = "Three",
				},
			},
		},
		Three = StopDancing,
		Four = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://1213335228",
			Dialogue = "...",
			PlaySound = "VietcongVoiceline",
			Responses = {
				{
					Text = "????",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = "????????",
					Type = "NextMessage",
					NextId = "Five",
				},
			},
		},
		Five = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://8060966373",
			Dialogue = "I'M BACK BABY!",
			Responses = {
				{
					Text = "That was... interesting.",
					Type = "NextMessage",
					NextId = "Six",
				},
				{
					Text = "*Flabbergasted*",
					Type = "NextMessage",
					NextId = "Six",
				},
			},
		},

		Six = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://652833974",
			Dialogue = "IM FREE OF THE CURSE FINALLY OH MY GOD.<br/>HAD TO MENTALLY DANCE PERFECTLY OR ELSE I WOULD BE SMITED BY THE GODS!",
			Responses = {
				{
					Text = "What defines a correct move?",
					Type = "NextMessage",
					NextId = "Seven",
				},
				{
					Text = "How does that make sense..?",
					Type = "NextMessage",
					NextId = "Seven",
				},
			},
		},
		Seven = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://9219139461",
			Dialogue = "Some ro-su mania thing popped up in my head, just had to 'click' at the correct time and it will be perfect!",
			Responses = {
				{
					Text = "Makes sense...<br/>Reward?",
					Type = "NextMessage",
					NextId = "Eight",
				},
				{
					Text = "COOLNOWREWARDNOW!",
					Type = "NextMessage",
					NextId = "Eight",
				},
			},
		},
		Eight = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://5692055",
			Dialogue = "Of course.<br/>Let me just hold this TV up for a second.",
			Responses = {
				{
					Text = "...Ok",
					Type = "NextMessage",
					NextId = "Nine",
				},
				{
					Text = "Why?",
					Type = "NextMessage",
					NextId = "Nine",
				},
			},
		},

		Nine = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://183241014",
			Dialogue = "Heh. This'll give a hefty amount.",
			Responses = {
				{
					Text = "...",
					Type = "NextMessage",
					NextId = "Ten",
				},
				{
					Text = "Ok run your pockets.",
					Type = "NextMessage",
					NextId = "Ten",
				},
			},
		},
		Ten = Run,
	},
}
