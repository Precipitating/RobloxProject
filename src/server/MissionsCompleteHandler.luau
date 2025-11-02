local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local MissionCompleteHandlers = {}
local ServerHelperFunctions = require(script.Parent.ServerHelperFunctions)
local GeneralRemotes = ReplicatedStorage.Remotes
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

MissionCompleteHandlers["Laptop"] = function(_)
	ServerHelperFunctions.SetNPCDialogueFile({ BosnianNameTag = "BosnianComplete" })
	print("Dialogue set to PsychoMantisWin")
end

MissionCompleteHandlers["StealTV"] = function(_)
	ServerHelperFunctions.SetNPCDialogueFile({ ThiefNameTag = "ThiefCompleted" })
	print("Dialogue set to ThiefCompleted")
end

MissionCompleteHandlers["FindSpine"] = function(player)
	GeneralRemotes.Frankenstein.FrankensteinPuzzle:FireClient(player)
end

return MissionCompleteHandlers
