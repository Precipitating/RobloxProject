local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local BadgeHandler = require(ServerScriptService.Server.BadgeHandler)
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local GeneralRemotes = ReplicatedStorage.Remotes
local TerminalUnlocked = {}

-- play music + disable controls
function TerminalUnlocked.StartTheme(player)
	GeneralRemotes.PlayTheme:FireClient(player, "McDonaldTheme")
	GeneralRemotes.DisableControls:FireClient(player, "Cutscene")
end

-- spawn van near player
function TerminalUnlocked.SpawnVan(player)
	local character = player.Character
	if not (character and character.PrimaryPart) then
		return nil
	end

	local primaryPart = character.PrimaryPart
	local arrivePos = primaryPart.Position + (primaryPart.CFrame.RightVector * 10) + (primaryPart.CFrame.UpVector * -2)

	local targetCFrame = CFrame.new(arrivePos, arrivePos + primaryPart.CFrame.LookVector)

	local spawnPos: Vector3 = primaryPart.Position
		+ (primaryPart.CFrame.RightVector * 10)
		+ (primaryPart.CFrame.UpVector * -5)
		+ (primaryPart.CFrame.LookVector * -150)

	local van = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Glitcher", "Van", spawnPos)
	if not van then
		warn("Van not found!")
		return nil
	end
	local hand = van:FindFirstChild("Hand")
	local handWeld = hand and hand:FindFirstChild("WeldConstraint")
	if handWeld then
		handWeld.Enabled = true
	end

	van:SetPrimaryPartCFrame(CFrame.lookAt(van.PrimaryPart.Position, primaryPart.Position))

	return van, hand, targetCFrame
end

-- tween van to player
function TerminalUnlocked.TweenVanToPlayer(van, targetCFrame)
	local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tween = TweenService:Create(van.PrimaryPart, tweenInfo, { CFrame = targetCFrame })
	tween:Play()
	tween.Completed:Wait()
end

-- tween the hand in/out
function TerminalUnlocked.TweenHand(hand, lookVectorDist)
	local tweenInfoHand = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tweenHand = TweenService:Create(hand, tweenInfoHand, {
		CFrame = hand.CFrame + hand.CFrame.LookVector * lookVectorDist,
	})
	tweenHand:Play()
	tweenHand.Completed:Wait()
end

-- grab player with hand
function TerminalUnlocked.AttachPlayerToHand(player, hand, van)
	local character = player.Character
	if not character then
		return
	end

	local handWeld = hand:FindFirstChild("WeldConstraint")
	if handWeld then
		handWeld.Part0 = nil
	end

	hand:SetNetworkOwner(nil)
	TerminalUnlocked.TweenHand(hand, -10)

	local root = character:FindFirstChild("HumanoidRootPart")
	local attachment = hand:FindFirstChild("AlignPosition")
	if root and attachment then
		attachment.Attachment0 = root:FindFirstChild("RootAttachment")
		attachment.Attachment1 = hand:FindFirstChild("Attachment")
	end

	TerminalUnlocked.TweenHand(hand, 10)
	if handWeld then
		handWeld.Part0 = van.PrimaryPart
	end
end

-- escape + fade
function TerminalUnlocked.EscapeSequence(player, van)
	local escapeTweenInfo = TweenInfo.new(10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local escapeTween = TweenService:Create(
		van.PrimaryPart,
		escapeTweenInfo,
		{ CFrame = van.PrimaryPart.CFrame * CFrame.new(0, 0, -100) }
	)
	escapeTween:Play()
	GeneralRemotes.BlackFade:FireClient(player, 3, 0)

	ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Glitcher", "RealVIPLocation", nil)
	escapeTween.Completed:Wait()
end

-- finish cutscene + award
function TerminalUnlocked.FinishCutscene(player)
	GeneralRemotes.StopAllMusic:InvokeClient(player)
	GeneralRemotes.PlayCutscene:FireClient(player, "GlitcherRealVIP")
	GeneralRemotes.BlackFade:FireClient(player, 1, 1)
	BadgeHandler.awardBadge(player, 3494073379327445)
	print("done")
end

-- orchestrator (runs the full flow)
function TerminalUnlocked.Run(player)
	TerminalUnlocked.StartTheme(player)

	local van, hand, targetCFrame = TerminalUnlocked.SpawnVan(player)
	if not (van and hand and targetCFrame) then
		return
	end

	TerminalUnlocked.TweenVanToPlayer(van, targetCFrame)
	TerminalUnlocked.AttachPlayerToHand(player, hand, van)
	TerminalUnlocked.EscapeSequence(player, van)
	TerminalUnlocked.FinishCutscene(player)
end

return TerminalUnlocked
