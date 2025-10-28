return {
	Nodes = {
		Thief = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://4150184738",
			Dialogue = "HUFF HUFF HUFF",
			VoiceId = "5",
			Pitch = -1,
			Speed = 1,
			Volume = 3,
			PlayTheme = "Aerobics",
			Responses = {
				{
					Text = "You okay there?",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Scoot past",
					Type = "Close",
				},
			},
		},

		One = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://5046112434",
			Dialogue = "JUST... HUFF... DOING...HUFF...MY...AEROBICS...HUFF.",
			Responses = {
				{
					Text = "Not sure doing Wartnite dances help",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "Cool. Enjoy. Bye.",
					Type = "Close",
				},
			},
		},

		Two = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://116567767903562",
			Dialogue = "YOU THINK I WANT TO DO THIS HUFF HUFF HUFF.",
			Responses = {
				{
					Text = "What are you? cursed?",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "<---",
					Type = "NextMessage",
					NextId = "Three",
				},
			},
		},

		Three = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://144928963",
			Dialogue = "I don't know what I was thinking, leaving that 100 inch OLED TV behind.<br/>Now I suffer the curse, and now I am blind.",
			Responses = {
				{
					Text = "...What?",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "Suddenly not huffing?",
					Type = "NextMessage",
					NextId = "Four",
				},
			},
		},

		Four = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://10017359424",
			Dialogue = "With all this anger, guilt, and sadness coming to haunt me forever.",
			Responses = {
				{
					Text = "You got cursed over a TV?",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = "Lost to a TV? that a new one.",
					Type = "NextMessage",
					NextId = "Five",
				},
			},
		},

		Five = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://10977605201",
			Dialogue = "Is this revenge I am seeking or seeking someone to avenge me?<br/>Stuck in my own paradox, I wanna set myself free.",
			Responses = {
				{
					Text = "...Where's the punchline?",
					Type = "NextMessage",
					NextId = "Six",
				},
				{
					Text = "...",
					Type = "NextMessage",
					NextId = "Six",
				},
			},
		},

		Six = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://478915056",
			Dialogue = "Maybe I should find and steal that TV before they'll try to stop it.<br/>It won't be long before I'll become a puppet.",
			Responses = {
				{
					Text = "...What do you want?",
					Type = "NextMessage",
					NextId = "End",
				},
				{
					Text = "STOP SINGING AND TELL ME WHAT YOU WANT",
					Type = "NextMessage",
					NextId = "End",
				},
			},
		},

		End = {
			Name = "Dan Foe",
			Portrait = "rbxassetid://9421231242",
			Dialogue = "JUST STEAL A TV FROM THE LAST HOUSE DOWN THE ROAD AND FREE ME FROM THE CURSE BRO.",
			Responses = {
				{
					Text = "THAT SIMPLE BUDDY.<br/>THAT SIMPLE.",
					Type = "Close",
					UnlockMission = "StealTV",
					SetDialogueFile = { ThiefNameTag = "ThiefAccepted" },
				},
				{
					Text = "Yeeaaaaaaaah no.",
					Type = "Close",
				},
			},
		},
	},
}
