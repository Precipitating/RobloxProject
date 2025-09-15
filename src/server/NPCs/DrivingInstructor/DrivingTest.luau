local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ConnectionManager = require(ServerScriptService.Server.ConnectionManager)
local HelperFunctions = require(ServerScriptService.Server.HelperFunctions)
local GeneralRemotes = ReplicatedStorage.Remotes
local PositionBeforeTeleport = nil
local Roads = ServerStorage.MissionModels.DrivingInstructor:GetChildren()
local CurrentRoads = {}
local PooledRoads = {}
local DrivingTest = {}

-- roundabout
local CorrectRoundAboutDirections = {}
local RoundAboutDirectionSpoken = false
local RoundAboutDirectionConversion = {
	Left = "first exit",
	Forward = "second exit",
	Right = "third exit",
}
local RoundAboutExitsToID = {
	Left = 1,
	Forward = 2,
	Right = 3,
}
local RoundAboutExpectedCheckpoint = 1

-- values are measured as 'per road'
local RoadsSpawned = 0
local CheckpointReachBeforeDeletion = 10
local CheckpointsReached = 0
local RoundAboutCooldown = 20
local TurnCooldown = 10
local RoadFinishCount = 100
local TrafficLightCooldown = 10
local FakeRoadsToSpawnAtRoundabout = 3

-- demerits
local RanRedLightCount = 0
local FailedRoundAbout = 0

function DrivingTest.GetDrivingTestResults()
	return { RedLight = RanRedLightCount, Roundabout = FailedRoundAbout }
end

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
	local hasTrafficLight = currentRoad:FindFirstChild("TrafficLight")
	if hasTrafficLight then
		-- since we pooled, we need to remove it if it already has a traffic light and recalculate
		-- since it will ruin the TrafficLightCooldown pattern if not.
		hasTrafficLight:Destroy()
		currentRoad:SetAttribute("IsRedLight", false)
	end

	if (RoadsSpawned % TrafficLightCooldown) == 0 and math.random() < 0.5 then
		print("Traffic light should spawn")
		local trafficLight =
			HelperFunctions.SpawnModelAtPosition("MissionModels", "DrivingInstructor", "TrafficLight", nil)
		trafficLight:PivotTo(currentRoad:FindFirstChild("TrafficLightPos"):GetPivot())
		trafficLight.Parent = currentRoad

		-- change the attribute true if red light else false
		local changer = trafficLight:FindFirstChild("LightStateChanger")
		local bindable = changer:FindFirstChild("LightChanged")
		local conn

		conn = bindable.Event:Connect(function(state)
			if state == "Red" then
				currentRoad:SetAttribute("IsRedLight", true)
			else
				currentRoad:SetAttribute("IsRedLight", false)
			end
		end)

		ConnectionManager.Add(currentRoad:GetAttribute("ID"), conn)
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
			if not forwardResult and not leftResult and not rightResult and RoadsSpawned % RoundAboutCooldown == 0 then
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
		if (roadName == "RoadLeft" or roadName == "RoadRight") and RoadsSpawned % TurnCooldown == 0 then
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

function DrivingTest.FindRoadInPool(name)
	if #PooledRoads <= 0 then
		return nil
	end

	for i, road in ipairs(PooledRoads) do
		if road.Name == name then
			table.remove(PooledRoads, i)
			return road
		end
	end

	return nil
end

local function AnnounceNextRoundAbout(player)
	-- voiceline speaker for roundabout directions
	if not RoundAboutDirectionSpoken and #CorrectRoundAboutDirections > 0 then
		RoundAboutDirectionSpoken = true
		local voiceline = GeneralRemotes.PlayTTS:InvokeClient(
			player,
			`At the next roundabout, please enter the {RoundAboutDirectionConversion[CorrectRoundAboutDirections[1]]}`
		)
		if not voiceline then
			RoundAboutDirectionSpoken = false
		end
	end
end

