return {
	Nodes = {
		Glitcher = {
			Name = "Dia",
			Portrait = "rbxassetid://15251428254",
			Dialogue = "<b>COME ON!!!!</b><br/>LET...<br/>ME...<br/>IN...<br/>",
			VoiceId = "8",
			Pitch = 1,
			Speed = 1,
			Volume = 3,
			PlayTheme = "Comedy",
			Responses = {
				{
					Text = "Errr....Hello?",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "The hell's going on in Arlington Texas?<br/>(leave)",
					Type = "Close",
				},
			},
		},

		One = {
			Name = "Dia",
			Portrait = "rbxassetid://18430670940",
			Dialogue = "PLEASE... SO CLOSE... SO CLOSE...<br/><b>CAM ON ENGERLAAAND</b>",
			Responses = {
				{
					Text = "What are you <b>DOING???</b>",
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
			Name = "Dia",
			Portrait = "rbxassetid://18249911139",
			Dialogue = "<b>COME OOOOOON!</b><br/>THE 2016 TUTORIAL SAID THIS WOULD WORK!!!!",
			Responses = {
				{
					Text = "HELLOOOO?",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "Ignorant noob (Leave)",
					Type = "Close",
				},
			},
		},

		Three = {
			Name = "Dia",
			Portrait = "rbxassetid://128264162967055",
			Dialogue = "SOME 2025 TUTORIAL MENTIONED DANCING TWICE OR SOMETHING, BUT I ALWAYS KNOW THAT OLDER IS BETTER!!!!<br/><font color='#4c1c27'>MR RELIABLE!</font><br/><font color='#a20e11'>TRIED AND TRUE!</font><br/><font color='#FFFF00'>OLD BUT GOLD!</font><br/><font color='#125339'>AGED LIKE CHEESE!</font>",
			Responses = {
				{
					Text = "Old codger huh?",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "...(Leave)",
					Type = "Close",
				},
			},
		},

		Four = {
			Name = "Dia",
			Portrait = "rbxassetid://11125881651",
			Dialogue = "MAYBE I CAN:<br/>-DECREMENT ITS T-SHIRT ID TO GET THE TEMPLATE,<br/>-SAVE AND UPLOAD AS MY OWN T-SHIRT,<br/>-PROFIT?",
			Responses = {
				{
					Text = "Impossible.<br/>VIP doors checks asset ID.",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = "(Why you still listening<br/>to this person?(Leave)",
					Type = "Close",
				},
			},
		},

		Five = {
			Name = "???",
			Portrait = "rbxassetid://14326109363",
			Dialogue = "THE VIP SHIRT IS CALLED <b>Rebels Over Lads</b>... MAYBE.. JUST MAYBE..",
			Responses = {
				{
					Text = "(Leave, too far gone)",
					Type = "Close",
				},
				{
					Text = "<--------",
					Type = "Close",
				},
			},
		},
	},
}
