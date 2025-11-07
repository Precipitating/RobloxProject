local WhodunnitPrompts = {}
local MaxAttempts = 3
local HostTTSRef = nil

function WhodunnitPrompts.HostTalk(text, attempts)
	attempts = attempts or 1
	if attempts > MaxAttempts then
		return false
	end
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
	local status = HostTTSRef:LoadAsync()
	if status ~= Enum.AssetFetchStatus.Success then
		warn(`TTS Load failed, retrying: {attempts} {status.Name}`)
		return WhodunnitPrompts.HostTalk(text, attempts + 1)
	end
	HostTTSRef:Play()
	HostTTSRef.Ended:Wait()
	print("Host TTS succeeded!")

	return true
end

return WhodunnitPrompts
