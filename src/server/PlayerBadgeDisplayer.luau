local CollectionService = game:GetService("CollectionService")
local BadgeHandler = require(script.Parent.BadgeHandler)
local PlayerBadgeDisplayer = {}
local ObtainedBadgesList = {}
local Badges = {
	550797482323175,
	4119036600108215,
	2723844059823653,
	3791811322299538,
	1658087564169818,
	126301904067129,
	1768903662252309,
	2250718080144467,
	1517353246082078,
	2121837446715483,
	2760480705679050,
	3494073379327445,
	352477117785792,
	2453227885155938,
	2207943165943416,
}

function PlayerBadgeDisplayer.GetObtainedBadges(player)
	for _, id in ipairs(Badges) do
		if BadgeHandler.HasBadge(player, id) then
			local badgeInfo = BadgeHandler.GetBadgeInfo(id)
			if badgeInfo then
				table.insert(ObtainedBadgesList, badgeInfo)
			end
		end
	end
end

function PlayerBadgeDisplayer.SetObtainedBadgesToAchievements()
	local decals = CollectionService:GetTagged("AchievementImage")

	if #decals == 0 then
		return
	end

	for idx, decal in ipairs(decals) do
		local badgeInfo = ObtainedBadgesList[idx]
		if badgeInfo and badgeInfo.IconImageId then
			decal.Texture = `rbxassetid://{badgeInfo.IconImageId}`
			print("SET")
		else
			break
		end
	end
end

return PlayerBadgeDisplayer
