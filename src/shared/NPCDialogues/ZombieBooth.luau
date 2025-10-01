return {
	Nodes = {
		ZombieBooth = {
			Name = "Zombie Recruiter",
			Portrait = "rbxassetid://2121208",
			Dialogue = "SURVIVE.A.WAVE.£5.PER.BRETHEN",
			VoiceId = "1",
			Pitch = -12,
			Speed = 1,
			Volume = 1,
			PlayTheme = "Gloomy",
			Responses = {
				{
					Text = "...Money money money",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "ZombieJob",
				},
				{
					Text = "NO AHHHHHHH",
					Type = "Close",
				},
			},
		},
	},
}
