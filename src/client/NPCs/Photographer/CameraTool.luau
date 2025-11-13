local CaptureService = game:GetService("CaptureService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local CameraLookDectector = require(StarterPlayer.StarterPlayerScripts.Client.CameraLookDectector)
local ScreenGUIHandler = require(StarterPlayer.StarterPlayerScripts.Client.ScreenGUIHandler)
local SoundModule = require(StarterPlayer.StarterPlayerScripts.Client.SoundModule)
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local TweenTop = nil
local TweenBottom = nil
local FailPhotoIds = {}
local CorrectPhotos = {}
local ShotsLeft = 5
local TweenInfo = TweenInfo.new(
	0.1,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out,
	0,
	true -- reverses on
)

local BlockCastParams = RaycastParams.new()
BlockCastParams.CollisionGroup = "CameraTarget"

local TopGoal = { Position = UDim2.fromScale(0.5, 0) }
local BottomGoal = { Position = UDim2.fromScale(0.5, 1) }
local GUIHandle = nil
local IsActive = false

local CameraTool = {}

function CameraTool.Initialize()
	local cameraGUI = ReplicatedStorage.GUI.PhotoJob.CameraGUI
	GUIHandle = cameraGUI:Clone()
	GUIHandle.Parent = Player.PlayerGui

	TweenTop = TweenService:Create(GUIHandle.TopFrame, TweenInfo, TopGoal)
	TweenBottom = TweenService:Create(GUIHandle.BottomFrame, TweenInfo, BottomGoal)
end

function CameraTool.Cleanup()
	GUIHandle:Destroy()
	GUIHandle = nil
	TweenTop = nil
	TweenBottom = nil
	ShotsLeft = 5
	FailPhotoIds = {}
	CorrectPhotos = {}
end
function CameraTool.GetFailPhotoIds()
	return FailPhotoIds
end

function CameraTool.GetCorrectPhotos()
	return CorrectPhotos
end
function CameraTool.CorrectPhotosCount()
	local count = 0
	for _ in pairs(CorrectPhotos) do
		count += 1
	end

	return count
end

local function PhotographedTarget(decalID)
	local result = CameraLookDectector.CameraBlockCast(4, 50, BlockCastParams)
	if not result then
		return
	end
	if result then
		local partAttribute = result.Instance:GetAttribute("CameraTarget")
		local modelAttribute = result.Instance:FindFirstAncestorWhichIsA("Model"):GetAttribute("CameraTarget")
		if partAttribute then
			if not CorrectPhotos[partAttribute] then
				CorrectPhotos[partAttribute] = { Id = decalID, Text = result.Instance:GetAttribute("CameraTargetText") }
				print(partAttribute)
			end
		elseif modelAttribute then
			if not CorrectPhotos[modelAttribute] then
				CorrectPhotos[modelAttribute] = {
					Id = decalID,
					Text = result.Instance:FindFirstAncestorWhichIsA("Model"):GetAttribute("CameraTargetText"),
				}

				print(modelAttribute)
			end
		end
	else
		table.insert(FailPhotoIds, decalID)
	end
end
local function OnShotTaken(decalID)
	PhotographedTarget(decalID)
	ShotsLeft -= 1
	SoundModule.PlaySound("CameraFlash")
	TweenTop:Play()
	TweenBottom:Play()

	TweenTop.Completed:Wait()
	ScreenGUIHandler.DisableAllGUI(false)
	IsActive = false
end
function CameraTool.ShotsLeft()
	return ShotsLeft
end

function CameraTool.TakePhotograph()
	if IsActive or ShotsLeft <= 0 then
		return
	end
	IsActive = true
	ScreenGUIHandler.DisableAllGUI(true)
	task.wait()
	CaptureService:CaptureScreenshot(OnShotTaken)
end

return CameraTool
