return {
	Nodes = {
		PsychoMantisFail = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://16642438470",
			Dialogue = "... You <s>WON</s> right?",
			VoiceId = 1,
			Pitch = 12,
			Speed = 0.5,
			Volume = 1,
			PlayTheme = "Calm",
			Responses = {
				{
					Text = "Yeah. Easy. Lol. Ez.",
					Type = "NextMessage",
					NextId = "Lie",
				},
				{
					Text = "Nn-n--n-nn-n-n--nn-",
					Type = "Truth",
				},
			},
		},

		Lie = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://16642438470",
			Dialogue = "You really think that me, <font color='#5ad976'><b>HACKER HAM</b></font>, don't know that you've tippy tapped your way into a loss to a room of people that includes:<br/>"
				.. "<font color='#FF0000'><b>Mr.Mugiwara</b></font>,<br/>"
				.. "<font color='#FF69B4'><b>Hello Kitty Girl</b></font>,<br/>"
				.. "<font color='#A52A2A'><b>xXStreetz2CrimRobangerXx</b></font>.<br/>"
				.. "Do you?",
			PlayTheme = "Calm",
			Responses = {
				{
					Text = "Yah",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Aha! ragebait successful!<br/>Ahahah got you there!",
					Type = "Close",
				},
			},
		},
	},
}
