local Chat = game:GetService("Chat")
local TweenService = game:GetService("TweenService")
local Dialogue = {
	"I can't see!",
	"how to play?",
	"i'm scared omg",
	"HELP ME",
	"whats happening?",
	"my screen is black",
	"this game is scary",
	"can i play",
	"why u blind me",
}
local IsPanicking = false
local GuestHeads = {}
local WhodunnitGuest = {}

function WhodunnitGuest.SetPanicking(val)
	IsPanicking = val
end
function WhodunnitGuest.RemoveHeadFromTable(key)
	GuestHeads[key] = nil
end
function WhodunnitGuest.TurnGuestHeadsToPlayer(target)
	local tween = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for key, head in pairs(GuestHeads) do
		print(key)
		task.spawn(function()
			local goal = {
				CFrame = CFrame.lookAt(head.Position, target.Position),
			}
			TweenService:Create(head, tween, goal):Play()
		end)
	end
end

function WhodunnitGuest.StartPanicking(head)
	GuestHeads[head.Parent.Name] = head
	task.spawn(function()
		while IsPanicking do
			Chat:Chat(head, Dialogue[math.random(1, #Dialogue)])
			task.wait(math.random(7, 10))
		end
	end)
end

return WhodunnitGuest
