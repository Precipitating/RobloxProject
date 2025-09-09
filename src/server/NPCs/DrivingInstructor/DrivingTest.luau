local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local HelperFunctions = require(ServerScriptService.Server.HelperFunctions)
local Roads = ServerStorage.MissionModels.DrivingInstructor:GetChildren()
local RoadNames = {}
local DrivingTest = {}

function DrivingTest.GetRoadModelNames()
	if #Roads > 0 then
		for _, model in Roads do
			table.insert(RoadNames, model.Name)
		end
	end
end

function DrivingTest.Init(player)
	if not Roads then
		error("No road models found")
	end
	DrivingTest.GetRoadModelNames()
	-- spawn start road
	local startRoad = HelperFunctions.SpawnModelAtPosition("MissionModels", "DrivingInstructor", "StraightRoad", nil)
	startRoad.Name = "StartRoad"

	local endAttachment = startRoad:FindFirstChild("End")

	if not endAttachment then
		error("No end attachment on start road")
	end

	local prevRoadName = ""

	-- connect random roads together
	for _ = 1, 20 do
		local nextRoadName = RoadNames[math.random(1, #RoadNames)]
		while nextRoadName ~= "StraightRoad" and nextRoadName == prevRoadName do
			nextRoadName = RoadNames[math.random(1, #RoadNames)]
		end
		local nextRoad = HelperFunctions.SpawnModelAtPosition("MissionModels", "DrivingInstructor", nextRoadName, nil)
		local newRoadStartAttachment = nextRoad:FindFirstChild("Start")
		local newRoadEndAttachment = nextRoad:FindFirstChild("End")

		nextRoad:PivotTo(endAttachment.WorldCFrame * newRoadStartAttachment.CFrame:Inverse())
		endAttachment = newRoadEndAttachment

		prevRoadName = nextRoadName
	end
end

return DrivingTest
