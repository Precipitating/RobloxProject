return {
	Nodes = {
		CashierDoctor = {
			Name = "Asylum Doctor",
			Portrait = "rbxassetid://1710521885",
			Dialogue = "Stay away from the door, you freak!",
			VoiceId = 5,
			Pitch = 1,
			Speed = 1,
			Volume = 3,
			PlayTheme = "Gloomy",
			Responses = {
				{
					Text = "WHY IM I HERE? <br/> WHAT IS GOING ON?",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Y-yes",
					Type = "Close",
				},
			},
		},

		One = {
			Name = "Asylum Doctor",
			Portrait = "rbxassetid://214531076",
			Dialogue = "Stop the jokes, you know what you did, you <b>MONSTER!</b>",
			Volume = 1,
			Responses = {
				{
					Text = "WHAT DID I DO???",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "I'M INNOCENT!<br/>THIS HAS TO BE A MISUNDERSTANDING!",
					Type = "NextMessage",
					NextId = "Two",
				},
			},
		},

		Two = {
			Name = "Asylum Doctor",
			Portrait = "rbxassetid://37700586",
			Dialogue = "You are the reason why the people in the room are like that. They became deranged <b>FREAKS!</b>",
			Volume = 1,
			Responses = {
				{
					Text = "IT WASN'T ME I SWEAR!",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "I WAS HJACKED!",
					Type = "NextMessage",
					NextId = "Three",
				},
			},
		},

		Three = {
			Name = "Asylum Doctor",
			Portrait = "rbxassetid://129477426868033",
			Dialogue = "You were terrorizing Junction Street, whispering into people's ears, turning them into braindead numeral robots.<br/>Whatever you whispered, is akin to the devil's breath.",
			Responses = {
				{
					Text = "IT WAS SHAYDEN WILLIAMS I SWEAR!",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "BELIEVE ME, IT WASN'T ME! SHAYDEN DID IT!",
					Type = "NextMessage",
					NextId = "Four",
				},
			},
		},
		Four = {
			Name = "Asylum Doctor",
			Portrait = "rbxassetid://8991722426",
			Dialogue = "You expect me to believe that depressed cashier from <i>Rebelism Essentials</i> is responsible for your actions?<br/>Do me a favour and stay contained in there - <b>FOREVER</b>",
			Responses = {
				{
					Text = "WAIT PLEASE SIR... SIR?.... SIR!",
					Type = "NextMessage",
					NextId = "End",
				},
				{
					Text = "BELIEVE ME, IT WASN'T ME! SHAYDEN DID IT!",
					Type = "NextMessage",
					NextId = "End",
				},
			},
		},

		End = {
			Name = "Asylum Doctor",
			Portrait = "rbxassetid://11163990252",
			Dialogue = "Goodbye forever, you ruthless beast!",
			Responses = {
				{
					Text = "SHAAAAYDEEEEEEEEEENNNNNNN!!!",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "CashierAngerEnd",
				},
				{
					Text = "NOOOOOOOOOOOOOOOOOOOOOOOOOO",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "CashierAngerEnd",
				},
			},
		},
	},
}
