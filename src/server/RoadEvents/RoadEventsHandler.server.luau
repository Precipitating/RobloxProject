local RoadEvents = require(script.Parent.RoadEvents)

-- run the loop in its own thread so it doesn’t block anything else
task.spawn(RoadEvents.SpawnLoop)
