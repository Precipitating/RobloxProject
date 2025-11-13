local BadgeHandler = require(script.Parent.BadgeHandler)
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local CurrencyHandler = require(script.Parent.CurrencyHandler)
local HaulJob = require(ReplicatedStorage.NPCs.ManualLabor.HaulJob)
local TrashPickup = require(ReplicatedStorage.NPCs.TrashPickup.TrashPickup)
local CashierModule = require(ServerScriptService.Server.NPCs.Cashier.CashierModule)
local GroceryBagModule = require(ServerScriptService.Server.NPCs.Cashier.GroceryBagModule)
local ShopLiftConsequences = require(ServerScriptService.Server.NPCs.Cashier.ShopLiftConsequences)
local PumpkinBossFight = require(ServerScriptService.Server.NPCs.CupcakeLover.PumpkinBossFight)
local DrivingTest = require(ServerScriptService.Server.NPCs.DrivingInstructor.DrivingTest)
local TerminalUnlocked = require(ServerScriptService.Server.NPCs.Glitcher.TerminalUnlocked)
local PrisonWardenEvent = require(ServerScriptService.Server.NPCs.PrisonWarden.PrisonWardenEvent)
local WhodunnitMode = require(ServerScriptService.Server.NPCs.Whodunnit.WhodunnitMode)
local TVRoomInitialize = require(ServerScriptService.Server.Room.TVRoomInitialize)
local BulletGuesser = require(ServerScriptService.Server.RoomScripts.Gamba.BulletGuesser)
local BosnianRoulette = require(script.Parent.NPCs.Glitcher.BosnianRoulette)
local GeneralRemotes = ReplicatedStorage.Remotes
local Safechatter = require(script.Parent.NPCs.Safechatter.Safechatter)
local ServerHelperFunctions = require(script.Parent.ServerHelperFunctions)
local Missions = require(ReplicatedStorage.Missions.Server.Missions)
local ZombieJob = require(ReplicatedStorage.NPCs.ZombieJob.ZombieJob)
local TalkModuleHelpers = require(script.Parent.TalkModuleHelpers)
local MissionEventHandlers = {}
-- handle all server game events

-- Roadman
MissionEventHandlers["StealPhone"] = function(_)
	-- spawn the next NPC that progresses this mission
	local victim = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Roadman", "PhoneVictim", nil)
	local spawnPosList = ServerStorage.MissionModels.Roadman:FindFirstChild("PhoneVictimSpawns"):GetChildren()
	local spawnPos = spawnPosList[math.random(1, #spawnPosList)]
	victim:PivotTo(spawnPos.CFrame)
end

MissionEventHandlers["RoadmanCaught"] = function(player)
	-- spawn surrounding cops around player
	ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Roadman", "Cops", nil)
	-- award badge
	BadgeHandler.awardBadge(player, 4119036600108215)
	-- call cutscene
	GeneralRemotes.PlayCutscene:FireClient(player, "RoadmanFail")
end

MissionEventHandlers["RoadmanWin"] = function(player)
	ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Roadman", "PC", nil)

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
		local signs = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Roadman", "MuggedSigns", nil)

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
	print("GUEST MISSION BEGIN")
	ServerHelperFunctions.SpawnMissionPositionedModels("MissionModels", "Safechatter", "Mission")
end

MissionEventHandlers["GuestHorrorMode"] = function(player)
	local light, pathModel, prevPlayerPos, prevEnemyPos = Safechatter.InitializeGuestHorrorMode(player)

	-- handle fail obby
	Safechatter.HandleGuestHorrorModeFail(pathModel, light, player)

	-- handle touching the portal
	Safechatter.HandleGuestHorrorModeWin(pathModel, player, prevPlayerPos, prevEnemyPos)
end

MissionEventHandlers["GuestPwn"] = function(player)
	GeneralRemotes.BlackFade:FireClient(player, 0, 0)
	local character = player.Character
	local alley = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Safechatter", "Alleyway", nil)
	workspace:FindFirstChild("InvisiblePaths"):Destroy()
	GeneralRemotes.PlayAnimation:FireClient(player, "73806503045226")
	BadgeHandler.awardBadge(player, 550797482323175)
	character:PivotTo(alley:FindFirstChild("SpawnLoc").CFrame)
	GeneralRemotes.PlayCutscene:FireClient(player, "GuestPwn")
	task.wait(1)
	GeneralRemotes.BlackFade:FireClient(player, 0.5, 1)
end

MissionEventHandlers["GuestComplete"] = function(player)
	local character = player.Character
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local hallway = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Safechatter", "BrainwashHallway", nil)
	rootPart.CFrame = hallway:WaitForChild("SpawnLoc").CFrame
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

	player.Character:PivotTo(workspace.StreetProps.Dumpster.Poop:GetPrimaryPartCFrame())
	if not init then
		error("Initialize word competition failed")
	end

	competition.Begin(player)
end

MissionEventHandlers["PsychoMantisFailLie"] = function(player)
	GeneralRemotes.BlackFade:FireClient(player, 1, 0)
	ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "PsychoMantis", "Hallway", nil)
	task.wait(3)
	GeneralRemotes.BlackFade:FireClient(player, 1, 1)
	GeneralRemotes.PlayCutscene:FireClient(player, "PsychoMantisFailLie")
	BadgeHandler.awardBadge(player, 1768903662252309)
end

MissionEventHandlers["PsychoMantisFailTruth"] = function(player)
	GeneralRemotes.BlackFade:FireClient(player, 1, 0)
	ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "PsychoMantis", "Hallway", nil)
	task.wait(3)
	GeneralRemotes.BlackFade:FireClient(player, 1, 1)
	GeneralRemotes.PlayCutscene:FireClient(player, "PsychoMantisFailTruth")
	BadgeHandler.awardBadge(player, 1517353246082078)
