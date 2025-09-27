local ServerHelperFunctions = require(script.Parent.ServerHelperFunctions)
local MissionFailedHandlers = {}

MissionFailedHandlers["TypingCompetition"] = function(_)
	ServerHelperFunctions.SetNPCDialogueFile({ PsychoMantisNameTag = "PsychoMantisFail" })
	print("Typing competition failed so dialogue set to PsychoMantisfail")
end

MissionFailedHandlers["Laptop"] = function(_)
	ServerHelperFunctions.SetNPCDialogueFile({ BosnianNameTag = "BosnianFailed" })
	print("Bosnian failed mission so dialogue set to BosnianScammed")
end

return MissionFailedHandlers
