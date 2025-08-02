return {
	Nodes = {
		RoadmanComplete = {
			Name = "Gentlemanly",
			Portrait = "rbxassetid://11640689559",
			Dialogue = "Bruv, you’re movin’ like a wasteman - man should be out there skimmin' a burner for me",
			Pitch = 12,
			Speed = 2,
			Volume = 3,
			PlayTheme = "RoadmanTune",
			PlaySound = "RadioBeep",
			Responses = {
				{
					Text = "I got it...",
					Type = "NextMessage",
					NextId = "Gentleman",
					RemoveTools = { "Skeng", "Nokia" },
				},
				{
					Text = "I forgor...",
					Type = "Close",
				},
			},
		},

		Gentleman = {
			Name = "Gentleman",
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			Portrait = "rbxassetid://10246439168",
			Dialogue = "Ahem. Ignore what transpired a second ago. Excellent, I will be taking this along with the walking stick I lended. Can you say where you took this from dear sir?",
			PlaySound = "RadioBeep",
			PlayTheme = "PoshTheme",
			Responses = {
				{
					Text = "Robbed some geezer.",
					Type = "NextMessage",
					NextId = "Parry",
				},
				{
					Text = "My nan. I swear.",
					Type = "NextMessage",
					NextId = "Nemeltneg",
				},
			},
		},

		Parry = {
			Name = "????Parry????",
			Pitch = -12,
			Speed = 2,
			Volume = 3,
			Portrait = "rbxassetid://729001246",
			PlaySound = "RadioBeep",
			PlayTheme = "PoliceCaught",
			Dialogue = "Control, this is Pc Parry on the case. We’ve got a Code 0 developing - repeat, Code zero - suspect just confessed over open mic to nicking a Nokia brick. Confirmed no license to hold that device. Requesting 300 Police Cruisers for detainment.",
			Responses = {
				{
					Text = "Ya got me...",
					Type = "CloseCutscene",
					DestroyObject = { "Roadman" },
					ExecuteScenarioEvent = "RoadmanCaught",
				},
				{
					Text = "em tog aY",
					Type = "CloseCutscene",
					DestroyObject = { "Roadman" },
					ExecuteScenarioEvent = "RoadmanCaught",
				},
			},
		},

		Nemeltneg = {
			Name = "nemeltneG",
			Speed = 1.5,
			Portrait = "rbxassetid://10246439168",
			Dialogue = "Ah, so I can safely assume it wasn’t your distinguished self I observed up the lane, theatrically demanding a mobile device from a startled gentleman as if you were Oliver Twist discovering meat on one hit point?",
			Responses = {
				{
					Text = "Wasn't me pal",
					Type = "NextMessage",
					NextId = "Gent",
				},
				{
					Text = "Name's not Oliwier ROFLCOPTER Dogeface",
					Type = "NextMessage",
					NextId = "GentZ",
				},
			},
		},

		Gent = {
			Name = "Gent",
			Portrait = "rbxassetid://11100293050",
			Dialogue = "Very well, I take your word for it. Here is the PC reward, do enjoy.",
			Responses = {
				{
					Text = "Time to play the better game",
					Type = "CloseCutscene",
					DestroyObject = { "Roadman" },
					ExecuteScenarioEvent = "RoadmanWin",
				},
				{
					Text = "Time to become a streamer!",
					Type = "CloseCutscene",
					DestroyObject = { "Roadman" },
					ExecuteScenarioEvent = "RoadmanWin",
				},
			},
		},

		GentZ = {
			Name = "Gent-Z",
			Pitch = 12,
			Speed = 1.5,
			Volume = 3,
			Portrait = "rbxassetid://11394123247",
			Dialogue = "Yikes, lil pup talkin' like that in the big 2025 jesus get with the times. Ts crazy old man. Take the W clanker reward",
			Responses = {
				{
					Text = "What the...",
					Type = "CloseCutscene",
					DestroyObject = { "Roadman" },
					ExecuteScenarioEvent = "RoadmanWin",
				},
				{
					Text = "Respect your elders...",
					Type = "CloseCutscene",
					DestroyObject = { "Roadman" },
					ExecuteScenarioEvent = "RoadmanWin",
				},
			},
		},
	},
}
