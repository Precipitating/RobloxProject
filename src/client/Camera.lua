local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local RunService = game:GetService("RunService")
local GeneralRemotes = ReplicatedStorage.Remotes
local RenderStepConn = nil
local WasVisible = false

local Camera = {}

function Camera.SetRenderStepConn(val)
	RenderStepConn = val
end
function Camera.DisconnectRenderStepConn()
	if RenderStepConn then
		RenderStepConn:Disconnect()
		RenderStepConn = nil
		print("Camera checking safechatter disabled (client)")
	end
end
function Camera.IsModelVisible(part)
	local camera = workspace.CurrentCamera

	if part:IsA("BasePart") then
		local _, onScreen = camera:WorldToViewportPoint(part.Position)
		if onScreen then
			return true
		end
	end

	return false
end

function Camera.StartLooking(partToFind)
	RenderStepConn = RunService.RenderStepped:Connect(function()
		local isVisible = Camera.IsModelVisible(partToFind)
		if isVisible ~= WasVisible then
			WasVisible = isVisible
			GeneralRemotes.IsCameraLookingAtPart:FireServer(isVisible)
		end
	end)
end

return Camera
