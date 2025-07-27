local MissionEventHandlers = {}
local ServerStorage = game:GetService("ServerStorage")
local NPCS = ServerStorage.NPCS
local CollectionService = game:GetService("CollectionService")

local function ToggleMeshVisibility(mesh: MeshPart, modelsetInvis: boolean)
	if modelsetInvis then
		mesh.Transparency = 1
		mesh.CanCollide = false
	else
		mesh.Transparency = 0
		mesh.CanCollide = true
	end
end

-- handle all mission logic
MissionEventHandlers["StealPhone"] = function()
	-- hide the knife from NPC
	local knifeRef = CollectionService:GetTagged("Knife")[1]
	if knifeRef then
		ToggleMeshVisibility(knifeRef, true)
	end
	local convoTag = CollectionService:GetTagged("RoadmanNameTag")[1]

	-- update convo to a new one since mission already accepted
	if convoTag then
		convoTag.Value = "RoadmanAccepted"
	end

	-- spawn the next NPC that progresses this mission
	local phoneVictim = NPCS:FindFirstChild("PhoneVictim"):Clone()
	phoneVictim.Parent = workspace
	local pos = Vector3.new(math.random(-360, 360), 5.23, -26.1)
	phoneVictim:MoveTo(pos)
end

return MissionEventHandlers
