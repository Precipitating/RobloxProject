return {
	Nodes = {
		RoadmanAccepted = {
			Name = "Esteemed GentleMAN?",
			Portrait = "rbxassetid://11640689559",
			Dialogue = "Bruv, you’re movin’ like a <font color='#FF7800'>wasteman</font> — man should be out there skimmin' a burner for me",
			VoiceId = "1",
			Pitch = 7,
			Speed = 2,
			Volume = 3,
			PlayTheme = "RoadmanTune",
			Responses = {
				{
					Text = "What happened to your voice?",
					Type = "NextMessage",
					NextId = "BritishHighClass",
				},
				{
					Text = "I forgor...",
					Type = "Close",
				},
			},
		},

		BritishHighClass = {
			Name = "British High-Class",
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			Portrait = "rbxassetid://10246439168",
			PlayTheme = "PoshTheme",
			Dialogue = "Ahem. The game bugged my friend. Acquire the communications device and I will give you a PC.<br/><b>Ecks Dee</b> as you kids say.",
			Responses = {
				{
					Text = "SIR YES SIR!",
					Type = "Close",
				},
				{
					Text = "What in the Harvey Dent",
					Type = "Close",
				},
			},
		},
	},
}
