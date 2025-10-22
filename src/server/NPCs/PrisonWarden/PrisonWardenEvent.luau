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

local EscapedRoom = false

local GameFinished = false

local RopeClimbTime = 30

local RopeTweenHandle = nil

function PrisonWardenEvent.SetPlayerRef(player)
	PlayerRef = player
end

function PrisonWardenEvent.CancelRopeTween()
	if not RopeTweenHandle then
		warn("No rope tween handle exists! Possibly cancelled already")
		return
	end
	RopeTweenHandle:Cancel()
	RopeTweenHandle = nil
	print("Rope tween cancelled!")
end

function PrisonWardenEvent.SetEscapedRoom(val)
	EscapedRoom = val

	if EscapedRoom then
		WardenRef = nil
		BlanketCoverRef = nil
		PaperCloneRef = nil
	end
end

function PrisonWardenEvent.HasEscaped()
	return EscapedRoom
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

function PrisonWardenEvent.SetGameFinished(val)
	if val then
		GameFinished = true
		PlayerRef.Character:PivotTo(workspace.BlackRoom.SpawnLoc:GetPivot())
		GeneralRemotes.DisableControls:FireClient(PlayerRef)
		local prison = workspace:FindFirstChild("Prison")

		if prison then
			prison:Destroy()
		end
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
		while task.wait(1) and not EscapedRoom do
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
	local openGoal = { Position = toilet.Position + vector.create(5, 0, 0) }
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
	local lift = vector.create(0, 0.4, 0)
	local dir = vector.normalize(throwable.CFrame.LookVector + lift)
	local strength = 105
	throwable:ApplyImpulse(dir * strength * throwable.AssemblyMass)
	throwable:SetNetworkOwner(nil)

	throwable.Touched:Once(function(_)
		throwable.AssemblyLinearVelocity = vector.zero
		throwable.AssemblyAngularVelocity = vector.zero
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

	if EscapedRoom then
		warn("Player escaped already, not checking suspicion")
		return
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
			PrisonWardenEvent.SetGameFinished(true)
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

function PrisonWardenEvent.InfirmaryDoorInit(player)
	local doorRef = workspace:FindFirstChild("Infirmary"):FindFirstChild("DoorBang")
	if not doorRef then
		error("Missing door ref for infirmary")
	end

	local tweenInfo = TweenInfo.new(
		0.1,
		Enum.EasingStyle.Bounce,
		Enum.EasingDirection.Out,
		-1, -- RepeatCount (when less than zero the tween will loop indefinitely)
		true, -- Reverses (tween will reverse once reaching it's goal)
		0.65 -- DelayTime
	)
	local goal = { CFrame = doorRef.CFrame * CFrame.new(-0.3, 0, 0) }
	local tween = TweenService:Create(doorRef, tweenInfo, goal)

	tween:Play()

	local sound = doorRef:FindFirstChild("AudioPlayer")

	if sound then
		sound:Play()
	end

	-- start timer before door breaks open
	task.spawn(function()
		local timeBeforeDoorOpens = 120
		while timeBeforeDoorOpens > 0 do
			task.wait(1)
			timeBeforeDoorOpens -= 1
		end

		if GameFinished then
			return
		end

		-- reach here = failed
		ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "MoneyBait", "ElectricChairRoom", nil)
		tween:Cancel()
		doorRef.Anchored = false
		doorRef:SetNetworkOwner(nil)
		sound:Stop()
		doorRef:ApplyImpulse(vector.create(0, 0, 60) * doorRef.AssemblyMass)

		local mcDonaldMan = workspace:FindFirstChild("Infirmary"):FindFirstChild("McDonaldMan")
		if not mcDonaldMan then
			error("McDonald man missing")
		end
		tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
		goal = { CFrame = mcDonaldMan.PrimaryPart.CFrame * CFrame.new(5, 0, 0) }
		tween = TweenService:Create(mcDonaldMan.PrimaryPart, tweenInfo, goal)
		tween:Play()
		tween.Completed:Wait()

		GeneralRemotes.PlaySound:InvokeClient(player, "Oi")
		GeneralRemotes.BlackFade:FireClient(player, 1, 0)

		task.wait(3)
		GeneralRemotes.PlayCutscene:FireClient(player, "MoneyBaitCaught")
		print("Failed to escape")
	end)
end

function PrisonWardenEvent.HookRope(player, modelName)
	local hooked = false
	local hookObjectsFolder = workspace:FindFirstChild("Infirmary"):FindFirstChild("HookObjects")
	local targetHook = hookObjectsFolder:FindFirstChild(modelName)
	local ropeConstraint = hookObjectsFolder:FindFirstChild("RopeConstraint")

	if not targetHook then
		error(`Failed to get hook model reference {modelName}`)
	end

	if not ropeConstraint then
		error("Failed to get rope constraint reference")
	end

	local ropeConstraint0 = ropeConstraint.Attachment0
	local ropeConstraint1 = ropeConstraint.Attachment1
	if not ropeConstraint0 then
		ropeConstraint.Attachment0 = targetHook:FindFirstChild("Attachment")
		hooked = true
	else
		if not ropeConstraint1 then
			ropeConstraint.Attachment1 = targetHook:FindFirstChild("Attachment")
			hooked = true
		end
	end

	if ropeConstraint and ropeConstraint.Attachment0 and ropeConstraint.Attachment1 then
		ServerHelperFunctions.RemoveEquippedTool(player)
		local elevatorButton = hookObjectsFolder:FindFirstChild("CloseElevatorButton")
		if not elevatorButton then
			error("Failed to get elevator button ref")
		end
		elevatorButton:FindFirstChild("ProximityPrompt").Enabled = true
		print("Rope connected, should be removed from inventory")
	end

	return hooked
end

function PrisonWardenEvent.CloseElevatorAndPullRope(player)
	local hookObjectsFolder = workspace:FindFirstChild("Infirmary"):FindFirstChild("HookObjects")
	local door = hookObjectsFolder:FindFirstChild("Door")
	if not door then
		error("Missing elevator door ref")
	end

	-- close door
	GeneralRemotes.PlaySound:InvokeClient(player, "CloseElevator", door)
	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear)
	local goal = { CFrame = door.CFrame * CFrame.new(0, 0, -4.409) }
	local tween = TweenService:Create(door, tweenInfo, goal)
	tween:Play()
	tween.Completed:Wait()

	-- start pulling rope
	local ropeRail = hookObjectsFolder:FindFirstChild("RopeRail")
	if not ropeRail then
		error("Failed to get rope rail ref")
	end
	tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear)
	GeneralRemotes.PlaySound:InvokeClient(player, "MoveElevator", door)
	goal = { Position = ropeRail.Position - vector.create(8, 0, 0) }
	tween = TweenService:Create(ropeRail, tweenInfo, goal)
	tween:Play()
	tween.Completed:Wait()

	-- rip bars off window
	local bar = hookObjectsFolder:FindFirstChild("Bars")
	bar.Anchored = false
	bar:SetNetworkOwner(nil)
	task.wait(0.03)
	GeneralRemotes.PlaySound:InvokeClient(player, "GateRip", bar)
	bar:ApplyImpulse(vector.create(-60, 0, 0) * bar.AssemblyMass)

	-- enable climb prompt
	local climbPrompt = hookObjectsFolder:FindFirstChild("ClimbRopePart"):FindFirstChild("ProximityPrompt")
	if not climbPrompt then
		error("Failed to get climb prompt ref")
	end
	climbPrompt.Enabled = true
