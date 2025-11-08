local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local PrisonWardenEvent = require(ServerScriptService.Server.NPCs.PrisonWarden.PrisonWardenEvent)
local TrashPickup = require(ReplicatedStorage.NPCs.TrashPickup.TrashPickup)
local CurrencyHandler = require(script.Parent.CurrencyHandler)
local CashierModule = require(script.Parent.NPCs.Cashier.CashierModule)
local GroceryBagModule = require(script.Parent.NPCs.Cashier.GroceryBagModule)
local PumpkinBossFight = require(script.Parent.NPCs.CupcakeLover.PumpkinBossFight)
local BosnianRoulette = require(script.Parent.NPCs.Glitcher.BosnianRoulette)
local TShirtChecker = require(script.Parent.NPCs.Glitcher.TShirtChecker)
local NPCModule = require(script.Parent.NPCs.NPCModule)
local ProfileDataModule = require(script.Parent.Player.GetPlayerInfo)
local RoomHandler = require(script.Parent.RoomHandler)
local DrivingTest = require(script.Parent.NPCs.DrivingInstructor.DrivingTest)
local RoadEvents = require(script.Parent.RoadEvents.RoadEvents)
local BulletGuesser = require(script.Parent.RoomScripts.Gamba.BulletGuesser)
local SlotMachine = require(script.Parent.RoomScripts.Gamba.SlotMachine)
local WheelSpinner = require(script.Parent.RoomScripts.Gamba.WheelSpinner)
local ServerHelperFunctions = require(script.Parent.ServerHelperFunctions)
local TalkModuleHelpers = require(script.Parent.TalkModuleHelpers)
local Events = ReplicatedStorage.Events
local GeneralRemotes = ReplicatedStorage.Remotes
local ServerStorage = game:GetService("ServerStorage")
local WhodunnitMode = require(ServerScriptService.Server.NPCs.Whodunnit.WhodunnitMode)
local PlayerInitialize = require(ServerScriptService.Server.Player.PlayerInitialize)
local TVRoomInitialize = require(ServerScriptService.Server.Room.TVRoomInitialize)
local TimeOfDay = require(ReplicatedStorage.TimeOfDay.TimeOfDay)
local ServerTools = ServerStorage.Tools

local ServerRemotes = {}

function ServerRemotes.PsychoMantisRemotes()
	GeneralRemotes.GetFriendsList.OnServerInvoke = function(player)
		return ProfileDataModule.RetrieveFriendsList(player)
	end

	GeneralRemotes.GetBasicPlayerData.OnServerInvoke = function(player)
		return ProfileDataModule.PlayerDetails(player)
	end

	GeneralRemotes.GetPlayerBio.OnServerInvoke = function(player)
		local success, response = ProfileDataModule.GetPlayerBio(player)

		return success, response
	end

	GeneralRemotes.GetPlayerFavourites.OnServerInvoke = function(player)
		local success, response = ProfileDataModule.GetPlayerFavouriteGames(player)
		return success, response
	end
	GeneralRemotes.GetCountryData.OnServerInvoke = function(_, countryCode)
		local country = ProfileDataModule.GetCountry(countryCode)
		local fact = ProfileDataModule.GetCountryFact(countryCode)
		return country, fact
	end
end

