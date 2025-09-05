local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local HelperFunctions = require(ServerScriptService.Server.HelperFunctions)
local Players = game:GetService("Players")
local IsActive = false
local RoadEvents = {}
local FlingForce = 200

function RoadEvents.IsActive()
	return IsActive
end

function RoadEvents.SpawnLearnerDriver()
	IsActive = true
	local spawnPos = ServerStorage.Road.LearnerDriver:FindFirstChild("SpawnPos")
	local driver = workspace:FindFirstChild("Clunker")
	local collide
	local hasBeenHit = false
	if not driver then
		driver = HelperFunctions.SpawnModelAtPosition("Road", "LearnerDriver", "Clunker", nil)
		driver.PrimaryPart.CFrame = spawnPos.CFrame
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
	else
		driver.PrimaryPart.CFrame = spawnPos.CFrame
	end
	local positionsToMove = ServerStorage.Road.LearnerDriver:FindFirstChild("RoadPath"):GetChildren()
	local primary = driver.PrimaryPart

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

return RoadEvents
