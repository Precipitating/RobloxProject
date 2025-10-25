return {
	Nodes = {
		TrashPickup = {
			Name = "Recruiter",
			Portrait = "rbxassetid://1169328873",
			Dialogue = "Want to take a load off the juvenile's back?<br/>Pick some trash outside and i'll pay chum-chums per load.",
			VoiceId = "1",
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "ArmyTheme",
			Responses = {
				{
					Text = "Give me that chum!<br/>(£10 per pickup)",
					Type = "Close",
					ExecuteScenarioEvent = "TrashPickup",
				},
				{
					Text = "Let them do their punishment!",
					Type = "Close",
				},
			},
		},
	},
}
