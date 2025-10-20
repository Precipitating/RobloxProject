local CollectionService = game:GetService("CollectionService")
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

	Events.NPC.ArrivedDestination.Event:Connect(function(name, pathName)
		local npc = NPCModule:GetNPC(name)

		if not npc then
			warn("NPC doesn't exist in the table")
			return
		end

		if npc:GetMode() == "Patrol" then
			if pathName then
				npc:SetLastPathArrived(pathName)
			end
			local pathData = npc:GetPathStorage():GetChildren()
			local nextLocation = nil
			repeat
				nextLocation = pathData[math.random(1, #pathData)]
			until npc:GetLastPathArrived() ~= nextLocation.Name

			if name == "Warden" and not PrisonWardenEvent.HasEscaped() then
				if pathName and pathName == "PlayerCellArrived" then
					npc:SetMode("Interacting")

					if not PrisonWardenEvent.CheckSuspicion() then
						npc:SetMode("Patrol")
					end
				elseif pathName and pathName == "McDonaldsCellArrived" then
					task.spawn(PrisonWardenEvent.SpawnThrowable, "PrisonSpoon")
					task.wait(math.random(5, 7))
					npc:StartPathing(nextLocation)
				elseif pathName and pathName == "Prisoner1CellArrived" then
					task.spawn(PrisonWardenEvent.SpawnThrowable, "Paper")
					task.wait(math.random(5, 7))
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

function ServerRemotes.Initialize()
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
end

return ServerRemotes