function ServerRemotes.NPCRemotes()
	ReplicatedStorage.Events.NPC.PauseNPCMovement.OnServerEvent:Connect(function(player, pause, NPCName)
		print(`{NPCName} pathfinding state on server: {pause}`)
		local targetNPC = NPCModule:GetNPC(NPCName)
		if pause then
			targetNPC:SetMode("Interacting")
		else
			targetNPC:SetBackPreviousMode(player)
		end
	end)

	ReplicatedStorage.Remotes.HumanoidMoveTo.OnServerInvoke = function(_, npcModel, targetPosition, yield)
		npcModel.Humanoid:MoveTo(targetPosition)
		if yield then
			npcModel.Humanoid.MoveToFinished:Wait()
		end
		return true
	end

	GeneralRemotes.EnableAllNPCPrompts.OnServerEvent:Connect(function(_, canTalk)
		print(`Set can speak client -> server = {canTalk}`)
		TalkModuleHelpers.SetCanTalk(canTalk)
	end)

	Events.NPC.InitializedNPC.Event:Connect(function(name)
		local npc = NPCModule:GetNPC(name)
		npc:SetMode("Patrol")
		print(`{name} NPC set to Patrol mode!`)
	end)

	local function GetUniqueNextDestination(npc)
		local nextDecidedLocation = nil
		if not npc:GetLastPathArrived() then
			nextDecidedLocation = npc:GetRandomPath()
		else
			repeat
				nextDecidedLocation = npc:GetRandomPath()
			until npc:GetLastPathArrived() ~= nextDecidedLocation.Name
		end

		return nextDecidedLocation
	end

	local YapLines = {
		"Prison has enough budget for metal spoons, huh warden? thank you tax payer money!",
		"Got any paper, Warden? Would like to create some sculptures with paper mache",
		"Got any curtains warden? I would like some privacy man",
		"Warden, please stop the other prisoners from hurling stuff at me, its annoying!",
		"What you looking at you one eyed freak?",
		"You gonna watch me on the toilet? bruh.",
		"Between me and you warden, that new prisoner is a noob!",
	}

	local function SnitchArrivedHandler(npc, arrivedPart)
		local playerCell = npc:GetPathInstanceNamed("PlayerCellArrived")
		local tts: AudioTextToSpeech = arrivedPart:FindFirstChildOfClass("AudioTextToSpeech")

		if tts then
			if PrisonWardenEvent.IsCellCovered() then
				tts.Text = `Warden! That new prisoner has his cell covered! hes doing something fishy!`
			else
				tts.Text = `Warden! I don't like how the new prisoner is looking at me! check him!`
			end
			tts:Play()
			tts.Ended:Wait()
		end

		npc:StartPathing(playerCell)
	end

	Events.NPC.ArrivedDestination.Event:Connect(function(name, arrivedPart)
		local npc = NPCModule:GetNPC(name)
		if not npc then
			warn("NPC doesn't exist in the table")
			return
		end

		if npc:GetMode() == "Patrol" then
			if arrivedPart then
				npc:SetLastPathArrived(arrivedPart.Name)
			end
			local nextLocation = GetUniqueNextDestination(npc)

			if name == "Warden" and not PrisonWardenEvent.HasEscaped() then
				if arrivedPart and arrivedPart.Name == "PlayerCellArrived" then
					npc:SetMode("Interacting")

					if not PrisonWardenEvent.CheckSuspicion() then
						npc:SetMode("Patrol")
					end
				elseif arrivedPart and arrivedPart.Name == "McDonaldsCellArrived" then
					task.spawn(PrisonWardenEvent.SpawnThrowable, "PrisonSpoon")
					task.wait(math.random(5, 7))
					npc:StartPathing(nextLocation)
				elseif arrivedPart and arrivedPart.Name == "Prisoner1CellArrived" then
					task.spawn(PrisonWardenEvent.SpawnThrowable, "Paper")
					task.wait(math.random(5, 7))
					npc:StartPathing(nextLocation)
				elseif arrivedPart and arrivedPart.Name == "SnitchCellArrived" then
					SnitchArrivedHandler(npc, arrivedPart)
				elseif arrivedPart and arrivedPart.Name == "YapCellArrived" then
					local tts = arrivedPart:FindFirstChildOfClass("AudioTextToSpeech")
					if tts then
						tts.Text = YapLines[math.random(1, #YapLines)]
						tts:Play()
						tts.Ended:Wait()
					end
					npc:StartPathing(nextLocation)
				else
					if npc:GetLastPathArrived() ~= "PlayerCellArrived" then
						task.wait(math.random(5, 7))
					end
					npc:StartPathing(nextLocation)
				end
				return
			end

			npc:StartPathing(nextLocation)
			print(`{name} arrived at destination. Go next`)
		end
	end)

	CollectionService:GetInstanceAddedSignal("MoveableNPC"):Connect(function(model)
		NPCModule:InitSingle(model)
		print(`New NPC instance initialized`)
	end)

	CollectionService:GetInstanceRemovedSignal("MoveableNPC"):Connect(function(model)
		local npc = NPCModule:GetNPC(model.Name)
		npc:Erase()
		print("MoveableNPC model removed:", model.Name)
	end)
end

function ServerRemotes.ModelRemotes()
	ReplicatedStorage.Remotes.SpawnServerStorageModel.OnServerInvoke = function(
		_,
		storageFolderName,
		folderName,
		modelName,
		pos
	)
		print(`Client -> Server spawn {modelName}`)
		return ServerHelperFunctions.SpawnModelAtPosition(storageFolderName, folderName, modelName, pos)
	end
end

function ServerRemotes.GlitcherRemotes()
	ReplicatedStorage.Remotes.GlitcherMission.EnteredLegally.OnServerInvoke = function(_)
		return TShirtChecker.HasGlitchedIn()
	end

	GeneralRemotes.GlitcherMission.SubmitBombTimeReduction.OnServerEvent:Connect(function(_, reductionVal)
		BosnianRoulette.ReduceBombTime(reductionVal)
	end)
end

function ServerRemotes.HouseRemotes()
	GeneralRemotes.House.HouseDoorInteracted.OnServerEvent:Connect(function(player, interactType, roomName)
		if interactType == "Enter" then
			RoomHandler.SpawnRoomAndEnter(player, roomName, true)
		else
			if interactType == "Exit" then
				RoomHandler.LeaveRoom(player)
			end
		end
	end)
end

function ServerRemotes.DrivingInstructorRemotes()
	GeneralRemotes.DrivingInstructor.GetDrivingTestResults.OnServerInvoke = function(_)
		return DrivingTest.GetDrivingTestResults()
	end
end

function ServerRemotes.MoneyRemotes()
	GeneralRemotes.GetCurrentMoney.OnServerInvoke = function()
		return CurrencyHandler.GetMoney()
	end

	GeneralRemotes.AddMoney.OnServerEvent:Connect(function(player, val)
		CurrencyHandler.AddMoney(player, val)
	end)

	GeneralRemotes.ReduceMoney.OnServerEvent:Connect(function(player, val)
		CurrencyHandler.ReduceMoney(player, val)
	end)
end

function ServerRemotes.CashierRemotes()
	GeneralRemotes.Cashier.CheckPrice.OnServerInvoke = function(_)
		return CashierModule.CheckPrice()
	end

	GeneralRemotes.Cashier.NextCustomer.OnServerEvent:Connect(function(player, currentTime, failed)
		if not failed then
			CashierModule.NextCustomer(player, currentTime)
		else
			CashierModule.FailedEvent(player)
		end
	end)

	GeneralRemotes.Cashier.GetGroceryItems.OnServerInvoke = function(_)
		return GroceryBagModule.GetCurrentGroceries()
	end
end

function ServerRemotes.GambaRemotes()
	GeneralRemotes.Gamba.InitializeSlotMachines.OnServerEvent:Connect(function()
		local slotMachines = workspace:FindFirstChild("Gamba"):FindFirstChild("SlotMachines"):GetChildren()
		if #slotMachines > 0 then
			for _, model in ipairs(slotMachines) do
				SlotMachine.Init(model)
			end
		end
	end)
	GeneralRemotes.Gamba.RemoveAllSlotMachines.OnServerEvent:Connect(function()
		SlotMachine.RemoveAll()
	end)

	GeneralRemotes.Gamba.IncreaseBet.OnServerEvent:Connect(function(_, modelName)
		SlotMachine.IncreaseBetPrompt(modelName)
	end)

	GeneralRemotes.Gamba.DecreaseBet.OnServerEvent:Connect(function(_, modelName)
		SlotMachine.DecreaseBetPrompt(modelName)
	end)

	GeneralRemotes.Gamba.SpinSlotMachine.OnServerEvent:Connect(function(player, modelName)
		SlotMachine.SpinPrompt(player, modelName)
	end)

	GeneralRemotes.Gamba.StartWheelSpin.OnServerEvent:Connect(function(player)
		WheelSpinner.Start(player)
	end)

	GeneralRemotes.Gamba.BulletGuesser.GetBulletIndex.OnServerInvoke = function(_)
		return BulletGuesser.GetStoredBulletIdx()
	end

	GeneralRemotes.Gamba.BulletGuesser.ResetBulletIndex.OnServerEvent:Connect(function()
		BulletGuesser.ResetBulletIdx()
	end)
end

function ServerRemotes.CupcakeLoverRemotes()
	GeneralRemotes.CupcakeLover.EnemyHit.OnServerEvent:Connect(function(_, type, id)
		PumpkinBossFight.ReduceHP(type, id)
	end)

	GeneralRemotes.CupcakeLover.Finished.OnServerEvent:Connect(function(player, bossDead)
		PumpkinBossFight.Finished(player, bossDead)
	end)
end

function ServerRemotes.JobRemotes()
	-- trash pickup
	GeneralRemotes.PickupTrash.TrashPickedUp.OnServerInvoke = function(_, trashModel)
		return TrashPickup.PickedUp(trashModel)
	end
	GeneralRemotes.PickupTrash.TrashGameFinished.OnServerInvoke = function(player)
		return TrashPickup.ServerFinishedGame(player)
	end

	GeneralRemotes.PickupTrash.TrashData.OnServerInvoke = function(_)
		return TrashPickup.TrashData()
	end
end

function ServerRemotes.RoadEventsRemotes()
	GeneralRemotes.EnableRoadEvents.OnServerEvent:Connect(function(_, enable)
		RoadEvents.EnableRoadEvents(enable)
	end)
end

-- remotes that can be used anywhere, not tied to a specific area
function ServerRemotes.UtilityRemotes()
	GeneralRemotes.RemoveAllToolsOfTag.OnServerEvent:Connect(function(player, tag)
		ServerHelperFunctions.RemoveTools(player, nil, tag)
	end)

	GeneralRemotes.CanTalk.OnServerInvoke = function()
		return TalkModuleHelpers.GetCanTalk()
	end

	GeneralRemotes.DestroyObjectByName.OnServerEvent:Connect(function(_, name)
		ServerHelperFunctions.DestroyObjectByName(name)
	end)

	GeneralRemotes.ConsumeTool.OnServerInvoke = function(player, name, amount)
		return ServerHelperFunctions.ConsumeTool(player, name, amount)
	end

	GeneralRemotes.RemoveEquippedTool.OnServerEvent:Connect(function(player)
		ServerHelperFunctions.RemoveEquippedTool(player)
	end)
end

function ServerRemotes.MoneyBaitRemotes()
	GeneralRemotes.MoneyBait.ShiftToilet.OnServerEvent:Connect(function(_, val)
		local toilet = workspace:FindFirstChild("Prison"):FindFirstChild("EscapeToilet")
		if not toilet then
			error("Missing toilet ref")
		end
		toilet:FindFirstChild("Opened").Value = val
	end)

	GeneralRemotes.MoneyBait.EscapedRoomSet.OnServerEvent:Connect(function(_, val)
		PrisonWardenEvent.SetEscapedRoom(val)
	end)

	GeneralRemotes.MoneyBait.HookRope.OnServerInvoke = function(player, modelName)
		local isEquippingRope = ServerHelperFunctions.IsEquippingToolCalled(player, "Rope")

		if isEquippingRope then
			return PrisonWardenEvent.HookRope(player, modelName)
		else
			warn("Equip the rope first")
			return false
		end
	end

	GeneralRemotes.MoneyBait.ActivateElevator.OnServerEvent:Connect(function(player)
		PrisonWardenEvent.CloseElevatorAndPullRope(player)
	end)

	GeneralRemotes.MoneyBait.PlayerAttachRope.OnServerEvent:Connect(function(player)
		PrisonWardenEvent.PlayerAttachRope(player)
	end)

	GeneralRemotes.MoneyBait.FailedRope.OnServerEvent:Connect(function(player)
		PrisonWardenEvent.CancelRopeTween()
	end)
end

function ServerRemotes.GamepassRemotes()
	local speedCoilId = 1492720359
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, successful)
		if successful and id == speedCoilId then
			ServerHelperFunctions.GiveTool(player, { "SpeedCoil", true })

			if not player.StarterGear:FindFirstChild("SpeedCoil") then
				local speedCoil = ServerTools.SpeedCoil:Clone()
				speedCoil.Parent = player.StarterGear
			end
		end
	end)
