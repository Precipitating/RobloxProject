local MissionEventHandlers = {}
local HelperFunctions = require(script.Parent.HelperFunctions)

-- handle all game event
MissionEventHandlers["StealPhone"] = function()
	-- spawn the next NPC that progresses this mission
	local pos = Vector3.new(math.random(-360, 360), 5.23, -26.1)
	HelperFunctions.SpawnNPCAtPosition("PhoneVictim", pos)
end

return MissionEventHandlers
