return {
	Nodes = {
		SafechatterMission1 = {
			Name = "Ancient Coot",
			Portrait = "rbxassetid://13692620728",
			Dialogue = "yo lil bro u want sum free tix??? lol",
			VoiceId = 10,
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "OldTheme",
			Responses = {
				{
					Text = "Yesh",
					Type = "NextMessage",
					NextId = "Question",
				},
				{
					Text = "Did I ask? Seeya",
					Type = "Close",
				},
			},
		},
		Question = {
			Name = "Ancient Coot",
			Portrait = "rbxassetid://5600499503",
			Dialogue = "k q 4 u... wut was roblox called 1st??? XD",
			Responses = {
				{
					Text = "Roblox, nice trick question bud.",
					Type = "NextMessage",
					NextId = "Fail",
				},
				{
					Text = "Dynablox, i'm a retro slopper.",
					Type = "NextMessage",
					NextId = "Win",
				},
			},
		},

		Fail = {
			Name = "n00b",
			Portrait = "rbxassetid://8991722426",
			Dialogue = "no u n00b go bak 2 grow ur garden LOL hahahaha",
			PlaySound = "OldSplat",
			Responses = {
				{
					Text = "ts crazy old man...",
					Type = "Close",
				},
				{
					Text = "I have more robux than you kid.",
					Type = "Close",
				},
			},
		},

		Win = {
			Name = "Impressed Old Coot",
			Portrait = "rbxassetid://6555366201",
			Dialogue = "wow kk fair nuf enjoy da tix kid",
			PlaySound = "OldButton",
			Responses = {
				{
					Text = "Heh.",
					DestroyObject = { "SafechatterMission1" },
					ProgressMission = {
						MissionName = "GuestMoney",
						ProgressVal = 1,
						TaskId = "Money",
					},
					Type = "Close",
				},
				{
					Text = "I'm a veteran pal.",
					DestroyObject = { "SafechatterMission1" },
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
