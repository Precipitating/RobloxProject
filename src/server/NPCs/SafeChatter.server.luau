local DebuggerConnectionManager = game:GetService("DebuggerConnectionManager")
local Players = game:GetService("Players")
local NPCModule = require(script.Parent.NPCModule)
local initializedRemote = game.ReplicatedStorage.Shared.Events.NPC.InitializedNPC
local arrivedRemote = game.ReplicatedStorage.Shared.Events.NPC.ArrivedDestination
local weepingAngelMode = game.ReplicatedStorage.Shared.Events.NPC.WeepingAngelMode
local IsCameraLookingAtSafechatterRemote = game.ReplicatedStorage.Shared.Remotes.IsCameraLookingAtPart
local EnableCameraLook = game.ReplicatedStorage.Shared.Remotes.EnableCameraLookDetection
local TripRemote = game.ReplicatedStorage.Shared.Remotes.Trip
local safeChatterRef
local delayHandle = nil
local hitEventConnected = false
local touchedDebounce = false

local function PatrolMode()
	local pathData = safeChatterRef:GetPathStorage():GetChildren()
	local nextLocation = pathData[math.random(1, #pathData)]
	safeChatterRef:StartPathing(nextLocation)
end

local function WeepingAngelMode(player, isLooking)
	if isLooking then
		--player is looking: cancel any delayed move and stop movement
		if delayHandle ~= nil then
			task.cancel(delayHandle)
			delayHandle = nil
		end
		safeChatterRef:ForceStopMovement()
	else
		-- player is NOT looking: start delay before movement
		if player and player.Character then
			delayHandle = task.delay(1, function()
				-- Double-check character still exists
				if player.Character then
					safeChatterRef:StartPathing(player.Character:GetPivot(), player)
					print("Path resume")
				end
				delayHandle = nil
			end)
		end
	end
end

IsCameraLookingAtSafechatterRemote.OnServerEvent:Connect(function(player, looking)
	print(`player looking at Safechatter = {looking}`)
	WeepingAngelMode(player, looking)
end)

-- init
initializedRemote.Event:Connect(function()
	safeChatterRef = NPCModule:GetNPC("Safechatter")
	safeChatterRef:SetMode("Patrol")
end)

weepingAngelMode.Event:Connect(function(player)
	EnableCameraLook:FireClient(player, true, safeChatterRef.HumanoidRootPart)
	WeepingAngelMode(player, false)

	-- if NPC touches player, trip them
	if not hitEventConnected then
		for _, part in pairs(safeChatterRef:GetModel():GetDescendants()) do
			if part:IsA("BasePart") then
				part.Touched:Connect(function(hit)
					local isPlayer = Players:GetPlayerFromCharacter(hit.Parent)
					if isPlayer and not touchedDebounce then
						touchedDebounce = true
						TripRemote:FireClient(player)
						task.wait(1)
						touchedDebounce = false
					end
				end)
			end
		end
		hitEventConnected = true
	end
end)

arrivedRemote.Event:Connect(function()
	if safeChatterRef:GetMode() == "Patrol" then
		PatrolMode()
		print("Arrived. Go to next destination ")
	end
end)
