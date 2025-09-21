local CollectionService = game:GetService("CollectionService")
local ClientHelperFunctions = {}

function ClientHelperFunctions.ChangeCameraSubject(targetCFrame)
	local camera = workspace.CurrentCamera
	if not targetCFrame then
		camera.CameraType = Enum.CameraType.Custom
		print("Camera back to player")
		return
	end

	camera.CameraType = Enum.CameraType.Scriptable

	camera.CFrame = targetCFrame
end

-- note that client can't access server storage, so NPCs stored inside server won't be modified
-- the extra check is if they're in ReplicatedStorage for some reason
function ClientHelperFunctions.EnableAllNPCPrompts(enabled)
	local npcs = CollectionService:GetTagged("NPC")

	for _, npc in ipairs(npcs) do
		local prompt = npc:FindFirstChild("ProximityPrompt")

		if prompt and prompt:IsDescendantOf(workspace) then
			if prompt.Enabled ~= enabled then
				prompt.Enabled = enabled
			end
		end
	end

	print(`NPC's prompts should all be enabled/disabled.`)
end

function ClientHelperFunctions.ToggleNPCProximityPrompt(name, state)
	local npcs = CollectionService:GetTagged(name)
	for _, npc in ipairs(npcs) do
		local prompt = npc:FindFirstChild("ProximityPrompt")

		if prompt and prompt:IsDescendantOf(workspace) then
			prompt.Enabled = state
		end
	end
end
return ClientHelperFunctions
