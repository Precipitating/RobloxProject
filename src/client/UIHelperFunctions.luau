local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UIHelperFunctions = {}
local blurRef = Lighting:FindFirstChild("Blur")

function UIHelperFunctions.AdjustBlur(duration, blurValue)
	task.spawn(function()
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local goal = { Size = blurValue }

		local tween = TweenService:Create(blurRef, tweenInfo, goal)
		tween:Play()
	end)
end

return UIHelperFunctions