end

MissionEventHandlers["PsychoMantisWin"] = function(player)
	GeneralRemotes.BlackFade:FireClient(player, 1, 0)
	ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "PsychoMantis", "HallwayWin", nil)
	task.wait(3)
	GeneralRemotes.BlackFade:FireClient(player, 1, 1)
	GeneralRemotes.PlayCutscene:FireClient(player, "PsychoMantisWin")
	BadgeHandler.awardBadge(player, 2250718080144467)
end

-- Glitcher
MissionEventHandlers["BosnianRoulette"] = function(player)
	BosnianRoulette.Init(player)
end

MissionEventHandlers["GlitcherTerminalUnlocked"] = function(player)
	TerminalUnlocked.Run(player)
end

-- Cashier
MissionEventHandlers["CashierShopLift"] = function(player)
	print("Cashier shoplift event")
	GroceryBagModule.UpdateGroceries(player)
	GeneralRemotes.Cashier.ClearBasket:FireClient(player)
	TalkModuleHelpers.SetCanTalk(false)

	local spawns = {
		function()
			ShopLiftConsequences.SpawnJacker(player)
		end,
		function()
			ShopLiftConsequences.SpawnTrap(player, "Anvil", "Anvil", math.random(0, 50), 50, 3, 5)
		end,
		function()
			ShopLiftConsequences.SpawnTrap(player, "Banana", "BananaSlip", 10, -2.3, 3, 5)
		end,
		function()
			ShopLiftConsequences.InvertControls(player)
		end,
		function()
			ShopLiftConsequences.Berate(player)
		end,
		function()
			ShopLiftConsequences.SpawnLightningBolt(player)
		end,
	}

	while not ShopLiftConsequences.IsBlackedOut() do
		task.wait(math.random(5, 7))

		local choice = spawns[math.random(1, #spawns)]
		choice()
	end

	-- player's screen is blacked out
	ShopLiftConsequences.SpawnMeteorite(player)
end

MissionEventHandlers["CashierScammed"] = function(player)
	print("Cashier scammed event")
	GroceryBagModule.UpdateGroceries(player)

	if GroceryBagModule.HasItem("Laptop") and Missions.MissionExists("Laptop") then
		Missions.addProgressToTask(player, "Laptop", "BuyLaptop", 1)
		workspace:FindFirstChild("BosnianDad"):Destroy()
	end

	GeneralRemotes.Cashier.ClearBasket:FireClient(player)
end

MissionEventHandlers["CashierAnger"] = function(player)
	print("Cashier Anger event")
	CashierModule.Init(player)
	CashierModule.Start(player)
end

MissionEventHandlers["CashierAngerEnd"] = function(player)
	GeneralRemotes.PlayCutscene:FireClient(player, "CashierAngerEnd")
	BadgeHandler.awardBadge(player, 352477117785792)
end

MissionEventHandlers["CashierScammedFinished"] = function(player)
	ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Cashier", "Warehouse", nil)
	GeneralRemotes.PlayCutscene:FireClient(player, "CashierScammed")
	BadgeHandler.awardBadge(player, 2453227885155938)
end

MissionEventHandlers["DrivingTest"] = function(player)
	DrivingTest.Init(player, player.Character:GetPivot())
end

MissionEventHandlers["DrivingTestPassed"] = function(player)
	TalkModuleHelpers.SetCanTalk(false)
	GeneralRemotes.BlackFade:FireClient(player, 0.5, 0)
	task.wait(0.5)
	BadgeHandler.awardBadge(player, 2493042217612033)
	GeneralRemotes.PlayCutscene:FireClient(player, "DrivingTestPassed")
end

MissionEventHandlers["DrivingTestFailed"] = function(player)
	TalkModuleHelpers.SetCanTalk(false)
	GeneralRemotes.BlackFade:FireClient(player, 0.5, 0)
	task.wait(0.5)
	BadgeHandler.awardBadge(player, 1698025412209346)
	GeneralRemotes.PlayCutscene:FireClient(player, "DrivingTestFailed")
end

MissionEventHandlers["HaulJob"] = function(player)
	HaulJob.ServerInit(player)
end

MissionEventHandlers["TrashPickup"] = function(_)
	TrashPickup.ServerInit()
end

MissionEventHandlers["BulletGuesser"] = function(player)
	BulletGuesser.Start(player)
end
MissionEventHandlers["BosnianStart"] = function(_)
	ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Bosnian", "BosnianDad", nil)
end
MissionEventHandlers["BosnianComplete"] = function(player)
	CurrencyHandler.AddMoney(player, 1)
	GeneralRemotes.BlackFade:FireClient(player, 1, 0)
	BadgeHandler.awardBadge(player, 4449692306836938)
	task.delay(1, function()
		GeneralRemotes.PlayCutscene:FireClient(player, "BosnianComplete")
		GeneralRemotes.BlackFade:FireClient(player, 1, 1)
	end)
end

MissionEventHandlers["BosnianScammed"] = function(player)
	GeneralRemotes.PlaySound:InvokeClient(player, "CartoonRun")
	workspace:FindFirstChild("BosnianDad"):Destroy()
	Missions.FailMission(player, "Laptop")
end

MissionEventHandlers["BosnianFailEvent"] = function(player)
	CurrencyHandler.AddMoney(player, 1)
	GeneralRemotes.BlackFade:FireClient(player, 1, 0)
	task.delay(1, function()
		BadgeHandler.awardBadge(player, 636617031698169)
		GeneralRemotes.PlayCutscene:FireClient(player, "BosnianFailed")
		GeneralRemotes.BlackFade:FireClient(player, 1, 1)
	end)
end
MissionEventHandlers["ZombieJob"] = function(player)
	ZombieJob.ServerInit(player)
end

MissionEventHandlers["R2DPumpkinBoss"] = function(player)
	PumpkinBossFight.Initialize(player)
end

MissionEventHandlers["PumpkinBossDefeated"] = function(player)
	ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "CupcakeLover", "Crowd", nil)
	GeneralRemotes.BlackFade:FireClient(player, 1, 0)
	task.wait(1)
	GeneralRemotes.PlayCutscene:FireClient(player, "CupcakeLoverBossDefeated")
	BadgeHandler.awardBadge(player, 4095855021468711)
end

-- Money Baited
MissionEventHandlers["MoneyBaited"] = function(player)
	local prison = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "MoneyBait", "Prison", nil)
	local prisonSpawnLoc = prison:FindFirstChild("SpawnLoc")

	-- car movement
	local car = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "MoneyBait", "PoliceCar", nil)
	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine)
	local moneyBait = workspace:FindFirstChild("North"):FindFirstChild("BaitMoney"):FindFirstChild("MoneyBait")
	local carDest = moneyBait:FindFirstChild("PoliceDestination")
	local goal = { Position = carDest.WorldPosition }
	moneyBait:Destroy()
	local tween = TweenService:Create(car, tweenInfo, goal)
	tween:Play()
	tween.Completed:Wait()

	-- teleport to cell
	GeneralRemotes.BlackFade:FireClient(player, 1, 0)
	task.wait(1)
	player.Character:PivotTo(prisonSpawnLoc.WorldCFrame)
	GeneralRemotes.BlackFade:FireClient(player, 3, 1)
	GeneralRemotes.EnableControls:FireClient(player)
	PrisonWardenEvent.SetPlayerRef(player)
	PrisonWardenEvent.SetupCellRegion(prison)
	car:Destroy()
	tween = nil
