local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShopBasketModule = require(ReplicatedStorage.Shared.NPCs.Cashier.ShopBasketModule)
local Player = game.Players.LocalPlayer
local Events = ReplicatedStorage.Shared.Missions.Events
local Character = Player.Character or Player.CharacterAdded:Wait()
local hasItemsInBasket = false

local function getEquippedTool()
	for _, item in pairs(Character:GetChildren()) do
		if item:IsA("Tool") and CollectionService:HasTag(item, "ShopItem") then
			return item
		end
	end

	return nil
end

game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt, _)
	local ShopBasket = CollectionService:HasTag(prompt.Parent, "Basket")
	local ShopItemGiver = CollectionService:HasTag(prompt.Parent, "ShopItemGiver")

	if ShopBasket then
		local equippedTool = getEquippedTool()

		if not equippedTool then
			return
		end

		ShopBasketModule.AddItem(
			equippedTool.Name,
			equippedTool:WaitForChild("Price").Value,
			equippedTool:WaitForChild("Quantity").Value
		)

		if not hasItemsInBasket then
			Events.SetDialogueFileEvent:FireServer({ { CashierNameTag = "CashierItems" } })
			hasItemsInBasket = true
		end
	elseif ShopItemGiver then
		local itemName = prompt:FindFirstChild("ItemName")

		if itemName then
			Events.GiveToolEvent:FireServer(itemName.Value)
			print(`Item given: {itemName}`)
		end
	end
end)
