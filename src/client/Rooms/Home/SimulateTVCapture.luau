local CaptureService = game:GetService("CaptureService")
local CollectionService = game:GetService("CollectionService")
local TVImageRef = nil
local SimulateTVCapture = {}
local AddedSignal = nil
local RemovedSignal = nil
local Active = true

function SimulateTVCapture.DisconnectAll()
	AddedSignal:Disconnect()
	RemovedSignal:Disconnect()
	AddedSignal = nil
	RemovedSignal = nil
end

local function OnCaptureReady(contentId)
	TVImageRef.Image = contentId
end

function SimulateTVCapture.Initialize()
	AddedSignal = CollectionService:GetInstanceAddedSignal("HomeTVImage"):Connect(function(imageLabel)
		TVImageRef = imageLabel
		Active = true
		SimulateTVCapture.Run()
	end)
	RemovedSignal = CollectionService:GetInstanceRemovedSignal("HomeTVImage"):Connect(function(_)
		Active = false
		TVImageRef = nil
		print("TV Capture disabled")
	end)
end

function SimulateTVCapture.Run()
	task.spawn(function()
		while Active do
			CaptureService:CaptureScreenshot(OnCaptureReady)
			task.wait(5)
		end
	end)
end

return SimulateTVCapture
