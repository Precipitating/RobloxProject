local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ShopBasketModule = require(ReplicatedStorage.NPCs.Cashier.ShopBasketModule)
local Player = game.Players.LocalPlayer
local Events = ReplicatedStorage.Missions.Events
local Character = Player.Character or Player.CharacterAdded:Wait()
local hasItemsInBasket = false

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

game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt, _)
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
end)
