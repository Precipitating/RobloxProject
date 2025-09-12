local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local HelperFunctions = require(ServerScriptService.Server.HelperFunctions)
local GeneralRemotes = ReplicatedStorage.Remotes
local Roads = ServerStorage.MissionModels.DrivingInstructor:GetChildren()
local RoadNames = {}
local CurrentRoads = {}
local DrivingTest = {}
local RoadCount = 0
local CheckpointReachBeforeDeletion = 10
local CheckpointsReached = 0
local CurrentRoadIdx = 1
local RoundAboutCooldown = 20
local TurnCooldown = 5

local function GetRayDirection(attachment, direction: string, distance: number)
	local cf = attachment.WorldCFrame

	if direction == "Forward" then
		return -cf.LookVector * distance
	elseif direction == "Left" then
		return cf.RightVector * distance
	elseif direction == "Right" then
		return -cf.RightVector * distance
	elseif direction == "Back" then
		return -cf.LookVector * distance
	else
		warn("Invalid direction specified, defaulting to Forward")
		return cf.LookVector * distance
	end
end

local function GetPartsByName(model, nameFragment)
	local result = {}
	for _, obj in ipairs(model:GetDescendants()) do
		if string.find(string.lower(obj.Name), string.lower(nameFragment)) then
			table.insert(result, obj)
		end
	end
	return result
end

local function SpawnTrafficLight(currentRoad)
	if math.random() < 0.2 then
		local trafficLight =
			HelperFunctions.SpawnModelAtPosition("MissionModels", "DrivingInstructor", "TrafficLight", nil)
		trafficLight:PivotTo(currentRoad:FindFirstChild("TrafficLightPos"):GetPivot())
		trafficLight.Parent = currentRoad

		-- change the attribute true if red light else false
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

local function GetOffsetPosition(attachment, forwardOffset: number, rightOffset: number, upOffset: number)
	local cf = attachment.WorldCFrame
	local origin = attachment.WorldPosition

	-- Calculate total offset using local axes
	local offset = cf.LookVector * forwardOffset -- forward/back
		+ cf.RightVector * rightOffset -- right/left
		+ cf.UpVector * upOffset -- up/down

	return origin + offset
end
-- raycast and if it doesn't hit another road, its a valid road name to spawn
local function GetSafeRoadsList(endAttachment)
	local SafeRoadsToSpawn = {}
	local forwardDirection = GetRayDirection(endAttachment, "Forward", 100)
	local leftDirection = GetRayDirection(endAttachment, "Left", 100)
	local rightDirection = GetRayDirection(endAttachment, "Right", 100)

	-- raycast should ignore the road it's firing from
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { endAttachment.Parent } -- ignore the parent part
	params.FilterType = Enum.RaycastFilterType.Exclude

	-- start raycasts
	local forwardResult = workspace:Raycast(GetOffsetPosition(endAttachment, -20, 0, 5), forwardDirection, params)
	local leftResult = workspace:Raycast(GetOffsetPosition(endAttachment, -20, 10, 5), leftDirection, params)
	local rightResult = workspace:Raycast(GetOffsetPosition(endAttachment, -20, -10, 5), rightDirection, params)

	local function AddSafeRoads(rayResult, roadName)
		-- if this is a roundabout, require all 3 rays to be clear
		if roadName == "RoundaboutRoad" then
			if not forwardResult and not leftResult and not rightResult and RoadCount % RoundAboutCooldown == 0 then
				table.insert(SafeRoadsToSpawn, roadName)
			end
			return
		end

		-- skip if ray hit anything
		if rayResult then
			warn(`Ray hit {rayResult.Instance.Name} when checking if {roadName} is valid to place.`)
			return
		end

		-- add turns if cooldown allows
		if (roadName == "RoadLeft" or roadName == "RoadRight") and RoadCount % TurnCooldown == 0 then
			table.insert(SafeRoadsToSpawn, roadName)
			return
		end

		-- straight roads are always allowed
		if roadName == "StraightRoad" then
			table.insert(SafeRoadsToSpawn, roadName)
			print("Straight")
		end
	end

	AddSafeRoads(forwardResult, "StraightRoad")
	AddSafeRoads(leftResult, "RoadLeft")
	AddSafeRoads(rightResult, "RoadRight")
	AddSafeRoads(nil, "RoundaboutRoad")

	print(SafeRoadsToSpawn)

	return SafeRoadsToSpawn
end

