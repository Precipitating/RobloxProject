local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NpcConfig = require(ReplicatedStorage.Shared.NpcConfig)

local function onPromptTriggered(promptObj, player)
	local model = promptObj:FindFirstAncestorWhichIsA("Model")
	if model.Name == "Noob" then
		NpcConfig.Speak("Why did you bump into me" .. player.Name)
	end
end

ProximityPromptService.PromptTriggerEnded:Connect(onPromptTriggered)
