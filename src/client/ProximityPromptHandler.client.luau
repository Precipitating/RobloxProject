local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local GeneralRemotes = ReplicatedStorage.Remotes

-- house
local HouseRemote = ReplicatedStorage.Remotes.House.HouseDoorInteracted
local HouseDoorDebounce = false

-- talk
local SoundModule = require(script.Parent.SoundModule)
local TalkModule = require(script.Parent.TalkModule)
local NPCEvents = ReplicatedStorage.Events.NPC
local PauseNPCMovement = NPCEvents.PauseNPCMovement
local MovementModule = require(script.Parent:WaitForChild("MovementHandler"))

-- cashier basket
local ShopBasketModule = require(ReplicatedStorage.NPCs.Cashier.ShopBasketModule)
local Player = game.Players.LocalPlayer
local Events = ReplicatedStorage.Missions.Events
local Character = Player.Character or Player.CharacterAdded:Wait()

local RoomExitFunctions = {
	ShopExit = function()
		GeneralRemotes.RemoveAllToolsOfTag:FireServer("ShopItem")
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
end

local function ShopBasketProximityPrompt(prompt)
	local ShopBasket = CollectionService:HasTag(prompt.Parent, "Basket")
	local ShopItemGiver = CollectionService:HasTag(prompt.Parent, "ShopItemGiver")

	if ShopBasket then
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
		local itemName = prompt:FindFirstChild("ItemName")

		if itemName then
			Events.GiveToolEvent:FireServer({ itemName.Value, false })
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
		gui:Destroy()
		ReplicatedStorage.Events.Currency.UpdateMoneyGUI:Fire()
		SoundModule.PlaySound("Correct")
	end
end

ProximityPromptService.PromptTriggered:Connect(function(prompt, _)
	HouseDoorProximityPrompt(prompt)
	TalkProximityPrompt(prompt)
	ShopBasketProximityPrompt(prompt)
	PickupTrashProximityPrompt(prompt)
end)
