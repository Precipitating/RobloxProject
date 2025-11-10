print("AnimationController module loaded!")
local CollectionService = game:GetService("CollectionService")
local AnimationController = {}

local function R6Animation(model)
	local Humanoid = model:WaitForChild("Humanoid")
	local RootPart = model:WaitForChild("HumanoidRootPart")
	local Animator = Humanoid:WaitForChild("Animator")

	local currentAnim = ""
	local currentAnimTrack = nil
	local animationTable = {}

	-- Preload animations
	local animations = {
		idleAnimation = "http://www.roblox.com/asset/?id=180435571",
		walkAnimation = "http://www.roblox.com/asset/?id=180426354",
		jumpAnimation = "http://www.roblox.com/asset/?id=125750702",
		fallAnimation = "http://www.roblox.com/asset/?id=180436148",
		climbAnimation = "http://www.roblox.com/asset/?id=180436334",
		sitAnimation = "http://www.roblox.com/asset/?id=178130996",
	}

	for animName, animId in pairs(animations) do
		local anim = Instance.new("Animation")
		anim.AnimationId = animId
		animationTable[animName] = anim
	end

	-- Stop all animations
	local function StopAllAnimations()
		if currentAnimTrack then
			currentAnimTrack:Stop()
			currentAnimTrack:Destroy()
			currentAnimTrack = nil
		end
	end

	-- Play animation by name
	local function PlayAnimation(animName)
		if animName == currentAnim then
			return
		end
		StopAllAnimations()
		currentAnim = animName
		currentAnimTrack = Animator:LoadAnimation(animationTable[animName])
		currentAnimTrack:Play()
	end

	local function onSeated()
		PlayAnimation("sitAnimation")
	end

	-- Humanoid state change functions
	local function onJumping()
		PlayAnimation("jumpAnimation")
	end

	local function onClimbing(speed)
		if math.abs(speed) > 0.2 then
			if currentAnim ~= "climbAnimation" then
				PlayAnimation("climbAnimation")
			elseif currentAnimTrack then
				currentAnimTrack:AdjustSpeed(1)
			end
		else
			if currentAnimTrack then
				currentAnimTrack:AdjustSpeed(0)
			end
		end
	end

	local function onFalling()
		PlayAnimation("fallAnimation")
	end

	local function onRunning(speed)
		if speed > 0.2 then
			PlayAnimation("walkAnimation")
		else
			PlayAnimation("idleAnimation")
		end
	end

	-- Connect humanoid state events
	Humanoid.Seated:Connect(function()
		StopAllAnimations()
		PlayAnimation("sitAnimation")
	end)

	-- no swim anim, uses running animation instead
	Humanoid.Swimming:Connect(onRunning)
	Humanoid.Running:Connect(onRunning)
	Humanoid.FreeFalling:Connect(onFalling)
	Humanoid.Climbing:Connect(onClimbing)
	Humanoid.Jumping:Connect(onJumping)
	Humanoid.Died:Connect(function()
		StopAllAnimations()
		currentAnim = ""
	end)
end
function AnimationController.ApplyToMoveableNPCS()
	local npcModels = CollectionService:GetTagged("MoveableNPC")
	for _, model in ipairs(npcModels) do
		task.spawn(R6Animation, model)
	end
end

return AnimationController
