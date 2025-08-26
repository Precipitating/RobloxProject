local TextToSpeech = {}

local SoundService = game:GetService("SoundService")
local TextToSpeechHandle = SoundService.AudioTextToSpeech

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
	TextToSpeechHandle.Text = cleanedText

	local status = TextToSpeechHandle:LoadAsync()
	if status ~= Enum.AssetFetchStatus.Success then
		warn("TTS Load failed:", status.Name)
		return false
	end
	print("TTS loaded successfully")

	TextToSpeechHandle:Play()
	return true
end

-- speed range: 0.5, 2.0
-- pitch range - -12, 12
-- voice Id range - 1 - 10
-- volume range - 1, 3
function TextToSpeech.UpdateVoiceConfig(voiceId, pitch, speed, volume)
	TextToSpeechHandle.VoiceId = voiceId
	TextToSpeechHandle.Pitch = pitch
	TextToSpeechHandle.Speed = speed
	TextToSpeechHandle.Volume = volume
end

function TextToSpeech.GetCurrentSpeed()
	return TextToSpeechHandle.Speed
end

function TextToSpeech.IsLoaded()
	return TextToSpeechHandle.IsLoaded
end

function TextToSpeech.GetHandle()
	return TextToSpeechHandle
end

return TextToSpeech
