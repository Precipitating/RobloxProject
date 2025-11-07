return {
	Nodes = {
		WhodunnitFailed = {
			Name = "Adam",
			Portrait = "rbxassetid://1250696703",
			VoiceId = "7",
			Pitch = -1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "OldTimerTheme",
			Dialogue = "That concludes the simulation.",
			Responses = {
				{
					Text = "I JUST STARTED??",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "Hold on...",
					Type = "Close",
				},
			},
		},
		Two = {
			Name = "Adam",
			Portrait = "rbxassetid://15619115564",
			Dialogue = "Thats the point.<br/>The host controls everything, you have no actual free will as killer.<br/>The round's story is controlled by the host, heh.",
			Responses = {
				{
					Text = "WHAT A TRASH GAME",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "WOW...",
					Type = "NextMessage",
					NextId = "Three",
				},
			},
		},

		Three = {
			Name = "Adam",
			Portrait = "rbxassetid://1078687003",
			Dialogue = "I mean maybe the tour would've been longer if you had no evidence for the host to prepare.<br/>Just spend 100 more pounds and find out.<br/>Haha",
			Responses = {
				{
					Text = "YOU SCAMMER YOU!",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "STOP LYING!!!",
					Type = "NextMessage",
					NextId = "Four",
				},
			},
		},

		Four = {
			Name = "Adam",
			Portrait = "rbxassetid://267421558",
			Dialogue = "Didn't check the back of my billboard?<br/>Should've read the fine print little chip.<br/>Should've used your wit as killer if you wanted to win eh?",
			Responses = {
				{
					Text = "IM GETTING MAAAD...",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = "RAHHHHHHHHHHHHHH",
					Type = "NextMessage",
					NextId = "Five",
				},
			},
		},
		Five = {
			Name = "Adam",
			Portrait = "rbxassetid://127607819132520",
			Dialogue = "Have a fantastical frumplicious day you loser!",
			Responses = {
				{
					Text = "I WILL BE BACK...",
					Type = "Close",
					SetDialogueFile = { WhodunnitNameTag = "Whodunnit" },
				},
				{
					Text = "YOU ARROGANT FRAUD...",
					Type = "Close",
					SetDialogueFile = { WhodunnitNameTag = "Whodunnit" },
				},
			},
		},
	},
}
