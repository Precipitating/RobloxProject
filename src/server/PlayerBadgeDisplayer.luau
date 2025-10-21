local ServerStorage = game:GetService("ServerStorage")
local BadgeHandler = require(script.Parent.BadgeHandler)
local ServerHelperFunctions = require(script.Parent.ServerHelperFunctions)
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
	2493042217612033,
	1698025412209346,
	2719901366655803,
	4449692306836938,
	636617031698169,
	4095855021468711,
	1699948559468830,
	157269881825360,
	3628178665725253,
}
local positions = ServerHelperFunctions.GetTaggedOfDirectory(ServerStorage, "AchievementPos")

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
	if #positions <= 0 then
		error("Missing position part for achievement displaying")
		return
	end

	if #positions < #ObtainedBadgesList then
		warn("Not enough achievement positions to spawn all achievements!")
		return
	end

	-- for each badge the player owns, spawn a display case and set its badge info
	for idx, info in ipairs(ObtainedBadgesList) do
		--print(positions[idx].Name)
		local display = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Home", "Display", nil)

		local decal = display.Frame.LargePictureFrame.Picture.Decal
		local textInfo = display.Info.SurfaceGui.TextLabel

		if not display or not decal or not textInfo then
			error(`Missing badge display references: display = {display}, decal = {decal}, info = {textInfo}`)
		end
		display:PivotTo(positions[idx].CFrame)
		display.Parent = workspace:FindFirstChild("Home"):FindFirstChild("AchievementsRoom")

		if info.IconImageId then
			decal.Texture = `rbxassetid://{info.IconImageId}`

			if info.Name and info.Description then
				textInfo.Text = `<sc><font color="#FF0000">{info.Name}</font></sc><br/>{info.Description}`
				--print(`{textInfo.Name} set successfully to display room! {idx}`)
			end
		end
	end
end

return PlayerBadgeDisplayer
