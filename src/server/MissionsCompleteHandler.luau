local MissionCompleteHandlers = {}
local ServerScriptService = game:GetService("ServerScriptService")
local HelperFunctions = require(ServerScriptService.Server.HelperFunctions)

-- handle all rewards
MissionCompleteHandlers["StealPhone"] = function(player)
	HelperFunctions.GiveTool(player, "Nokia")
	HelperFunctions.SetNPCDialogueFile({ { RoadmanNameTag = "RoadmanComplete" } })
	print("StealPhone reward given and dialogue set to RoadmanComplete")
end

return MissionCompleteHandlers
