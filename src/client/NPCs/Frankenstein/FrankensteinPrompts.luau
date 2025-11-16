local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)
local UIHelperFunctions = require(StarterPlayer.StarterPlayerScripts.Client.UIHelperFunctions)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Player = Players.LocalPlayer
local Events = ReplicatedStorage.Missions.Events
local GeneralRemotes = ReplicatedStorage.Remotes

local BodyComplete = false
local BodypartsPickedUp = {}
local FrankensteinActivated = false

local FrankensteinPrompts = {}

local function CollectedAllParts()
	local count = 0
	for _, bodyPart in ipairs(Player.Backpack:GetChildren()) do
		if CollectionService:HasTag(bodyPart, "FrankensteinBodyPart") then
			count += 1
		end
	end
	if count ~= 4 then
		return false
	end

	return true
end

local function ActivateLever(prompt)
	if not BodyComplete then
		warn("Body not assembled")
		return
	end
	prompt.Enabled = false
	local hitbox = prompt.Parent
	local goal = { CFrame = hitbox.CFrame * CFrame.new(0, 0, -1.275) }
	local info = TweenInfo.new(0.5, Enum.EasingStyle.Sine)
	local tween = TweenService:Create(hitbox, info, goal)
	SoundModule.PlaySound("FrankensteinLever", prompt.Parent)
	tween:Play()
	tween.Completed:Wait()
	print("done")
end

local function LightningBolt()
	local body = workspace:WaitForChild("FrankensteinRoom"):WaitForChild("FrankensteinCompleteBody")
	GeneralRemotes.SpawnServerStorageModel:InvokeServer(
		"MissionModels",
		"Cashier",
		"LightningBolt",
		body:GetPivot().Position
	)
	SoundModule.PlaySound("LightningBolt")
	body:Destroy()
	Debris:AddItem(workspace:WaitForChild("LightningBolt"), 0.5)
	UIHelperFunctions.AdjustBlackScreen(0.1, 0)
	FrankensteinActivated = true
	UIHelperFunctions.AdjustBlackScreen(0.1, 1)
end

function FrankensteinPrompts.FrankensteinRevived()
	return FrankensteinActivated
end

function FrankensteinPrompts.RoomEntered(room)
	local body = room:WaitForChild("FrankensteinBody")
	local bodyPartsList = BodypartsPickedUp

	-- revived already so empty room
	if FrankensteinActivated then
		local completeBody = room:WaitForChild("FrankensteinBody")
		completeBody:Destroy()
		local leverPrompt =
			room:WaitForChild("Lever"):WaitForChild("pull"):WaitForChild("hitbox"):WaitForChild("FrankensteinLever")
		leverPrompt.Enabled = false
	elseif BodyComplete then
		-- only show completed body, remove bodyparts
		body:Destroy()
		GeneralRemotes.SpawnServerStorageModel:InvokeServer(
			"MissionModels",
			"Frankenstein",
			"FrankensteinCompleteBody",
			nil
		)
		workspace:WaitForChild("FrankensteinCompleteBody").Parent = workspace:WaitForChild("FrankensteinRoom")
		table.clear(bodyPartsList)
	end
	-- delete bodyparts already picked up
	if #bodyPartsList > 0 then
		for _, partName in ipairs(bodyPartsList) do
			body:WaitForChild(partName):Destroy()
		end
	end
end

function FrankensteinPrompts.HandlePrompts(prompt)
	if not string.find(prompt.Name, "Frankenstein") then
		return
	end

	-- assemble bodyparts if we have them all
	if string.find(prompt.Name, "Assemble") then
		if not CollectedAllParts() then
			return
		end

		-- remove from tools if got all parts
		for _, bodyPart in ipairs(Player.Backpack:GetChildren()) do
			if CollectionService:HasTag(bodyPart, "FrankensteinBodyPart") then
				bodyPart:Destroy()
			end
		end

		-- spawn full body
		BodyComplete = true
		prompt.Parent:Destroy()
		GeneralRemotes.SpawnServerStorageModel:InvokeServer(
			"MissionModels",
			"Frankenstein",
			"FrankensteinCompleteBody",
			nil
		)
		workspace:WaitForChild("FrankensteinCompleteBody").Parent = workspace:WaitForChild("FrankensteinRoom")
		return
	elseif string.find(prompt.Name, "Lever") then
		-- lever activation, (only if body assembled)
		ActivateLever(prompt)
		LightningBolt()
		return
	elseif string.find(prompt.Name, "Spine") then
		prompt.Parent:Destroy()
		Events.ProgressMissionEvent:FireServer({
			MissionName = "FindSpine",
			ProgressVal = 1,
			TaskId = "FindSpinePieces",
		})
	else
		-- else we're picking a body part up
		GeneralRemotes.Frankenstein.GiveBodyPartTool:FireServer(prompt.Parent.Name, "FrankensteinBodyPart")
		table.insert(BodypartsPickedUp, prompt.Parent.Name)
	end
end

return FrankensteinPrompts
