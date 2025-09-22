local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Money = 0
local GeneralRemotes = ReplicatedStorage.Remotes
local CurrencyHandler = {}

function CurrencyHandler.AddMoney(player, val)
	Money = Money + val
	GeneralRemotes.UpdateMoneyGUI:FireClient(player, Money)
	print(`Total money after INCREASE by {val}: {Money}`)
end

function CurrencyHandler.ReduceMoney(player, val)
	Money = math.max(0, Money - val)
	GeneralRemotes.UpdateMoneyGUI:FireClient(player, Money)
	print(`Total money after DECREASE by {val}: {Money}`)
end

function CurrencyHandler.GetMoney()
	return Money
end

return CurrencyHandler
