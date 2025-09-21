local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Events = ReplicatedStorage.Missions.Events
local NPCEvents = ReplicatedStorage.Events.NPC
local CurrentPrompt = nil
local TalkModule = {}

-- remotes
local RemoteMap = {
	UnlockMission = Events.UnlockMissionEvent,
	ProgressMission = Events.ProgressMissionEvent,
	GiveTool = Events.GiveToolEvent,
	ForceEquip = Events.ForceEquipEvent,
	RemoveTools = Events.RemoveToolsEvent,
	SetMeshVisibility = Events.SetMeshVisibilityEvent,
	SetDialogueFile = Events.SetDialogueFileEvent,
	DestroyObject = Events.DestroyObjectEvent,
	ExecuteScenarioEvent = Events.ExecuteScenarioEvent,
}

-- npc
local PauseNPCMovement = NPCEvents.PauseNPCMovement
local moveableNPCName = nil
local CanTalk = true

-- modules
local ClientHelperFunctions = require(script.Parent.ClientHelperFunctions)
local MissionsClientHandler = require(script.Parent.MissionsClientHandler)
local MovementModule = require(script.Parent:WaitForChild("MovementHandler"))
local TextToSpeech = require(ReplicatedStorage.TextToSpeech)
local SoundModule = require(script.Parent:WaitForChild("SoundModule"))

-- ui
local ui = Player.PlayerGui.NPCChatSystem:WaitForChild("ChatUI")
local frame = ui:WaitForChild("DialogueFrame")
local nameLabel = frame:WaitForChild("NameLabel")
local portrait = frame:WaitForChild("Portrait")
local dialogueText = frame:WaitForChild("DialogueText")
local btn1 = frame.ButtonHolder.Response1
local btn2 = frame.ButtonHolder.Response2

local btn1Conn
local btn2Conn
local talking = false
local debounce = false

local function typeText(text)
	btn1.Interactable = false
	btn2.Interactable = false
	btn1.Text = ""
	btn2.Text = ""
	dialogueText.Text = ""

	local ttsSuccess = TextToSpeech.Speak(text)
	local charDelay = 0.05
	local ttsHandle = TextToSpeech.GetHandle()
	local graphemeCount
	if ttsSuccess then
		graphemeCount = 0
		for _ in utf8.graphemes(ttsHandle.Text) do
			graphemeCount += 1
		end
		charDelay = ttsHandle.TimeLength / graphemeCount
	end
	-- use built in ROBLOX graphemes to simulate typewriter effect
	dialogueText.RichText = true
	dialogueText.Text = text
	dialogueText.MaxVisibleGraphemes = 0

	local index = 0

	for first, last in utf8.graphemes(ttsHandle.Text) do
		local grapheme = ttsHandle.Text:sub(first, last)
		index += 1
		if grapheme ~= " " then
			dialogueText.MaxVisibleGraphemes = index
			if not ttsSuccess then
				SoundModule.PlaySound("TypeSound")
			end
			task.wait(charDelay)
		end
	end

	-- prevent TTS playing issues if typewriter is too fast
	while ttsHandle.IsPlaying and ttsSuccess do
		task.wait()
	end
	btn1.Interactable = true
	btn2.Interactable = true
end

function TalkModule.IsTalking()
	return talking
end

function TalkModule.SetTalking(shouldTalk)
	talking = shouldTalk
end

function TalkModule.GetMoveableNPCName()
	return moveableNPCName
end

function TalkModule.SetMoveableNPCName(name)
	moveableNPCName = name
end

function TalkModule.GetCurrentPrompt()
	return moveableNPCName
end

function TalkModule.SetCurrentPrompt(prompt)
	CurrentPrompt = prompt
end
function TalkModule.CanTalk()
	return CanTalk
end
function TalkModule.SetCanTalk(canTalk)
	CanTalk = canTalk
end

function TalkModule.hideUI(responseData)
	task.delay(0.3, function()
		if moveableNPCName then
			PauseNPCMovement:FireServer(false, moveableNPCName)
			moveableNPCName = nil
		end

		if responseData.Type == "Close" then
			SoundModule.PlayTheme("Main")
			-- re-enable movement (if not last disabled by cutscene)
			MovementModule.EnableControls("UI")
		elseif responseData.Type == "CloseCutscene" then
			SoundModule.StopAllSounds()
			ClientHelperFunctions.EnableAllNPCPrompts(false)
		elseif responseData.Type == "CloseKeepTheme" then
			MovementModule.EnableControls("UI")
		end

		talking = false
		frame.Visible = false
		ui.Enabled = false

		if CurrentPrompt and responseData.Type ~= "CloseCutscene" then
			CurrentPrompt.Enabled = true
			CurrentPrompt = nil
		end
	end)
