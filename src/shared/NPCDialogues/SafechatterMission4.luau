return {
	Nodes = {
		SafechatterMission4 = {
			Name = "Stuck in 2013",
			Portrait = "rbxassetid://134009593",
			Dialogue = "God what an event that was... I was one of the 2011 people that beat the event... Jesus..",
			VoiceId = 1,
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "OldTheme",
			Responses = {
				{
					Text = "What? Tickets please?",
					Type = "NextMessage",
					NextId = "Question",
				},
				{
					Text = "... Old coots ramblin' im off.",
					Type = "Close",
				},
			},
		},
		Question = {
			Name = "Hallow",
			Portrait = "rbxassetid://183769773",
			Dialogue = "Answer some questions and you'll get some Tix lad. Firstly, What year was the Witching Hour?",
			Responses = {
				{
					Text = "2012",
					Type = "NextMessage",
					NextId = "Fail",
				},
				{
					Text = "2013",
					Type = "NextMessage",
					NextId = "Win1",
				},
			},
		},

		Fail = {
			Name = "...Chopper",
			Portrait = "rbxassetid://11886454251",
			Dialogue = "LEAVE YOU FLOPPLE DOODLE DOO NOOB! ENJOY THOSE EVENTS CREATED BY THE COMMUNITY NOT ROBLOX THEMSELVES",
			Responses = {
				{
					Text = "Er..",
					Type = "Close",
				},
				{
					Text = "Er... Blame John.. right?",
					Type = "Close",
				},
			},
		},

		Win1 = {
			Name = "Witching Hour",
			Portrait = "rbxassetid://134401087",
			Dialogue = "Right good. Now, what item types did this event primarily give?",
			Responses = {
				{
					Text = "Back Accessories. Capes. Supa supa!",
					Type = "NextMessage",
					NextId = "Fail",
				},
				{
					Text = "Some admin bloxikin . Narcissistic people huh?.",
					Type = "NextMessage",
					NextId = "Win2",
				},
			},
		},
		Win2 = {
			Name = "Scooter",
			Portrait = "rbxassetid://181753531",
			Dialogue = "Here's the deal breaker: what hat did you get if you paid 1000 robux for early access?",
			Responses = {
				{
					Text = "Zombie Headrow",
					Type = "NextMessage",
					NextId = "Win3",
				},
				{
					Text = "Orange Banded Top Hat",
					Type = "NextMessage",
					NextId = "Fail",
				},
			},
		},

		Win3 = {
			Name = "Jailed in 2025",
			Portrait = "rbxassetid://134009557",
			Dialogue = "Good job on the persistence. Take it.",
			Responses = {
				{
					Text = "Bruteforced it. LEL.",
					DestroyObject = { "SafechatterMission4" },
					ProgressMission = {
						MissionName = "GuestMoney",
						ProgressVal = 1,
						TaskId = "Money",
					},
					Type = "Close",
				},
				{
					Text = "I was one of the 2011 people I swear! Ts is epic!",
					DestroyObject = { "SafechatterMission4" },
					ProgressMission = {
						MissionName = "GuestMoney",
						ProgressVal = 1,
						TaskId = "Money",
					},
					Type = "Close",
				},
			},
		},
	},
}
