return {
	Nodes = {
		SafechatterEscaped = {
			Name = "Guest 1337",
			Portrait = "rbxassetid://15815325811",
			Dialogue = "Lights out.",
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
					Text = "YOU TRIED TO SILENCE ME?",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "'Hmm...' WHAT ARE YOU ON ABOUT",
					Type = "NextMessage",
					NextId = "Two",
				},
			},
		},

		Two = {
			Name = "Guest 1337",
			Portrait = "rbxassetid://15296361385",
			Dialogue = "Lights out.",
			PlayTheme = "Scary",

			Responses = {
				{
					Text = "YOU'RE TRYING IT AGAIN",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "??????",
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
					Text = "EXPLAIN OR ELSE...",
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
