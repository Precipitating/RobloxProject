return {
	Nodes = {
		DrivingInstructor = {
			Name = "Bertha",
			Portrait = "rbxassetid://5821164654",
			Dialogue = "Remember to look both ways before crossing!",
			VoiceId = "2",
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "PrisonTheme",
			Responses = {
				{
					Text = "What?",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Wrong place.",
					Type = "Close",
				},
			},
		},

		One = {
			Name = "Bertha",
			Portrait = "rbxassetid://9713418245",
			Dialogue = "Check your blind spots regulary!",
			Responses = {
				{
					Text = "Are you real?",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "(Walk away, it's a chatbot.)",
					Type = "Close",
				},
			},
		},
		Two = {
			Name = "Bertha (AI)",
			Portrait = "rbxassetid://189484244",
			Dialogue = "Yes I am AI designed to assist Driving School Init on simple matters.<br/>Please state your request, if I cannot solve it, a human will take over.",
			Responses = {
				{
					Text = "How much for a lesson?",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "(Leave, firm believer of the<br/><b>Clankless Association</b>)",
					Type = "Close",
				},
			},
		},

		Three = {
			Name = "Bertha (AI)",
			Portrait = "rbxassetid://70697563124739",
			Dialogue = "A driving lesson is a single session, or part of a course, where a person is taught the skills and knowledge needed to operate a vehicle and pass a driving test to obtain a driver's license.",
			Responses = {
				{
					Text = "I meant how MUCH",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},

		Four = {
			Name = "Bertha (AI)",
			Portrait = "rbxassetid://425210204",
			Dialogue = "The quantity of a lesson depends on the instructor's evaluation of your progress.",
			Responses = {
				{
					Text = "I MEANT HOW MUCH FOR A LESSON",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},
		Five = {
			Name = "Bertha (AI)",
			Portrait = "rbxassetid://15910139548",
			Dialogue = "What type of lesson do you require?",
			Responses = {
				{
					Text = "DRIVING. LESSON.",
					Type = "NextMessage",
					NextId = "Six",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},
		Six = {
			Name = "Bertha (AI)",
			Portrait = "rbxassetid://6175211096",
			Dialogue = "What vehicle lesson do you want to request for?<br/>Boat<br/>Car<br/>Plane<br/>Motorcycle<br/>Automatic Car<br/>Train<br/>Helicopter<br/>Let me know!",
			Responses = {
				{
					Text = "...A 4 WHEELED VEHICLE. PLEASE.",
					Type = "NextMessage",
					NextId = "Seven",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},

		Seven = {
			Name = "Bertha (AI)",
			Portrait = "rbxassetid://10560492522",
			Dialogue = "I see you have chosen a forklift license.<br/>It seems that I forgot to put that on the list!<br/>Apologies customer ID 1",
			Responses = {
				{
					Text = "...I'd like to order one million lessons.",
					Type = "NextMessage",
					NextId = "Eight",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},

		Eight = {
			Name = "Bertha (AI)",
			Portrait = "rbxassetid://190473558",
			Dialogue = ".............",
			PlaySound = "Static",
			Responses = {
				{
					Text = "....(Please work)",
					Type = "NextMessage",
					NextId = "Nine",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},
		Nine = {
			Name = "Bertha",
			Portrait = "rbxassetid://281439737",
			Dialogue = "This is Bertha speaking, how may I help you?",
			VoiceId = "2",
			Pitch = -12,
			Responses = {
				{
					Text = "One driving lesson.<br/>For a car<br/>How much?",
					Type = "NextMessage",
					NextId = "Ten",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},

		Ten = {
			Name = "Bertha",
			Portrait = "rbxassetid://749274798",
			Dialogue = "Two pentatrillion Woe-Buckaroos per lesson.<br/>No refunds.<br/>100% success rate.<br/>Worth it.­",
			Responses = {
				{
					Text = "(Ignore the absurd price and<br/>pay up quick before AI comes back)",
					Type = "NextMessage",
					NextId = "Accepted",
				},
				{
					Text = "WHAT IS THAT PRICE??<br/>IS THIS A ROBBERY?",
					Type = "NextMessage",
					NextId = "Declined",
				},
			},
		},

		Declined = {
			Name = "Bertha",
			Portrait = "rbxassetid://12592437416",
			Dialogue = "Berthatron AI activated.­",
			PlaySound = "Static",
			VoiceId = "2",
			Pitch = 1,
			Responses = {
				{
					Text = "Please no...",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Give up",
					Type = "Close",
				},
			},
		},

		Accepted = {
			Name = "Bertha",
			Portrait = "rbxassetid://134827695349525",
			Dialogue = "Excellent.<br/>By the way, this is in driving test conditions, so don't fail.<br/><b>Heh.</b>",
			Responses = {
				{
					Text = "Should be good, 100% pass rate it says.",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "DrivingTest",
				},
				{
					Text = "(Too far in to stop now)",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "DrivingTest",
				},
			},
		},
	},
}
