local TweenService = game:GetService("TweenService")
local DoorTweens: any = {}
local NormalDoor = {}

function NormalDoor.Clear()
	table.clear(DoorTweens)
end

function NormalDoor.Interact(prompt, hinge, doorName)
	if not DoorTweens[doorName] then
		local goalOpen = { CFrame = hinge.CFrame * CFrame.Angles(0, math.rad(90), 0) }
		local goalClose = { CFrame = hinge.CFrame * CFrame.Angles(0, 0, 0) }
		local tweenInfo = TweenInfo.new(1)
		local tweenOpen = TweenService:Create(hinge, tweenInfo, goalOpen)
		local tweenClose = TweenService:Create(hinge, tweenInfo, goalClose)

		DoorTweens[doorName] = { Open = tweenOpen, Close = tweenClose }
	end

	if prompt.ActionText == "Close" then
		DoorTweens[doorName].Close:Play()
		prompt.ActionText = "Open"
	else
		DoorTweens[doorName].Open:Play()
		prompt.ActionText = "Close"
	end
end

return NormalDoor
