local MissionCompleteHandlers = {}
local ServerHelperFunctions = require(script.Parent.ServerHelperFunctions)
-- handle all rewards
MissionCompleteHandlers["StealPhone"] = function(player)
	ServerHelperFunctions.GiveTool(player, { "Nokia", true })
	ServerHelperFunctions.SetNPCDialogueFile({ RoadmanNameTag = "RoadmanComplete" })
	print("StealPhone reward given and dialogue set to RoadmanComplete")
end

MissionCompleteHandlers["GuestMoney"] = function(player)
	ServerHelperFunctions.GiveTool(player, { "TixBag", true })
	ServerHelperFunctions.SetNPCDialogueFile({ SafechatterNameTag = "SafechatterMissionComplete" })
	print("GuestMoney reward given and dialogue set to RoadmanComplete")
end

MissionCompleteHandlers["TypingCompetition"] = function(player)
	ServerHelperFunctions.GiveTool(player, { "Keyboard", true })
	ServerHelperFunctions.SetNPCDialogueFile({ PsychoMantisNameTag = "PsychoMantisWin" })
	print("Typing competition reward given and dialogue set to PsychoMantisWin")
end

return MissionCompleteHandlers