end

MissionEventHandlers["ApplyBlanketToCell"] = function(player)
	if PrisonWardenEvent.IsCellCovered() then
		warn("Already covered cell!")
		return
	end
	if ServerHelperFunctions.IsEquippingToolCalled(player, "Blanket") then
		ServerHelperFunctions.RemoveEquippedTool(player)
		PrisonWardenEvent.SetCellCovered(player, true)
	end
end

MissionEventHandlers["UnscrewToilet"] = function(player)
	PrisonWardenEvent.UnscrewToilet(player)
end
MissionEventHandlers["ApplyPaperClone"] = function(player)
	if
		ServerHelperFunctions.IsEquippingToolCalled(player, "PaperClone")
		and not PrisonWardenEvent.IsPaperCloneActivated()
	then
		PrisonWardenEvent.SetPaperClone(true)
		ServerHelperFunctions.RemoveEquippedTool(player)
	end
end

MissionEventHandlers["InfirmaryRoomEntered"] = function(player)
	PrisonWardenEvent.InfirmaryDoorInit(player)
end

-- Thief
-- when mission unlocks, this should call as well
MissionEventHandlers["StealTV"] = function(player)
	local prompt = CollectionService:GetTagged("TVRoomEnterPrompt")
	if #prompt <= 0 then
		error("TVHouseDoor prompt missing ref!")
	end

	prompt[1].Enabled = true
