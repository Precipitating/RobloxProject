local StarterPlayer = game:GetService("StarterPlayer")
local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local MissionEvents = ReplicatedStorage.Missions.Events
local ShopBasketModule = {}
local ItemsInBasket = {}

function ShopBasketModule.AddItem(name, price, quantity)
	if ItemsInBasket[name] then
		ItemsInBasket[name].Quantity += quantity
		MissionEvents.RemoveEquippedToolEvent:FireServer()
		print(`{name} already exists in cashier basket, added to quantity {ItemsInBasket[name].Quantity}`)
		SoundModule.PlaySound("Rustle")

		return
	end

	ItemsInBasket[name] = { Price = price, Quantity = quantity }
	MissionEvents.RemoveEquippedToolEvent:FireServer()

	print(`{quantity} {name} added to cashier basket`)
	SoundModule.PlaySound("Rustle")
end

function ShopBasketModule.GetItemsInBasket()
	return ItemsInBasket
end

-- respects quantity in regards to its removal
function ShopBasketModule.ReduceQuantity(itemName, amount)
	if not ItemsInBasket[itemName] then
		return
	end

	local item = ItemsInBasket[itemName]

	if item > 0 then
		item.Quantity -= amount
		if item.Quantity <= 0 then
			ShopBasketModule.RemoveItem(itemName)
		end
	end
end

-- ignore the quantity, hard removal
function ShopBasketModule.RemoveItem(itemName)
	if ItemsInBasket[itemName] then
		ItemsInBasket[itemName] = nil
		print(`Removed {itemName} from basket`)
	end
end

function ShopBasketModule.ClearBasket()
	table.clear(ItemsInBasket)
end

return ShopBasketModule
