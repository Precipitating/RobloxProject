local Thief = {}
local CanDance = true

local function PlayDefaultAnimation()
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://115866388328663"

	local Character = workspace:WaitForChild("NPCs"):WaitForChild("Thief"):WaitForChild("Thief")
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid:WaitForChild("Animator")
	local animTrack = Animator:LoadAnimation(animation)
	animTrack.Looped = false

	local function PlayLoop()
		while Character and CanDance do
			-- forward
			animTrack:Play()
			animTrack.TimePosition = 0
			animTrack:AdjustSpeed(1)
			animTrack.Stopped:Wait()

			-- reverse
			animTrack:Play()
			animTrack.TimePosition = animTrack.Length
			animTrack:AdjustSpeed(-1)
			animTrack.Stopped:Wait()
		end
	end

	task.spawn(PlayLoop)
end

function Thief.SetDanceState(val)
	CanDance = val
end

function Thief.Initialize()
	PlayDefaultAnimation()
end

return Thief
