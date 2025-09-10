local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local HelperFunctions = require(ServerScriptService.Server.HelperFunctions)
local Roads = ServerStorage.MissionModels.DrivingInstructor:GetChildren()
local RoadNames = {}
local CurrentRoads = {}
local DrivingTest = {}
local RoadCount = 0
local PrevRoadTurnName = ""
local CheckpointReachBeforeDeletion = 5
local CheckpointsReached = 0

function DrivingTest.GetRoadModelNames()
	if #Roads > 0 then
		for _, model in Roads do
			if string.find(model.Name:lower(), "road") then
				table.insert(RoadNames, model.Name)
			end
		end
	end
end

local function RedLightHandler(currentRoad)
	local ranRedLight = currentRoad:GetAttribute("IsRedLight")
	if ranRedLight then
		print("RAN RED LIGHT!")
	end
end

function DrivingTest.SpawnTrafficLight(currentRoad)
	if math.random() < 0.3 then
		local trafficLight =
			HelperFunctions.SpawnModelAtPosition("MissionModels", "DrivingInstructor", "TrafficLight", nil)
		trafficLight:PivotTo(currentRoad:FindFirstChild("TrafficLightPos"):GetPivot())
		trafficLight.Parent = currentRoad

		-- change the attribute to determine if red light
		local changer = trafficLight:FindFirstChild("LightStateChanger")
		local bindable = changer:FindFirstChild("LightChanged")

		bindable.Event:Connect(function(state)
			if state == "Red" then
				currentRoad:SetAttribute("IsRedLight", true)
			else
				currentRoad:SetAttribute("IsRedLight", false)
			end
		end)
	end
end

local function GenerateRoads(amountToSpawn, currentEndAttachment)
	for _ = 1, amountToSpawn do
		-- choose a valid road type
		local nextRoadName = RoadNames[math.random(1, #RoadNames)]
		while PrevRoadTurnName == nextRoadName do
			nextRoadName = RoadNames[math.random(1, #RoadNames)]
		end
		-- spawn road at end of current road and get attachment references
		local nextRoad = HelperFunctions.SpawnModelAtPosition("MissionModels", "DrivingInstructor", nextRoadName, nil)
		local newRoadStartAttachment = nextRoad:FindFirstChild("Start")
		local newRoadEndAttachment = nextRoad:FindFirstChild("End")
		nextRoad:PivotTo(currentEndAttachment.WorldCFrame * newRoadStartAttachment.CFrame:Inverse())
		currentEndAttachment = newRoadEndAttachment

		-- store the left/right road names if its chosen, used to prevent going in a circle
		if nextRoadName ~= "StraightRoad" then
			PrevRoadTurnName = nextRoadName
		else
			-- spawn traffic light if straight road is being spawned (30% chance)
			DrivingTest.SpawnTrafficLight(nextRoad)
		end

		local conn
		conn = nextRoad:FindFirstChild("Completed").Touched:Connect(function(hit)
			print("Checkpoint touched!")
			conn:Disconnect()

			-- handle deleting and generating infinite roads
			CheckpointsReached = CheckpointsReached + 1
			if (CheckpointsReached % CheckpointReachBeforeDeletion) == 0 then
				-- regenerate at ends
				-- get updated last road end attachment as well
				local lastRoad = CurrentRoads[#CurrentRoads]
				local newEndAttachment = lastRoad:FindFirstChild("End")
				GenerateRoads(CheckpointReachBeforeDeletion, newEndAttachment)

				-- delete roads X behind
				for _ = 1, CheckpointReachBeforeDeletion do
					CurrentRoads[1]:Destroy()
					table.remove(CurrentRoads, 1)
					RoadCount = RoadCount - 1
				end
			end

			-- red light handler
			RedLightHandler(nextRoad)
		end)

		RoadCount = RoadCount + 1
		table.insert(CurrentRoads, nextRoad)
	end
end

function DrivingTest.Init(player)
	if not Roads then
		error("No road models found")
	end
	DrivingTest.GetRoadModelNames()
	-- spawn start road
	local startRoad = HelperFunctions.SpawnModelAtPosition("MissionModels", "DrivingInstructor", "StraightRoad", nil)
	player.Character:PivotTo(startRoad:GetPivot() * CFrame.new(0, 10, 10))
	startRoad.Name = "StartRoad"
	RoadCount = RoadCount + 1
	table.insert(CurrentRoads, startRoad)

	local endAttachment = startRoad:FindFirstChild("End")

	if not endAttachment then
		error("No end attachment on start road")
	end

	GenerateRoads(20, endAttachment)
end

return DrivingTest
