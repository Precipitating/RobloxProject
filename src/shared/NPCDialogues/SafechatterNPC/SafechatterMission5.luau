return {
	Nodes = {
		SafechatterMission5 = {
			Name = "???OG USER???",
			Portrait = "rbxassetid://150933824",
			Dialogue = "Wait black milli at RT? Maybe I could jump him with my Auto 5 or PPSH",
			VoiceId = "5",
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "OldTheme",
			Responses = {
				{
					Text = "Err? You got tix pal?",
					Type = "NextMessage",
					NextId = "Question",
				},
				{
					Text = "Weird cosplayer. Bye.",
					Type = "Close",
				},
			},
		},
		Question = {
			Name = "Apoc dude",
			Portrait = "rbxassetid://18636752982",
			Dialogue = "Errrr don't have any old questions at the moment.<br/>Let me pop an Apoc one while I think: What's the most popular location?",
			Responses = {
				{
					Text = "Kin?",
					Type = "NextMessage",
					NextId = "Win1",
				},
				{
					Text = "University?",
					Type = "NextMessage",
					NextId = "Fail",
				},
			},
		},

		Fail = {
			Name = "C&G Enthusiast",
			Portrait = "rbxassetid://60181106",
			Dialogue = "You're wasting my time... I'm off to <i>Kin</i> to get some blood packs.<br/><b>Bog off.</b>",
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
			Name = "Kinwah",
			Portrait = "rbxassetid://150686898",
			Dialogue = "Err still can't think of one soooo...<br/>What does a <font color='#000000'>'black milli'</font> signify to other users?",
			Responses = {
				{
					Text = "Guys stacked out the <b>gaff.</b>",
					Type = "NextMessage",
					NextId = "Win2",
				},
				{
					Text = "Guy has a black military backpack.<br/>Nothing really.",
					Type = "NextMessage",
					NextId = "Fail",
				},
			},
		},
		Win2 = {
			Name = "Opportunity taker",
			Portrait = "rbxassetid://147647099",
			Dialogue = "Oh, here's one:<br/>Why was <b>Riptide</b> a popular item?",
			Responses = {
				{
					Text = "Infinite robux glitch<br/>Get the badge, delete & repeat",
					Type = "NextMessage",
					NextId = "Win3",
				},
				{
					Text = "Infinite tix glitch",
					Type = "NextMessage",
					NextId = "Fail",
				},
			},
		},

		Win3 = {
			Name = "RT",
			Portrait = "rbxassetid://18434077998",
			Dialogue = "Cool. Take it.<br/>Need to go to RT and one shot with my Patriot I just spaw- found legally.",
			Responses = {
				{
					Text = "Apoc 2 is out you know...?",
					DestroyObject = { "SafechatterMission5" },
					ProgressMission = {
						MissionName = "GuestMoney",
						ProgressVal = 1,
						TaskId = "Money",
					},
					Type = "Close",
				},
				{
					Text = "Didn't you have an Auto-5/PPSH?",
					DestroyObject = { "SafechatterMission5" },
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
