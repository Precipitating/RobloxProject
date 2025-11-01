local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local InitializeGUIModule = require(StarterPlayer.StarterPlayerScripts.Client.InitializeGUI.InitializeGUIModule)
local InitializeToolModule = require(StarterPlayer.StarterPlayerScripts.Client.InitializeGUI.InitializeToolModule)
local MovementHandler = require(StarterPlayer.StarterPlayerScripts.Client.MovementHandler)
local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Player = Players.LocalPlayer
local Events = ReplicatedStorage.Missions.Events
local GeneralRemotes = ReplicatedStorage.Remotes

local MoneyBaitPrompts = {}

local function GiveTool(name, onlyOneAllowed)
	return Events.GiveToolEvent:InvokeServer({ name, onlyOneAllowed })
end
local function DestroyObject(parent)
	GeneralRemotes.DestroyObjectByName:FireServer(parent.Name)
end

function MoneyBaitPrompts.HandlePrompts(prompt)
	if
		not (
			CollectionService:HasTag(prompt.Parent, "PrisonPrompt") or CollectionService:HasTag(prompt, "PrisonPrompt")
		)
	then
		return
	end
	local parent = prompt.Parent
	-- tag-action map
	local tagActions = {
		MoneyBait = function()
			MovementHandler.DisableControls()
			prompt.Enabled = false
			SoundModule.PlaySound("Oi").Ended:Wait()
			Events.ExecuteScenarioEvent:FireServer("MoneyBaited")
			SoundModule.PlayTheme("PrisonTheme")
			print("BAITED")
		end,

		Blanket = function()
			GiveTool("Blanket", true)
		end,
		PaperClone = function()
			Events.ExecuteScenarioEvent:FireServer("ApplyPaperClone")
		end,

		Sink = function()
			local amountToCreateClone = 3
			local done = GeneralRemotes.ConsumeTool:InvokeServer("Paper", amountToCreateClone)

			if done then
				GiveTool("PaperClone", true)
			else
				warn("Not enough paper to create clone")
			end
		end,

		CoverCell = function()
			Events.ExecuteScenarioEvent:FireServer("ApplyBlanketToCell")
		end,

		PrisonSpoon = function()
			local givenTool = GiveTool("PrisonSpoon", true)
			if givenTool then
				InitializeToolModule["PrisonSpoon"](Player.Backpack:WaitForChild("PrisonSpoon"))
				DestroyObject(parent)
			end
		end,

		Paper = function()
			GiveTool("Paper", false)
			DestroyObject(parent)
		end,

		UnscrewToilet = function()
			Events.ExecuteScenarioEvent:FireServer("UnscrewToilet")
		end,

		OpenToilet = function()
			GeneralRemotes.MoneyBait.ShiftToilet:FireServer(true)
		end,

		CloseToilet = function()
			GeneralRemotes.MoneyBait.ShiftToilet:FireServer(false)
		end,

		RopeCurtain = function()
			GiveTool("CurtainTool", false)
			DestroyObject(parent)
		end,
		RopeCraftTable = function()
			local amountToCreateRope = 2
			local done = GeneralRemotes.ConsumeTool:InvokeServer("CurtainTool", amountToCreateRope)

			if done then
				GiveTool("Rope", true)
			else
				warn("Not enough curtains to create rope")
			end
		end,
		RopeHookPoint = function()
			local hooked = GeneralRemotes.MoneyBait.HookRope:InvokeServer(prompt.Parent.Name)
			if hooked then
				prompt.Enabled = false
			end
		end,

		CloseElevator = function()
			prompt.Enabled = false
			GeneralRemotes.MoneyBait.ActivateElevator:FireServer()
		end,

		ClimbRope = function()
			prompt.Enabled = false
			GeneralRemotes.MoneyBait.PlayerAttachRope:FireServer()
			InitializeGUIModule["ClimbRopeQuickTime"]()
		end,
	}

	-- execute action for the first matching tag
	for tag, action in pairs(tagActions) do
		if CollectionService:HasTag(parent, tag) or CollectionService:HasTag(prompt, tag) then
			action(prompt)
			break
		end
	end
end

function MoneyBaitPrompts.InfirmaryEnter()
	GeneralRemotes.MoneyBait.EscapedRoomSet:FireServer(true)
	GeneralRemotes.DestroyObjectByName:FireServer("Prison")
	SoundModule.PlayTheme("TimeTheme")
	Events.ExecuteScenarioEvent:FireServer("InfirmaryRoomEntered")
end

return MoneyBaitPrompts
