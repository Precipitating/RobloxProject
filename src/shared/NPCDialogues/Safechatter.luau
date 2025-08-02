return {
	Nodes = {
		Safechatter = {
			Name = "Guest",
			Portrait = "rbxassetid://60376597",
			Dialogue = "Hello",
			VoiceId = 10,
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "GuestTheme",
			Responses = {
				{
					Text = "Hello",
					Type = "NextMessage",
					NextId = "Safechatter1",
				},
				{
					Text = "Goodbye",
					Type = "Close",
				},
			},
		},

		Safechatter1 = {
			Name = "Guest",
			Portrait = "rbxassetid://18142327542",
			Dialogue = "...",
			Responses = {
				{
					Text = "Quiet type huh?",
					Type = "NextMessage",
					NextId = "Safechatter2",
				},
				{
					Text = "Walk off",
					Type = "Close",
				},
			},
		},

		Safechatter2 = {
			Name = "Guest",
			Portrait = "rbxassetid://18142323609",
			Dialogue = "You are ... ",
			Responses = {
				{
					Text = "?",
					Type = "NextMessage",
					NextId = "Safechatter3",
				},
				{
					Text = "Walk off",
					Type = "Close",
				},
			},
		},

		Safechatter3 = {
			Name = "Guest",
			Portrait = "rbxassetid://18142330697",
			Dialogue = "I don't want to say boy or girl. Don't ask.",
			Responses = {
				{
					Text = "What?",
					Type = "NextMessage",
					NextId = "Safechatter31",
				},
				{
					Text = "I'm going to blox you in a second...",
					Type = "NextMessage",
					NextId = "Safechatter32",
				},
			},
		},

		Safechatter31 = {
			Name = "Guest",
			Portrait = "rbxassetid://18142323609",
			Dialogue = "Help me with this",
			Responses = {
				{
					Text = "With what?",
					Type = "NextMessage",
					NextId = "Safechatter311",
				},
				{
					Text = "Why would I listen to yew?",
					Type = "NextMessage",
					NextId = "Safechatter321",
				},
			},
		},

		-- mission route
		Safechatter311 = {
			Name = "gREEdY gUEST",
			Portrait = "rbxassetid://111329274606489",
			Dialogue = "I like money",
			Responses = {
				{
					Text = "Ok?",
					Type = "NextMessage",
					NextId = "Safechatter312",
				},
				{
					Text = "That's it, i'm leaving you wally!",
					Type = "NextMessage",
					NextId = "Safechatter321",
				},
			},
		},
		Safechatter312 = {
			Name = "Guest?",
			Portrait = "rbxassetid://12347327938",
			Dialogue = "TEH EPIK DUCK IS COMING!!! ",
			Responses = {
				{
					Text = "Wetro Shlop Grr!",
					Type = "NextMessage",
					NextId = "Safechatter313",
				},
				{
					Text = "My house is on fire! gtg.",
					Type = "NextMessage",
					NextId = "Safechatter321",
				},
			},
		},

		Safechatter313 = {
			Name = "Guest",
			Portrait = "rbxassetid://18142327542",
			Dialogue = "Have a nice day",
			Responses = {
				{
					Text = "Have a nice d- SHUTAAAAAYAAUUUUUUUUUUP",
					SetDialogueFile = { { SafechatterNameTag = "SafechatterAccepted" } },
					Type = "Close",
				},
				{
					Text = "(VERY CALM RESPONSE. VERY. CALM.)",
					Type = "NextMessage",
					NextId = "Safechatter321",
				},
			},
		},
		-- scary route
		Safechatter321 = {
			Name = "Guest 1",
			Portrait = "rbxassetid://15815325811",
			Dialogue = "You are doing something I don't like. Please stop.",
			PlaySound = "Static",
			Responses = {
				{
					Text = "Or what?",
					Type = "NextMessage",
					NextId = "HorrorMode",
				},
				{
					Text = "What you gonna do?",
					Type = "NextMessage",
					NextId = "HorrorMode",
				},
			},
		},

		HorrorMode = {
			Name = "Guest 1337",
			Portrait = "rbxassetid://15815325811",
			Dialogue = "Lights out.",
			PlayTheme = "Scary",
			PlaySound = "Static",
			Responses = {
				{
					Text = "Wha-",
					Type = "NextMessage",
					NextId = "Close",
				},
				{
					Text = "W-",
					Type = "Close",
				},
			},
		},
	},
}
