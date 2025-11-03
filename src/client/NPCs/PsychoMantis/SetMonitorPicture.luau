local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local SetMonitorPicture = {}

function SetMonitorPicture.Set(singleDecal)
	-- fetch the thumbnail, retry until it's ready
	local userId = Player.UserId
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size420x420

	local content, isReady
	repeat
		content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
		if not isReady then
			task.wait(0.1)
		end
	until isReady

	-- apply to tagged decal
	if not singleDecal then
		local laptopDecal = CollectionService:GetTagged("PsychoMantisLaptopDecal")
		if #laptopDecal > 0 then
			for _, decal in ipairs(laptopDecal) do
				decal.Texture = content
			end
		end
	else
		singleDecal.Texture = content
	end
end

return SetMonitorPicture
