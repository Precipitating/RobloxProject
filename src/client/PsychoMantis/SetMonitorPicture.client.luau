local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Fetch the thumbnail
local userId = Player.UserId
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

local laptopDecal = CollectionService:GetTagged("PsychoMantisLaptopDecal")
if laptopDecal and isReady then
	laptopDecal[1].Texture = content
end
