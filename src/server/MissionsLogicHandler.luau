local HelperFunctions = require(script.Parent.HelperFunctions)
local BadgeHandler = require(script.Parent.BadgeHandler)
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local BosnianRoulette = require(script.Parent.NPCs.Glitcher.BosnianRoulette)
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local SafechatterHelpers = require(script.Parent.NPCs.Safechatter.SafechatterHelpers)

local MissionEventHandlers = {}
-- handle all game events

-- Roadman
MissionEventHandlers["StealPhone"] = function(_)
	-- spawn the next NPC that progresses this mission
	local pos = Vector3.new(math.random(-360, 360), 5.23, -26.1)
	HelperFunctions.SpawnModelAtPosition("MissionModels", "Roadman", "PhoneVictim", pos)
end

MissionEventHandlers["RoadmanCaught"] = function(player)
	-- spawn surrounding cops around player
	HelperFunctions.SpawnModelAtPosition("MissionModels", "Roadman", "Cops", nil)

	-- award badge
	BadgeHandler.awardBadge(player, 4119036600108215)
	-- call cutscene
	GeneralRemotes.PlayCutscene:FireClient(player, "RoadmanFail")
end

MissionEventHandlers["RoadmanWin"] = function(player)
	HelperFunctions.SpawnModelAtPosition("MissionModels", "Roadman", "PC", nil)

	-- award badge
	BadgeHandler.awardBadge(player, 126301904067129)

	-- call cutscene
	GeneralRemotes.PlayCutscene:FireClient(player, "RoadmanWin")
end

MissionEventHandlers["RoadmanMugged"] = function(player)
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoid and rootPart then
		-- spawn signs
		local signs = HelperFunctions.SpawnModelAtPosition("MissionModels", "Roadman", "MuggedSigns", nil)

		-- award badge
		BadgeHandler.awardBadge(player, 1658087564169818)

		-- load beg animation
		GeneralRemotes.PlayAnimation:FireClient(player, "107485474814421")

		-- teleport player to sign's MoveLoc
		rootPart.CFrame = signs.MoveLoc.CFrame

		-- trigger cutscene for this player
		GeneralRemotes.PlayCutscene:FireClient(player, "RoadmanMugged")
	else
		warn("Humanoid or HumanoidRootPart missing for", player.Name)
	end
end

-- Safechatter
MissionEventHandlers["GuestMoney"] = function(_)
	print("GUEST MISSIO NBEGIN")
	HelperFunctions.SpawnMissionPositionedModels("Safechatter", "Mission")
end

MissionEventHandlers["GuestHorrorMode"] = function(player)
	local light, pathModel, prevPlayerPos, prevEnemyPos = SafechatterHelpers.InitializeGuestHorrorMode(player)

	-- handle fail obby
	local failed = SafechatterHelpers.HandleGuestHorrorModeFail(pathModel, light, player)

	-- handle touching the portal
	SafechatterHelpers.HandleGuestHorrorModeWin(pathModel, player, failed, prevPlayerPos, prevEnemyPos)
end

MissionEventHandlers["GuestPwn"] = function(player)
	GeneralRemotes.Blur:FireClient(player, 1, 100)
	local character = player.Character
	local alley = HelperFunctions.SpawnModelAtPosition("MissionModels", "Safechatter", "Alleyway")
	character:SetPrimaryPartCFrame(alley:FindFirstChild("SpawnLoc").CFrame)
	GeneralRemotes.PlayAnimation:FireClient(player, "73806503045226")
	BadgeHandler.awardBadge(player, 550797482323175)
	GeneralRemotes.PlayCutscene:FireClient(player, "GuestPwn")
	--cutsceneRemotes.PlayGuestPwn:FireClient(player)
	GeneralRemotes.Blur:FireClient(player, 1, 0)
end

MissionEventHandlers["GuestComplete"] = function(player)
	local character = player.Character
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local hallway = HelperFunctions.SpawnModelAtPosition("MissionModels", "Safechatter", "BrainwashHallway", nil)
	rootPart.CFrame = hallway:FindFirstChild("SpawnLoc").CFrame
	BadgeHandler.awardBadge(player, 3791811322299538)
	GeneralRemotes.PlayAnimation:FireClient(player, "135338300387862")
	GeneralRemotes.PlayCutscene:FireClient(player, "GuestMissionComplete")

	-- make pitch black
	Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
	Lighting.ClockTime = 0
end

-- Psycho Mantis

MissionEventHandlers["TypingCompetition"] = function(player)
	print("Typing competition start!")
	local competition = require(script.Parent.NPCs.PsychoMantis.TypingCompetition)
	if not competition then
		error("Word type competition failed to begin: Failed to obtain module")
	end
	local init = competition.Init(player)

	player.Character:SetPrimaryPartCFrame(workspace.Dumpster.Poop:GetPrimaryPartCFrame())
	if not init then
		error("Initialize word competition failed")
	end

	competition.Begin(player)
end

MissionEventHandlers["PsychoMantisFailLie"] = function(player)
	GeneralRemotes.Blur:FireClient(player, 1, 100)
	HelperFunctions.SpawnModelAtPosition("MissionModels", "PsychoMantis", "Hallway", nil)
	task.wait(3)
	GeneralRemotes.Blur:FireClient(player, 1, 0)
	GeneralRemotes.PlayCutscene:FireClient(player, "PsychoMantisFailLie")
	BadgeHandler.awardBadge(player, 1768903662252309)
end

MissionEventHandlers["PsychoMantisFailTruth"] = function(player)
	GeneralRemotes.Blur:FireClient(player, 1, 100)
	HelperFunctions.SpawnModelAtPosition("MissionModels", "PsychoMantis", "Hallway", nil)
	task.wait(3)
	GeneralRemotes.Blur:FireClient(player, 1, 0)
	GeneralRemotes.PlayCutscene:FireClient(player, "PsychoMantisFailTruth")
	BadgeHandler.awardBadge(player, 1517353246082078)
end

MissionEventHandlers["PsychoMantisWin"] = function(player)
	GeneralRemotes.Blur:FireClient(player, 1, 100)
	HelperFunctions.SpawnModelAtPosition("MissionModels", "PsychoMantis", "HallwayWin", nil)
	task.wait(3)
	GeneralRemotes.Blur:FireClient(player, 1, 0)
	GeneralRemotes.PlayCutscene:FireClient(player, "PsychoMantisWin")
	BadgeHandler.awardBadge(player, 2250718080144467)
end

-- Glitcher
MissionEventHandlers["BosnianRoulette"] = function(player)
	BosnianRoulette.Init(player)
end

return MissionEventHandlers
