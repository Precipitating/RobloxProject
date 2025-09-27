local CollectionService = game:GetService("CollectionService")
local TalkModuleHelpers = {}
local CanTalk = true

local function DisableAllPrompts(canTalk)
	local npcs = CollectionService:GetTagged("NPC")
	for _, npc in ipairs(npcs) do
		local prompt = npc:FindFirstChild("ProximityPrompt")
		if prompt then
			prompt.Enabled = canTalk
		end
	end
end

function TalkModuleHelpers.SetCanTalk(canTalk)
	CanTalk = canTalk
	DisableAllPrompts(canTalk)
	print(`NPC Prompts Enabled set to {canTalk}`)
end

function TalkModuleHelpers.GetCanTalk()
	return CanTalk
end

return TalkModuleHelpers
