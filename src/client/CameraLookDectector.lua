local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local RunService = game:GetService("RunService")
local GeneralRemotes = ReplicatedStorage.Remotes
local RenderStepConn = nil
local WasVisible = false
local Camera = workspace.CurrentCamera

local CameraLookDetector = {}

function CameraLookDetector.SetRenderStepConn(val)
	RenderStepConn = val
end
function CameraLookDetector.DisconnectRenderStepConn()
	if RenderStepConn then
		RenderStepConn:Disconnect()
		RenderStepConn = nil
		print("Camera checking safechatter disabled (client)")
	end
end
function CameraLookDetector.IsModelVisible(part)
	local camera = workspace.CurrentCamera
	if part:IsA("BasePart") then
		local _, onScreen = camera:WorldToViewportPoint(part.Position)
		if onScreen then
			return true
		end
	end

	return false
end

function CameraLookDetector.CameraBlockCast(blockSize, dist, params)
	return workspace:Blockcast(
		Camera.CFrame,
		Vector3.new(blockSize, blockSize, blockSize),
		Camera.CFrame.LookVector * dist,
		params
	)
end

function CameraLookDetector.StartLooking(partToFind)
	RenderStepConn = RunService.RenderStepped:Connect(function()
		local isVisible = CameraLookDetector.IsModelVisible(partToFind)
		if isVisible ~= WasVisible then
			WasVisible = isVisible
			GeneralRemotes.IsCameraLookingAtPart:FireServer(isVisible)
		end
	end)
end

return CameraLookDetector
