local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local TrashPickup = require(ReplicatedStorage.NPCs.TrashPickup.TrashPickup)
local CurrencyHandler = require(script.CurrencyHandler)
local CashierModule = require(script.NPCs.Cashier.CashierModule)
local GroceryBagModule = require(script.NPCs.Cashier.GroceryBagModule)
local PumpkinBossFight = require(script.NPCs.CupcakeLover.PumpkinBossFight)
local BosnianRoulette = require(script.NPCs.Glitcher.BosnianRoulette)
local TShirtChecker = require(script.NPCs.Glitcher.TShirtChecker)
local NPCModule = require(script.NPCs.NPCModule)
local ProfileDataModule = require(script.Player.GetPlayerInfo)
local PlayerInitialize = require(script.Player.PlayerInitialize)
local RoomHandler = require(script.RoomHandler)
local DrivingTest = require(script.NPCs.DrivingInstructor.DrivingTest)
local RoadEvents = require(script.RoadEvents.RoadEvents)
local BulletGuesser = require(script.RoomScripts.Gamba.BulletGuesser)
local SlotMachine = require(script.RoomScripts.Gamba.SlotMachine)
local WheelSpinner = require(script.RoomScripts.Gamba.WheelSpinner)
local ServerHelperFunctions = require(script.ServerHelperFunctions)
local TalkModuleHelpers = require(script.TalkModuleHelpers)
local GeneralRemotes = ReplicatedStorage.Remotes

-- PSYCHOMANTIS
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

-- NPC
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

-- MODEL
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

-- GLITCHER
ReplicatedStorage.Remotes.GlitcherMission.EnteredLegally.OnServerInvoke = function(_)
	return TShirtChecker.HasGlitchedIn()
end

GeneralRemotes.House.HouseDoorInteracted.OnServerEvent:Connect(function(player, interactType, roomName)
	if interactType == "Enter" then
		RoomHandler.SpawnRoomAndEnter(player, roomName, true)
	else
		if interactType == "Exit" then
			RoomHandler.LeaveRoom(player)
		end
	end
end)

GeneralRemotes.GlitcherMission.SubmitBombTimeReduction.OnServerEvent:Connect(function(_, reductionVal)
	BosnianRoulette.ReduceBombTime(reductionVal)
end)

-- CASHIER
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

GeneralRemotes.RemoveAllToolsOfTag.OnServerEvent:Connect(function(player, tag)
	ServerHelperFunctions.RemoveTools(player, nil, tag)
end)

GeneralRemotes.Cashier.GetGroceryItems.OnServerInvoke = function(_)
	return GroceryBagModule.GetCurrentGroceries()
end

GeneralRemotes.DrivingInstructor.GetDrivingTestResults.OnServerInvoke = function(_)
	return DrivingTest.GetDrivingTestResults()
end

-- money
GeneralRemotes.GetCurrentMoney.OnServerInvoke = function()
	return CurrencyHandler.GetMoney()
end

GeneralRemotes.AddMoney.OnServerEvent:Connect(function(player, val)
	CurrencyHandler.AddMoney(player, val)
end)

GeneralRemotes.ReduceMoney.OnServerEvent:Connect(function(player, val)
	CurrencyHandler.ReduceMoney(player, val)
end)

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

GeneralRemotes.EnableAllNPCPrompts.OnServerEvent:Connect(function(_, canTalk)
	print(`Set can speak client -> server = {canTalk}`)
	TalkModuleHelpers.SetCanTalk(canTalk)
end)
GeneralRemotes.CanTalk.OnServerInvoke = function()
	return TalkModuleHelpers.GetCanTalk()
end

-- gamba
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

GeneralRemotes.EnableRoadEvents.OnServerEvent:Connect(function(_, enable)
	RoadEvents.EnableRoadEvents(enable)
end)

GeneralRemotes.CupcakeLover.EnemyHit.OnServerEvent:Connect(function(_, type, id)
	PumpkinBossFight.ReduceHP(type, id)
end)

-- set player's achievements
-- spawn player in their room when spawned
Players.PlayerAdded:Connect(function(player)
	PlayerInitialize.SetupAchievements(player)
	local safePosition = nil

	local function setupCharacter(character)
		local spawnPos = PlayerInitialize.SpawnHome()
		PlayerInitialize.TeleportHome(character, spawnPos)
		local humanoid = character:WaitForChild("Humanoid")
		local hrp = character:WaitForChild("HumanoidRootPart")
		PlayerInitialize.SetCollisionGroup(character)
		PlayerInitialize.GiveSpeedCoil(player)

		local function isOnGround()
			local root = character:FindFirstChild("HumanoidRootPart")
			if not root then
				return false
			end

			local rayOrigin = root.Position
			local rayDirection = Vector3.new(0, -3, 0)

			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = { character }
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude

			return workspace:Raycast(rayOrigin, rayDirection, raycastParams)
		end

		-- update safe position periodically
		task.spawn(function()
			while character.Parent do
				task.wait(2)
				local groundPos = isOnGround()
				if groundPos then
					safePosition = groundPos.Position
				end
			end
		end)

		-- teleport if fallen below -450 Y
		task.spawn(function()
			while character.Parent do
				task.wait(0.1)
				if hrp.Position.Y <= -400 and safePosition then
					character:MoveTo(safePosition)
				end
			end
		end)

		-- disconnect heartbeat when character dies
		humanoid.Died:Connect(function()
			task.wait(3)
			player:LoadCharacter()
		end)
	end

	-- First spawn
	player.CharacterAdded:Connect(setupCharacter)
	player:LoadCharacter()
end)

-- run the loop in its own thread so it doesn’t block anything else
task.spawn(RoadEvents.SpawnLoop)
