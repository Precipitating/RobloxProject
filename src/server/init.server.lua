local ReplicatedStorage = game:GetService("ReplicatedStorage")
local profileDataModule = require(script.PlayerProfileData.GetPlayerInfo)
local generalRemotes = ReplicatedStorage.Shared.Remotes

generalRemotes.GetFriendsList.OnServerInvoke = function(player)
	return profileDataModule.RetrieveFriendsList(player)
end

generalRemotes.GetBasicPlayerData.OnServerInvoke = function(player)
	return profileDataModule.PlayerDetails(player)
end

generalRemotes.GetPlayerBio.OnServerInvoke = function(player)
	local success, response = profileDataModule.GetPlayerBio(player)

	return success, response
end

generalRemotes.GetPlayerFavourites.OnServerInvoke = function(player)
	local success, response = profileDataModule.GetPlayerFavouriteGames(player)
	return success, response
end
generalRemotes.GetCountryData.OnServerInvoke = function(_, countryCode)
	local country = profileDataModule.GetCountry(countryCode)
	local fact = profileDataModule.GetCountryFact(countryCode)
	return country, fact
end
