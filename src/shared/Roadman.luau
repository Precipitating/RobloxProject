return {
	["Roadman"] = {
		Name = "Roadman",
		Portrait = "rbxassetid://15375763382",
		Dialogue = "Oi wagwan bruv what you looking at mate? i'll ching ya",
		Responses = {
			{
				Text = "You look dodgy as pal.",
				Type = "NextMessage",
				NextDialogue = {
					Name = "Angry Roadman",
					Portrait = "rbxassetid://16802505162",
					Dialogue = "FINK UR FUNNY MATE... THIS ZOMBIE KNOIF AINT MUCKING AROUND... ONE MORE WORD.. I DARE YAH BRAV. ",
					Responses = {
						{
							Text = "Calm down sir please it was a joke please don't hurt me",
							Type = "NextMessage",
							NextDialogue = {
								Name = "Arrogant Roadman",
								Portrait = "rbxassetid://94016123678494",
								Dialogue = "Exactly mate... code brown on your joggy bottoms is it? scurry off little boy.",
								Responses = {
									{
										Text = "I swear that's chocolate.",
										Type = "Close",
									},
									{
										Text = "Bruh",
										Type = "Close",
									},
								},
							},
						},
						{
							Text = "*throws PG Tip teabags into his face*",
							Type = "NextMessage",
							NextDialogue = {
								Name = "Esteemed Gentlemen",
								Portrait = "rbxassetid://87797218754881",
								Dialogue = "AHHGUUUHadddaahhhhh... Oh dear, my throat is parched, I give my thanks to you kind sir, as this beverage you call a PG Tip is quenching my thirst. All is foul and foul is fair. Macbeth says: Look! I see your under where! ",
								Responses = {
									{
										Text = "... Jesus these brits are OFF it.",
										Type = "Close",
									},
									{
										Text = "Look behind you! there's a jammy dodger!",
										Type = "Close",
									},
								},
							},
						},
					},
				},
			},
			{
				Text = "N-nothing s-sir a-aha!",
				Type = "Close",
			},
		},
	},
}
