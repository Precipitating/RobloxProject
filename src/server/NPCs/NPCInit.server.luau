local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local InitializedRemote = ReplicatedStorage.Events.NPC.InitializedNPC
local ArrivedRemote = ReplicatedStorage.Events.NPC.ArrivedDestination
local NPCModule = require(script.Parent.NPCModule)
-- handle pathfinding events
local function PatrolMode(name)
	local npc = NPCModule:GetNPC(name)
	local pathData = npc:GetPathStorage():GetChildren()
	local nextLocation = pathData[math.random(1, #pathData)]
	npc:StartPathing(nextLocation)
end

InitializedRemote.Event:Connect(function(name)
	local npc = NPCModule:GetNPC(name)
	npc:SetMode("Patrol")
	print(`{name} NPC set to Patrol mode!`)
end)

ArrivedRemote.Event:Connect(function(name)
	local npc = NPCModule:GetNPC(name)
	if npc:GetMode() == "Patrol" then
		PatrolMode(name)
		print(`{name} arrived at destination. Go next`)
	end
end)

-- Get all moveable NPCS and assign a NPC class to it
NPCModule:Init()
