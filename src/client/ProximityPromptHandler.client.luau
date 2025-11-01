local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared

local Player = game.Players.LocalPlayer
local Events = ReplicatedStorage.Missions.Events
local Character = Player.Character or Player.CharacterAdded:Wait()
local PlayerGui = Player:WaitForChild("PlayerGui")

local GeneralRemotes = ReplicatedStorage.Remotes

-- house
local HouseRemote = ReplicatedStorage.Remotes.House.HouseDoorInteracted
local HouseDoorDebounce = false

-- talk
local InitializeGUIModule = require(StarterPlayer.StarterPlayerScripts.Client.InitializeGUI.InitializeGUIModule)
local FrankensteinPrompts = require(StarterPlayer.StarterPlayerScripts.Client.NPCs.Frankenstein.FrankensteinPrompts)
local MoneyBaitPrompts = require(StarterPlayer.StarterPlayerScripts.Client.NPCs.MoneyBait.MoneyBaitPrompts)
local SoundModule = require(script.Parent.SoundModule)
local TalkModule = require(script.Parent.TalkModule)
local NPCEvents = ReplicatedStorage.Events.NPC
local PauseNPCMovement = NPCEvents.PauseNPCMovement
local MovementModule = require(script.Parent:WaitForChild("MovementHandler"))

-- cashier basket
local ShopBasketModule = require(ReplicatedStorage.NPCs.Cashier.ShopBasketModule)

local RoomExitFunctions = {
	ShopExit = function()
		GeneralRemotes.RemoveAllToolsOfTag:FireServer("ShopItem")
	end,

	GambaExit = function()
		GeneralRemotes.Gamba.RemoveAllSlotMachines:FireServer()
	end,

	TVHomeExit = function()
		task.spawn(function()
			local holdingTV = GeneralRemotes.TVHome.HoldingRealTV:InvokeServer()
			if holdingTV then
				Events.ProgressMissionEvent:FireServer({
					MissionName = "StealTV",
					ProgressVal = 1,
					TaskId = "Steal",
				})
			end
		end)

		Events.ExecuteScenarioEvent:FireServer("StealTVModeExit")
		PlayerGui:WaitForChild("SleepMeter"):Destroy()
	end,
}

local RoomEnterFunctions = {
	GambaEnter = function(modelName)
		-- ensure its loaded first
		workspace:WaitForChild(modelName)
		GeneralRemotes.Gamba.InitializeSlotMachines:FireServer()
	end,
	InfirmaryEnter = function(modelName)
		workspace:WaitForChild(modelName)
		MoneyBaitPrompts.InfirmaryEnter()
	end,
	TVHomeEnter = function(modelName)
		workspace:WaitForChild(modelName)
		Events.ExecuteScenarioEvent:FireServer("StealTVMode")
		InitializeGUIModule["TVHomeGUI"]()
	end,
	FrankensteinRoomEnter = function(modelName)
		local room = workspace:WaitForChild(modelName)
		FrankensteinPrompts.RoomEntered(room)
	end,
	HomeEnter = function(modelName)
		local home = workspace:WaitForChild(modelName)
		if FrankensteinPrompts.FrankensteinRevived() then
			GeneralRemotes.SpawnServerStorageModel:InvokeServer(
				"MissionModels",
				"Frankenstein",
				"FrankensteinAtHome",
				nil
			)
			workspace:WaitForChild("FrankensteinAtHome").Parent = home
		end
	end,
}

local function GetShopItems()
	local shopItems = {}
	-- check equipped first
	for _, item in pairs(Character:GetChildren()) do
		if item:IsA("Tool") and CollectionService:HasTag(item, "ShopItem") then
			table.insert(shopItems, item)
		end
	end

	-- then backpack
	for _, item in pairs(Player.Backpack:GetChildren()) do
		if item:IsA("Tool") and CollectionService:HasTag(item, "ShopItem") then
			table.insert(shopItems, item)
		end
	end

	return shopItems
