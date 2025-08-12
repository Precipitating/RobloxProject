return {
	Nodes = {
		PsychoMantisWin = {
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
			Portrait = "rbxassetid://16573701490",
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

		Truth = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://113239226",
			Dialogue = "Roleplaying Stuttering Stuart are we? <br/>I'll take that as a <b>NO.</b><br/>You know what I said i'll do if you lost... <b>RIGHT?</b>",
			Responses = {
				{
					Text = "Knock on wood?",
					Type = "NextMessage",
					NextId = "Decision",
				},
				{
					Text = "Kk-k-kI-II--",
					Type = "Decision",
				},
			},
		},

		Decision = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://73456431219005",
			Dialogue = "Nothing! Have a nice day!",
			Responses = {
				{
					Text = "Phew",
					Type = "NextMessage",
					NextId = "Close",
				},
				{
					Text = "PHEW!",
					Type = "Close",
				},
			},
		},
	},
}
