local RoadEvents = require(script.Parent.RoadEvents)

while true do
	task.wait(math.random(10, 240))
	if not RoadEvents.IsActive() then
		RoadEvents.SpawnLearnerDriver()
	end
end
