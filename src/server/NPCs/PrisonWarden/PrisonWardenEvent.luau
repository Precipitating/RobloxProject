local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local PrisonWardenEvent = {}
local GeneralRemotes = ReplicatedStorage.Remotes
local PlayerDoingSuspiciousActivity = false
local PlayerCellCovered = false
local WardenRef = nil
local PlayerRef = nil

function PrisonWardenEvent.SetPlayerRef(player)
	PlayerRef = player
end

function PrisonWardenEvent.CheckSuspicion()
	if not PlayerRef then
		error("Player reference not set!")
	end
	if not WardenRef then
		WardenRef = workspace:FindFirstChild("Prison"):FindFirstChild("PrisonWarden"):FindFirstChild("Warden")
	end
	local caught = false

	if PlayerDoingSuspiciousActivity then
		GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "Oi", WardenRef)
		caught = true
	end

	return caught
end

return PrisonWardenEvent
