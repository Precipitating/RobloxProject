local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local Events = ReplicatedStorage.Missions.Events
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
local movementModule = require(script.Parent:WaitForChild("MovementHandler"))
local textToSpeech = require(ReplicatedStorage.TextToSpeech)
local soundModule = require(script.Parent:WaitForChild("SoundModule"))

-- ui
local ui = player.PlayerGui.NPCChatSystem:WaitForChild("ChatUI")
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
	textToSpeech.Speak(text)

	local timeout = 5
	local startTime = tick()
	local ttsFailed = false

	while not textToSpeech.IsLoaded() do
		if tick() - startTime >= timeout then
			warn("Taking too long to generate TTS, proceeding without audio")
			ttsFailed = true
			break
		end
		task.wait()
	end

	for i = 1, #text do
		dialogueText.Text = string.sub(text, 1, i)
		if ttsFailed then
			soundModule.PlaySound("TypeSound")
		end
		task.wait(0.05 / textToSpeech.GetCurrentSpeed())
	end

	btn1.Interactable = true
	btn2.Interactable = true
end

function hideUI(closeType)
	task.delay(0.3, function()
		if closeType ~= "CloseCutscene" then
			soundModule.PlayTheme("Main")
			-- re-enable movement (if not last disabled by cutscene)
			movementModule.EnableControls("UI")
		else
			soundModule.StopAllSounds()
		end

		talking = false
		frame.Visible = false
		ui.Enabled = false
	end)
end

local function fireAndLog(event, data, label)
	if data then
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
	if responseData.Type == "Close" or responseData.Type == "CloseCutscene" then
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
	-- stop player movement
	movementModule.DisableControls("UI")
	soundModule.PauseTheme()

	ui.Enabled = true
	frame.Visible = true

	updateUI(data, dialogueId)
end

game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt, _)
	if talking then
		return
	end
	talking = true

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

	local npcData = require(dataModule)

	openUI(npcData.Nodes, npc.Value)
end)
