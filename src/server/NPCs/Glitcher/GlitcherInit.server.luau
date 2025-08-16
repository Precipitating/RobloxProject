local CollectionService = game:GetService("CollectionService")
local ref = CollectionService:GetTagged("Glitcher")
local isRunning = true
local function PlayDefaultAnim()
	if #ref > 0 then
		ref = ref[1]
		-- add run anim
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://180426354"
		animation.Name = "RunAnim"
		animation.Parent = ref

		local Humanoid = ref:FindFirstChildOfClass("Humanoid")
		local Animator = Humanoid:FindFirstChildOfClass("Animator")
		local LoadAnim = Animator:LoadAnimation(animation)
		LoadAnim:Play()
	else
		warn("Glitcher has no Tag 'Glitcher'")
	end
end

local function LookOppositeDirection()
	ref:SetPrimaryPartCFrame(
		CFrame.new(
			ref.HumanoidRootPart.Position,
			ref.HumanoidRootPart.Position - ref.HumanoidRootPart.CFrame.LookVector
		)
	)
end

local function StartGlitchingAttempt()
	while isRunning do
		LookOppositeDirection()
		task.wait(1)
	end
end

PlayDefaultAnim()

task.spawn(StartGlitchingAttempt)
