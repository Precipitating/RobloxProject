local MissionFailedHandlers = {}
local ServerScriptService = game:GetService("ServerScriptService")
local HelperFunctions = require(ServerScriptService.Server.HelperFunctions)

MissionFailedHandlers["TypingCompetition"] = function(_)
	HelperFunctions.SetNPCDialogueFile({ { PsychoMantisNameTag = "PsychoMantisFail" } })
	print("Typing competition failed so dialogue set to PsychoMantisfail")
end

return MissionFailedHandlers
