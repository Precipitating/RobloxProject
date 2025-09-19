local Money = 0
local CurrencyHandler = {}

function CurrencyHandler.AddMoney(val)
	Money = Money + val
	print(`Total money after INCREASE by {val}: {Money}`)
end

function CurrencyHandler.ReduceMoney(val)
	Money = math.max(0, Money - val)
	print(`Total money after DECREASE by {val}: {Money}`)
end

return CurrencyHandler
