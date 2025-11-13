local StarterPlayer = game:GetService("StarterPlayer")
local CameraTool = require(StarterPlayer.StarterPlayerScripts.Client.NPCs.Photographer.CameraTool)
local FailDialogue = {
	"What is this bro?",
	"What im I looking at?",
	"Gnarly dude...",
	"Bruh...",
}
local Nodes = {}
local function Done()
	if CameraTool.ShotsLeft() >= 0 then
		return {
			Name = "???",
			Portrait = "rbxassetid://8474920817",
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
			Portrait = "rbxassetid://8474920817",
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
	local photosList = CameraTool.GetCorrectPhotos()
	local size = #photosList
	local idx = 1

	-- no correct
	if size == 0 then
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
		if idx + 1 > size then
			-- last entry before fail check
			Nodes[`Correct{tostring(idx)}`] = {
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
		else
			Nodes[`Correct{tostring(idx)}`] = {
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
		if idx == #photosList then
			Nodes[{ `Fail{idx}` }] = {
				Name = "???",
				Portrait = decalId,
				Dialogue = FailDialogue[math.random(1, #FailDialogue)],
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
		Nodes[{ `Fail{idx}` }] = {
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
					Type = "CloseCutscene",
				},
				{
					Text = "WHY DO I NEED TO CENTER IT?<br/>LEARN TO SCRIPT!!!",
					Type = "CloseCutscene",
				},
			},
		}
	else
		return {
			Name = "???",
			Portrait = "rbxassetid://16909037668",
			Dialogue = "YOU DID IT! I WILL DESTROY YOUR PHOTO AND I GET PAID WELL! HORAAY!",
			Responses = {
				{
					Text = "Good, I am pro photographer.",
					Type = "CloseCutscene",
				},
				{
					Text = "Wait you get paid...?",
					Type = "CloseCutscene",
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
