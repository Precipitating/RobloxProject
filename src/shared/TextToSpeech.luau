local TextToSpeech = {}

local soundService = game:GetService("SoundService")
local textToSpeechHandle = soundService.AudioTextToSpeech

function TextToSpeech.Speak(text)
	textToSpeechHandle.Text = text
	textToSpeechHandle:Play()
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

return TextToSpeech
