local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local SoundModule = require(script.Parent.SoundModule)
local TalkModule = require(script.Parent.TalkModule)
local NPCEvents = ReplicatedStorage.Events.NPC
local PauseNPCMovement = NPCEvents.PauseNPCMovement
local MovementModule = require(script.Parent:WaitForChild("MovementHandler"))

game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt, _)
	-- for NPCS only
	if not TalkModule.CanTalk() then
		print("Shouldn't talk")
		return
	end

	if
		not (CollectionService:HasTag(prompt.Parent, "MoveableNPC") or CollectionService:HasTag(prompt.Parent, "NPC"))
	then
		return
	end

	if TalkModule.IsTalking() then
		return
	end
	TalkModule.SetTalking(true)

	-- check if moveable NPC, and if so pause its movement
	if CollectionService:HasTag(prompt.Parent, "MoveableNPC") then
		PauseNPCMovement:FireServer(true, prompt.Parent.Name)
		TalkModule.SetMoveableNPCName(prompt.Parent.Name)
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
	MovementModule.DisableControls("UI")
	SoundModule.PauseTheme()

	local npcData = require(dataModule)

	TalkModule.openUI(npcData.Nodes, npc.Value)
	prompt.Enabled = false
	TalkModule.SetCurrentPrompt(prompt)
end)
