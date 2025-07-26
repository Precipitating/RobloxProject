local TextToSpeech = {}

local soundService = game:GetService("SoundService")
local textToSpeechHandle = soundService.AudioTextToSpeech

function TextToSpeech.Speak(text)
	textToSpeechHandle.Text = text
	textToSpeechHandle:Play()
end

function TextToSpeech.IsLoaded()
	return textToSpeechHandle.IsLoaded
end

return TextToSpeech
