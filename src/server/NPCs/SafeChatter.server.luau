local NPCModule = require(script.Parent.NPCModule)
local initializedRemote = game.ReplicatedStorage.Shared.Events.NPC.InitializedNPC
local arrivedRemote = game.ReplicatedStorage.Shared.Events.NPC.ArrivedDestination

initializedRemote.Event:Connect(function(data)
	print("found")
	arrivedRemote:Fire()
end)

arrivedRemote.Event:Connect(function(data)
	print("Arrived. Go to next destination ")

	local safeChatterRef = NPCModule:GetNPC("Safechatter")
	local pathData = safeChatterRef:GetPathStorage():GetChildren()
	local nextLocation = pathData[math.random(1, #pathData)]
	safeChatterRef:PathFindTo(nextLocation)
end)
