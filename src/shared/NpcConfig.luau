local SoundService = game:GetService("SoundService")
local TextToSpeech = SoundService.AudioTextToSpeech

local NpcConfig = {
	name = "NPC",
	modelId = 49475274,
	talkLines = {},
}

function NpcConfig.Speak(text)
	TextToSpeech.Text = text
	TextToSpeech:Play()
end

return NpcConfig
