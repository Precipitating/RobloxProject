local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local NPCModule = require(ServerScriptService.Server.NPCs.NPCModule)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local WeepingAngelModeEvent = ReplicatedStorage.Events.NPC.WeepingAngelMode
local IsCameraLookingAtSafechatterRemote = ReplicatedStorage.Remotes.IsCameraLookingAtPart
local EnableCameraLook = ReplicatedStorage.Remotes.EnableCameraLookDetection
local TripRemote = ReplicatedStorage.Remotes.Trip
local DelayHandle = nil
local HitEventConnected = false
local TouchedDebounce = false

local function WeepingAngelMode(player, isLooking)
	local SafeChatterRef = NPCModule:GetNPC("Safechatter")
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
					SafeChatterRef:StartPathing(player.Character:GetPivot())
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

WeepingAngelModeEvent.Event:Connect(function(player)
	local SafeChatterRef = NPCModule:GetNPC("Safechatter")
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
