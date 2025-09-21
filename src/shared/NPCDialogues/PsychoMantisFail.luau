return {
	Nodes = {
		PsychoMantisFail = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://16642438470",
			Dialogue = "... You <s>WON</s> right?",
			VoiceId = "1",
			Pitch = 4,
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
					Type = "NextMessage",
					NextId = "Truth",
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
					NextId = "Lie1",
				},
				{
					Text = "Aha! ragebait successful!<br/>Ahahah got you there!",
					Type = "NextMessage",
					NextId = "Lie1",
				},
			},
		},

		Lie1 = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://113239226",
			Dialogue = "<b>You are testing my patience you little chip stain.</b><br/>You know what i'm gonna do now you lying little <b><font color='#5ad976'>gremlin?</font></b>",
			Responses = {
				{
					Text = "What you gonna do with my username info?<br/> claim it on other websites <b>OoOo</b> sCARY ",
					Type = "NextMessage",
					NextId = "DecisionLie",
				},
				{
					Text = "What you gonna do in that chair <b>BOY?</b>",
					Type = "NextMessage",
					NextId = "DecisionLie",
				},
			},
		},

		Truth = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://113239226",
			Dialogue = "Roleplaying Stuttering Stuart are we?<br/>I'll take that as a <b>NO.</b><br/>You know what I said i'll do if you lost...<b>RIGHT?</b>",
			Responses = {
				{
					Text = "Knock on wood?",
					Type = "NextMessage",
					NextId = "DecisionTruth",
				},
				{
					Text = "Kk-k-kI-II--",
					Type = "NextMessage",
					NextId = "DecisionTruth",
				},
			},
		},

		DecisionLie = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://73456431219005",
			Dialogue = "Nothing! Have a nice day! (^._.^)",
			Responses = {
				{
					Text = "Phew he's a skid!<br/>Guy buys level 7s and thinks he's a god!",
					ExecuteScenarioEvent = "PsychoMantisFailLie",
					Type = "CloseCutscene",
				},
				{
					Text = "(Thank god I lied...)",
					ExecuteScenarioEvent = "PsychoMantisFailLie",
					Type = "CloseCutscene",
				},
			},
		},

		DecisionTruth = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://73456431219005",
			Dialogue = "Nothing! Have a nice day!<br/> 🍟🍔 Yummers!",
			Responses = {
				{
					Text = "Phew he's a skid!<br/> Script Builder's his level!",
					ExecuteScenarioEvent = "PsychoMantisFailTruth",
					Type = "CloseCutscene",
				},
				{
					Text = "(He was a fraud after all...)",
					ExecuteScenarioEvent = "PsychoMantisFailTruth",
					Type = "CloseCutscene",
				},
			},
		},
	},
}
