local ServerScriptService = game:GetService("ServerScriptService")
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)

local BossRef = nil
local MapRef = nil
local PumpkinBossFight = {}

function PumpkinBossFight.Initialize(player)
	MapRef = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "CupcakeLover", "PumpkinMap", nil)
	BossRef = MapRef:FindFirstChild("PumpkinBoss")
	player.Character:PivotTo(MapRef:FindFirstChild("SpawnLoc").CFrame)
	-- give minigun
	ServerHelperFunctions.GiveTool(player, { "Minigun", true })
end

return PumpkinBossFight
