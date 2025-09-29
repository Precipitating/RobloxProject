local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
return {
	Nodes = {
		BosnianDad = {
			Name = "???",
			Portrait = "rbxassetid://13643869126",
			Dialogue = "Oi brate, want a really good deal?",
			VoiceId = "1",
			Pitch = -5,
			Speed = 1,
			Volume = 3,
			PlayTheme = "BosniaTheme",
			Responses = {
				{
					Text = "Did I hear good deal?",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "(Scoot past)",
					Type = "Close",
				},
			},
		},
		One = {
			Name = "???",
			Portrait = "rbxassetid://11123669394",
			Dialogue = "See that amazing laptop right there?<br/>All yours for £1000",
			Responses = {
				{
					Text = "Bro... screen's cracked...",
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
			Name = "???",
			Portrait = "rbxassetid://9412043399",
			Dialogue = "Sestro, it's a wallpaper I set, trust me, it's the deal of your life, check out the specs:<br/>5090 59003DX MONSTERTOP 128TB RAM DDR6 1 PETABYTE M.2.",
			Responses = {
				{
					Text = "Wait... that's a good deal...",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "Hollup...",
					Type = "NextMessage",
					NextId = "Three",
				},
			},
		},
		Three = {
			Name = "???",
			Portrait = "rbxassetid://5842992746",
			Dialogue = "Exactly my friend, you want it or not?",
			Responses = {
				{
					Text = "£200.",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "£300",
					Type = "NextMessage",
					NextId = "Four",
				},
			},
		},
		Four = {
			Name = "???",
			Portrait = "rbxassetid://111303002257639",
			Dialogue = "Are you kidding man?<br/>This is the best deal ever, and you want even lower?<br/>The only reason i'm selling this cheap is because i'm just £500 short for the rare clan point hat at the auction.<br/>Ajde covjece...",
			Responses = {
				{
					Text = "£500",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = "£500",
					Type = "NextMessage",
					NextId = "Five",
				},
			},
		},
		Five = function()
			local currentCash = ReplicatedStorage.Remotes.GetCurrentMoney:InvokeServer()
			if currentCash >= 500 then
				return {
					Name = "???",
					Portrait = "rbxassetid://6848487743",
					Dialogue = "Deal.<br/>Pleasure doing business with you. ",
					Responses = {
						{
							Text = "(This guy sounds like<br/>someone I know...)",
							Type = "Close",
							ExecuteScenarioEvent = "BosnianScammed",
							ReduceMoney = 500,
						},
						{
							Text = "(Not for me anyway, same specs too)",
							Type = "Close",
							ExecuteScenarioEvent = "BosnianScammed",
							ReduceMoney = 500,
						},
					},
				}
			else
				return {
					Name = "???",
					Portrait = "rbxassetid://6848487743",
					Dialogue = "You can't afford it... stop wasting my time...",
					Responses = {
						{
							Text = "Doh!",
							Type = "Close",
						},
						{
							Text = "Dang.",
							Type = "Close",
						},
					},
				}
			end
		end,
	},
}
