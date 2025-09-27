return {
	Nodes = {
		BosnianFailed = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://12817163905",
			Dialogue = "I smell a fresh laptop nearby...",
			VoiceId = "1",
			Pitch = 5,
			Speed = 1,
			Volume = 3,
			PlayTheme = "BosniaTheme",
			Responses = {
				{
					Text = "You may be correct.",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Yeah for me, bye!",
					Type = "Close",
				},
			},
		},
		One = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://6982510374",
			Dialogue = "F-for me dobar građanin?",
			Responses = {
				{
					Text = "You may be correct.",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "No, sayanora.",
					Type = "Close",
				},
			},
		},
		Two = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://83476883704798",
			Dialogue = "THANK YOU SO MUCH MY PRIJATELJU<br/>THANK YOU SO MUCH<br/>THANK YOU S- wait...",
			Responses = {
				{
					Text = "..Yes?",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "...(He got me?)",
					Type = "NextMessage",
					NextId = "Three",
				},
			},
		},
		Three = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://5842992746",
			Dialogue = "Why did they set a cracked screen wallpaper... HAHAHAHAH, funny company they are!",
			Responses = {
				{
					Text = "Yes hahah!!",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "JAHAHAHAH!",
					Type = "NextMessage",
					NextId = "Four",
				},
			},
		},
		Four = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://8300516120",
			Dialogue = "Anyways, here's a token of my appreciation, my life savings.",
			Responses = {
				{
					Text = "~Oh nooo..<br/>you don't have toooo~",
					Type = "Close",
					ExecuteScenarioEvent = "BosnianFailEvent",
				},
				{
					Text = "Thanks bud.<br/>I'll use it well.",
					Type = "Close",
					ExecuteScenarioEvent = "BosnianFailEvent",
				},
			},
		},
	},
}
