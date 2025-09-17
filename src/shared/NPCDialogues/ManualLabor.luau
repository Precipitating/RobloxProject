return {
	Nodes = {
		ManualLabor = {
			Name = "Recruiter",
			Portrait = "rbxassetid://13881226702",
			Dialogue = "Want some quick cash?<br/>Help unload some goods from the van, and i'll pay 5 bucks per item.",
			VoiceId = "1",
			Pitch = 12,
			Speed = 1,
			Volume = 1,
			PlayTheme = "ArmyTheme",
			Responses = {
				{
					Text = "Say no more.",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "HaulJob",
				},
				{
					Text = "No.",
					Type = "Close",
				},
			},
		},
	},
}
