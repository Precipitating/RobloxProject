local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local BadgeHandler = require(ServerScriptService.Server.BadgeHandler)
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local PrisonWardenEvent = {}
local GeneralRemotes = ReplicatedStorage.Remotes
local PlayerDoingSuspiciousActivity = false
local PlayerCellCovered = false
local BlanketCoverRef = nil
local WardenRef = nil
local BlanketCellPrompt = nil
local PlayerRef = nil

function PrisonWardenEvent.SetPlayerRef(player)
	PlayerRef = player
end
function PrisonWardenEvent.IsCellCovered()
	return PlayerCellCovered
end

function PrisonWardenEvent.SetDoingSusActivity(isSus)
	PlayerDoingSuspiciousActivity = isSus
end
function PrisonWardenEvent.SetCellCovered(player, covered)
	-- disable/reenable cover cell prompt
	if not BlanketCellPrompt then
		BlanketCellPrompt = ServerHelperFunctions.GetTaggedOfDirectory(workspace, "CoverCellPrompt")[1]
	end
	if covered then
		BlanketCoverRef = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "MoneyBait", "PrisonBlanket", nil)
		GeneralRemotes.PlaySound:InvokeClient(player, "OldSplat")
		BlanketCellPrompt.Enabled = false
	else
		BlanketCellPrompt.Enabled = true
	end
	PlayerCellCovered = covered
	print(`Cell covered set to {covered} `)
end

function PrisonWardenEvent.SpawnSpoon()
	local spoon = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "MoneyBait", "PrisonSpoon", nil)
	spoon.Name = `PrisonSpoon_{HttpService:GenerateGUID(false)}`
	local lift = Vector3.new(0, 0.4, 0)
	local dir = (spoon.CFrame.LookVector + lift).Unit
	local strength = 105
	spoon:ApplyImpulse(dir * strength * spoon.AssemblyMass)
	spoon:SetNetworkOwner(nil)

	spoon.Touched:Once(function(_)
		spoon.AssemblyLinearVelocity = Vector3.zero
		spoon.AssemblyAngularVelocity = Vector3.zero
	end)

	Debris:AddItem(spoon, 30)
end
function PrisonWardenEvent.CheckSuspicion()
	if not PlayerRef then
		error("Player reference not set!")
	end
	if not WardenRef then
		WardenRef = workspace:FindFirstChild("Prison"):FindFirstChild("PrisonWarden"):FindFirstChild("Warden")
	end
	local caught = false

	local secondsWatched = 0

	if PlayerCellCovered then
		GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "Confused", WardenRef)
		task.wait(2)
		GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "BlanketPull")

		for _, blanket in ipairs(BlanketCoverRef:GetChildren()) do
			blanket.Anchored = false
			Debris:AddItem(blanket, 2)
		end
		PrisonWardenEvent.SetCellCovered(false)
	end
	repeat
		if PlayerDoingSuspiciousActivity then
			GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "Oi", WardenRef)
			GeneralRemotes.DisableControls:FireClient(PlayerRef)
			ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "MoneyBait", "ElectricChairRoom")
			GeneralRemotes.BlackFade:FireClient(PlayerRef, 3, 0)
			task.wait(5)
			BadgeHandler.awardBadge(PlayerRef, 157269881825360)
			GeneralRemotes.PlayCutscene:FireClient(PlayerRef, "MoneyBaitCaught")

			caught = true
		end
		task.wait(1)
		secondsWatched += 1
		print(`Warden watching you...`)
	until caught or secondsWatched >= math.random(3, 6)

	return caught
end

return PrisonWardenEvent