end

function PrisonWardenEvent.PlayerAttachRope(player)
	local infirmary = workspace:FindFirstChild("Infirmary")
	local character = player.Character
	local hook = infirmary:FindFirstChild("Hook")

	if not hook then
		error("Failed to get hook reference")
	end
	local characterAttachment = character.Torso.BodyFrontAttachment
	local hookAttachment = hook:FindFirstChild("HookOnAttachment")

	-- hook player onto rope
	local alignOrientation = hookAttachment:FindFirstChildOfClass("AlignOrientation")
	local alignPos = hookAttachment:FindFirstChildOfClass("AlignPosition")
	alignOrientation.Attachment1 = characterAttachment
	alignPos.Attachment1 = characterAttachment
	character.Humanoid.PlatformStand = true

	-- set player anim
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://85149388449475"
	local animTrack = character.Humanoid:LoadAnimation(animation)
	animTrack:Play()

	-- slowly move hook
	local tweenInfo = TweenInfo.new(RopeClimbTime, Enum.EasingStyle.Linear)
	local goal = { Position = hookAttachment.Position + vector.create(0, 61, 0) }
	RopeTweenHandle = TweenService:Create(hookAttachment, tweenInfo, goal)
	RopeTweenHandle:Play()

	-- if completed, then stop hooking player
	RopeTweenHandle.Completed:Once(function(state)
		character.Humanoid.PlatformStand = false
		animTrack:Stop()
		alignOrientation.Attachment1 = nil
		alignPos.Attachment1 = nil

		if state == Enum.PlaybackState.Completed then
			GeneralRemotes.MoneyBait.DeleteQuickTimeGUI:FireClient(player)
			GeneralRemotes.BlackFade:FireClient(player, 1, 0)
			task.wait(1)
			ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "MoneyBait", "Alleyway")
			GeneralRemotes.PlayCutscene:FireClient(player, "MoneyBaitEscaped")
			BadgeHandler.awardBadge(player, 3628178665725253)
		elseif state == Enum.PlaybackState.Cancelled then
			-- failed
			GeneralRemotes.BlackFade:FireClient(player, 1, 0)
			task.wait(1)
			ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "MoneyBait", "ElectricChairRoom")
			GeneralRemotes.PlayCutscene:FireClient(player, "MoneyBaitCaught")
		end

		PrisonWardenEvent.SetGameFinished(true)
	end)
end
return PrisonWardenEvent
