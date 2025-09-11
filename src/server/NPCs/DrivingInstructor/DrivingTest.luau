local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local HelperFunctions = require(ServerScriptService.Server.HelperFunctions)
local GeneralRemotes = ReplicatedStorage.Remotes
local Roads = ServerStorage.MissionModels.DrivingInstructor:GetChildren()
local RoadNames = {}
local CurrentRoads = {}
local DrivingTest = {}
local RoadCount = 0
local PrevRoadTurnName = ""
local CheckpointReachBeforeDeletion = 5
local CheckpointsReached = 0
local CurrentRoadIdx = 1
local RoundAboutCooldown = 5
local TurnCooldown = 2

local function GetPartsByName(model, nameFragment)
	local result = {}
	for _, obj in ipairs(model:GetDescendants()) do
		if string.find(string.lower(obj.Name), string.lower(nameFragment)) then
			table.insert(result, obj)
		end
	end
	return result
end

function DrivingTest.GetRoadModelNames()
	if #Roads > 0 then
		for _, model in Roads do
			if string.find(model.Name:lower(), "road") then
				table.insert(RoadNames, model.Name)
			end
		end
	end
end

local function RedLightHandler(player, currentRoad)
	local ranRedLight = currentRoad:GetAttribute("IsRedLight")
	if ranRedLight then
		print("RAN RED LIGHT!")
		GeneralRemotes.PlaySound:InvokeClient(player, "Error")
	end
end

local function SpawnTrafficLight(currentRoad)
	if math.random() < 0.2 then
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

local function GenerateRoads(player, amountToSpawn, currentEndAttachment)
	for _ = 1, amountToSpawn do
		-- choose a valid road type
		local nextRoadName = RoadNames[math.random(1, #RoadNames)]
		while (nextRoadName == "RoadLeft" or nextRoadName == "RoadRight") and TurnCooldown > 0 do
			nextRoadName = "StraightRoad"
		end
		while PrevRoadTurnName == nextRoadName do
			nextRoadName = RoadNames[math.random(1, #RoadNames)]
		end
		while nextRoadName == "RoundaboutRoad" and RoundAboutCooldown > 0 do
			nextRoadName = RoadNames[math.random(1, #RoadNames)]
		end
		-- spawn road at end of current road and get attachment references
		local nextRoad = HelperFunctions.SpawnModelAtPosition("MissionModels", "DrivingInstructor", nextRoadName, nil)
		local newRoadStartAttachment = nextRoad:FindFirstChild("Start")
		local newRoadEndAttachment = nextRoad:FindFirstChild("End")

		if nextRoadName == "RoundaboutRoad" then
			local exits = GetPartsByName(nextRoad, "end")
			local chosenExitStringVal = nextRoad:FindFirstChild("ChosenExit")
			-- choose a valid exit
			newRoadEndAttachment = exits[math.random(1, #exits)]
			-- set the valid exit for detection
			chosenExitStringVal.Value = string.sub(newRoadEndAttachment.Name, 1, -4)
		end
		nextRoad:PivotTo(currentEndAttachment.WorldCFrame * newRoadStartAttachment.CFrame:Inverse())
		currentEndAttachment = newRoadEndAttachment

		-- store the left/right road names if its chosen, used to prevent same turn repeating
		if nextRoadName ~= "StraightRoad" then
			PrevRoadTurnName = nextRoadName
		else
			-- spawn traffic light if straight road is being spawned (30% chance)
			SpawnTrafficLight(nextRoad)
		end

		local conn
		local completedPart = nextRoad:FindFirstChild("Completed")
		conn = completedPart.Touched:Connect(function(hit)
			print("Checkpoint touched!")
			CurrentRoadIdx = CurrentRoadIdx + 1
			conn:Disconnect()
			-- handle deleting and generating infinite roads
			CheckpointsReached = CheckpointsReached + 1
			if (CheckpointsReached % CheckpointReachBeforeDeletion) == 0 then
				-- regenerate at ends
				-- get updated last road end attachment as well
				local lastRoad = CurrentRoads[#CurrentRoads]
				local newEndAttachment = lastRoad:FindFirstChild("End")
				GenerateRoads(player, CheckpointReachBeforeDeletion, newEndAttachment)

				-- delete roads X behind
				for _ = 1, CheckpointReachBeforeDeletion do
					CurrentRoads[1]:Destroy()
					table.remove(CurrentRoads, 1)
					RoadCount = RoadCount - 1
				end
			end

			-- red light handler
			RedLightHandler(player, nextRoad)
		end)

		RoadCount = RoadCount + 1
		RoundAboutCooldown = RoundAboutCooldown - 1
		TurnCooldown = TurnCooldown - 1
		if RoundAboutCooldown <= 0 then
			RoundAboutCooldown = 5
		end
		if TurnCooldown <= 0 then
			TurnCooldown = 3
		end
		table.insert(CurrentRoads, nextRoad)
	end
end

function DrivingTest.Init(player)
	if not Roads then
		error("No road models found")
	end
	-- disable jump
	player.Character.Humanoid.JumpPower = 0

	DrivingTest.GetRoadModelNames()
	-- spawn start road
	local startRoad = HelperFunctions.SpawnModelAtPosition("MissionModels", "DrivingInstructor", "Start", nil)
	player.Character:PivotTo(startRoad:GetPivot() * CFrame.new(0, 10, 10))
	RoadCount = RoadCount + 1

	-- spawn car
	local car = HelperFunctions.SpawnModelAtPosition("MissionModels", "DrivingInstructor", "Car", nil)
	car:PivotTo(startRoad:GetPivot() * CFrame.new(0, 10, 20) * CFrame.Angles(0, 0, math.rad(180)))
	task.wait(1)
	local seat = car["Reliant Robin"]:FindFirstChild("DriveSeat")

	-- force seat player to car
	local humanoid = player.Character:FindFirstChild("Humanoid")
	if not humanoid then
		error("Humanoid not found")
	end
	seat:Sit(humanoid)

	local endAttachment = startRoad:FindFirstChild("End")

	if not endAttachment then
		error("No end attachment on start road")
	end

	local startRoad2 = HelperFunctions.SpawnModelAtPosition("MissionModels", "DrivingInstructor", "StraightRoad", nil)
	local newRoadAttachment = startRoad2:FindFirstChild("Start")
	local newEndAttachment = startRoad2:FindFirstChild("End")
	startRoad2:PivotTo(endAttachment.WorldCFrame * newRoadAttachment.CFrame:Inverse())
	table.insert(CurrentRoads, startRoad)
	table.insert(CurrentRoads, startRoad2)

	GenerateRoads(player, 20, newEndAttachment)
end

return DrivingTest
