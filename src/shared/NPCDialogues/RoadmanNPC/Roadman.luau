return {
	Nodes = {
		Roadman = {
			Name = "Roadman",
			Portrait = "rbxassetid://15375763382",
			Dialogue = "Oi wagwan <b>bruv</b> what you looking at mate?<br/>I'll <font color='#e22f1e'><b>ching</b></font> ya.",
			VoiceId = "1",
			Pitch = 3,
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
			Dialogue = "FINK UR <b>FUNNY</b> MATE...<br/>THIS <font color='#118349'><b>ZOMBIE KNOIF</b></font> AINT MUCKING AROUND...<br/>ONE MORE WORD..<br/>I DARE YAH BRAV.",
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
			Dialogue = "Exactly mate...<br/>Code brown on your joggy bottoms is it?<br/>Scurry off you muppet.",
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
			Dialogue = [[AUGHBRAHUUNG... Oh dear, my throat is <b>parched</b>.<br/>I give my thanks to you kind sir, as this beverage you call a <b><font color='#5ad976'>PG Tip</font></b> is quenching my thirst.<br/><i>All is foul and foul is fair</i>.<br/><i>Cat in the adage.</i><br/><i>Succulent Chinese Meal</i>.<br/><font color='#000000'>Divorced</font>, <font color='#e22f1e'>Beheaded</font>, <font color='#5c3a31'>Died</font>, <font color='#000000'>Divorced</font>, <font color='#e22f1e'>Beheaded</font>, <font color='#118349'>Survived.</font>]],
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
			Dialogue = "Speaking of our Lord, dear chap, do take this finely crafted instrument and, under the most virtuous pretence of feeding the little ones, discreetly acquire some poor wretch’s mobile telephone.<br/>A <b>noble</b> cause cloaked in necessity - how thoroughly spendid!",
			Responses = {
				{
					Text = "Sir yes sir!",
					Type = "Close",
					UnlockMission = "StealPhone",
					GiveTool = { "Skeng", true },
					SetMeshVisibility = { { RoadmanKnife = false } },
					SetDialogueFile = { RoadmanNameTag = "RoadmanAccepted" },
				},
				{
					Text = "Hell naw",
					Type = "Close",
				},
			},
		},
	},
}