local function SpawnRoad(name: string, attachmentToSpawnAt: Attachment?, player: Player)
	local nextRoad = HelperFunctions.SpawnModelAtPosition("MissionModels", "DrivingInstructor", name, nil)
	local newRoadStartAttachment = nextRoad:FindFirstChild("Start")
	local newRoadEndAttachment = nextRoad:FindFirstChild("End")
	if attachmentToSpawnAt then
		nextRoad:PivotTo(attachmentToSpawnAt.WorldCFrame * newRoadStartAttachment.CFrame:Inverse())
	end

	if not newRoadEndAttachment then
		if name == "RoundaboutRoad" then
			print("Roundabout chosen")
			-- roundabout is handled differently due to many exits

			-- attachments
			local exits = GetPartsByName(nextRoad, "end")
			local chosenExitStringVal = nextRoad:FindFirstChild("ChosenExit")
			-- choose a valid exit
			local chosenExit = exits[math.random(1, #exits)]
			newRoadEndAttachment = chosenExit
			-- set the valid exit so we can detect if player has drove through it
			chosenExitStringVal.Value = string.sub(newRoadEndAttachment.Name, 1, -4)

			-- generate some fake roads on wrong exits to prevent emptiness
			for _, endAttachment in ipairs(exits) do
				if endAttachment ~= chosenExit then
					DrivingTest.GenerateRoads(player, 5, endAttachment, true)
				end
			end
		else
			if name ~= "EndRoad" then
				error(`No end attachment on road {name}`)
			end
		end
	end

	-- spawn traffic light if straight road is being spawned (30% chance)
	if name == "StraightRoad" then
		SpawnTrafficLight(nextRoad)
	end

	table.insert(CurrentRoads, nextRoad)
	RoadCount = RoadCount + 1

	return nextRoad, newRoadStartAttachment, newRoadEndAttachment
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

local function GetNextRoadName(currentEndAttachment)
	local nextRoadName = "StraightRoad" -- default
	if currentEndAttachment then
		local safeRoadNames = GetSafeRoadsList(currentEndAttachment)
		if safeRoadNames and #safeRoadNames > 0 then
			nextRoadName = safeRoadNames[math.random(1, #safeRoadNames)]
		else
			error("No direction valid")
		end
	end

	return nextRoadName
end

function DrivingTest.CheckpointTouchedHandler(player, nextRoad)
	local conn
	local completedPart = nextRoad:FindFirstChild("Completed")
	conn = completedPart.Touched:Connect(function(hit)
		if not CollectionService:HasTag(hit, "DrivingTestCar") then
			return
		end

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
			DrivingTest.GenerateRoads(player, CheckpointReachBeforeDeletion, newEndAttachment)

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
end

function DrivingTest.GenerateRoads(
	player: Player,
	amountToSpawn: number,
	currentEndAttachment: Attachment?,
	capOff: boolean?
)
	for _ = 1, amountToSpawn do
		if not currentEndAttachment then
			warn("Generation attachment handle is nil, ending.")
			return
		end
		-- choose a valid road type
		local nextRoadName = GetNextRoadName(currentEndAttachment)

		-- spawn road at end of current road and get attachment references
		local nextRoad, _, nextRoadEndAttachment = SpawnRoad(nextRoadName, currentEndAttachment, player)

		currentEndAttachment = nextRoadEndAttachment

		-- handle checkpoint
		DrivingTest.CheckpointTouchedHandler(player, nextRoad)
	end

	if capOff then
		SpawnRoad("EndRoad", currentEndAttachment, player)
	end
end

local function SpawnCar(startRoad)
	-- spawn car
	local car = HelperFunctions.SpawnModelAtPosition("MissionModels", "DrivingInstructor", "Car", nil)
	car:PivotTo(startRoad:GetPivot() * CFrame.new(0, 10, 20) * CFrame.Angles(0, 0, math.rad(180)))
	task.wait(1)
	local seat = car["Reliant Robin"]:FindFirstChild("DriveSeat")

	return seat
end

local function SeatPlayerToCar(player, seat)
	-- force seat player to car
	local humanoid = player.Character:FindFirstChild("Humanoid")
	if not humanoid then
		error("Humanoid not found")
	end
	seat:Sit(humanoid)
end

function DrivingTest.Init(player)
	if not Roads then
		error("No road models found")
	end
	DrivingTest.GetRoadModelNames()

	-- spawn start roads
	local startRoad, _, startRoadEndAttachment = SpawnRoad("Start", nil, player)
	local _, _, startRoad2EndAttachment = SpawnRoad("StraightRoad", startRoadEndAttachment, player)

	-- teleport player to startRoad
	player.Character:PivotTo(startRoad:GetPivot() * CFrame.new(0, 10, 10))

	-- spawn & seat player to car
	player.Character.Humanoid.JumpPower = 0
	local seat = SpawnCar(startRoad)
	SeatPlayerToCar(player, seat)

	DrivingTest.GenerateRoads(player, 20, startRoad2EndAttachment)
end

return DrivingTest