end

local function HouseDoorProximityPrompt(prompt)
	if not CollectionService:HasTag(prompt.Parent, "HouseDoor") then
		return
	end

	local houseName = prompt:FindFirstChild("HouseName").Value

	if not houseName then
		error("Door has no string value")
		return
	end

	if HouseDoorDebounce then
		return
	end
	local modelName
	local isEnter = string.find(houseName, "Enter")
	local isExit = string.find(houseName, "Exit")

	if not (isEnter or isExit) then
		warn("Door string value has no 'Enter' or 'Exit' included")
		return
	end

	print(houseName)

	if isEnter then
		HouseDoorDebounce = true
		modelName = string.sub(houseName, 1, isEnter - 1)
		print(`Entering room {modelName}`)
		HouseRemote:FireServer("Enter", modelName)
		if RoomEnterFunctions[houseName] then
			RoomEnterFunctions[houseName](modelName)
		end
		task.wait(2)
		HouseDoorDebounce = false
	elseif isExit then
		HouseDoorDebounce = true
		modelName = string.sub(houseName, 1, isExit - 1)
		print(`Leaving room {modelName}`)
		HouseRemote:FireServer("Exit", modelName)
		if RoomExitFunctions[houseName] then
			RoomExitFunctions[houseName]()
		end
		task.wait(2)
		HouseDoorDebounce = false
	end
end

local function TalkProximityPrompt(prompt)
	if
		not (
			CollectionService:HasTag(prompt.Parent, "MoveableNPC")
			or CollectionService:HasTag(prompt.Parent, "NPC")
			or CollectionService:HasTag(prompt.Parent, "UINPC")
		)
	then
		return
	end
	-- for NPCS only
	local canTalk = GeneralRemotes.CanTalk:InvokeServer()
	if not canTalk then
		print("Shouldn't talk")
		return
	else
		print(`Can talk`)
	end
	if TalkModule.IsTalking() then
		warn("Already talking")
		return
	end

	-- disable all talk prompts
	GeneralRemotes.EnableAllNPCPrompts:FireServer(false)

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

	-- NPCS that don't talk but opens a UI instead
	if CollectionService:HasTag(prompt.Parent, "UINPC") then
		MovementModule.DisableControls("UI")
		print("UI NPC detected!")
		InitializeGUIModule[npc.Value]()
		return
	end

	-- normal dialogue talking NPCS
	TalkModule.SetTalking(true)
	local dataModule = ReplicatedStorage:WaitForChild("NPCDialogues"):FindFirstChild(npc.Value, true)
	if not dataModule then
		print("Failed to get NPC module (UI)")
		return
	end

	-- stop Player movement
	MovementModule.DisableControls("UI")
	SoundModule.PauseTheme()

	local npcData = require(dataModule)
	TalkModule.openUI(npcData.Nodes, npc.Value)
	TalkModule.SetCurrentPrompt(prompt)
end

local function ShopBasketProximityPrompt(prompt)
	local ShopBasket = CollectionService:HasTag(prompt.Parent, "Basket")
	local ShopItemGiver = CollectionService:HasTag(prompt.Parent, "ShopItemGiver")
	local ClearBasket = CollectionService:HasTag(prompt, "ClearBasket")

	if ShopBasket then
		-- clear basket
		if ClearBasket then
			print("Cleared basket!")
			ShopBasketModule.ClearBasket()
			Events.SetDialogueFileEvent:FireServer({ CashierNameTag = "Cashier" })
			return
		end

		-- add to basket
		local shopItems = GetShopItems()

		if next(shopItems) == nil then
			warn("No shop items in backpack.")
			return
		end

		for _, item in ipairs(shopItems) do
			ShopBasketModule.AddItem(item.Name, item:WaitForChild("Price").Value, item:WaitForChild("Quantity").Value)
		end

		Events.SetDialogueFileEvent:FireServer({ CashierNameTag = "CashierItems" })
	elseif ShopItemGiver then
		-- give tool from shelf
		local itemName = prompt:FindFirstChild("ItemName")

		if itemName then
			Events.GiveToolEvent:InvokeServer({ itemName.Value, false })
			print(`Item given: {itemName}`)
		end
	end
