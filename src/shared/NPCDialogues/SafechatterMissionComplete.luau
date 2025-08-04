return {
	Nodes = {
		SafechatterMissionComplete = {
			Name = "Guest",
			Portrait = "rbxassetid://60376597",
			Dialogue = "I can only see menu chats.",
			VoiceId = 10,
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "GuestTheme",
			Responses = {
				{
					Text = "123 for 5 tix",
					Type = "NextMessage",
					NextId = "Complete",
				},
				{
					Text = "Ta-ta for now!",
					Type = "Close",
				},
			},
		},

		Complete = {
			Name = "Guest",
			Portrait = "rbxassetid://112275522847651",
			Dialogue = "You are awesome!",
			Responses = {
				{
					Text = "So what do I get?",
					Type = "NextMessage",
					NextId = "Complete1",
				},
				{
					Text = "Just put the ending in the bag bro.",
					Type = "NextMessage",
					NextId = "Complete1",
				},
			},
		},

		Complete1 = {
			Name = "SOPA Lover",
			Portrait = "rbxassetid://70379700",
			Dialogue = "Honest Politicians",
			Responses = {
				{
					Text = "Wat...",
					Type = "NextMessage",
					NextId = "Complete2",
				},
				{
					Text = "???",
					Type = "NextMessage",
					NextId = "Complete2",
				},
			},
		},

		Complete2 = {
			Name = "Released Guest",
			Portrait = "rbxassetid://60376597",
			Dialogue = "AA-AAAH. FINALLY",
			Responses = {
				{
					Text = "der...",
					Type = "NextMessage",
					NextId = "Complete3",
				},
				{
					Text = "???",
					Type = "NextMessage",
					NextId = "Complete3",
				},
			},
		},

		Complete3 = {
			Name = "Guest",
			Portrait = "rbxassetid://11886454251",
			Dialogue = "AA-AAAH. FINALLY I ESCAPED THE SAFE CHAT THANKS TO THE 5 TIX I CONVERTED ON THE EXCHANGE FOR ROBUX TO PAY NOBLEDRAGON FOR CHAT ACCESS.",
			Responses = {
				{
					Text = "Didn't ask bud. Give me the reward.",
					Type = "NextMessage",
					NextId = "Complete4",
				},
				{
					Text = "<------------",
					Type = "NextMessage",
					NextId = "Complete4",
				},
			},
		},

		Complete4 = {
			Name = "G#est",
			Portrait = "rbxassetid://60376597",
			Dialogue = "Ok I will give yo# # music 10 ############### ###########",
			PlaySound = "Static",
			PlayTheme = "Scary",
			Responses = {
				{
					Text = "Music reward? is this a joke",
					Type = "NextMessage",
					NextId = "Complete5",
				},
				{
					Text = "I'm about to CRASH OUT!!!!",
					Type = "NextMessage",
					NextId = "Complete5",
				},
			},
		},

		Complete5 = {
			Name = "Guest",
			Portrait = "rbxassetid://18100184060",
			Dialogue = "#### ###### # ####### ######",
			PlaySound = "Static",
			Responses = {
				{
					Text = "You've go## ## Wh- #w # HELP# ",
					ExecuteScenarioEvent = "GuestComplete",
					Type = "CloseCutscene",
				},
				{
					Text = "Th# ##### AAH#### #",
					ExecuteScenarioEvent = "GuestComplete",
					Type = "CloseCutscene",
				},
			},
		},
	},
}
