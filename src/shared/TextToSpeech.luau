local TextToSpeech = {}

local SoundService = game:GetService("SoundService")
local TextToSpeechHandle = SoundService.AudioTextToSpeech
local MaxAttempts = 5

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
function TextToSpeech.Speak(text, attempts)
	attempts = attempts or 0
	if attempts > MaxAttempts then
		return false
	end
	local cleanedText = TextToSpeech.CleanTextForTTS(text)
	TextToSpeechHandle.Text = cleanedText

	local status = TextToSpeechHandle:LoadAsync()
	if status ~= Enum.AssetFetchStatus.Success then
		warn("TTS Load failed:", status.Name)
		return TextToSpeech.Speak(text, attempts + 1)
	end
	print("TTS loaded successfully")

	TextToSpeechHandle:Play()
	return true
end

function TextToSpeech.Speak3D(tts, text, attempts)
	attempts = attempts or 0
	if attempts > MaxAttempts then
		print(`Failed to play 3D TTS for {tts:FindFirstAncestorOfClass("Model").Name}, skipping...`)
		return false
	end
	if text and attempts == 0 then
		tts.Text = text
	end
	local status = tts:LoadAsync()
	if status ~= Enum.AssetFetchStatus.Success then
		print(`Failed to play 3D TTS, attempt {attempts}`)
		task.wait(0.5)
		return TextToSpeech.Speak3D(tts, text, attempts + 1)
	end
	tts:Play()
	tts.Ended:Wait()
	return true
end

-- voice Id range - 1 - 10
-- speed range: 0.5, 2.0
-- pitch range - -12, 12
-- volume range - 1, 3
function TextToSpeech.UpdateVoiceConfig(config)
	for _, key in ipairs({ "VoiceId", "Pitch", "Speed", "Volume" }) do
		if config[key] ~= nil then
			print(`{key} to {config[key]}`)
			TextToSpeechHandle[key] = config[key]
		end
	end
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
