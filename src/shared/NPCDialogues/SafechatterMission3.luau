return {
	Nodes = {
		SafechatterMission3 = {
			Name = "Adurite",
			Portrait = "rbxassetid://277685067",
			Dialogue = "<b>Adurite</b> for life hahah",
			VoiceId = 7,
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "OldTheme",
			Responses = {
				{
					Text = "Tix plz",
					Type = "NextMessage",
					NextId = "Question",
				},
				{
					Text = "... I'm off.",
					Type = "Close",
				},
			},
		},
		Question = {
			Name = "Audurite",
			Portrait = "rbxassetid://405140721",
			Dialogue = "HAHAHA WHAT EVENT DID U GET THESE HATS FROOOM?",
			Responses = {
				{
					Text = "2016 Halloweenverse",
					Type = "NextMessage",
					NextId = "Fail",
				},
				{
					Text = "2014 Summer Games",
					Type = "NextMessage",
					NextId = "Win1",
				},
			},
		},

		Fail = {
			Name = "Red",
			Portrait = "rbxassetid://37700586",
			Dialogue = "LEAVE YOU ADURITE-LESS <b>PAGAN.</b>",
			Responses = {
				{
					Text = "... Blue better anyway",
					Type = "Close",
				},
				{
					Text = "You're off it pal.",
					Type = "Close",
				},
			},
		},

		Win1 = {
			Name = "Aduroite",
			Portrait = "rbxassetid://337008046",
			Dialogue = "WHAT PLAYER POINT RANKING DO YA NEEED TO GET THESE <b>BOMBTASTIC</b> THINGS?",
			Responses = {
				{
					Text = "Top 20 for dailies, 10,000 for weeklies.",
					Type = "NextMessage",
					NextId = "Win2",
				},
				{
					Text = "Top 10 for dailies, 1000 for weeklies.",
					Type = "NextMessage",
					NextId = "Fail",
				},
			},
		},
		Win2 = {
			Name = "Adurite",
			Portrait = "rbxassetid://12820103439",
			Dialogue = "LAST QUESTION: HAS ROBLOX FALLEN OFF SINCE THEN?",
			Responses = {
				{
					Text = "Yes. Absolutely. Certainly. 100%. On god. Sort it out. NOW.",
					Type = "NextMessage",
					NextId = "Fail",
				},
				{
					Text = "No Mr Bazooka hah... I loooove ROBLOX 2025!",
					Type = "NextMessage",
					NextId = "Win3",
				},
			},
		},

		Win3 = {
			Name = "Dawid",
			Portrait = "rbxassetid://867849809",
			Dialogue = "<b>TAKE IT THEEEEEEEEEEEN?</b>",
			Volume = 3,
			Responses = {
				{
					Text = "Gud.",
					DestroyObject = { "SafechatterMission3" },
					ProgressMission = {
						MissionName = "GuestMoney",
						ProgressVal = 1,
						TaskId = "Money",
					},
					Type = "Close",
				},
				{
					Text = "Finally, im legging it!",
					DestroyObject = { "SafechatterMission3" },
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
