local CollectionService = game:GetService("CollectionService")
local GlitcherRef = nil
local isRunning = true
local Glitcher = {}
local function PlayDefaultAnim()
	-- add run anim
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://180426354"
	animation.Name = "RunAnim"
	animation.Parent = GlitcherRef

	local Humanoid = GlitcherRef:FindFirstChildOfClass("Humanoid")
	local Animator = Humanoid:FindFirstChildOfClass("Animator")
	local LoadAnim = Animator:LoadAnimation(animation)
	LoadAnim:Play()
end

local function LookOppositeDirection()
	GlitcherRef:PivotTo(
		CFrame.new(
			GlitcherRef.HumanoidRootPart.Position,
			GlitcherRef.HumanoidRootPart.Position - GlitcherRef.HumanoidRootPart.CFrame.LookVector
		)
	)
end

function Glitcher.Initialize()
	GlitcherRef = CollectionService:GetTagged("Glitcher")
	if #GlitcherRef > 0 then
		GlitcherRef = GlitcherRef[1]
	else
		warn("Glitcher reference not found!")
	end
	Glitcher.StartGlitchingAttempt()
	PlayDefaultAnim()
end

function Glitcher.StartGlitchingAttempt()
	task.spawn(function()
		while isRunning do
			LookOppositeDirection()
			task.wait(1)
		end
	end)
end

return Glitcher
