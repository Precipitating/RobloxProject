local TextToSpeech = {}

local soundService = game:GetService("SoundService")
local textToSpeechHandle = soundService.AudioTextToSpeech

function TextToSpeech.Speak(text)
	textToSpeechHandle.Text = text
	local status = textToSpeechHandle:LoadAsync()

	if status ~= Enum.AssetFetchStatus.Success then
		warn("TTS Load failed:", status.Name)
		return false
	end
	print("TTS loaded successfully")

	textToSpeechHandle:Play()
	return true
end

-- speed range: 0.5, 2.0
-- pitch range - -12, 12
-- voice Id range - 1 - 10
-- volume range - 1, 3
function TextToSpeech.UpdateVoiceConfig(voiceId, pitch, speed, volume)
	textToSpeechHandle.VoiceId = voiceId
	textToSpeechHandle.Pitch = pitch
	textToSpeechHandle.Speed = speed
	textToSpeechHandle.Volume = volume
end

function TextToSpeech.GetCurrentSpeed()
	return textToSpeechHandle.Speed
end

function TextToSpeech.IsLoaded()
	return textToSpeechHandle.IsLoaded
end

function TextToSpeech.GetHandle()
	return textToSpeechHandle
end

return TextToSpeech
