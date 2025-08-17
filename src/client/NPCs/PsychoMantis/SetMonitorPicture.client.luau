local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Fetch the thumbnail, retry until it's ready
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

-- Apply to tagged decal
local laptopDecal = CollectionService:GetTagged("PsychoMantisLaptopDecal")
if #laptopDecal > 0 then
	laptopDecal[1].Texture = content
end