local function SpawnRoad(name: string, attachmentToSpawnAt: Attachment?, player: Player)
	local nextRoad = nil
	local roadInPool = DrivingTest.FindRoadInPool(name)
	if roadInPool then
		nextRoad = roadInPool
	else
		nextRoad = HelperFunctions.SpawnModelAtPosition("MissionModels", "DrivingInstructor", name, nil)
		-- set unique ID for each road spawned
		if nextRoad:GetAttribute("ID") then
			nextRoad:SetAttribute("ID", HttpService:GenerateGUID(false))
		end
	end

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
			table.insert(CorrectRoundAboutDirections, chosenExitStringVal.Value)
			print(CorrectRoundAboutDirections)

			-- generate some fake roads on wrong exits to prevent emptiness
			for _, endAttachment in ipairs(exits) do
				if endAttachment ~= chosenExit then
					DrivingTest.GenerateRoads(
						player,
						FakeRoadsToSpawnAtRoundabout,
						endAttachment,
						true,
						false,
						"RoundaboutRoad"
					)
				end
			end
		else
			if name ~= "EndRoad" and name ~= "FinishedRoad" then
				error(`No end attachment on road {name}`)
			end
		end
	end

	-- spawn traffic light if straight road is being spawned (30% chance)
	if name == "StraightRoad" then
		SpawnTrafficLight(nextRoad)
	end

	table.insert(CurrentRoads, nextRoad)
	RoadsSpawned = RoadsSpawned + 1

	return nextRoad, newRoadStartAttachment, newRoadEndAttachment
end

-- runs on each Completed part collision if the current road's red light is active
local function RedLightHandler(player, currentRoad)
	local ranRedLight = currentRoad:GetAttribute("IsRedLight")
	if ranRedLight then
		print("RAN RED LIGHT!")
		GeneralRemotes.PlaySound:InvokeClient(player, "Error")
		RanRedLightCount = RanRedLightCount + 1
	end
end

