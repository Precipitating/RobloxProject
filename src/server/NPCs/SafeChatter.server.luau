local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local NPCModule = require(script.Parent.NPCModule)
local InitializedRemote = ReplicatedStorage.Events.NPC.InitializedNPC
local ArrivedRemote = ReplicatedStorage.Events.NPC.ArrivedDestination
local WeepingAngelModeEvent = ReplicatedStorage.Events.NPC.WeepingAngelMode
local IsCameraLookingAtSafechatterRemote = ReplicatedStorage.Remotes.IsCameraLookingAtPart
local EnableCameraLook = ReplicatedStorage.Remotes.EnableCameraLookDetection
local TripRemote = ReplicatedStorage.Remotes.Trip
local SafeChatterRef
local DelayHandle = nil
local HitEventConnected = false
local TouchedDebounce = false

local function PatrolMode()
	local pathData = SafeChatterRef:GetPathStorage():GetChildren()
	local nextLocation = pathData[math.random(1, #pathData)]
	SafeChatterRef:StartPathing(nextLocation)
end

local function WeepingAngelMode(player, isLooking)
	if isLooking then
		--player is looking: cancel any delayed move and stop movement
		if DelayHandle ~= nil then
			task.cancel(DelayHandle)
			DelayHandle = nil
		end
		SafeChatterRef:ForceStopMovement()
	else
		-- player is NOT looking: start delay before movement
		if player and player.Character then
			DelayHandle = task.delay(2, function()
				-- Double-check character still exists
				if player.Character then
					SafeChatterRef:StartPathing(player.Character:GetPivot(), player)
					print("Path resume")
				end
				DelayHandle = nil
			end)
		end
	end
end

IsCameraLookingAtSafechatterRemote.OnServerEvent:Connect(function(player, looking)
	print(`player looking at Safechatter = {looking}`)
	WeepingAngelMode(player, looking)
end)

-- init
InitializedRemote.Event:Connect(function()
	SafeChatterRef = NPCModule:GetNPC("Safechatter")
	SafeChatterRef:SetMode("Patrol")
end)

WeepingAngelModeEvent.Event:Connect(function(player)
	EnableCameraLook:FireClient(player, true, SafeChatterRef.HumanoidRootPart)
	WeepingAngelMode(player, false)

	-- if NPC touches player, trip them
	if not HitEventConnected then
		for _, part in pairs(SafeChatterRef:GetModel():GetDescendants()) do
			if part:IsA("BasePart") then
				local connection = part.Touched:Connect(function(hit)
					local isPlayer = Players:GetPlayerFromCharacter(hit.Parent)
					if isPlayer and not TouchedDebounce then
						TouchedDebounce = true
						TripRemote:FireClient(player)
						task.wait(1)
						TouchedDebounce = false
					end
				end)
				SafeChatterRef.Connections[connection] = true
			end
		end
		HitEventConnected = true
	end
end)

ArrivedRemote.Event:Connect(function()
	if SafeChatterRef:GetMode() == "Patrol" then
		PatrolMode()
		print("Arrived. Go to next destination ")
	end
end)
