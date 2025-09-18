local ServerHelperFunctions = require(script.Parent.ServerHelperFunctions)
local MissionFailedHandlers = {}

MissionFailedHandlers["TypingCompetition"] = function(_)
	ServerHelperFunctions.SetNPCDialogueFile({ { PsychoMantisNameTag = "PsychoMantisFail" } })
	print("Typing competition failed so dialogue set to PsychoMantisfail")
end

return MissionFailedHandlers
