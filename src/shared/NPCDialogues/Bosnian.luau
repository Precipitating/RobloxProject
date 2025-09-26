return {
	Nodes = {
		Bosnian = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://14396015112",
			Dialogue = "Zdravo my friend.",
			VoiceId = "1",
			Pitch = 5,
			Speed = 1,
			Volume = 3,
			PlayTheme = "BosniaTheme",
			Responses = {
				{
					Text = "How's it going brother.",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Run",
					Type = "Close",
				},
			},
		},

		One = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://137918938744791",
			Dialogue = "Could be better my friend.",
			Responses = {
				{
					Text = "Maybe I can fix that...",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "Not my problem BYE!",
					Type = "Close",
				},
			},
		},

		Two = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://46957365",
			Dialogue = "<b>MY DAD PROMISED ME A LAPTOP TODAY...<br/>10 YEARS AGO HE TOLD ME HE WOULD BUY ME A OVERKILL MONSTEROUS LAPTOP ON THIS DATE...<br/>NOW HE SAYS HE SPENT IT ALL ON AN ANTIQUE ANCHOR FROM THE TITANIC...</b>",
			Responses = {
				{
					Text = "What do you have currently?",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "(You cannot leave now.<br/>Enjoy the burden.)",
					Type = "NextMessage",
					NextId = "Three",
				},
			},
		},

		Three = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://6738909547",
			Dialogue = "SOME ANCIENT RO-TOP...CAN BARELY RUN ROBLOX ON 10FPS... IT CAN ONLY RUN PURBLE PALACE...<br/>WHY GOD... WHY...",
			Responses = {
				{
					Text = "What's with the anchor thing?<br/>A common event with your dad?",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "<-------",
					Type = "NextMessage",
					NextId = "Four",
				},
			},
		},

		Four = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://8242151157",
			Dialogue = "HE ALWAYS COMES BACK WITH A RANDOM ITEM...<br/><b>A GOLDEN DUCK</b><br/><b>A 100,000 MARK BICYCLE</b><br/><b>A LITERAL SHIP</b><br/><b>THE FUR OF BIGFOOT FOR A TRILLION MARKS...</b>",
			Responses = {
				{
					Text = "Your dad must be rich...?",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = "<-------",
					Type = "NextMessage",
					NextId = "Five",
				},
			},
		},

		Five = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://6117642787",
			Dialogue = "HE SPENDS IT ALL!<br/>THATS THE ISSUE!<br/>HE SAYS HE HAS NO MONEY, BUT SPENDS IT ON A GOLDEN SLAP CHOP THE NEXT DAY!",
			Responses = {
				{
					Text = "What do you want me to do...?",
					Type = "NextMessage",
					NextId = "Six",
				},
				{
					Text = "<--------",
					Type = "NextMessage",
					NextId = "Six",
				},
			},
		},

		Six = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://1337719202",
			Dialogue = "PLEASE BUY ME A LAPTOP WORTH 11268 MARKS... NOW!",
			Responses = {
				{
					Text = "No promises...<br/>I'll see what I can do. (£5k)",
					Type = "NextMessage",
					NextId = "End",
				},
				{
					Text = "(Nevermind, you can leave now.<br/>Hes a greedy brat!)",
					Type = "Close",
				},
			},
		},

		End = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://7015273574",
			Dialogue = "THANK YOU SO MUCH IF YOU GET ME THE 5090 59003DX MONSTER TOP 128TB RAM DDR6 1 PETABYTE M.2.",
			Responses = {
				{
					Text = "... Bit specific..?",
					Type = "Close",
					UnlockMission = "Laptop",
					SetDialogueFile = { BosnianNameTag = "BosnianAccepted" },
				},
				{
					Text = ".......",
					Type = "Close",
					UnlockMission = "StealPhone",
					SetDialogueFile = { BosnianNameTag = "BosnianAccepted" },
				},
			},
		},
	},
}