end

MissionEventHandlers["StealTVMode"] = function(player)
	ServerHelperFunctions.ForceUnEquip(player)
	TVRoomInitialize.Initialize(player)
end
MissionEventHandlers["StealTVModeExit"] = function(player)
	TVRoomInitialize.Exit(player)
end

MissionEventHandlers["StealTVModeFailed"] = function(player)
	TVRoomInitialize.Exit(player)
	ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Thief", "ThiefFailedCharacter", nil)
	player.Character:PivotTo(workspace:FindFirstChild("BlackRoom"):FindFirstChild("SpawnLoc").CFrame)
	workspace:FindFirstChild("TVHome"):Destroy()
	BadgeHandler.awardBadge(player, 970208823763244)
end

MissionEventHandlers["ThiefSuccess"] = function(player)
	ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Thief", "ThiefSuccessShop", nil)
	GeneralRemotes.BlackFade:FireClient(player, 1, 0)
	task.wait(1)
	GeneralRemotes.DisableControls:FireClient(player)
	player.Character:PivotTo(workspace:FindFirstChild("BlackRoom"):FindFirstChild("SpawnLoc").CFrame)
	BadgeHandler.awardBadge(player, 2503897671068625)
	GeneralRemotes.PlayCutscene:FireClient(player, "ThiefSuccess")
end

MissionEventHandlers["FrankensteinFindSpine"] = function(_)
	ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Frankenstein", "SpinePieces", nil)
end
MissionEventHandlers["FrankensteinComplete"] = function(player)
	task.wait(1)
	GeneralRemotes.PlaySound:InvokeClient(player, "Punch")
	GeneralRemotes.BlackFade:FireClient(player, 0, 0)
	BadgeHandler.awardBadge(player, 1297814770331368)
	GeneralRemotes.Rejoin:FireClient(player, 5)
end

MissionEventHandlers["WhodunnitStart"] = function(player)
	WhodunnitMode.Start(player)
end

MissionEventHandlers["PhotoJob"] = function(player)
	ServerHelperFunctions.GiveTool(player, { "Camera", true })
end

return MissionEventHandlers
