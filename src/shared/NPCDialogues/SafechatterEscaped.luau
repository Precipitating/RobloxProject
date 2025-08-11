return {
	Nodes = {
		SafechatterEscaped = {
			Name = "Guest 1337",
			Portrait = "rbxassetid://15815325811",
			Dialogue = "<b>Lights out</b>",
			VoiceId = 10,
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "Scary",
			Responses = {
				{
					Text = "Wh-what happened?",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "What did you just do to me?",
					Type = "NextMessage",
					NextId = "One",
				},
			},
		},

		One = {
			Name = "Wut der",
			Portrait = "rbxassetid://98681559732626",
			Dialogue = "Hmm...",
			PlayTheme = "OldTheme",
			PlaySound = "OldSplat",
			Responses = {
				{
					Text = "Weeping angel gimmick huh?",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "'Hmm...'<br/>WHAT ARE YOU ON ABOUT",
					Type = "NextMessage",
					NextId = "Two",
				},
			},
		},

		Two = {
			Name = "Guest 1337",
			Portrait = "rbxassetid://15296361385",
			Dialogue = "<b>Lights out</b>",
			PlayTheme = "Scary",

			Responses = {
				{
					Text = "Wh-",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "W-",
					Type = "NextMessage",
					NextId = "Three",
				},
			},
		},

		Three = {
			Name = "Flabbergasted",
			Portrait = "rbxassetid://12587169836",
			Dialogue = "regen",
			PlayTheme = "OldTheme",
			PlaySound = "OldButton",
			Responses = {
				{
					Text = "DIDNT WORK THIS TIME EH?",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "THATS IT.... (PWN HIM)",
					ExecuteScenarioEvent = "GuestPwn",
					Type = "CloseCutscene",
				},
			},
		},
	},
}
