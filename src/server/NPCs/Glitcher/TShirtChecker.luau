local MarketplaceService = game:GetService("MarketplaceService")
local EnteredViaTShirt = false
local TShirtChecker = {}

function TShirtChecker.SetTShirtMethodActivated(val)
	if EnteredViaTShirt == val then
		return
	end
	EnteredViaTShirt = val

	print(`Entered via T-Shirt method {EnteredViaTShirt}`)
end

function TShirtChecker.GetPlayersTShirtName(character)
	local tShirt = character:FindFirstChild("Shirt Graphic")
	if not tShirt then
		warn("No T-Shirt found.")
		return nil
	end
	local success, info = pcall(function()
		local id = tonumber(tShirt.Graphic:match("%d+"))
		return MarketplaceService:GetProductInfo(id)
	end)

	if success then
		print(info.Name)
		return info.Name
	end
	warn("Getting T-Shirt info failed")
	return nil
end

return TShirtChecker
