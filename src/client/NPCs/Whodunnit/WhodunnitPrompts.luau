local WhodunnitPrompts = {}
local MaxAttempts = 5
local HostTTSRef = nil

function WhodunnitPrompts.ResetHostTTSRef()
	HostTTSRef = nil
end

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
			error("Can't find HostTTS reference!")
			return false
		end
	end

	HostTTSRef.Text = text
	local status = HostTTSRef:LoadAsync()
	if status ~= Enum.AssetFetchStatus.Success then
		warn(`TTS Load failed, retrying: {attempts} {status.Name}`)
		task.wait(0.5)
		return WhodunnitPrompts.HostTalk(text, attempts + 1)
	end
	HostTTSRef:Play()
	HostTTSRef.Ended:Wait()
	print("Host TTS succeeded!")

	return true
end

return WhodunnitPrompts