end

function ServerRemotes.StreetLightRemotes()
	local streetLights = TimeOfDay.GetStreetLights()
	if #streetLights <= 0 then
		warn("No street lights to modify")
		return
	end
	GeneralRemotes.TimeOfDay.ModifyStreetLights.OnServerEvent:Connect(function(_, on)
		-- don't continue if requested change type is already at that state
		if (on and TimeOfDay.GetLightState()) or (not on and not TimeOfDay.GetLightState()) then
			return
		end

		if not on then
			-- turn off street lights
			if TimeOfDay.GetLightState() then
				TimeOfDay.SetLightState(false)
				for _, light in ipairs(streetLights) do
					light.PointLight.Enabled = false
					light.BrickColor = BrickColor.new("Pearl")
					light.Material = Enum.Material.SmoothPlastic
				end
				print("Street lights off!")
			end
		elseif on then
			if not TimeOfDay.GetLightState() then
				TimeOfDay.SetLightState(true)
				for _, light in ipairs(streetLights) do
					light.PointLight.Enabled = true
					light.BrickColor = BrickColor.new("Pastel blue-green")
					light.Material = Enum.Material.Neon
				end
				print("Street lights ON!")
			end
		end
	end)
end

function ServerRemotes.TVHomeRemotes()
	GeneralRemotes.TVHome.RealTVGrab.OnServerEvent:Connect(function(player)
		TVRoomInitialize.GrabRealTV(player)
	end)

	GeneralRemotes.TVHome.HoldingRealTV.OnServerInvoke = function()
		return TVRoomInitialize.IsHoldingRealTV()
	end
