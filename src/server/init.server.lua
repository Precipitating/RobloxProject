local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileDataModule = require(script.PlayerProfileData.GetPlayerInfo)
local RoomHandler = require(script.RoomHandler)
local GeneralRemotes = ReplicatedStorage.Shared.Remotes

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

GeneralRemotes.House.HouseDoorInteracted.OnServerEvent:Connect(function(player, interactType, roomName)
	if interactType == "Enter" then
		RoomHandler.SpawnRoomAndEnter(player, roomName)
	else
		if interactType == "Exit" then
			RoomHandler.LeaveRoom(player)
		end
	end
end)
