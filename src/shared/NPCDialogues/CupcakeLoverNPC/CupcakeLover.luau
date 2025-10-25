return {
	Nodes = {
		CupcakeLover = {
			Name = "???",
			Portrait = "rbxassetid://7675264896",
			Dialogue = "...",
			VoiceId = "1",
			Pitch = 2,
			Speed = 1,
			Volume = 3,
			PlayTheme = "Mysterious",
			Responses = {
				{
					Text = "..?",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Walk past this sus guy",
					Type = "Close",
				},
			},
		},

		One = {
			Name = "???",
			Portrait = "rbxassetid://109654173001654",
			Dialogue = "What?<br/>You want my autograph, kid?",
			Responses = {
				{
					Text = "Who even are you?",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "No, onwards.",
					Type = "Close",
				},
			},
		},

		Two = {
			Name = "???",
			Portrait = "rbxassetid://7279585383",
			Dialogue = "Buddy, you know i'm a famous developer... I contributed 100 million visits to Floparia, BUD.",
			Responses = {
				{
					Text = "...No idea bro.",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "(Leave, too arrogant)",
					Type = "Close",
				},
			},
		},

		Three = {
			Name = "???",
			Portrait = "rbxassetid://42168102",
			Dialogue = "Here's a hint... Cards.",
			Responses = {
				{
					Text = "...Doesn't ring a bell.",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "<-------",
					Type = "NextMessage",
					NextId = "Four",
				},
			},
		},

		Four = {
			Name = "???",
			Portrait = "rbxassetid://8261093756",
			Dialogue = "You must live under a rock huh, Patrick?<br/>Guess i'll break the ice and say it.<br/>Hello, my name is Damon,<br/>Lead card designer of the Floparia institution.",
			Responses = {
				{
					Text = "...Who?",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = "...Doesnt bell my ring.",
					Type = "NextMessage",
					NextId = "Five",
				},
			},
		},

		Five = {
			Name = "Damon",
			Portrait = "rbxassetid://4547477002",
			Dialogue = "EVERYONE KNOWS ME PAL! EVERYONE... KNOWS.. ME.. AUGHAhh-ACK",
			Speed = 3,
			Volume = 3,
			Responses = {
				{
					Text = "...You ok?",
					Type = "NextMessage",
					NextId = "End",
				},
				{
					Text = "Calm down er.. Daymond is it?",
					Type = "NextMessage",
					NextId = "End",
				},
			},
		},

		End = {
			Name = "Damon",
			Portrait = "rbxassetid://12951982529",
			Dialogue = "It's fine...<br/>Get me a gluten free cupcake, i'm running low on sugar.<br/>I'll make it worth your while.",
			Speed = 1,
			Volume = 1,
			PlayTheme = "Vader",
			Responses = {
				{
					Text = "I'll see what I can do.",
					SetDialogueFile = { CupcakeLoverNameTag = "CupcakeLoverAccepted" },
					Type = "Close",
				},
				{
					Text = "Right...",
					SetDialogueFile = { CupcakeLoverNameTag = "CupcakeLoverAccepted" },
					Type = "Close",
				},
			},
		},
	},
}
