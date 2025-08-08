local HttpService = game:GetService("HttpService")
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
	local url = "https://users.roproxy.com/v1/users/" .. player.UserId
	local success, response = pcall(function()
		return HttpService:GetAsync(url)
	end)

	return success, response
end
