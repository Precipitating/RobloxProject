local ServerScriptService = game:GetService("ServerScriptService")
local CurrencyHandler = require(ServerScriptService.Server.CurrencyHandler)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local GeneralRemotes = ReplicatedStorage.Remotes
local RandomIndex = nil
local Cost = 50
local BulletGuesser = {}

function BulletGuesser.GetStoredBulletIdx()
	return RandomIndex
end

function BulletGuesser.ResetBulletIdx()
	RandomIndex = nil
end

function BulletGuesser.Start(player)
	CurrencyHandler.ReduceMoney(player, Cost)

	if not RandomIndex then
		RandomIndex = math.random(1, 6)
		print(RandomIndex)
	end
	task.wait(1)
	GeneralRemotes.PlayTheme:FireClient(player, "Breathing")
	GeneralRemotes.InitializeGUI:FireClient(player, "BulletGuesser")
end

return BulletGuesser
