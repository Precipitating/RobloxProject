local RoadEvents = require(script.Parent.RoadEvents)

local function SpawnLoop()
	while true do
		-- wait a random amount of time before next attempt
		task.wait(math.random(10, 240))

		-- only spawn if there isn't already an active event
		if not RoadEvents.IsActive() then
			RoadEvents.PlayRandomEvent()
		end
	end
end

-- run the loop in its own thread so it doesn’t block anything else
task.spawn(SpawnLoop)
