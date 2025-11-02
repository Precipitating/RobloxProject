local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local GeneralRemotes = ReplicatedStorage.Remotes
local function HasSpine()
	local done = GeneralRemotes.ConsumeTool:InvokeServer("Spine", 1)

	if not done then
		return {
			Name = `"Red"`,
			Portrait = "rbxassetid://9657742673",
			Dialogue = "YOU HAVE SPINE?<br/>OR NOT.",
			VoiceId = "9",
			Pitch = -6,
			Speed = 1,
			Volume = 3,
			PlayTheme = "Creepy",
			Responses = {
				{
					Text = "WHERE ARE THEY?",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "No",
					Type = "Close",
				},
			},
		}
	else
		return {
			Name = `"Red"`,
			Portrait = "rbxassetid://9657742673",
			Dialogue = "YOU HAVE SPINE?<br/>OR NOT.",
			VoiceId = "9",
			Pitch = -6,
			Speed = 1,
			Volume = 1,
			PlayTheme = "Creepy",
			Responses = {
				{
					Text = "YEP SCRAM NOW!",
					Type = "NextMessage",
					NextId = "Completed",
				},
				{
					Text = "YESSSSSS",
					Type = "NextMessage",
					NextId = "Completed",
				},
			},
		}
	end
end

return {
	Nodes = {
		FrankensteinAccepted = HasSpine,
		One = {
			Name = `"Red"`,
			Portrait = "rbxassetid://9657742673",
			Dialogue = "LOOK AROUND.<br/>THE STREET.<br/>I STAY FOREVER.<br/>THATS FINE.",
			Responses = {
				{
					Text = "STOP SQUATTING MAN",
					Type = "Close",
				},
				{
					Text = "Grr...",
					Type = "Close",
				},
			},
		},
		Completed = {
			Name = `"Red"`,
			Portrait = "rbxassetid://11718051017",
			Dialogue = "EXCELLENT.<br/>I INSTALL NOW.",
			Responses = {
				{
					Text = "HURRY UP",
					Type = "NextMessage",
					NextId = "Completed1",
				},
				{
					Text = "DONT MAKE A MESS",
					Type = "NextMessage",
					NextId = "Completed1",
				},
			},
		},
		Completed1 = {
			Name = `"Red"`,
			Portrait = "rbxassetid://11834063428",
			Dialogue = "...",
			PlayTheme = "SpineSong",
			PlaySound = "NeckSnap",
			Responses = {
				{
					Text = "JESUS",
					Type = "NextMessage",
					NextId = "Completed2",
				},
				{
					Text = "CHRIST",
					Type = "NextMessage",
					NextId = "Completed2",
				},
			},
		},

		Completed2 = {
			Name = `"Red"`,
			Portrait = "rbxassetid://114855323649734",
			Dialogue = "...",
			PlaySound = "NeckSnap",
			Responses = {
				{
					Text = "ITS STUCK HALFWAY",
					Type = "NextMessage",
					NextId = "Completed3",
				},
				{
					Text = "AHHHHHH",
					Type = "NextMessage",
					NextId = "Completed3",
				},
			},
		},
		Completed3 = {
			Name = `"Red"`,
			Portrait = "rbxassetid://10559071846",
			Dialogue = "...",
			PlaySound = "NeckSnap",
			Responses = {
				{
					Text = "DONE?",
					Type = "NextMessage",
					NextId = "Completed4",
				},
				{
					Text = "AHHHHHH",
					Type = "NextMessage",
					NextId = "Completed4",
				},
			},
		},
		Completed4 = {
			Name = `"Red"`,
			Portrait = "rbxassetid://114786539369049",
			Dialogue = "DONE.",
			Responses = {
				{
					Text = "Leave the domicile NOW!",
					Type = "NextMessage",
					NextId = "Completed5",
				},
				{
					Text = "LEAVE THEN",
					Type = "NextMessage",
					NextId = "Completed5",
				},
			},
		},

		Completed5 = {
			Name = `"Red"`,
			Portrait = "rbxassetid://133110384058077",
			Dialogue = "HAHA.<br/>YOU THINK REALLY.<br/>I AM HOUSE OF THE SPINE.<br/>I WALK NOW.<br/>LIKE I OWN THE PLACE<br/>THANKS.",
			Responses = {
				{
					Text = "*PUNCH*",
					Type = "NextMessage",
					NextId = "Completed6",
				},
				{
					Text = "*KICK*",
					Type = "NextMessage",
					NextId = "Completed6",
				},
			},
		},

		Completed6 = {
			Name = `Hellbender`,
			Portrait = "rbxassetid://11563324594",
			Dialogue = "MASSAGE NICE HAHA.<br/>I USE YOUR PC.<br/>YOUR BED TOO.<br/>YOUR TV TOO.<br/>THEN I OWN YOUR HOME.<br/>SQUATTER RIGHT FOR LIFE.<br/>HAHA.",
			Responses = {
				{
					Text = "DOESNT WORK LIEK THAT!",
					Type = "NextMessage",
					NextId = "Completed7",
				},
				{
					Text = "NOT MY PC!",
					Type = "NextMessage",
					NextId = "Completed7",
				},
			},
		},

		Completed7 = {
			Name = `JOYRIDE`,
			Portrait = "rbxassetid://9104107231",
			Dialogue = "NO ENDING.<br/>YOU NOOB.<br/>YOU REVIVED.<br/>YOU TAKE RESPONSIBILITY.<br/>YOU EASY.<br/>NEXT TIME U JOIN EXPECT ME.<br/>",
			Responses = {
				{
					Text = "YOU CAN'T DO THIS TO ME!",
					Type = "NextMessage",
					NextId = "Completed8",
				},
				{
					Text = "I SUE YOU!",
					Type = "NextMessage",
					NextId = "Completed8",
				},
			},
		},
		Completed8 = {
			Name = `"Red"`,
			Portrait = "rbxassetid://80331112835517",
			Dialogue = "ONE THING MORE!",
			Responses = {
				{
					Text = "LEAVE PLEASE",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "FrankensteinComplete",
				},
				{
					Text = "WHAT",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "FrankensteinComplete",
				},
			},
		},
	},
}
