return {
	Nodes = {
		Frankenstein = {
			Name = "???",
			Portrait = "rbxassetid://9657742673",
			Dialogue = "UGGH AGHHHH RAAHHHH",
			VoiceId = "9",
			Pitch = -6,
			Speed = 1,
			Volume = 1,
			PlayTheme = "Creepy",
			Responses = {
				{
					Text = "WHAT ARE YOU DOING<br/>IN MY HOUSE!",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "RUN",
					Type = "Close",
				},
			},
		},

		One = {
			Name = "???",
			Portrait = "rbxassetid://7713734473",
			Dialogue = "WARM HOME.<br/>I LIKE.",
			Responses = {
				{
					Text = "GET OUT NOW!",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "HOW DID YOU GET IN!",
					Type = "NextMessage",
					NextId = "Two",
				},
			},
		},
		Two = {
			Name = "???",
			Portrait = "rbxassetid://10945717378",
			Dialogue = "NO.<br/>I SQUAT.<br/>I LIVE.<br/>YOU FAIL.",
			Responses = {
				{
					Text = "I WILL CALL THE CONSTABLES!",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "I REVIVED YOU!",
					Type = "NextMessage",
					NextId = "Three",
				},
			},
		},

		Three = {
			Name = "???",
			Portrait = "rbxassetid://7713734956",
			Dialogue = "DONT CARE.<br/>I INCOMPLETE.<br/>MISSING NEW SPINE.<br/>RED HAS SCOLIOSIS PAIN.",
			Responses = {
				{
					Text = "IF I FIND A NEW SPINE YOU'LL LEAVE?",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "(Leave, he owns you)",
					Type = "Close",
				},
			},
		},

		Four = {
			Name = `"Red"`,
			Portrait = "rbxassetid://16145852105",
			Dialogue = "NEW SPINE.<br/>I LEAVE.<br/>OK.",
			Responses = {
				{
					Text = "You better...",
					UnlockMission = "FindSpine",
					SetDialogueFile = { FrankensteinNameTag = "FrankensteinAccepted" },
					ExecuteScenarioEvent = "FrankensteinFindSpine",
					Type = "Close",
				},
				{
					Text = "(Leave, hes lying)",
					Type = "Close",
				},
			},
		},
	},
}
