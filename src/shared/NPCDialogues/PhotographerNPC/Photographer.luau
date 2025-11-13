return {
	Nodes = {
		Photographer = {
			Name = "???",
			Portrait = "rbxassetid://8474920817",
			Dialogue = "...",
			VoiceId = "3",
			Pitch = 4,
			Speed = 1,
			Volume = 1,
			PlayTheme = "Eerie",
			PlaySound = "CameraFlash",
			Responses = {
				{
					Text = "DID YOU TAKE A PIC OF ME?",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Fast walk past",
					Type = "Close",
				},
			},
		},

		One = {
			Name = "???",
			Portrait = "rbxassetid://15010779943",
			Dialogue = "Do we a problem dawg?",
			Responses = {
				{
					Text = "YOU HAVE NO PERMISSION!",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "N-no. B-bye.",
					Type = "Close",
				},
			},
		},
		Two = {
			Name = "???",
			Portrait = "rbxassetid://1438884354",
			Dialogue = "Broski, this is a public area.<br/>I can do what I want, when I want.",
			Responses = {
				{
					Text = "I CALL POLICE!",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "STILL...",
					Type = "NextMessage",
					NextId = "Three",
				},
			},
		},

		Three = {
			Name = "???",
			Portrait = "rbxassetid://7713734956",
			Dialogue = "Nothing you can do bro-cha-cho.<br/>I'm an auditer, a photographer, a paparazzi, and a winner.<br/>WHATSITTOYAH?",
			Responses = {
				{
					Text = "I'm not famous...",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "Why did you take a PICTURE OF ME?",
					Type = "NextMessage",
					NextId = "Four",
				},
			},
		},

		Four = {
			Name = `???"`,
			Portrait = "rbxassetid://75936727404849",
			Dialogue = "Just doing some freelance for Roogle Maps yah know?<br/>That yellow homie you use for 3D view? i'm responsible for this street, bruh.<br/>You just happened to be in my way.",
			Responses = {
				{
					Text = "Take another picture<br/>without me then...",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = `They use vans, "bruh"`,
					Type = "NextMessage",
					NextId = "Five",
				},
			},
		},
		Five = {
			Name = `???"`,
			Portrait = "rbxassetid://15646082847",
			Dialogue = "First things first cuh, i'm using an instant camera, so I have limited shots available.<br/>Secondly, they can't use vans due to how high this place is to reach.<br/>Keep up, Trackstar.",
			Responses = {
				{
					Text = "Don't care, remove it.",
					Type = "NextMessage",
					NextId = "Six",
				},
				{
					Text = "Should've been prepared.",
					Type = "NextMessage",
					NextId = "Six",
				},
			},
		},
		Six = {
			Name = `???"`,
			Portrait = "rbxassetid://1592626808",
			Dialogue = "Theres only 5 shots left.<br/> Tell you what, if you do my job and take 5 shots of a list of things, I will destroy the photo of you.",
			Responses = {
				{
					Text = "Fine.",
					Type = "NextMessage",
					NextId = "Seven",
				},
				{
					Text = "Nevermind, I enjoy the fame.",
					Type = "Close",
				},
			},
		},
		Seven = {
			Name = `???"`,
			Portrait = "rbxassetid://5055375402",
			Dialogue = "Excellent, take my camera and take a picture of:<br/>The Ginger Man Portrait<br/>A Dancing Geeza<br/>Amy<br/>Homeless Guy<br/>Whodunnit Guy<br/>Make sure it's centered and not too far away.",
			Responses = {
				{
					Text = "You better delete it.",
					Type = "Close",
					ExecuteScenarioEvent = "PhotoJob",
					SetDialogueFile = { PhotographerNameTag = "PhotographerAccepted" },
				},
				{
					Text = "Easy",
					Type = "Close",
					SetDialogueFile = { PhotographerNameTag = "PhotographerAccepted" },
				},
			},
		},
	},
}
