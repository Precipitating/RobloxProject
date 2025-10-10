local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Events = ReplicatedStorage.Missions.Events
local function HasCupcake()
	local found = Events.RemoveToolsEvent:InvokeServer({ "Cupcake" })

	if not found then
		return {
			Name = "Damon",
			Portrait = "rbxassetid://12951982529",
			Dialogue = "You got it yet?",
			VoiceId = "1",
			Pitch = 2,
			Speed = 1,
			Volume = 3,
			PlayTheme = "Vader",
			Responses = {
				{
					Text = "Negative",
					Type = "Close",
				},
				{
					Text = "No, sorry",
					Type = "Close",
				},
			},
		}
	else
		return {
			Name = "Damon",
			Portrait = "rbxassetid://18477198512",
			Dialogue = "I smelt it. I picked pocketed it, I devour it.",
			VoiceId = "1",
			Pitch = 2,
			Speed = 1,
			Volume = 3,
			PlayTheme = "Vader",
			Responses = {
				{
					Text = "CALM DOWN",
					Type = "NextMessage",
					NextId = "Given",
				},
				{
					Text = "OI!",
					Type = "NextMessage",
					NextId = "Given",
				},
			},
		}
	end
end

return {
	Nodes = {
		CupcakeLoverAccepted = HasCupcake,

		Given = {
			Name = "Damon",
			Portrait = "rbxassetid://71332657794263",
			Dialogue = "Mmch glunch garch glip glug brrch pssh clack",
			PlayTheme = "EatingTheme",
			Responses = {
				{
					Text = "Disgustang",
					Type = "NextMessage",
					NextId = "Given2",
				},
				{
					Text = "Spitting bars..?",
					Type = "NextMessage",
					NextId = "Given2",
				},
			},
		},
		Given2 = {
			Name = "Damon",
			Portrait = "rbxassetid://8334075874",
			Dialogue = "Crunch glunch flch glch glahh clck pssh clok",
			Responses = {
				{
					Text = "Disgustang",
					Type = "NextMessage",
					NextId = "Given3",
				},
				{
					Text = "Spitting bars..?",
					Type = "NextMessage",
					NextId = "Given3",
				},
			},
		},
		Given3 = {
			Name = "Damon",
			Portrait = "rbxassetid://4974864583",
			Dialogue = "Mmp mmf chrk krk mmph slrp glp nmm chrk mmf glrk shlp mmph crnch mmm",
			Responses = {
				{
					Text = "HOW LONG?",
					Type = "NextMessage",
					NextId = "Warning",
				},
				{
					Text = "ITS A SMALL CUPCAKE",
					Type = "NextMessage",
					NextId = "Warning",
				},
			},
		},
		Warning = {
			Name = "Damon",
			Portrait = "rbxassetid://9945117121",
			Dialogue = "... Oh god... turn down your volume, its coming.. ohhhhhh...",
			Responses = {
				{
					Text = "What?",
					Type = "NextMessage",
					NextId = "Given4",
				},
				{
					Text = "...",
					Type = "NextMessage",
					NextId = "Given4",
				},
			},
		},
		Given4 = {
			Name = "Damon",
			Portrait = "rbxassetid://14762762139",
			Dialogue = "...",
			PlaySound = "LongBurp",
			Responses = {
				{
					Text = "AAAHHHH",
					Type = "NextMessage",
					NextId = "Given5",
				},
				{
					Text = "####### ###",
					Type = "NextMessage",
					NextId = "Given5",
				},
			},
		},
		Given5 = {
			Name = "Damon",
			Portrait = "rbxassetid://7278205582",
			Dialogue = "...",
			PlaySound = "LongFart",
			Responses = {
				{
					Text = "*GAG*",
					Type = "NextMessage",
					NextId = "Given6",
				},
				{
					Text = "UUUUAAH",
					Type = "NextMessage",
					NextId = "Given6",
				},
			},
		},

		Given6 = {
			Name = "Damon",
			Portrait = "rbxassetid://17342156854",
			Dialogue = "YEAAAAAAAAAAAAAAAUUUUUUPPP",
			Responses = {
				{
					Text = "You are FOUL",
					Type = "NextMessage",
					NextId = "Given7",
				},
				{
					Text = "JESUS... CHRIST...",
					Type = "NextMessage",
					NextId = "Given7",
				},
			},
		},

		Given7 = {
			Name = "Damon",
			Portrait = "rbxassetid://23735436",
			Dialogue = "Thanks for that, peasant!",
			Responses = {
				{
					Text = "So what do I get?",
					Type = "NextMessage",
					NextId = "Given8",
				},
				{
					Text = "Reward. NOW!",
					Type = "NextMessage",
					NextId = "Given8",
				},
			},
		},
		Given8 = {
			Name = "Damon",
			Portrait = "rbxassetid://131567274935529",
			Dialogue = "Who said that you were promised a reward?<br/>I'm a famous dev, I naturally command you, peasant.",
			Responses = {
				{
					Text = "You will pay...",
					Type = "NextMessage",
					NextId = "Given9",
				},
				{
					Text = "GRRRRRRRRR",
					Type = "NextMessage",
					NextId = "Given9",
				},
			},
		},
		Given9 = {
			Name = "Damon",
			Portrait = "rbxassetid://8991722426",
			Dialogue = "What you gonna do about it?",
			Responses = {
				{
					Text = "Expose you on RoTube.",
					Type = "NextMessage",
					NextId = "Given10",
				},
				{
					Text = "Recorded you, it's over.",
					Type = "NextMessage",
					NextId = "Given10",
				},
			},
		},

		Given10 = {
			Name = "Damon",
			Portrait = "rbxassetid://116567767903562",
			Dialogue = "Not on my watch... :Spawn R2DLordPumpkinBoss",
			Responses = {
				{
					Text = "Wha?",
					Type = "Close",
					ExecuteScenarioEvent = "R2DPumpkinBoss",
				},
				{
					Text = "?????",
					Type = "Close",
					ExecuteScenarioEvent = "R2DPumpkinBoss",
				},
			},
		},
	},
}
