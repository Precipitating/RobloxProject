return {
	Nodes = {
		SafechatterMission2 = {
			Name = "Sauce-us",
			Portrait = "rbxassetid://7910429061",
			Dialogue = "Let me guess, tickets?",
			VoiceId = 5,
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "OldTheme",
			Responses = {
				{
					Text = "Hurry up...",
					Type = "NextMessage",
					NextId = "Question",
				},
				{
					Text = "No. Robux. Bye",
					Type = "Close",
				},
			},
		},
		Question = {
			Name = "Source?",
			Portrait = "rbxassetid://6862780932",
			Dialogue = "Answer this then kid. Where was I placed in the egg hunt?",
			Responses = {
				{
					Text = "You spawned in with 1/100 chance at the village.",
					Type = "NextMessage",
					NextId = "Fail",
				},
				{
					Text = "Under a bridge or something.",
					Type = "NextMessage",
					NextId = "Win1",
				},
			},
		},

		Fail = {
			Name = "Sorus",
			Portrait = "rbxassetid://6888586040",
			Dialogue = "Embarrassing. Leave.",
			Responses = {
				{
					Text = "WHO DYO U THINK YO UAAREE???",
					Type = "Close",
				},
				{
					Text = "I can just retry forever.. Ez.",
					Type = "Close",
				},
			},
		},

		Win1 = {
			Name = "Sorc",
			Portrait = "rbxassetid://1781166127",
			Dialogue = "Thought it's over huh? WHAT ITEM DID YOU NEED TO GET MY EGG?",
			Responses = {
				{
					Text = "Spam. Yummers.",
					Type = "NextMessage",
					NextId = "Win2",
				},
				{
					Text = "Fork. I'm a vet bud.",
					Type = "NextMessage",
					NextId = "Fail",
				},
			},
		},
		Win2 = {
			Name = "Sorcu",
			Portrait = "rbxassetid://118445828581543",
			Dialogue = "W-well WHERE DID YOU GET THIS SO CALLED 'SPAM'",
			Responses = {
				{
					Text = "3rd teleport, in the cave.. give it already..",
					Type = "NextMessage",
					NextId = "Fail",
				},
				{
					Text = "Idk snagged it at some house",
					Type = "NextMessage",
					NextId = "Win3",
				},
			},
		},

		Win3 = {
			Name = "Sorcus",
			Portrait = "rbxassetid://17286318",
			Dialogue = "Take it, you wiki searched it.. bum.",
			Volume = 3,
			Responses = {
				{
					Text = "Shut thy lips and thy will tolerate.",
					DestroyObject = { "SafechatterMission2" },
					ProgressMission = {
						MissionName = "GuestMoney",
						ProgressVal = 1,
						TaskId = "Money",
					},
					Type = "Close",
				},
				{
					Text = "Yeah yeah shhhhhhhhhhhhhhhhhhhhhhh",
					DestroyObject = { "SafechatterMission2" },
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
