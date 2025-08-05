local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPCModule = require(script.Parent.NPCModule)
local initializedRemote = game.ReplicatedStorage.Shared.Events.NPC.InitializedNPC
local arrivedRemote = game.ReplicatedStorage.Shared.Events.NPC.ArrivedDestination
local weepingAngelMode = game.ReplicatedStorage.Shared.Events.NPC.WeepingAngelMode
local IsCameraLookingAtSafechatterRemote = game.ReplicatedStorage.Shared.Remotes.IsCameraLookingAtPart
local EnableCameraLook = game.ReplicatedStorage.Shared.Remotes.EnableCameraLookDetection
local safeChatterRef
local isMoving = false

local function PatrolMode()
	local pathData = safeChatterRef:GetPathStorage():GetChildren()
	local nextLocation = pathData[math.random(1, #pathData)]
	safeChatterRef:StartPathing(nextLocation)
end

local function WeepingAngelMode(isLooking, player)
	if isLooking then
		safeChatterRef:ForceStopMovement()
		isMoving = false
	else
		if player then
			safeChatterRef:StartPathing(player.Character:GetPivot())
			isMoving = true
			print("PATH SS")
		end
	end
end

IsCameraLookingAtSafechatterRemote.OnServerEvent:Connect(function(player, looking)
	print(`player looking at Safechatter = {looking}`)
	WeepingAngelMode(looking, player)
end)

-- init
initializedRemote.Event:Connect(function()
	safeChatterRef = NPCModule:GetNPC("Safechatter")
	safeChatterRef:SetMode("Patrol")
end)

weepingAngelMode.Event:Connect(function(player)
	EnableCameraLook:FireClient(player, true, safeChatterRef.HumanoidRootPart)
end)

arrivedRemote.Event:Connect(function()
	if safeChatterRef:GetMode() == "Patrol" then
		PatrolMode()
		print("Arrived. Go to next destination ")
	elseif safeChatterRef:GetMode() == "Angel" then
		isMoving = false
	end
end)