end

local function fireAndLog(event, data, label)
	if data then
		if label == "UnlockMission" then
			SoundModule.PlaySound("NewMission")
		end
		if label == "ProgressMission" then
			SoundModule.PlaySound("Ping")
		end

		event:FireServer(data)

		print(`Remote fired! {label}: {data}`)
	end
end

function TalkModule.handleResponse(data, responseData)
	if not responseData or not responseData.Type then
		warn("Invalid response data")
		return
	end
	print(responseData.Type)
	if
		responseData.Type == "Close"
		or responseData.Type == "CloseCutscene"
		or responseData.Type == "CloseKeepTheme"
	then
		TalkModule.hideUI(responseData)
	elseif responseData.Type == "NextMessage" then
		local newData = data[responseData.NextId]
		if newData then
			TalkModule.updateUI(data, responseData.NextId)
		else
			warn("NextMessage type, but no NextDialogue data.")
			TalkModule.hideUI(responseData)
		end
	else
		warn("Unknown request type:", responseData.Type)
		TalkModule.hideUI(responseData)
	end

	for key, event in pairs(RemoteMap) do
		local value = responseData[key]
		if event and value ~= nil then
			local label = (key == "ExecuteScenarioEvent" and `Execute scenario {value}`) or key
			fireAndLog(event, value, label)

			-- client logic handler if applicable
			if key == "ExecuteScenarioEvent" then
				print("Client called MissionsClientHandler")
				if MissionsClientHandler[value] then
					MissionsClientHandler[value]()
				end
			end
		end
	end
end

function TalkModule.updateUI(data, dialogueId)
	local selectedDialogue = data[dialogueId]
	-- some dialogues are functions that returns a table instead, for condition checking
	if typeof(selectedDialogue) == "function" then
		selectedDialogue = data[dialogueId]()
	end
	nameLabel.Text = selectedDialogue.Name
	portrait.Image = selectedDialogue.Portrait
	-- client events
	if selectedDialogue.PlaySound then
		print(`Client wants to play sound: {selectedDialogue.PlaySound}`)
		SoundModule.PlaySound(selectedDialogue.PlaySound)
	end
	if selectedDialogue.PlayTheme then
		print(`Client wants to play theme: {selectedDialogue.PlayTheme}`)
		SoundModule.PlayTheme(selectedDialogue.PlayTheme)
	end
	if selectedDialogue.ChangeThemePitch then
		print("Pitch changed")
		SoundModule.ChangeThemePlaybackSpeed(selectedDialogue.ChangeThemePitch)
	end

	if selectedDialogue.StopSound then
		print(`Client wants to stop sound: {selectedDialogue.StopSound}`)
		SoundModule.StopSound(selectedDialogue.StopSound)
	end

	if
		selectedDialogue.VoiceId ~= nil
		or selectedDialogue.Pitch ~= nil
		or selectedDialogue.Speed ~= nil
		or selectedDialogue.Volume ~= nil
	then
		print("changed TTS config")
		local config = {}
		if selectedDialogue.VoiceId ~= nil then
			config.VoiceId = selectedDialogue.VoiceId
		end
		if selectedDialogue.Pitch ~= nil then
			config.Pitch = selectedDialogue.Pitch
		end
		if selectedDialogue.Speed ~= nil then
			config.Speed = selectedDialogue.Speed
		end
		if selectedDialogue.Volume ~= nil then
			config.Volume = selectedDialogue.Volume
		end

		TextToSpeech.UpdateVoiceConfig(config)
	end

	if btn1Conn then
		btn1Conn:Disconnect()
	end
	if btn2Conn then
		btn2Conn:Disconnect()
	end

	btn1Conn = btn1.MouseButton1Click:Connect(function()
		if debounce then
			return
		end
		debounce = true
		TalkModule.handleResponse(data, selectedDialogue.Responses[1])
		task.delay(0.1, function()
			debounce = false
		end)
	end)

	btn2Conn = btn2.MouseButton1Click:Connect(function()
		if debounce then
			return
		end
		debounce = true
		TalkModule.handleResponse(data, selectedDialogue.Responses[2])
		task.delay(0.1, function()
			debounce = false
		end)
	end)

	if typeof(selectedDialogue.Dialogue) == "function" then
		typeText(selectedDialogue.Dialogue())
	else
		typeText(selectedDialogue.Dialogue)
	end

	btn1.Text = selectedDialogue.Responses[1].Text
	btn2.Text = selectedDialogue.Responses[2].Text
end

function TalkModule.openUI(data, dialogueId)
	ui.Enabled = true
	frame.Visible = true

	TalkModule.updateUI(data, dialogueId)
end

return TalkModule
