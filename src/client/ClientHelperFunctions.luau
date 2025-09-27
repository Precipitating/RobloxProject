local ClientHelperFunctions = {}

function ClientHelperFunctions.ChangeCameraSubject(targetCFrame)
	local camera = workspace.CurrentCamera
	if not targetCFrame then
		camera.CameraType = Enum.CameraType.Custom
		print("Camera back to player")
		return
	end

	camera.CameraType = Enum.CameraType.Scriptable

	camera.CFrame = targetCFrame
end
return ClientHelperFunctions