end

function ServerRemotes.FrankensteinRemotes()
	GeneralRemotes.Frankenstein.GiveBodyPartTool.OnServerEvent:Connect(function(player, bodyPartName, tag)
		local body = workspace:FindFirstChild("FrankensteinRoom"):FindFirstChild("FrankensteinBody")
		if not body then
			error("Missing Frankenstein body reference on server")
		end
		local bodyPart = body:FindFirstChild(bodyPartName)
		if not bodyPart then
			error("Missing body part on Frankenstein body")
		end
		bodyPart:FindFirstChildOfClass("ProximityPrompt"):Destroy()
		local function BodyPartToTool()
			local tool = Instance.new("Tool")
			tool.CanBeDropped = false
			tool.Name = bodyPartName
			tool.Parent = player.Backpack

			local clonedPart = bodyPart:Clone()
			clonedPart.Name = "Handle"
			clonedPart.Anchored = false
			clonedPart.Massless = true
			CollectionService:AddTag(tool, tag)
			clonedPart.Parent = tool
			bodyPart:Destroy()
		end

		BodyPartToTool()
	end)

	GeneralRemotes.Frankenstein.FrankensteinHomeSpawn.OnServerEvent:Connect(function(player)
		local home = workspace:WaitForChild("Home")
		local frankensteinRoom =
			ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Frankenstein", "FrankensteinAtHome", nil)
		local frankensteinNPC =
			ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Frankenstein", "FrankensteinHome", nil)

		frankensteinRoom.Parent = home
		frankensteinNPC.Parent = home
	end)

	GeneralRemotes.Frankenstein.SquatterCheckAndSpawn.OnServerInvoke = function(player)
		local home = workspace:WaitForChild("Home")
		return PlayerInitialize.SquatterActivate(player, home)
	end
