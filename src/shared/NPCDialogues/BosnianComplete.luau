return {
	Nodes = {
		BosnianComplete = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://12817163905",
			Dialogue = "I smell a fresh laptop nearby...",
			VoiceId = "1",
			Pitch = 5,
			Speed = 1,
			Volume = 3,
			PlayTheme = "BosniaTheme",
			Responses = {
				{
					Text = "You may be correct.",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Yeah for me, bye!",
					Type = "Close",
				},
			},
		},
		One = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://6982510374",
			Dialogue = "F-for me dobar građanin?",
			Responses = {
				{
					Text = "You may be correct.",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "No, sayanora.",
					Type = "Close",
				},
			},
		},
		Two = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://83476883704798",
			Dialogue = "THANK YOU SO MUCH MY PRIJATELJU<br/>THANK YOU SO MUCH<br/>THANK YOU SO MUCH<br/>THANK YOU SO MUCH<br/>THANK YOU SO MUCH<br/>THANK YOU SO MUCH<br/>",
			Responses = {
				{
					Text = "Enjoy.<br/>Not expecting any reward.<br/>Just spent my life savings.<br/>No big deal though...<br/>NO BIG DEAL THOUGH......",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "So, do I get anything?",
					Type = "NextMessage",
					NextId = "Three",
				},
			},
		},
		Three = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://5842992746",
			Dialogue = "Wait, you were expecting a reward for a charitable cause..?<br/>My friend, you do know i live in the dumps, you know what street that is right?",
			Responses = {
				{
					Text = "I was expecting, you know, an ending..?",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "A free badge maybe?",
					Type = "NextMessage",
					NextId = "Four",
				},
			},
		},
		Four = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://11137148488",
			Dialogue = "Are you ok my friend? What are you talking about?<br/>Gaming lingo?<br/>Can't relate since I can't run them on my trashtop.",
			Responses = {
				{
					Text = "Nothing. Just unbox and use the PC when you get home.",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = "Nuffin.",
					Type = "NextMessage",
					NextId = "Five",
				},
			},
		},
		Five = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://8300516120",
			Dialogue = "It's not much friend, but this is all I have, thank you for your charitable donation, friend!",
			Responses = {
				{
					Text = "Thx.............",
					Type = "Close",
					ExecuteScenarioEvent = "BosnianComplete",
				},
				{
					Text = "Nooo, I didn't expect any reewaaard!",
					Type = "Close",
					ExecuteScenarioEvent = "BosnianComplete",
				},
			},
		},
	},
}
