local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local GeneralRemotes = ReplicatedStorage.Remotes
-- server only
local CurrentGroceries = {}
local GroceryBagModule = {}

function GroceryBagModule.UpdateGroceries(player)
	local clientItems = GeneralRemotes.Cashier.GetClientBasketItems:InvokeClient(player)
	CurrentGroceries = clientItems
	print(CurrentGroceries)
end

function GroceryBagModule.GetCurrentGroceries()
	return CurrentGroceries
end

function GroceryBagModule.HasItem(name)
	return CurrentGroceries[name]
end

return GroceryBagModule
