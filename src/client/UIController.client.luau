local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local unlockEvent = ReplicatedStorage.Missions.Events:WaitForChild("UnlockMissionEvent")
local progressEvent = ReplicatedStorage.Missions.Events:WaitForChild("ProgressMissionEvent")
local textToSpeech = require(ReplicatedStorage.TextToSpeech)

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

local function typeText(text)
	btn1.Interactable = false
	btn2.Interactable = false
	dialogueText.Text = ""
	textToSpeech.Speak(text)

	while not textToSpeech.IsLoaded() do
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

function handleResponse(responseData)
	if responseData.Type == "Close" then
		hideUI()
	elseif responseData.Type == "NextMessage" then
		local newData = responseData.NextDialogue
		if newData then
			updateUI(newData)
		end
	else
		warn("Unknown request type")
		hideUI()
	end
	if responseData.UnlockMission then
		unlockEvent:FireServer(responseData.UnlockMission)
		print("Remote fired! mission unlock of " .. responseData.UnlockMission)
	end

	if responseData.ProgressMission then
		progressEvent:FireServer(responseData.ProgressMission)
		print("Remote fired! mission progress of " .. responseData.MissionName)
	end
end

function updateUI(data)
	nameLabel.Text = data.Name
	portrait.Image = data.Portrait

	if data.VoiceId or data.Pitch or data.Speed or data.Volume then
		print("changed TTS config")
		textToSpeech.UpdateVoiceConfig(data.VoiceId or "1", data.Pitch or 1, data.Speed or 1, data.Volume or 1)
	end
	typeText(data.Dialogue)

	btn1.Text = data.Responses[1].Text
	btn2.Text = data.Responses[2].Text

	if btn1Conn then
		btn1Conn:Disconnect()
	end
	if btn2Conn then
		btn2Conn:Disconnect()
	end

	btn1Conn = btn1.MouseButton1Click:Connect(function()
		handleResponse(data.Responses[1])
	end)

	btn2Conn = btn2.MouseButton1Click:Connect(function()
		handleResponse(data.Responses[2])
	end)
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
