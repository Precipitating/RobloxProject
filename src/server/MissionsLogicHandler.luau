local HelperFunctions = require(script.Parent.HelperFunctions)
local BadgeHandler = require(script.Parent.BadgeHandler)
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local CashierModule = require(ServerScriptService.Server.NPCs.Cashier.CashierModule)
local BosnianRoulette = require(script.Parent.NPCs.Glitcher.BosnianRoulette)
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local SafechatterHelpers = require(script.Parent.NPCs.Safechatter.SafechatterHelpers)

local MissionEventHandlers = {}
-- handle all game events

-- Roadman
MissionEventHandlers["StealPhone"] = function(_)
	-- spawn the next NPC that progresses this mission
	local pos = Vector3.new(math.random(-360, 360), 5.23, -26.1)
	HelperFunctions.SpawnModelAtPosition("MissionModels", "Roadman", "PhoneVictim", pos)
end

MissionEventHandlers["RoadmanCaught"] = function(player)
	-- spawn surrounding cops around player
	HelperFunctions.SpawnModelAtPosition("MissionModels", "Roadman", "Cops", nil)

	-- award badge
	BadgeHandler.awardBadge(player, 4119036600108215)
	-- call cutscene
	GeneralRemotes.PlayCutscene:FireClient(player, "RoadmanFail")
end

MissionEventHandlers["RoadmanWin"] = function(player)
	HelperFunctions.SpawnModelAtPosition("MissionModels", "Roadman", "PC", nil)

	-- award badge
	BadgeHandler.awardBadge(player, 126301904067129)

	-- call cutscene
	GeneralRemotes.PlayCutscene:FireClient(player, "RoadmanWin")
end

MissionEventHandlers["RoadmanMugged"] = function(player)
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoid and rootPart then
		-- spawn signs
		local signs = HelperFunctions.SpawnModelAtPosition("MissionModels", "Roadman", "MuggedSigns", nil)

		-- award badge
		BadgeHandler.awardBadge(player, 1658087564169818)

		-- load beg animation
		GeneralRemotes.PlayAnimation:FireClient(player, "107485474814421")

		-- teleport player to sign's MoveLoc
		rootPart.CFrame = signs.MoveLoc.CFrame

		-- trigger cutscene for this player
		GeneralRemotes.PlayCutscene:FireClient(player, "RoadmanMugged")
	else
		warn("Humanoid or HumanoidRootPart missing for", player.Name)
	end
end

-- Safechatter
MissionEventHandlers["GuestMoney"] = function(_)
	print("GUEST MISSIO NBEGIN")
	HelperFunctions.SpawnMissionPositionedModels("Safechatter", "Mission")
end

MissionEventHandlers["GuestHorrorMode"] = function(player)
	local light, pathModel, prevPlayerPos, prevEnemyPos = SafechatterHelpers.InitializeGuestHorrorMode(player)

	-- handle fail obby
	local failed = SafechatterHelpers.HandleGuestHorrorModeFail(pathModel, light, player)

	-- handle touching the portal
	SafechatterHelpers.HandleGuestHorrorModeWin(pathModel, player, failed, prevPlayerPos, prevEnemyPos)
end

MissionEventHandlers["GuestPwn"] = function(player)
	GeneralRemotes.Blur:FireClient(player, 1, 100)
	local character = player.Character
	local alley = HelperFunctions.SpawnModelAtPosition("MissionModels", "Safechatter", "Alleyway")
	character:SetPrimaryPartCFrame(alley:FindFirstChild("SpawnLoc").CFrame)
	GeneralRemotes.PlayAnimation:FireClient(player, "73806503045226")
	BadgeHandler.awardBadge(player, 550797482323175)
	GeneralRemotes.PlayCutscene:FireClient(player, "GuestPwn")
	--cutsceneRemotes.PlayGuestPwn:FireClient(player)
	GeneralRemotes.Blur:FireClient(player, 1, 0)
end

MissionEventHandlers["GuestComplete"] = function(player)
	local character = player.Character
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local hallway = HelperFunctions.SpawnModelAtPosition("MissionModels", "Safechatter", "BrainwashHallway", nil)
	rootPart.CFrame = hallway:FindFirstChild("SpawnLoc").CFrame
	BadgeHandler.awardBadge(player, 3791811322299538)
	GeneralRemotes.PlayAnimation:FireClient(player, "135338300387862")
	GeneralRemotes.PlayCutscene:FireClient(player, "GuestMissionComplete")

	-- make pitch black
	Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
	Lighting.ClockTime = 0
end

-- Psycho Mantis

MissionEventHandlers["TypingCompetition"] = function(player)
	print("Typing competition start!")
	local competition = require(script.Parent.NPCs.PsychoMantis.TypingCompetition)
	if not competition then
		error("Word type competition failed to begin: Failed to obtain module")
	end
	local init = competition.Init(player)

	player.Character:SetPrimaryPartCFrame(workspace.Dumpster.Poop:GetPrimaryPartCFrame())
	if not init then
		error("Initialize word competition failed")
	end

	competition.Begin(player)
end

