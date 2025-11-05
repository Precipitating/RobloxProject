local WhodunnitPrompts = {}
local HostTTSRef = nil

function WhodunnitPrompts.HostTalk(text)
	if not HostTTSRef then
		HostTTSRef = workspace
			:WaitForChild("ZapsMansion")
			:WaitForChild("WhodunnitHost")
			:WaitForChild("HumanoidRootPart")
			:WaitForChild("AudioTextToSpeech")

		if not HostTTSRef then
			warn("Can't find HostTTS reference!")
			return false
		end
	end

	HostTTSRef.Text = text
	HostTTSRef:Play()
	HostTTSRef.Ended:Wait()
	return true
end

return WhodunnitPrompts
