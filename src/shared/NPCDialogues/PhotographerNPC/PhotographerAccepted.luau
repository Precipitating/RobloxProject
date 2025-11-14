local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local StarterPlayer = game:GetService("StarterPlayer")
local InitializeToolModule = require(StarterPlayer.StarterPlayerScripts.Client.InitializeGUI.InitializeToolModule)
local CameraTool = require(StarterPlayer.StarterPlayerScripts.Client.NPCs.Photographer.CameraTool)
local Events = ReplicatedStorage.Missions.Events
local FailDialogue = {
	"What is this bro?",
	"What im I looking at?",
	"Sir this isn't what I wanted...",
	"Bruh this isn't the target...",
	"Huh?",
}
local Nodes = {}
local RNG = Random.new()
local function Done()
	if CameraTool.ShotsLeft() > 0 then
		return {
			Name = "???",
			Portrait = "rbxassetid://18434768340",
			Dialogue = "Done or what?",
			VoiceId = "3",
			Pitch = 4,
			Speed = 1,
			Volume = 1,
			PlayTheme = "Eerie",
			Responses = {
				{
					Text = "No",
					Type = "Close",
				},
				{
					Text = "Nay",
					Type = "Close",
				},
			},
		}
	else
		return {
			Name = "???",
			Portrait = "rbxassetid://18434768340",
			Dialogue = "Done or what?",
			VoiceId = "3",
			Pitch = 4,
			Speed = 1,
			Volume = 1,
			PlayTheme = "Eerie",
			Responses = {
				{
					Text = "Yes",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Nay",
					Type = "Close",
				},
			},
		}
	end
end

local function ProcessCorrectPhotos()
	InitializeToolModule.DisconnectAll("Camera")
	Events.RemoveToolsEvent:InvokeServer({ "Camera" })
	local photosList = CameraTool.GetCorrectPhotos()
	local correctPhotosCount = CameraTool.CorrectPhotosCount()
	local idx = 1
	-- none correct
	if correctPhotosCount == 0 then
		Nodes["NoCorrect"] = {
			Name = "???",
			Portrait = "rbxassetid://6568954064",
			Dialogue = "No successful photos taken, bruh.",
			Responses = {
				{
					Text = "...",
					Type = "NextMessage",
					NextId = `ProcessFail`,
				},
				{
					Text = "...",
					Type = "NextMessage",
					NextId = `ProcessFail`,
				},
			},
		}
		return Nodes["NoCorrect"]
	end
	-- create dialogue for each correct
	for _, photoData in pairs(photosList) do
		if idx + 1 > correctPhotosCount then
			-- last entry before fail check
			Nodes[`Correct{idx}`] = {
				Name = "???",
				Portrait = photoData.Id,
				Dialogue = photoData.Text,
				Responses = {
					{
						Text = "...",
						Type = "NextMessage",
						NextId = `ProcessFail`,
					},
					{
						Text = "...",
						Type = "NextMessage",
						NextId = `ProcessFail`,
					},
				},
			}
			break
		else
			Nodes[`Correct{idx}`] = {
				Name = "???",
				Portrait = photoData.Id,
				Dialogue = photoData.Text,
				Responses = {
					{
						Text = "...",
						Type = "NextMessage",
						NextId = `Correct{tostring(idx + 1)}`,
					},
					{
						Text = "...",
						Type = "NextMessage",
						NextId = `Correct{tostring(idx + 1)}`,
					},
				},
			}
		end
		idx += 1
	end
	return Nodes["Correct1"]
end
local function ProcessFailPhotos()
	local photosList = CameraTool.GetFailPhotoIds()
	if #photosList <= 0 then
		Nodes["NoFail"] = {
			Name = "???",
			Portrait = "rbxassetid://5264425511",
			Dialogue = "No failures, nice.",
			Responses = {
				{
					Text = "...",
					Type = "NextMessage",
					NextId = `End`,
				},
				{
					Text = "...",
					Type = "NextMessage",
					NextId = `End`,
				},
			},
		}
		return Nodes["NoFail"]
	end

	for idx, decalId in ipairs(photosList) do
		if idx >= #photosList then
			Nodes[`Fail{idx}`] = {
				Name = "???",
				Portrait = decalId,
				Dialogue = FailDialogue[RNG:NextInteger(1, #FailDialogue)],
				Responses = {
					{
						Text = "...",
						Type = "NextMessage",
						NextId = `End`,
					},
					{
						Text = "...",
						Type = "NextMessage",
						NextId = `End`,
					},
				},
			}
			break
		end
		--
		Nodes[`Fail{idx}`] = {
			Name = "???",
			Portrait = decalId,
			Dialogue = FailDialogue[math.random(1, #FailDialogue)],
			Responses = {
				{
					Text = "...",
					Type = "NextMessage",
					NextId = `Fail{idx + 1}`,
				},
				{
					Text = "...",
					Type = "NextMessage",
					NextId = `Fail{idx + 1}`,
				},
			},
		}
	end
	return Nodes["Fail1"]
end
local function ProcessEnd()
	local failed = CameraTool.CorrectPhotosCount() < 5

	if failed then
		return {
			Name = "???",
			Portrait = "rbxassetid://16909037668",
			Dialogue = "YOU FAILED, AND NOW YOUR PHOTO WILL BE ON ROOGLE MAPS, BROSKI.",
			Responses = {
				{
					Text = "NOOOOOOOOOOOOOOOOOO",
					ExecuteScenarioEvent = "PhotographerFail",
					Type = "CloseCutscene",
				},
				{
					Text = "WHY DO I NEED TO CENTER IT? LEARN TO SCRIPT!",
					ExecuteScenarioEvent = "PhotographerFail",
					Type = "CloseCutscene",
				},
			},
		}
	else
		return {
			Name = "???",
			Portrait = "rbxassetid://12934920558",
			Dialogue = "YOU DID IT! I WILL DESTROY YOUR PHOTO AND I GET PAID WELL! HORAAY!",
			Responses = {
				{
					Text = "Good, I am pro photographer.",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "PhotographerWin",
				},
				{
					Text = "Where's my cut..?",
					Type = "CloseCutscene",
					ExecuteScenarioEvent = "PhotographerWin",
				},
			},
		}
	end
end

Nodes.PhotographerAccepted = Done
Nodes.One = {
	Name = "???",
	Portrait = "rbxassetid://1571748001",
	Dialogue = "Excellent, lets go through them one by one.",
	Responses = {
		{
			Text = "...",
			Type = "NextMessage",
			NextId = "ProcessCorrect",
		},
		{
			Text = "...",
			Type = "NextMessage",
			NextId = "ProcessCorrect",
		},
	},
}
Nodes.ProcessCorrect = ProcessCorrectPhotos
Nodes.ProcessFail = ProcessFailPhotos
Nodes.End = ProcessEnd

return {
	Nodes = Nodes,
}
