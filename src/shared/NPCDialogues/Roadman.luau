return {
	Nodes = {
		Roadman = {
			Name = "Roadman",
			Portrait = "rbxassetid://15375763382",
			Dialogue = "Oi wagwan bruv what you looking at mate? i'll ching ya",
			Pitch = 12,
			Speed = 2,
			Volume = 3,
			PlayTheme = "RoadmanTune",
			Responses = {
				{
					Text = "You look dodgy as pal.",
					Type = "NextMessage",
					NextId = "AngryRoadman",
				},
				{
					Text = "N-nothing s-sir a-aha!",
					Type = "Close",
				},
			},
		},

		AngryRoadman = {
			Name = "Angry Roadman",
			Portrait = "rbxassetid://16802505162",
			Dialogue = "FINK UR FUNNY MATE... THIS ZOMBIE KNOIF AINT MUCKING AROUND... ONE MORE WORD.. I DARE YAH BRAV. ",
			Responses = {
				{
					Text = "S-sorry s-sir",
					Type = "NextMessage",
					NextId = "ArrogantRoadman",
				},
				{
					Text = "*throws PG Tip*",
					Type = "NextMessage",
					NextId = "EsteemedGentlemenPG",
				},
			},
		},

		ArrogantRoadman = {
			Name = "Arrogant Roadman",
			Portrait = "rbxassetid://94016123678494",
			Dialogue = "Exactly mate... code brown on your joggy bottoms is it? scurry off you muppet",
			Responses = {
				{
					Text = "I swear that's chocolate.",
					Type = "Close",
				},
				{
					Text = "Ya got me..",
					Type = "Close",
				},
			},
		},

		EsteemedGentlemenPG = {
			Name = "Esteemed Gentlemen",
			Portrait = "rbxassetid://87797218754881",
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "PoshTheme",
			Dialogue = [[AUGHBRAHUUNG... Oh dear, my throat is parched, I give my thanks to you kind sir, as this beverage you call a PG Tip is quenching my thirst. All is foul and foul is fair. Cat in the adage. Succulent Chinese Meal. Divorced, Beheaded, Died, Divorced, Beheaded, Survived.]],
			Responses = {
				{
					Text = "... Jesus christ",
					Type = "NextMessage",
					NextId = "EsteemedGentlemenMission",
				},
				{
					Text = "Run",
					Type = "Close",
				},
			},
		},

		EsteemedGentlemenMission = {
			Name = "Esteemed Gentlemen",
			Portrait = "rbxassetid://6196108971",
			Dialogue = "Speaking of our Lord, dear chap, do take this finely crafted instrument and, under the most virtuous pretence of feeding the little ones, discreetly acquire some poor wretch’s mobile telephone. A noble cause cloaked in necessity - how thoroughly spendid!",
			Responses = {
				{
					Text = "Sir yes sir!",
					Type = "Close",
					UnlockMission = "StealPhone",
					GiveTool = "Skeng",
					SetMeshVisibility = { { RoadmanKnife = false } },
					SetDialogueFile = { { RoadmanNameTag = "RoadmanAccepted" } },
				},
				{
					Text = "Hell naw",
					Type = "Close",
				},
			},
		},
	},
}
