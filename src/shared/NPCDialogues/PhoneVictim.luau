return {
	["PhoneVictim"] = {
		Name = "Jack",
		Portrait = "rbxassetid://1228431715",
		Dialogue = "ROBLOX does not give a- Oh, what do you want, i'm livestreaming here!",
		VoiceId = 3,
		Pitch = 3,
		Speed = 1,
		Volume = 1,
		PlayTheme = "Santa",
		Responses = {
			{
				Text = "Nice Nokia Brick.",
				Type = "NextMessage",
				ForceEquip = "Skeng",
				NextDialogue = {
					Name = "Jack (smirking)",
					Portrait = "rbxassetid://14851941873",
					Dialogue = "Thanks pal, however, is that all you've come here to say?",
					Responses = {
						{
							Text = "Give it. Now.",
							Type = "NextMessage",
							NextDialogue = {
								Name = "Scared Jack",
								Portrait = "rbxassetid://4954505630",
								Pitch = -6,
								Speed = 1.5,
								Volume = 3,
								Dialogue = "WHAT IN THE DIDDLY HUNKY DORY HECKINGTON IS THAT MONSTER? TAKE IT. DON'T HURT ME PLEASE!",
								PlayTheme = "Toilet",
								Responses = {
									{
										DestroyObject = { "PhoneVictim" },
										Text = "Exactly. Simple as.",
										Type = "Close",
										ProgressMission = {
											MissionName = "StealPhone",
											ProgressVal = 1,
											TaskId = "Steal",
										},
									},
									{
										Text = "Nvm cba.",
										Type = "Close",
									},
								},
							},
						},
						{
							Text = "G-give it. o-or else",
							Type = "NextMessage",
							NextDialogue = {
								Name = "Jack.",
								Portrait = "rbxassetid://7069589164",
								Pitch = -12,
								Speed = 1,
								Volume = 3,
								Dialogue = "You really thought you could steal my phone with that confidence. Heh. You little, little boy. You know what they called me back then? The Beast Of Last Christmas. Why? GRAH-GRUH-RAAAUR-FUAAARRRR-GRAAAAH-SAAAAAAH-FAAAH. How about this. Give me YOUR PHONE, NOW!",
								PlayTheme = "Scary",
								Responses = {
									{
										Text = "Cry & Forfeit",
										Type = "NextMessage",
										NextDialogue = {
											Name = "???",
											Portrait = "rbxassetid://11125881651",
											Dialogue = "EXACTLY LITTLE BOY, GIVE ME ALL YOUR BELONGINGS AS WELL OR IM ABOUT TO UNLEASH THE BEAST OF CURRENT CHRISTMAS",
											Responses = {
												{
													Text = "Ya-yamete.",
													DestroyObject = { "PhoneVictim" },
													ExecuteScenarioEvent = "RoadmanMugged",
													Type = "Close",
												},
												{
													Text = "SIR YES SIR",
													DestroyObject = { "PhoneVictim" },
													ExecuteScenarioEvent = "RoadmanMugged",
													Type = "Close",
												},
											},
										},
									},
									{
										Text = "(It's over bud)",
										Type = "Close",
										DestroyObject = { "PhoneVictim" },
										ExecuteScenarioEvent = "RoadmanMugged",
									},
								},
							},
						},
					},
				},
			},
			{
				Text = "I can only see menu chats.",
				Type = "Close",
			},
		},
	},
}
