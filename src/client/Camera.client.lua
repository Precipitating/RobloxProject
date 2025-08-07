local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CameraEnableRemote = ReplicatedStorage.Shared.Remotes.EnableCameraLookDetection
local IsCameraLookingAtPartRemote = ReplicatedStorage.Shared.Remotes.IsCameraLookingAtPart
local loopHandle
local wasVisible = false
local function IsModelVisible(part)
	local camera = workspace.CurrentCamera

	if part:IsA("BasePart") then
		local _, onScreen = camera:WorldToViewportPoint(part.Position)
		if onScreen then
			return true
		end
	end

	return false
end

local function StartLooking(partToFind)
	loopHandle = RunService.RenderStepped:Connect(function()
		local isVisible = IsModelVisible(partToFind)
		if isVisible ~= wasVisible then
			wasVisible = isVisible
			IsCameraLookingAtPartRemote:FireServer(isVisible)
		end
	end)
end

CameraEnableRemote.OnClientEvent:Connect(function(enabled, partToFind)
	if enabled then
		StartLooking(partToFind)
	else
		loopHandle:Disconnect()
		loopHandle = nil
	end
end)
