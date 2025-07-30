local BadgeHandler = {}

local BadgeService = game:GetService("BadgeService")

function BadgeHandler.awardBadge(player, badgeId)
	-- Fetch badge information
	local success, badgeInfo = pcall(function()
		return BadgeService:GetBadgeInfoAsync(badgeId)
	end)

	if success then
		-- Confirm that badge can be awarded
		if badgeInfo.IsEnabled then
			-- Award badge
			local awardSuccess, result = pcall(function()
				return BadgeService:AwardBadge(player.UserId, badgeId)
			end)

			if not awardSuccess then
				-- the AwardBadge function threw an error
				warn("Error while awarding badge:", result)
			elseif not result then
				-- the AwardBadge function did not award a badge
				warn("Failed to award badge.")
			end
		end
	else
		warn("Error while fetching badge info: " .. badgeInfo)
	end
end

return BadgeHandler
