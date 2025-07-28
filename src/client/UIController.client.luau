local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local unlockEvent = ReplicatedStorage.Missions.Events.UnlockMissionEvent
local progressEvent = ReplicatedStorage.Missions.Events.ProgressMissionEvent
local giveToolEvent = ReplicatedStorage.Missions.Events.GiveToolEvent
local forceEquipEvent = ReplicatedStorage.Missions.Events.ForceEquipEvent
local removeToolsEvent = ReplicatedStorage.Missions.Events.RemoveToolsEvent
local setMeshVisibilityEvent = ReplicatedStorage.Missions.Events.SetMeshVisibilityEvent
local setDialogueFileEvent = ReplicatedStorage.Missions.Events.SetDialogueFileEvent
local textToSpeech = require(ReplicatedStorage.TextToSpeech)
local soundModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("Client"):WaitForChild("SoundModule"))

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

	while not textToSpeech.IsLoaded() do
		if tick() - startTime >= timeout then
			warn("Taking too long to generate TTS, proceeding without audio")
			break
		end
		task.wait()
	end

	for i = 1, #text do
		dialogueText.Text = string.sub(text, 1, i)
		task.wait(0.05 / textToSpeech.GetCurrentSpeed())
	end

	btn1.Interactable = true
	btn2.Interactable = true
end

function hideUI()
	task.delay(0.3, function()
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
function handleResponse(responseData)
	-- Handle response types
	if responseData.Type == "Close" then
		hideUI()
	elseif responseData.Type == "NextMessage" then
		local newData = responseData.NextDialogue
		if newData then
			updateUI(newData)
		else
			warn("NextMessage type, but no NextDialogue data.")
			hideUI()
		end
	else
		warn("Unknown request type:", responseData.Type)
		hideUI()
	end

	-- client events
	if responseData.PlaySound then
		print(`Client wants to play sound: {responseData.PlaySound}`)
		soundModule.PlaySound(responseData.PlaySound)
	end

	-- server events
	fireAndLog(unlockEvent, responseData.UnlockMission, "Mission unlock")
	fireAndLog(progressEvent, responseData.ProgressMission, "Mission progress")
	fireAndLog(giveToolEvent, responseData.GiveTool, "Give Tool")
	fireAndLog(forceEquipEvent, responseData.ForceEquip, "Force Equip Tool")
	fireAndLog(removeToolsEvent, responseData.RemoveTools, "Remove tools")
	fireAndLog(setMeshVisibilityEvent, responseData.SetMeshVisibility, "Set Mesh Visibility")
	fireAndLog(setDialogueFileEvent, responseData.SetDialogueFile, "Set Dialogue File")
end

function updateUI(data)
	nameLabel.Text = data.Name
	portrait.Image = data.Portrait

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
		handleResponse(data.Responses[1])
		task.delay(1, function()
			debounce = false
		end)
	end)

	btn2Conn = btn2.MouseButton1Click:Connect(function()
		if debounce then
			return
		end
		debounce = true
		handleResponse(data.Responses[2])
		task.delay(1, function()
			debounce = false
		end)
	end)

	if data.VoiceId or data.Pitch or data.Speed or data.Volume then
		print("changed TTS config")
		textToSpeech.UpdateVoiceConfig(data.VoiceId or "1", data.Pitch or 1, data.Speed or 1, data.Volume or 1)
	end
	typeText(data.Dialogue)

	btn1.Text = data.Responses[1].Text
	btn2.Text = data.Responses[2].Text
end

function openUI(data)
	ui.Enabled = true
	frame.Visible = true
	updateUI(data)
end

game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt, player)
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

	openUI(npcData[npc.Value])
end)
