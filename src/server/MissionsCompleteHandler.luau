local MissionCompleteHandlers = {}
local ServerScriptService = game:GetService("ServerScriptService")
local HelperFunctions = require(ServerScriptService.Server.HelperFunctions)

-- handle all rewards
MissionCompleteHandlers["StealPhone"] = function(player)
	HelperFunctions.GiveTool(player, { "Nokia", true })
	HelperFunctions.SetNPCDialogueFile({ RoadmanNameTag = "RoadmanComplete" })
	print("StealPhone reward given and dialogue set to RoadmanComplete")
end

MissionCompleteHandlers["GuestMoney"] = function(player)
	HelperFunctions.GiveTool(player, { "TixBag", true })
	HelperFunctions.SetNPCDialogueFile({ SafechatterNameTag = "SafechatterMissionComplete" })
	print("GuestMoney reward given and dialogue set to RoadmanComplete")
end

MissionCompleteHandlers["TypingCompetition"] = function(player)
	HelperFunctions.GiveTool(player, { "Keyboard", true })
	HelperFunctions.SetNPCDialogueFile({ PsychoMantisNameTag = "PsychoMantisWin" })
	print("Typing competition reward given and dialogue set to PsychoMantisWin")
end

return MissionCompleteHandlers
