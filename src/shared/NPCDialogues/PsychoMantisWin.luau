return {
	Nodes = {
		PsychoMantisWin = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://16642438470",
			Dialogue = "... You <s>WON</s> right?",
			VoiceId = "1",
			Pitch = 12,
			Speed = 0.5,
			Volume = 1,
			PlayTheme = "Calm",
			Responses = {
				{
					Text = "Easiest thing i've ever done.",
					Type = "NextMessage",
					RemoveTools = { "Keyboard" },
					NextId = "Truth",
				},
				{
					Text = "Yes, more importantly, why was<br/>I inside a dumpster?",
					Type = "NextMessage",
					NextId = "TrashBin",
				},
			},
		},

		TrashBin = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://129937383",
			Dialogue = "I set a random coordinate back here when you finished the competition.<br/>Maybe fate decided that's where you belong?<br/><b>Tra-la-la-la-lah</b>",
			Responses = {
				{
					Text = "AHAHAHAHAHHA!",
					RemoveTools = { "Keyboard" },
					Type = "NextMessage",
					NextId = "Truth",
				},
				{
					Text = "<i>Ha ha ha!</i><br/><i>(He has my info)</i>",
					RemoveTools = { "Keyboard" },
					Type = "NextMessage",
					NextId = "Truth",
				},
			},
		},

		Truth = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://113239226",
			Dialogue = "Excellent, i'll take that <b>delicious</b> Loo-ting keyboard or whatever it's called off you.<br/>What's yours is mine.",
			Responses = {
				{
					Text = "So.... what do I get then?",
					Type = "NextMessage",
					NextId = "Reward",
				},
				{
					Text = "Yes haha!<br/><i>(He has my info)</i>",

					Type = "NextMessage",
					NextId = "Decision",
				},
			},
		},

		Reward = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://113239226",
			Dialogue = "Wait... you thought you had negotiating power...?<br/><font color='#FF0000'>HAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHA</font>",
			Responses = {
				{
					Text = ".....",
					Type = "NextMessage",
					NextId = "Decision",
				},
				{
					Text = ".....",
					Type = "NextMessage",
					NextId = "Decision",
				},
			},
		},

		Decision = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://115280474356122",
			Dialogue = "Be grateful for this, I'll give your information back.<br/>Spawned it somewhere in your room.<br/>Wait is this the <b>correct</b> one?<br/>Ah whatever.<br/>We're <b>EVEN!</b>",
			Responses = {
				{
					Text = "Uneven more like",
					Type = "NextMessage",
					NextId = "End",
				},
				{
					Text = "PHEW!",
					Type = "NextMessage",
					NextId = "End",
				},
			},
		},

		End = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://73456431219005",
			Dialogue = "Have a nice day! :)",
			Responses = {
				{
					Text = "(Walk off)",
					ExecuteScenarioEvent = "PsychoMantisWin",
					Type = "CloseCutscene",
				},
				{
					Text = "(Run off)",
					ExecuteScenarioEvent = "PsychoMantisWin",
					Type = "CloseCutscene",
				},
			},
		},
	},
}
