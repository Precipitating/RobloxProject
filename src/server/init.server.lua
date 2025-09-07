local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local HelperFunctions = require(script.HelperFunctions)
local CashierModule = require(script.NPCs.Cashier.CashierModule)
local GroceryBagModule = require(script.NPCs.Cashier.GroceryBagModule)
local BosnianRoulette = require(script.NPCs.Glitcher.BosnianRoulette)
local TShirtChecker = require(script.NPCs.Glitcher.TShirtChecker)
local NPCModule = require(script.NPCs.NPCModule)
local ProfileDataModule = require(script.Player.GetPlayerInfo)
local PlayerInitialize = require(script.Player.PlayerInitialize)
local RoomHandler = require(script.RoomHandler)
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
		targetNPC:SetMode("Interacting", player)
	else
		targetNPC:SetBackPreviousMode(player)
	end
end)

ReplicatedStorage.Remotes.HumanoidMoveTo.OnServerEvent:Connect(function(_, targetHumanoid, targetPosition)
	targetHumanoid:MoveTo(targetPosition)
end)

-- MODEL
ReplicatedStorage.Remotes.SpawnServerStorageModel.OnServerEvent:Connect(
	function(_, storageFolderName, folderName, modelName, pos)
		print(`Client -> Server spawn {modelName}`)
		HelperFunctions.SpawnModelAtPosition(storageFolderName, folderName, modelName, pos)
	end
)

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

GeneralRemotes.GlitcherMission.SubmitBombTimeReduction.OnServerEvent:Connect(function(player, reductionVal)
	BosnianRoulette.ReduceBombTime(reductionVal)
end)

-- CASHIER
GeneralRemotes.Cashier.CheckPrice.OnServerInvoke = function(_)
	return CashierModule.CheckPrice()
end

GeneralRemotes.Cashier.NextCustomer.OnServerEvent:Connect(function(player, currentTime, failed)
	print("DEBUG:", currentTime, failed, typeof(failed))
	if not failed then
		CashierModule.NextCustomer(player, currentTime)
	else
		CashierModule.FailedEvent(player)
	end
end)

GeneralRemotes.RemoveAllToolsOfTag.OnServerEvent:Connect(function(player, tag)
	HelperFunctions.RemoveTools(player, nil, tag)
end)

GeneralRemotes.Cashier.GetGroceryItems.OnServerInvoke = function(_)
	return GroceryBagModule.GetCurrentGroceries()
end

-- set player's achievements

-- spawn player in their room when spawned
Players.PlayerAdded:Connect(function(player)
	local deathConn = nil
	PlayerInitialize.SetupAchievements(player)

	-- Function to spawn and teleport character
	local function spawnAndTeleport()
		player:LoadCharacter() -- spawn character
		local character = player.Character or player.CharacterAdded:Wait()
		local spawnPos = PlayerInitialize.SpawnHome()
		PlayerInitialize.TeleportHome(character, spawnPos)

		if not deathConn then
			local humanoid = character:WaitForChild("Humanoid")
			deathConn = humanoid.Died:Connect(function()
				task.wait(3)
				spawnAndTeleport() -- spawns again
			end)
		end
	end

	-- First spawn
	spawnAndTeleport()

	-- Handle respawns after death
	player.CharacterAdded:Connect(function(character)
		local spawnPos = PlayerInitialize.SpawnHome()
		PlayerInitialize.TeleportHome(character, spawnPos)
	end)
end)
