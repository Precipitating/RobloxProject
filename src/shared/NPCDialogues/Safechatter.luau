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
					NextId = "Safechatter321",
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
			Dialogue = "I like <font color='#2d6f2a'>money</font>",
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
			Dialogue = "<font color='#ffde32'>TEH EPIK DUCK IS COMING!!!</font>",
			Responses = {
				{
					Text = "Wetro Shlop GaiSHzz!",
					Type = "NextMessage",
					NextId = "MissionMode",
				},
				{
					Text = "My house is on fire! gtg.",
					Type = "NextMessage",
					NextId = "Safechatter321",
				},
			},
		},

		MissionMode = {
			Name = "Guest",
			Portrait = "rbxassetid://18142327542",
			Dialogue = "Have a nice day",
			Responses = {
				{
					Text = "xD Have a nice day :) aha! xD",
					SetDialogueFile = { { SafechatterNameTag = "SafechatterAccepted" } },
					UnlockMission = "GuestMoney",
					Type = "Close",
				},
				{
					Text = "(VERY <b>CALM</b> RESPONSE. VERY. <b>CALM</b>.)",
					Type = "NextMessage",
					NextId = "Safechatter321",
				},
			},
		},
		-- scary route
		Safechatter321 = {
			Name = "Guest 1",
			Portrait = "rbxassetid://15815325811",
			Dialogue = "You are doing something I don't like. Please <b>stop</b>.",
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
			Dialogue = `<font size="40"><b>Lights out</b></font>`,
			PlayTheme = "Scary",
			PlaySound = "Static",
			ChangeThemePlaybackSpeed = 0.2,
			Responses = {
				{
					Text = "Wha-",
					ExecuteScenarioEvent = "GuestHorrorMode",
					Type = "CloseKeepTheme",
				},
				{
					Text = "W-",
					ExecuteScenarioEvent = "GuestHorrorMode",
					Type = "CloseKeepTheme",
				},
			},
		},
	},
}
