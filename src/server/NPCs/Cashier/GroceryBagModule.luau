local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShopBasketModule = require(ReplicatedStorage.Shared.NPCs.Cashier.ShopBasketModule)
local CurrentGroceries = {}
local GroceryBagModule = {}

function GroceryBagModule.UpdateGroceries()
	CurrentGroceries = ShopBasketModule.GetItemsInBasket()
end

return GroceryBagModule
