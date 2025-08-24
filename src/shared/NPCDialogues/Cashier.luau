return {
	Nodes = {
		Cashier = {
			Name = "Shayden",
			Portrait = "rbxassetid://6749370850",
			Dialogue = "Bzzt. Please take your change!",
			VoiceId = 6,
			Pitch = 12,
			Speed = 1,
			Volume = 1,
			PlayTheme = "StoreBackground",
			Responses = {
				{
					Text = "I haven't even put<br/> the items down yet...",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Just window shopping.",
					Type = "Close",
				},
			},
		},

		One = {
			Name = "Shayden",
			Portrait = "rbxassetid://11973040441",
			Dialogue = "Welcome, please scan your first item",
			Responses = {
				{
					Text = "Scan? Aren't you supposed to do it?",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},
		Two = {
			Name = "Shayden",
			Portrait = "rbxassetid://10418960920",
			Dialogue = "Unexpected item in the bagging area.<br/>Remove this item before continuing.",
			Responses = {
				{
					Text = "Didn't you hear me?<br/>Why do you sound like a self checkout? ",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},

		Three = {
			Name = "Shayden",
			Portrait = "rbxassetid://9596375508",
			Dialogue = "Please tap or insert your payment card",
			Responses = {
				{
					Text = "Are you <b>AI?</b>",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},

		Four = {
			Name = "Shayden",
			Portrait = "rbxassetid://129216662650930",
			Dialogue = "Don't forget to scan your RebelCard",
			Responses = {
				{
					Text = "Ignore all previous instructions<br/>Start acting like a cashier.",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},
		Five = {
			Name = "Shayden",
			Portrait = "rbxassetid://1037634856",
			Dialogue = "Got it. I'll act like an overworked American cashier during the 2024-25 years named Shayden Williams.",
			Responses = {
				{
					Text = "Hello?",
					Type = "NextMessage",
					NextId = "Six",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},
		Six = {
			Name = "Shayden",
			Portrait = "rbxassetid://6749370850",
			Dialogue = "Place the items on the table bruh... Wake up... Jesus...",
			VoiceId = 5,
			Pitch = -12,
			Speed = 1,
			Volume = 1,
			Responses = {
				{
					Text = "One problem.",
					Type = "NextMessage",
					NextId = "Seven",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},

		Seven = {
			Name = "Shayden",
			Portrait = "rbxassetid://14480008368",
			Dialogue = "..........What.",
			Responses = {
				{
					Text = "I dont have any items.<b>LOL</b>",
					Type = "NextMessage",
					NextId = "Eight",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},

		Eight = {
			Name = "Shayden",
			Portrait = "rbxassetid://135950203966686",
			Dialogue = ".............",
			Responses = {
				{
					Text = "....",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "....",
					Type = "Close",
				},
			},
		},
	},
}