end

function ServerRemotes.WhodunnitRemotes(player)
	local humanoid = player.Character.Humanoid
	local seatConn = nil
	-- seat handler
	seatConn = humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
		local seat = humanoid.SeatPart
		if CollectionService:HasTag(seat, "WhodunnitSeat") and not WhodunnitMode.SleepAreaUnlocked() then
			GeneralRemotes.DisableControls:FireClient(player)
			WhodunnitMode.AssemblyHall()
		elseif CollectionService:HasTag(seat, "WhodunnitBed") then
			seatConn:Disconnect()
			GeneralRemotes.DisableControls:FireClient(player)
			WhodunnitMode.Sleeping()
		end
	end)

	-- wall touched handlers
	local descendantConn = nil
	local debounce = false
	local touchConn = nil

	local function PlayerHitWall(descendant, customFunc)
		touchConn = descendant.Touched:Connect(function(hit)
			if debounce then
				return
			end
			if not Players:GetPlayerFromCharacter(hit:FindFirstAncestorOfClass("Model")) then
				return
			end
			debounce = true

			customFunc()

			task.delay(1, function()
				debounce = false
			end)
		end)
	end

	descendantConn = workspace.DescendantAdded:Connect(function(descendant)
		if CollectionService:HasTag(descendant, "SleepRoomBlockage") then
			PlayerHitWall(descendant, function()
				if WhodunnitMode.SleepAreaUnlocked() then
					descendant:Destroy()
					WhodunnitMode.SleepArea()
				end
			end)
		elseif CollectionService:HasTag(descendant, "ArrivedAtMurder") then
			PlayerHitWall(descendant, function()
				descendant:Destroy()
				if WhodunnitMode.HasAccessory() then
					WhodunnitMode.ArrivedAtMurderEvidence()
				else
					WhodunnitMode.ArrivedAtMurderNoEvidence()
				end
			end)
		elseif CollectionService:HasTag(descendant, "PoolTouched") then
			print("POOOL")
			PlayerHitWall(descendant, function()
				print("Touch event connected")
				if WhodunnitMode.PoolUnlocked() then
					descendant:Destroy()
					WhodunnitMode.PoolAreaEvent()
				end
			end)
		end
	end)

	GeneralRemotes.Whodunnit.KillVictim.OnServerEvent:Connect(function(_, modelName)
		WhodunnitMode.KillVictim(modelName)
	end)
end

function ServerRemotes.Initialize(player)
	ServerRemotes.PsychoMantisRemotes()
	ServerRemotes.NPCRemotes()
	ServerRemotes.ModelRemotes()
	ServerRemotes.GlitcherRemotes()
	ServerRemotes.HouseRemotes()
	ServerRemotes.DrivingInstructorRemotes()
	ServerRemotes.MoneyRemotes()
	ServerRemotes.CashierRemotes()
	ServerRemotes.GambaRemotes()
	ServerRemotes.CupcakeLoverRemotes()
	ServerRemotes.JobRemotes()
	ServerRemotes.RoadEventsRemotes()
	ServerRemotes.UtilityRemotes()
	ServerRemotes.MoneyBaitRemotes()
	ServerRemotes.GamepassRemotes()
	ServerRemotes.StreetLightRemotes()
	ServerRemotes.TVHomeRemotes()
	ServerRemotes.FrankensteinRemotes()
	ServerRemotes.WhodunnitRemotes(player)
end

return ServerRemotes
