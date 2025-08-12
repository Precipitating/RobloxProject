local TextToSpeech = {}

local soundService = game:GetService("SoundService")
local textToSpeechHandle = soundService.AudioTextToSpeech

function TextToSpeech.CleanTextForTTS(str)
	-- Replace <br/> and newlines with a single space
	str = str:gsub("<br%s*/>", " ")
	str = str:gsub("\n", " ")

	-- Remove all other tags
	str = str:gsub("<[^<>]->", "")

	-- Collapse multiple spaces into one
	str = str:gsub("%s+", " ")

	-- Trim leading/trailing spaces
	str = str:match("^%s*(.-)%s*$")

	return str
end
function TextToSpeech.Speak(text)
	local cleanedText = TextToSpeech.CleanTextForTTS(text)
	textToSpeechHandle.Text = cleanedText
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
