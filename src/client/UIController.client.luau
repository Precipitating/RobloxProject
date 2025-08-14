local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Events = ReplicatedStorage.Missions.Events
local NPCEvents = ReplicatedStorage.Events.NPC
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

local movementModule = require(script.Parent:WaitForChild("MovementHandler"))
local textToSpeech = require(ReplicatedStorage.TextToSpeech)
local soundModule = require(script.Parent:WaitForChild("SoundModule"))

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

	local ttsSuccess = textToSpeech.Speak(text)
	local charDelay = 0.05
	local ttsHandle = textToSpeech.GetHandle()
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
				soundModule.PlaySound("TypeSound")
			end
			task.wait(charDelay)
		end
	end

	-- prevent TTS playing issues if typewriter is too fast
	while ttsHandle.IsPlaying do
		task.wait()
	end
	btn1.Interactable = true
	btn2.Interactable = true
end

function hideUI(closeType)
	task.delay(0.3, function()
		if moveableNPCName then
			PauseNPCMovement:FireServer(false, moveableNPCName)
			moveableNPCName = nil
		end

		if closeType == "Close" then
			soundModule.PlayTheme("Main")
			-- re-enable movement (if not last disabled by cutscene)
			movementModule.EnableControls("UI")
		elseif closeType == "CloseCutscene" then
			soundModule.StopAllSounds()
		elseif closeType == "CloseKeepTheme" then
			movementModule.EnableControls("UI")
		end

		talking = false
		frame.Visible = false
		ui.Enabled = false
	end)
end

local function fireAndLog(event, data, label)
	if data then
		if label == "UnlockMission" then
			soundModule.PlaySound("NewMission")
		end
		if label == "ProgressMission" then
			soundModule.PlaySound("Ping")
		end

		event:FireServer(data)
		print(`Remote fired! {label}: {data}`)
	end
end

function handleResponse(data, responseData)
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
		hideUI(responseData.Type)
	elseif responseData.Type == "NextMessage" then
		local newData = data[responseData.NextId]
		if newData then
			updateUI(data, responseData.NextId)
		else
			warn("NextMessage type, but no NextDialogue data.")
			hideUI(responseData.Type)
		end
	else
		warn("Unknown request type:", responseData.Type)
		hideUI(responseData.Type)
	end

	for key, event in pairs(RemoteMap) do
		local value = responseData[key]
		if event and value ~= nil then
			local label = (key == "ExecuteScenarioEvent" and `Execute scenario {value}`) or key
			fireAndLog(event, value, label)
		end
	end
end

function updateUI(data, dialogueId)
	local selectedDialogue = data[dialogueId]
	nameLabel.Text = selectedDialogue.Name
	portrait.Image = selectedDialogue.Portrait
	-- client events
	if selectedDialogue.PlaySound then
		print(`Client wants to play sound: {selectedDialogue.PlaySound}`)
		soundModule.PlaySound(selectedDialogue.PlaySound)
	end
	if selectedDialogue.PlayTheme then
		print(`Client wants to play theme: {selectedDialogue.PlayTheme}`)
		soundModule.PlayTheme(selectedDialogue.PlayTheme)
	end
	if selectedDialogue.ChangeThemePitch then
		print("Pitch changed")
		soundModule.ChangeThemePlaybackSpeed(selectedDialogue.ChangeThemePitch)
	end

	if selectedDialogue.StopSound then
		print(`Client wants to stop sound: {selectedDialogue.StopSound}`)
		soundModule.StopSound(selectedDialogue.StopSound)
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
		handleResponse(data, selectedDialogue.Responses[1])
		task.delay(0.1, function()
			debounce = false
		end)
	end)

	btn2Conn = btn2.MouseButton1Click:Connect(function()
		if debounce then
			return
		end
		debounce = true
		handleResponse(data, selectedDialogue.Responses[2])
		task.delay(0.1, function()
			debounce = false
		end)
	end)

	if selectedDialogue.VoiceId or selectedDialogue.Pitch or selectedDialogue.Speed or selectedDialogue.Volume then
		print("changed TTS config")
		textToSpeech.UpdateVoiceConfig(
			selectedDialogue.VoiceId or "1",
			selectedDialogue.Pitch or 1,
			selectedDialogue.Speed or 1,
			selectedDialogue.Volume or 1
		)
	end
	typeText(selectedDialogue.Dialogue)

	btn1.Text = selectedDialogue.Responses[1].Text
	btn2.Text = selectedDialogue.Responses[2].Text
end

function openUI(data, dialogueId)
	ui.Enabled = true
	frame.Visible = true

	updateUI(data, dialogueId)
end

game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt, _)
	if talking then
		return
	end
	talking = true

	-- check if moveable NPC, and if so pause its movement
	if CollectionService:HasTag(prompt.Parent, "MoveableNPC") then
		PauseNPCMovement:FireServer(true, prompt.Parent.Name)
		moveableNPCName = prompt.Parent.Name
	end

	local npc = prompt.Parent:FindFirstChild("NPCName")
	if not npc then
		print("Failed to get NPCName")
		return
	end

	local dataModule = ReplicatedStorage:WaitForChild("NPCDialogues"):FindFirstChild(npc.Value)
	if not dataModule then
		print("Failed to get NPC module (UI)")
		return
	end

	-- stop Player movement
	movementModule.DisableControls("UI")
	soundModule.PauseTheme()

	local npcData = require(dataModule)

	openUI(npcData.Nodes, npc.Value)
end)
