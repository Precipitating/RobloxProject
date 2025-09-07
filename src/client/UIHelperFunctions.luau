-- UIHelperFunctions Module
local UIHelperFunctions = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Reference to your Blur effect
local BlurRef = game.Lighting:FindFirstChildOfClass("BlurEffect")
UIHelperFunctions.CurrentBlurTween = nil

-- Adjusts the blur with smooth tween, cancels previous tweens
function UIHelperFunctions.AdjustBlur(duration, blurValue)
	if not BlurRef then
		return
	end

	-- Cancel any existing tween
	if UIHelperFunctions.CurrentBlurTween then
		UIHelperFunctions.CurrentBlurTween:Cancel()
		UIHelperFunctions.CurrentBlurTween = nil
	end

	-- Enable blur if increasing
	if blurValue > 0 then
		BlurRef.Enabled = true
	end

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local goal = { Size = blurValue }

	local tween = TweenService:Create(BlurRef, tweenInfo, goal)
	UIHelperFunctions.CurrentBlurTween = tween

	tween:Play()

	-- When tween finishes
	tween.Completed:Connect(function()
		-- Disable blur if fully faded out
		if blurValue == 0 then
			BlurRef.Enabled = false
		end
		UIHelperFunctions.CurrentBlurTween = nil
	end)
end

function UIHelperFunctions.AdjustBlackScreen(duration, blurValue)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local blackScreen = playerGui:WaitForChild("BlackScreen")
	local frame = blackScreen:WaitForChild("Frame")

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(frame, tweenInfo, { BackgroundTransparency = blurValue })
	tween:Play()
	tween.Completed:Wait()
end

return UIHelperFunctions
