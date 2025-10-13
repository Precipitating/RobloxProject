local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
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

	Events.NPC.ArrivedDestination.Event:Connect(function(name)
		local npc = NPCModule:GetNPC(name)

		if npc:GetMode() == "Patrol" then
			local function PatrolMode()
				local pathData = npc:GetPathStorage():GetChildren()
				local nextLocation = pathData[math.random(1, #pathData)]
				npc:StartPathing(nextLocation)
			end

			PatrolMode()
			print(`{name} arrived at destination. Go next`)
		end
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
end

return ServerRemotes
