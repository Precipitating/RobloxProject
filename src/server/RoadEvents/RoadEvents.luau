local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)

local IsActive = false
local RoadEvents = {}
local FlingForce = 200
local ApocDriveDuration = 20
local DNSLDriveDuration = 30
local RunRoadEvents = true

function RoadEvents.IsActive()
	return IsActive
end

function RoadEvents.EnableRoadEvents(enable)
	warn(`Road events enabled = {enable}`)
	RunRoadEvents = enable
end

function RoadEvents.SpawnLoop()
	while RunRoadEvents do
		-- wait a random amount of time before next attempt
		task.wait(math.random(30, 300))

		-- only spawn if there isn't already an active event
		if not RoadEvents.IsActive() then
			RoadEvents.PlayRandomEvent()
		end
	end
end

function RoadEvents.SpawnLearnerDriver()
	IsActive = true
	local spawnPos = ServerStorage.Road.LearnerDriver:FindFirstChild("SpawnPos")
	local driver = workspace:FindFirstChild("Clunker")
	local collide
	local hasBeenHit = false
	if not driver then
		driver = ServerHelperFunctions.SpawnModelAtPosition("Road", "LearnerDriver", "Clunker", nil)
		collide = driver:FindFirstChild("Collide")

		-- collide functionality
		collide.Touched:Connect(function(hit)
			if hasBeenHit then
				return
			end
			hasBeenHit = true
			local character = hit:FindFirstAncestorOfClass("Model")
			if character then
				local player = Players:GetPlayerFromCharacter(character)
				if player then
					local hrp = character:FindFirstChild("HumanoidRootPart")
					local humanoid = character:FindFirstChild("Humanoid")
					if hrp then
						print("hit")
						humanoid.PlatformStand = true
						local flingDirection = (collide.Position - hrp.Position).Unit
						local velocity = Instance.new("BodyVelocity")
						velocity.Velocity = flingDirection * FlingForce
						velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
						velocity.Parent = hrp
						game:GetService("Debris"):AddItem(velocity, 0.5)

						task.wait(2)
						humanoid.PlatformStand = false
						hasBeenHit = false
					end
				end
			end
		end)
	end
	driver.PrimaryPart.CFrame = spawnPos.CFrame
	local positionsToMove = ServerStorage.Road.LearnerDriver:FindFirstChild("RoadPath"):GetChildren()
	local primary = driver.PrimaryPart

	-- ensure it's in order (models are numbered 1,2,3,4 etc)
	table.sort(positionsToMove, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)

	local function tweenTo(part, targetPos)
		local goal = { CFrame = targetPos }
		local tween = TweenService:Create(part, tweenInfo, goal)
		tween:Play()
		tween.Completed:Wait()
	end

	for _, node in ipairs(positionsToMove) do
		tweenTo(primary, node.CFrame)
	end

	IsActive = false
end

function RoadEvents.SpawnApocCar()
	IsActive = true
	local spawnPos = ServerStorage.Road.ApocCar:FindFirstChild("SpawnPos")
	local targetPos = ServerStorage.Road.ApocCar:FindFirstChild("Target")
	local car = workspace:FindFirstChild("Car")

	if not car then
		car = ServerHelperFunctions.SpawnModelAtPosition("Road", "ApocCar", "Car", nil)
	end
	local tree = car:FindFirstChild("Tree")
	local base = car:FindFirstChild("Base")
	car.PrimaryPart.CFrame = spawnPos.CFrame

	-- simulate driving to target
	local tweenInfo = TweenInfo.new(ApocDriveDuration, Enum.EasingStyle.Linear)
	local goal = { CFrame = targetPos.CFrame }
	local tween = TweenService:Create(car.PrimaryPart, tweenInfo, goal)
	tween:Play()

	-- explode car apoc style
	task.delay(math.random(5, ApocDriveDuration * 0.7), function()
		local treeParts = tree:GetChildren()

		-- show tree
		for _, part in treeParts do
			part.Transparency = 0
		end

		local crash = base:FindFirstChild("Crash")
		local explode = base:FindFirstChild("Explode")
		local anger = base:FindFirstChild("Angry")
		local drive = base:FindFirstChild("Drive")
		if not crash and not explode and not anger then
			error("Apoc car missing sound references")
		end
		crash:Play()
		explode:Play()
		drive:Stop()

		for _, part in ipairs(car:GetDescendants()) do
			if not part:IsA("BasePart") or part.Parent.Name == "Tree" then
				continue
			end
			if math.random() > 0.5 then
				part.Material = Enum.Material.CorrodedMetal
			end
			if part.Name == "Wheel" or part.Name == "Tire" then
				part:Destroy()
			elseif part.Name == "Engine" then
				part:FindFirstChild("BigFire").Enabled = true
			end
		end

		tween:Cancel()

		task.wait(1)
		anger:Play()

		-- despawn
		task.delay(7, function()
			car:Destroy()
			IsActive = false
		end)
	end)
end

function RoadEvents.SpawnDNSL()
	IsActive = true
	local spawnPos = ServerStorage.Road.DanielTruck:FindFirstChild("SpawnPos")
	local targetPos = ServerStorage.Road.DanielTruck:FindFirstChild("Target")
	local car = workspace:FindFirstChild("Truck")

	if car then
		car:Destroy()
	end
	car = ServerHelperFunctions.SpawnModelAtPosition("Road", "DanielTruck", "Truck", nil)
	car.PrimaryPart.CFrame = spawnPos.CFrame

	local tweenInfo = TweenInfo.new(DNSLDriveDuration, Enum.EasingStyle.Linear)
	local goal = { CFrame = targetPos.CFrame }
	local tween = TweenService:Create(car.PrimaryPart, tweenInfo, goal)
	tween:Play()
	tween.Completed:Wait()
	car:Destroy()
	IsActive = false
end

local RandomEvents = { RoadEvents.SpawnLearnerDriver, RoadEvents.SpawnApocCar, RoadEvents.SpawnDNSL }
function RoadEvents.PlayRandomEvent()
	task.spawn(function()
		RandomEvents[math.random(1, #RandomEvents)]()
	end)
end

return RoadEvents
