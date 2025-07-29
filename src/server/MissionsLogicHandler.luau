local MissionEventHandlers = {}
local HelperFunctions = require(script.Parent.HelperFunctions)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cutsceneRemotes = ReplicatedStorage.Shared.Cutscenes

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

	-- call cutscene
	cutsceneRemotes.PlayRoadmanFail:FireClient(player)
end

return MissionEventHandlers