-- returns a single random road string after using GetSafeRoadsList to detect safe roads to spawn
local function GetNextRoadName(currentEndAttachment, excludeRoad: string?)
	local nextRoadName = "StraightRoad" -- default
	if currentEndAttachment then
		local safeRoadNames = GetSafeRoadsList(currentEndAttachment)

		-- exclude roads if specified
		if excludeRoad then
			if excludeRoad then
				for i, v in ipairs(safeRoadNames) do
					if v == excludeRoad then
						table.remove(safeRoadNames, i)
						break
					end
				end
			end
		end

		-- pick random road out of list
		if safeRoadNames and #safeRoadNames > 0 then
			nextRoadName = safeRoadNames[math.random(1, #safeRoadNames)]
		else
			nextRoadName = "StraightDownRoad"
			warn("No direction valid, so default to Straight Down")
		end
	end

	return nextRoadName
end

-- last road that ends the minigame, determined by roadcount being >= RoadFinishCount
local function AddFinishedRoad(player)
	local lastRoad = CurrentRoads[#CurrentRoads]
	local newEndAttachment = lastRoad:FindFirstChild("End")
	local endRoad, _, _ = SpawnRoad("FinishedRoad", newEndAttachment, player)
	local endCollide = endRoad:FindFirstChild("EndCollide")

	local conn
	conn = endCollide.Touched:Connect(function(hit)
		if not CollectionService:HasTag(hit, "DrivingTestCar") then
			return
		end
		conn:Disconnect()
		-- transition
		GeneralRemotes.BlackFade:FireClient(player, 0.5, 0)
		GeneralRemotes.DisableControls:FireClient(player, nil)

		player.Character.Humanoid.Sit = false
		player.Character.Humanoid.JumpPower = 50
		task.wait(1)
		-- teleport back to room
		player.Character:PivotTo(PositionBeforeTeleport)

		task.wait(1)
		-- revert music, enable controls and change instructor dialogue.
		GeneralRemotes.BlackFade:FireClient(player, 0.5, 1)
		GeneralRemotes.EnableControls:FireClient(player, nil)
		GeneralRemotes.PlayTheme:FireClient(player, "Main")
		HelperFunctions.SetNPCDialogueFile({ DrivingInstructorNameTag = "DrivingInstructorResults" })
	end)
end

-- connect the roundabout validators, to determine if the player has driven around the
-- roundabout correctly.
local function HandleRoundAboutValidation(player, roundAboutModel, correctExit)
	local roundAboutValidators = roundAboutModel:FindFirstChild("ValidationCheckpoints")
	local correctExitToID = RoundAboutExitsToID[correctExit]

	if roundAboutValidators then
		local validators = roundAboutValidators:GetChildren()

		for _, touchedValidator in ipairs(validators) do
			local conn
			conn = touchedValidator.Touched:Connect(function(hit)
				if not CollectionService:HasTag(hit, "DrivingTestCar") then
					return
				end
				conn:Disconnect()

				-- check if touched in correct order
				local touchedCheckpointID = touchedValidator:GetAttribute("CheckpointID")
				if touchedCheckpointID then
					-- touched correct order
					if touchedCheckpointID == RoundAboutExpectedCheckpoint then
						-- if not last checkpoint before correct exit, add one to RoundAboutExpectedCheckpoint
						if touchedCheckpointID ~= correctExitToID then
							RoundAboutExpectedCheckpoint = RoundAboutExpectedCheckpoint + 1
							print("Correct roundabout checkpoint touched! not finished yet!")
						else
							-- indicates final checkpoint reached to exit correctly
							RoundAboutExpectedCheckpoint = 1
							print("Final roundabout checkpoint reached! safe to exit")
						end
						GeneralRemotes.PlaySound:InvokeClient(player, "Correct")
					else
						-- wrong order, fail outright & reset
						print(`Expected {RoundAboutExpectedCheckpoint}, touched {touchedCheckpointID} `)
						GeneralRemotes.PlaySound:InvokeClient(player, "Error")
						ConnectionManager.Clear(roundAboutModel:GetAttribute("ID"))
						FailedRoundAbout = FailedRoundAbout + 1
						RoundAboutExpectedCheckpoint = 1
					end
				end
			end)
			-- it only disconnects IF we touch it, so if we pool we need to store the
			-- other connections that aren't touched to disconnect it all
			ConnectionManager.Add(roundAboutModel:GetAttribute("ID"), conn)
		end
	end
end

function DrivingTest.RoundAboutCheckpointTouchedHandler(player, roundAboutModel)
	local completedNames = { "LeftCompleted", "ForwardCompleted", "RightCompleted" }
	local correctCompletedName = `{roundAboutModel.ChosenExit.Value}Completed`
	local id = roundAboutModel:GetAttribute("ID")

	-- handle roundabout exit connections
	for _, name in ipairs(completedNames) do
		-- if entered correct way
		local touchPart = roundAboutModel:FindFirstChild(name)
		if name == correctCompletedName then
			local conn
			conn = touchPart.Touched:Connect(function(hit)
				if not CollectionService:HasTag(hit, "DrivingTestCar") then
					return
				end
				conn:Disconnect()
				-- ok to announce next roundabout if we have one stored in CorrectRoundAboutDirections
				if RoundAboutDirectionSpoken then
					RoundAboutDirectionSpoken = false
					if #CorrectRoundAboutDirections > 0 then
						table.remove(CorrectRoundAboutDirections, 1)
						AnnounceNextRoundAbout(player)
					end
				end

				-- count as if we've entered FakeRoadsToSpawnAtRoundabout * 2 roads, as they don't have checkpoints enabled,
				-- without this, road deletion/creation will lag behind every time we go thru a roundabout
				-- (as we determine when to delete/generate per checkpoint touched)
				for _ = 1, FakeRoadsToSpawnAtRoundabout * 2 do
					DrivingTest.HandleGeneratingAndDeletingRoads(player)
				end

				-- disconnect lingering exits that haven't been entered (pooling the model keeps this old connection)
				ConnectionManager.Clear(id)
			end)
		else
			-- wrong exits
			local conn2
			conn2 = touchPart.Touched:Connect(function(hit)
				if not CollectionService:HasTag(hit, "DrivingTestCar") then
					return
				end
				conn2:Disconnect()
				GeneralRemotes.PlaySound:InvokeClient(player, "Error")
				FailedRoundAbout = FailedRoundAbout + 1
				ConnectionManager.Clear(id)
			end)

			ConnectionManager.Add(id, conn2)
		end
	end

	-- handle the roundabout validation
	HandleRoundAboutValidation(player, roundAboutModel, roundAboutModel.ChosenExit.Value)
end

function DrivingTest.HandleGeneratingAndDeletingRoads(player)
	-- handle deleting and generating infinite roads
	CheckpointsReached = CheckpointsReached + 1
	if (CheckpointsReached % CheckpointReachBeforeDeletion) == 0 then
		print("Start pooling roads")
		-- regenerate at ends
		-- get updated last road end attachment
		local lastRoad = CurrentRoads[#CurrentRoads]
		local newEndAttachment = lastRoad:FindFirstChild("End")
		DrivingTest.GenerateRoads(player, CheckpointReachBeforeDeletion, newEndAttachment, false, true)

		-- store deleted roads in pool
		for _ = 1, CheckpointReachBeforeDeletion do
			-- theres only going to be one "start model", so just destroy and not pool
			if CurrentRoads[1].Name == "Start" then
				CurrentRoads[1]:Destroy()
				table.remove(CurrentRoads, 1)
				continue
			end

			table.insert(PooledRoads, CurrentRoads[1])
			-- hide the pooled models somewhere impossible to see
			PooledRoads[#PooledRoads]:PivotTo(CFrame.new(0, -9999, 0))
			ConnectionManager.Clear(PooledRoads[#PooledRoads]:GetAttribute("ID"))
			table.remove(CurrentRoads, 1)
		end

		-- add an invis wall incase player decides to go back & drive off the map
		local firstRoad = CurrentRoads[1]
		local fallBarrier = workspace:FindFirstChild("FallBarrier")
		if not fallBarrier then
			fallBarrier = Instance.new("Part")
			fallBarrier.Anchored = true
			fallBarrier.Name = "FallBarrier"
			fallBarrier.Size = Vector3.new(80, 40, 1)
			fallBarrier.Transparency = 1
			fallBarrier.Parent = workspace
		end
		fallBarrier.CFrame = firstRoad:FindFirstChild("Start").WorldCFrame
	end
end

function DrivingTest.CheckpointTouchedHandler(player, nextRoad)
	local conn
	local completedPart = nextRoad:FindFirstChild("Completed")
	conn = completedPart.Touched:Connect(function(hit)
		if not CollectionService:HasTag(hit, "DrivingTestCar") then
			return
		end

		print("Checkpoint touched!")
		conn:Disconnect()

		-- stop generating and cap off the road if RoadFinishCount is exceeded
		if RoadsSpawned >= RoadFinishCount then
			if not workspace:FindFirstChild("FinishedRoad") then
				AddFinishedRoad(player)
			end
			return
		end

		-- generate & delete roads per checkpoint reached & conditions met
		DrivingTest.HandleGeneratingAndDeletingRoads(player)

		-- red light handler
		RedLightHandler(player, nextRoad)

		-- announce next roundabout if spawned and not already doing one
		AnnounceNextRoundAbout(player)
	end)
end

function DrivingTest.GenerateRoads(
	player: Player,
	amountToSpawn: number,
	currentEndAttachment: Attachment?,
	capOff: boolean?,
	considerCheckpoints: boolean?,
	excludeRoad: string?
)
	for _ = 1, amountToSpawn do
		if not currentEndAttachment then
			warn("Generation attachment handle is nil, ending.")
			return
		end
		-- choose a valid road type
		local nextRoadName = GetNextRoadName(currentEndAttachment, excludeRoad)

		-- spawn road at end of current road and get attachment references
		local nextRoad, _, nextRoadEndAttachment = SpawnRoad(nextRoadName, currentEndAttachment, player)

		currentEndAttachment = nextRoadEndAttachment

		-- handle checkpoint
		if considerCheckpoints then
			if nextRoadName == "RoundaboutRoad" then
				print("Roundabout checkpoint")
				DrivingTest.RoundAboutCheckpointTouchedHandler(player, nextRoad)
			else
				DrivingTest.CheckpointTouchedHandler(player, nextRoad)
			end
		end
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

function DrivingTest.Init(player, posBeforeTeleport)
	if not Roads then
		error("No road models found")
	end
	PositionBeforeTeleport = posBeforeTeleport
	GeneralRemotes.BlackFade:FireClient(player, 0.5, 0)

	-- ensure EndCutscene stops the current main theme before calling this
	task.wait(1)
	GeneralRemotes.PlayTheme:FireClient(player, "Chill")

	-- spawn start roads
	local startRoad, _, startRoadEndAttachment = SpawnRoad("Start", nil, player)
	local _, _, startRoad2EndAttachment = SpawnRoad("StraightRoad", startRoadEndAttachment, player)

	-- teleport player to startRoad
	player.Character:PivotTo(startRoad:GetPivot() * CFrame.new(0, 10, 10))

	-- spawn & seat player to car
	player.Character.Humanoid.JumpPower = 0
	local seat = SpawnCar(startRoad)
	SeatPlayerToCar(player, seat)

	DrivingTest.GenerateRoads(player, 20, startRoad2EndAttachment, false, true)
	GeneralRemotes.BlackFade:FireClient(player, 0.5, 1)
end

return DrivingTest