end

local function PickupTrashProximityPrompt(prompt)
	if not (CollectionService:HasTag(prompt.Parent, "Trash")) then
		return
	end
	SoundModule.PlaySound("OldSplat")
	local result = GeneralRemotes.PickupTrash.TrashPickedUp:InvokeServer(prompt.Parent)

	-- update player GUI
	local gui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("TrashCounter"):WaitForChild("Counter")
	if not gui then
		error("Client can't find TrashCounter GUI")
	end
	gui.Text = `Trash Picked<br/>{tostring(result.PickedUp)}/{tostring(result.TotalTrash)}`

	-- completed
	if result.PickedUp >= result.TotalTrash then
		GeneralRemotes.PickupTrash.TrashGameFinished:InvokeServer()
		gui.Parent:Destroy()

		GeneralRemotes.EnableAllNPCPrompts:FireServer(true)
		SoundModule.PlaySound("Correct")
	end
end

local function SlotMachineProximityPrompts(prompt)
	local GambaRemotes = GeneralRemotes.Gamba
	if CollectionService:HasTag(prompt, "IncreaseBetPrompt") then
		GambaRemotes.IncreaseBet:FireServer(prompt.Parent.Parent.Name)
		return
	end
	if CollectionService:HasTag(prompt, "DecreaseBetPrompt") then
		GambaRemotes.DecreaseBet:FireServer(prompt.Parent.Parent.Name)
		return
	end

	if CollectionService:HasTag(prompt, "SpinPrompt") then
		GambaRemotes.SpinSlotMachine:FireServer(prompt.Parent.Parent.Name)
		return
	end
end

local function WheelSpinner(prompt)
	if not (CollectionService:HasTag(prompt, "SpinWheel")) then
		return
	end
	print("Wheel prompt activate")
	GeneralRemotes.Gamba.StartWheelSpin:FireServer()
end

local function R2DBossPrompts(prompt)
	if not (CollectionService:HasTag(prompt, "AmmoRefill")) then
		return
	end
	local stacks = PlayerGui:WaitForChild("R2DMinigunGUI"):WaitForChild("Base"):WaitForChild("Stacks")
	if not stacks then
		error("Stacks reference missing")
	end
	stacks.Value = 2
end

local function TVHomePrompts(prompt)
	if CollectionService:HasTag(prompt.Parent, "FakeTV") then
		prompt.Enabled = false
		local tv = prompt.Parent
		tv.Anchored = false
		tv.AssemblyLinearVelocity = vector.zero -- resets motion
		tv:ApplyImpulse(vector.create(0, -1, 1) * 100 * tv.AssemblyMass)

		SoundModule.PlaySound("CarCrash")
		-- if this proximity is activated, sleepemeter MUST exist already.
		local sleepVal = PlayerGui.SleepMeter.BG.Meter.CurrentSleepVal
		sleepVal.Value -= 0.3
	elseif CollectionService:HasTag(prompt.Parent, "RealTV") then
		prompt.Enabled = false

		GeneralRemotes.TVHome.RealTVGrab:FireServer()
	end
end

ProximityPromptService.PromptTriggered:Connect(function(prompt, _)
	HouseDoorProximityPrompt(prompt)
	TalkProximityPrompt(prompt)
	ShopBasketProximityPrompt(prompt)
	PickupTrashProximityPrompt(prompt)
	SlotMachineProximityPrompts(prompt)
	WheelSpinner(prompt)
	R2DBossPrompts(prompt)
	MoneyBaitPrompts.HandlePrompts(prompt)
	TVHomePrompts(prompt)
	FrankensteinPrompts.HandlePrompts(prompt)
end)
