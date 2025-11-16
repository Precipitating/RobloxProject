local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local CurrencyHandler = require(ServerScriptService.Server.CurrencyHandler)
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local GeneralRemotes = ReplicatedStorage.Remotes
local BakeryShop = {}

local items = {
	Cupcake = { Price = 5 },
}
function BakeryShop.BuyItem(player, itemName)
	local currentMoney = CurrencyHandler.GetMoney()
	local itemPrice = items[itemName].Price

	-- exit early if can't afford item
	if currentMoney < itemPrice then
		warn(`Can't afford {itemName}, which costs {itemPrice}`)
		GeneralRemotes.PlaySound:InvokeClient(player, "Error")

		return
	end

	-- can afford, give tool and reduce money
	CurrencyHandler.ReduceMoney(player, itemPrice)
	ServerHelperFunctions.GiveTool(player, { itemName, false })
end

return BakeryShop
