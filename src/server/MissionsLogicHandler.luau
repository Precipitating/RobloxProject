local MissionEventHandlers = {}
local HelperFunctions = require(script.Parent.HelperFunctions)
local BadgeHandler = require(script.Parent.BadgeHandler)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cutsceneRemotes = ReplicatedStorage.Shared.Cutscenes
local mainMusic = ReplicatedStorage.Shared.Sounds.Main

-- handle all game events
MissionEventHandlers["StealPhone"] = function()
	-- spawn the next NPC that progresses this mission
	local pos = Vector3.new(math.random(-360, 360), 5.23, -26.1)
	HelperFunctions.SpawnModelAtPosition("NPCS", "PhoneVictim", pos)
end

MissionEventHandlers["RoadmanCaught"] = function(player)
	-- stop movement
	local character = player.Character
	character.Humanoid.WalkSpeed = 0
	character.Humanoid.JumpPower = 0
	-- spawn surrounding cops around player
	HelperFunctions.SpawnModelAtPosition("MissionModels", "Cops", nil)
	mainMusic:Stop()
	mainMusic:Destroy()
	-- award badge
	BadgeHandler.awardBadge(player, 3145652566759102)
	-- call cutscene
	cutsceneRemotes.PlayRoadmanFail:FireClient(player)
end

MissionEventHandlers["RoadmanWin"] = function(player)
	-- stop movement
	local character = player.Character
	character.Humanoid.WalkSpeed = 0
	character.Humanoid.JumpPower = 0
	HelperFunctions.SpawnModelAtPosition("MissionModels", "PC", nil)

	-- destroy main music, because after this function is called, hideUI (UIController) will call, auto resuming main music
	mainMusic:Stop()
	mainMusic:Destroy()

	-- award badge
	BadgeHandler.awardBadge(player, 2251989026476496)

	-- call cutscene
	cutsceneRemotes.PlayRoadmanWin:FireClient(player)
end

return MissionEventHandlers
