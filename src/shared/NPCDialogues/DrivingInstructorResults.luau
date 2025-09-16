local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local DrivingTestResults = nil

local function GetDrivingTestResults()
	DrivingTestResults = ReplicatedStorage.Remotes.DrivingInstructor.GetDrivingTestResults:InvokeServer()

	return ""
end
local function GetRedLightsPassed()
	return DrivingTestResults["RedLight"]
end

local function GetRoundaboutsFailed()
	return DrivingTestResults["Roundabout"]
end

local function GetSheepsHit()
	return DrivingTestResults["Sheep"]
end
local function HasFailed()
	return GetRedLightsPassed() > 0 or GetRoundaboutsFailed() > 0 or GetSheepsHit() > 0
end
local function ResultsDialogue()
	local result = {}
	if HasFailed() then
		result = {
			Name = "Bertha",
			Portrait = "rbxassetid://6076798179",
			Dialogue = "You have failed.<br/>Any result above 0 is an <b>AUTOMATIC</b> failure.",
			Responses = {
				{
					Text = "100% success rate it says on the wall<br/>YOU LIAR!",
					Type = "NextMessage",
					NextId = "Failed",
				},
				{
					Text = "I swear I was perfect...",
					Type = "NextMessage",
					NextId = "Failed",
				},
			},
		}
	else
		result = {
			Name = "Bertha",
			Portrait = "rbxassetid://15051569084",
			Dialogue = "You have passed.<br/>Didn't think you had it in you.",
			Responses = {
				{
					Text = "Nice congratulations there.",
					Type = "NextMessage",
					NextId = "Passed",
				},
				{
					Text = "Wow. Thanks. ",
					Type = "NextMessage",
					NextId = "Passed",
				},
			},
		}
	end

	return result
end

return {
	Nodes = {
		DrivingInstructorResults = {
			Name = "Bertha",
			Portrait = "rbxassetid://127967159186528",
			Dialogue = "Well... lets see the results on your test.",
			PlayTheme = "PrisonTheme",
			Responses = {
				{
					Text = "I'm confident.",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Forgot something.<br/>Be right back!",
					Type = "Close",
				},
			},
		},

		One = {
			Name = "Bertha",
			Portrait = "rbxassetid://15490532405",
			Dialogue = `{GetDrivingTestResults()}Here are the results that are checked during the test.<br/>Red lights passed: {GetRedLightsPassed()}<br/>Roundabouts failed: {GetRoundaboutsFailed()}<br/>Sheeps hit: {GetSheepsHit()}`,
			Responses = {
				{
					Text = "Well? is that good?",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "(Walk away, can't handle this)",
					Type = "Close",
				},
			},
		},
		Two = ResultsDialogue(),
		Passed = {
			Name = "Bertha",
			Portrait = "rbxassetid://77534133277449",
			Dialogue = "Relax.<br/>100% success rate poster on the wall for a reason.<br/>I am confident in my ability to teach, and I knew I could turn you into the real deal.",
			Responses = {
				{
					Text = "...Right.",
					Type = "NextMessage",
					NextId = "Passed1",
				},
				{
					Text = "...Sure.",
					Type = "NextMessage",
					NextId = "Passed1",
				},
			},
		},
		Passed1 = {
			Name = "Bertha",
			Portrait = "rbxassetid://6076798179",
			Dialogue = "Anyways, here's the driving license.<br/>Take the Robin Reliant as well, a gift to celebrate this occasion.<br/>Enjoy.",
			Responses = {
				{
					Text = "(Take & move at haste)",
					Type = "Close",
					ExecuteScenarioEvent = "DrivingTestPassed",
				},
				{
					Text = "(Take & run away from the mood killer)",
					Type = "Close",
					ExecuteScenarioEvent = "DrivingTestPassed",
				},
			},
		},

		Failed = {
			Name = "Bertha",
			Portrait = "rbxassetid://11336258106",
			Dialogue = "Maybe more lessons would help?<br/>More T-Puzzles, more lessons.<br/>By the way there's a 1 month cooldown before you can try again.<br/>Whoops.",
			Responses = {
				{
					Text = "<b>GRRRRRRRRR</b>",
					Type = "NextMessage",
					NextId = "Failed1",
				},
				{
					Text = "Think you're funny?",
					Type = "NextMessage",
					NextId = "Failed1",
				},
			},
		},
		Failed1 = {
			Name = "Bertha",
			Portrait = "rbxassetid://12461124489",
			Dialogue = "Meanwhile you can try other means of transport to get around?<br/>99% pass rate now, thanks to you.<br/>Goodbye.",
			Responses = {
				{
					Text = "I will pass one day...<br/>I will wipe that SMIRK off your face.",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "DrivingTestFailed",
				},
				{
					Text = "...(He's lying, but I can't prove it...)",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "DrivingTestFailed",
				},
			},
		},
	},
}
