local ServerStorage = game:GetService("ServerStorage")
local Accessories = ServerStorage.NPCs.Accessories
local Hats = Accessories.Hats
local Shirts = Accessories.Shirts
local Pants = Accessories.Pants
local Hair = Accessories.Hair
local Faces = Accessories.Faces

local NPCOutfit = {}

function NPCOutfit.ApplyRandomOutfit(npcRef)
	print("ATTEMPT OUTFIT CHANGE")
	local head = npcRef:FindFirstChild("Head")

	-- Hat
	local hat = Hats:FindFirstChild(tostring(math.random(1, 5)))
	if hat then
		hat:Clone().Parent = npcRef
	end
	-- Shirt
	local shirt = Shirts:FindFirstChild(tostring(math.random(1, 5)))
	if shirt then
		shirt:Clone().Parent = npcRef
	end

	-- Pants
	local pants = Pants:FindFirstChild(tostring(math.random(1, 5)))
	if pants then
		pants:Clone().Parent = npcRef
	end

	-- Hair
	local hair = Hair:FindFirstChild(tostring(math.random(1, 5)))
	if hair then
		hair:Clone().Parent = npcRef
	end

	-- Face
	if head then
		local face = Faces:FindFirstChild(tostring(math.random(1, 5)))
		if face then
			face:Clone().Parent = head
		end
	end

	print("Random outfit applied to NPC")
end

function NPCOutfit.RemoveOutfit(npcRef)
	-- remove hats & shirt/pants
	for _, child in ipairs(npcRef:GetChildren()) do
		if child:IsA("Accessory") then
			child:Destroy()
		end

		if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
			child:Destroy()
		end
	end

	-- remove face

	local head = npcRef:FindFirstChild("Head")
	if head then
		local face = head:FindFirstChildOfClass("Decal")
		if face then
			face:Destroy()
		end
	end
end

return NPCOutfit
