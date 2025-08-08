local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local GroupService = game:GetService("GroupService")
local GetPlayerInfo = {}

local function iterPageItems(pages)
	return coroutine.wrap(function()
		local pagenum = 1

		while true do
			for _, item in ipairs(pages:GetCurrentPage()) do
				coroutine.yield(item, pagenum)
			end
			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
			pagenum = pagenum + 1
		end
	end)
end

function GetPlayerInfo.RetrieveFriendsList(player)
	local PlayersFriends = {}
	local friendPages = Players:GetFriendsAsync(player.UserId)
	for item, _pageNo in iterPageItems(friendPages) do
		table.insert(PlayersFriends, item)
		print(item.Username)
	end
	-- Id, Username, DisplayName
	return PlayersFriends
end

function GetPlayerInfo.PlayerDetails(player)
	local _, code = pcall(LocalizationService.GetCountryRegionForPlayerAsync, LocalizationService, player)

	local hasPremium = player.MembershipType == Enum.MembershipType.Premium
	local groups = GroupService:GetGroupsAsync(player.UserId)

	return {
		Name = player.Name,
		DisplayName = player.DisplayName,
		HasPremium = hasPremium,
		Age = player.AccountAge,
		Country = code,
		-- Id, EmblemUrl, EmblemId, Rank, Role, IsPrimary
		Groups = groups,
	}
end

return GetPlayerInfo
