local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextToSpeech = require(ReplicatedStorage.Shared.TextToSpeech)
local WhodunnitPrompts = {}
local HostTTSRef = nil

function WhodunnitPrompts.ResetHostTTSRef()
	HostTTSRef = nil
end

function WhodunnitPrompts.HostTalk(text)
	if not HostTTSRef then
		HostTTSRef = workspace
			:WaitForChild("ZapsMansion")
			:WaitForChild("WhodunnitHost")
			:WaitForChild("HumanoidRootPart")
			:WaitForChild("AudioTextToSpeech")

		if not HostTTSRef then
			error("Can't find HostTTS reference!")
			return false
		end
	end

	TextToSpeech.Speak3D(HostTTSRef, text, 0)

	return true
end

return WhodunnitPrompts
