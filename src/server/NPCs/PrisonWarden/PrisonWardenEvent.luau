local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local BadgeHandler = require(ServerScriptService.Server.BadgeHandler)
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local GeneralRemotes = ReplicatedStorage.Remotes
local PrisonWardenEvent = {}

local PlayerDoingSuspiciousActivity = false
local PlayerCellCovered = false
local ToiletOpened = false

local BlanketCoverRef = nil
local BlanketCellPrompt = nil

local PlayerInCell = true

local WardenRef = nil
local PlayerRef = nil

local PaperCloneActivated = false
local PaperCloneRef = nil

function PrisonWardenEvent.SetPlayerRef(player)
	PlayerRef = player
end
function PrisonWardenEvent.IsCellCovered()
	return PlayerCellCovered
end
function PrisonWardenEvent.IsPaperCloneActivated()
	return PaperCloneActivated
end
function PrisonWardenEvent.SetPaperClone(val)
	if val then
		if PaperCloneRef then
			PaperCloneRef = nil
		end
		PaperCloneRef = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "MoneyBait", "PaperClone", nil)
		PaperCloneActivated = true
	else
		PaperCloneRef:Destroy()
		PaperCloneRef = nil
		PaperCloneActivated = false
		GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "PaperScrunch")
	end
end

function PrisonWardenEvent.UpdateSuspicion()
	PlayerDoingSuspiciousActivity = ToiletOpened or (not PlayerInCell and not PaperCloneActivated)
end

function PrisonWardenEvent.SetupCellRegion(prisonModel)
	local regionPart = prisonModel:FindFirstChild("Region", true)
	if not regionPart then
		error("Missing region ref")
	end

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { PlayerRef.Character }

	task.spawn(function()
		while task.wait(1) do
			local partsInRegion = workspace:GetPartBoundsInBox(regionPart.CFrame, regionPart.Size, params)
			local isPlayerInCell = false

			for _, partInRegion in ipairs(partsInRegion) do
				if partInRegion:IsDescendantOf(PlayerRef.Character) then
					isPlayerInCell = true
					break
				end
			end

			if isPlayerInCell ~= PlayerInCell then
				PlayerInCell = isPlayerInCell
				print(PlayerInCell and "Player in cell" or "Player NOT in cell")
				PrisonWardenEvent.UpdateSuspicion()
			end
		end
	end)
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

-- handle open/close toilet prompts
local function HandleToiletMovement(toilet)
	local unscrewPrompt = toilet:FindFirstChild("UnscrewPrompt")
	local openPrompt = toilet:FindFirstChild("OpenPrompt")
	local closePrompt = toilet:FindFirstChild("ClosePrompt")
	local isToiletOpened = toilet:FindFirstChild("Opened")
	if not unscrewPrompt or not closePrompt or not openPrompt then
		error("Missing toilet prompt references")
	end
	unscrewPrompt.Enabled = false

	local toiletMoveTween = TweenInfo.new(2, Enum.EasingStyle.Sine)
	local openGoal = { Position = toilet.Position + Vector3.new(5, 0, 0) }
	local closeGoal = { Position = toilet.Position }
	local openTween = TweenService:Create(toilet, toiletMoveTween, openGoal)
	local closeTween = TweenService:Create(toilet, toiletMoveTween, closeGoal)
	openPrompt.Enabled = true

	-- handle open/close toilet
	isToiletOpened:GetPropertyChangedSignal("Value"):Connect(function()
		print("BoolValue changed to:", isToiletOpened.Value)
		if isToiletOpened.Value then
			openPrompt.Enabled = false
			openTween:Play()
			openTween.Completed:Wait()
			closePrompt.Enabled = true
			ToiletOpened = true
			PrisonWardenEvent.UpdateSuspicion()
		else
			closePrompt.Enabled = false
			closeTween:Play()
			closeTween.Completed:Wait()
			openPrompt.Enabled = true
			ToiletOpened = false
			PrisonWardenEvent.UpdateSuspicion()
		end
	end)
end

function PrisonWardenEvent.UnscrewToilet(player)
	local holdingSpoon = player.Character:FindFirstChild("PrisonSpoon")
	if not holdingSpoon then
		warn("Not holding spoon, can't unscrew toilet.")
		return
	end
	local toilet = workspace:FindFirstChild("Prison"):FindFirstChild("EscapeToilet")
	if not toilet then
		error("Toilet ref missing")
	end

	holdingSpoon:Destroy()
	GeneralRemotes.PlaySound:InvokeClient(player, "MetalSnap")

	HandleToiletMovement(toilet)
end
function PrisonWardenEvent.SpawnThrowable(name)
	local throwable = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "MoneyBait", name, nil)
	throwable.Name = `{name}_{HttpService:GenerateGUID(false)}`
	local lift = Vector3.new(0, 0.4, 0)
	local dir = (throwable.CFrame.LookVector + lift).Unit
	local strength = 105
	throwable:ApplyImpulse(dir * strength * throwable.AssemblyMass)
	throwable:SetNetworkOwner(nil)

	throwable.Touched:Once(function(_)
		throwable.AssemblyLinearVelocity = Vector3.zero
		throwable.AssemblyAngularVelocity = Vector3.zero
	end)

	Debris:AddItem(throwable, 30)
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

	if not PlayerInCell and PaperCloneActivated then
		PrisonWardenEvent.SetPaperClone(false)
	end

	return caught
end

return PrisonWardenEvent