MissionEventHandlers["PsychoMantisFailLie"] = function(player)
	GeneralRemotes.Blur:FireClient(player, 1, 100)
	HelperFunctions.SpawnModelAtPosition("MissionModels", "PsychoMantis", "Hallway", nil)
	task.wait(3)
	GeneralRemotes.Blur:FireClient(player, 1, 0)
	GeneralRemotes.PlayCutscene:FireClient(player, "PsychoMantisFailLie")
	BadgeHandler.awardBadge(player, 1768903662252309)
end

MissionEventHandlers["PsychoMantisFailTruth"] = function(player)
	GeneralRemotes.Blur:FireClient(player, 1, 100)
	HelperFunctions.SpawnModelAtPosition("MissionModels", "PsychoMantis", "Hallway", nil)
	task.wait(3)
	GeneralRemotes.Blur:FireClient(player, 1, 0)
	GeneralRemotes.PlayCutscene:FireClient(player, "PsychoMantisFailTruth")
	BadgeHandler.awardBadge(player, 1517353246082078)
end

MissionEventHandlers["PsychoMantisWin"] = function(player)
	GeneralRemotes.Blur:FireClient(player, 1, 100)
	HelperFunctions.SpawnModelAtPosition("MissionModels", "PsychoMantis", "HallwayWin", nil)
	task.wait(3)
	GeneralRemotes.Blur:FireClient(player, 1, 0)
	GeneralRemotes.PlayCutscene:FireClient(player, "PsychoMantisWin")
	BadgeHandler.awardBadge(player, 2250718080144467)
end

-- Glitcher
MissionEventHandlers["BosnianRoulette"] = function(player)
	BosnianRoulette.Init(player)
end

MissionEventHandlers["GlitcherTerminalUnlocked"] = function(player)
	GeneralRemotes.PlayTheme:FireClient(player, "McDonaldTheme")
	GeneralRemotes.DisableControls:FireClient(player, "Cutscene")

	-- spawn van at X distance away from player, and arrive next to the player
	local character = player.Character
	if character and character.PrimaryPart then
		local primaryPart = character.PrimaryPart
		local arrivePos = primaryPart.Position
			+ (primaryPart.CFrame.RightVector * 10)
			+ (primaryPart.CFrame.UpVector * -2)

		local targetCFrame = CFrame.new(arrivePos, arrivePos + primaryPart.CFrame.LookVector)

		local spawnPos: Vector3 = primaryPart.Position
			+ (primaryPart.CFrame.RightVector * 10)
			+ (primaryPart.CFrame.UpVector * -5)
			+ (primaryPart.CFrame.LookVector * -150)

		local van = HelperFunctions.SpawnModelAtPosition("MissionModels", "Glitcher", "Van", spawnPos)
		local hand = van:FindFirstChild("Hand")
		van:SetPrimaryPartCFrame(CFrame.lookAt(van.PrimaryPart.Position, primaryPart.Position))

		-- tween van to player
		local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local tween = TweenService:Create(van.PrimaryPart, tweenInfo, { CFrame = targetCFrame })
		tween:Play()
		tween.Completed:Wait()

		local function handTween(lookVectorDist)
			local tweenInfoHand = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			local tweenHand = TweenService:Create(hand, tweenInfoHand, {
				CFrame = hand.CFrame + hand.CFrame.LookVector * lookVectorDist,
			})
			tweenHand:Play()
			tweenHand.Completed:Wait()
		end

		-- tween hand to player
		local handWeld = hand:FindFirstChild("WeldConstraint")
		handWeld.Part0 = nil
		hand:SetNetworkOwner(nil)
		handTween(-10)

		-- attach player to hand
		local root = character:FindFirstChild("HumanoidRootPart")
		local ap = Instance.new("AlignPosition")
		ap.Attachment0 = character.HumanoidRootPart:FindFirstChild("RootAttachment")
		ap.Attachment1 = hand:FindFirstChild("Attachment") -- make an Attachment in your moving part
		ap.RigidityEnabled = true
		ap.Parent = root

		-- tween hand (player attached) to van
		handTween(10)
		handWeld.Part0 = hand

		-- move van somewhere else + fade to black
		local escapeTweenInfo = TweenInfo.new(10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local escapeTween = TweenService:Create(
			van.PrimaryPart,
			escapeTweenInfo,
			{ CFrame = van.PrimaryPart.CFrame * CFrame.new(0, 0, -100) }
		)
		escapeTween:Play()
		GeneralRemotes.BlackFade:FireClient(player, 3, 0)

		-- cutscene
		HelperFunctions.SpawnModelAtPosition("MissionModels", "Glitcher", "RealVIPLocation", nil)
		escapeTween.Completed:Wait()
		GeneralRemotes.StopAllMusic:InvokeClient(player)

		GeneralRemotes.PlayCutscene:FireClient(player, "GlitcherRealVIP")
		GeneralRemotes.BlackFade:FireClient(player, 1, 1)
		BadgeHandler.awardBadge(player, 3494073379327445)

		print("done")
	end
end

-- Cashier
MissionEventHandlers["CashierShopLift"] = function(player)
	print("Cashier shoplift event")
end

MissionEventHandlers["CashierScammed"] = function(player)
	print("Cashier scammed event")
end

MissionEventHandlers["CashierAnger"] = function(player)
	print("Cashier Anger event")
	CashierModule.Init(player)
	CashierModule.Start(player)
end

return MissionEventHandlers
