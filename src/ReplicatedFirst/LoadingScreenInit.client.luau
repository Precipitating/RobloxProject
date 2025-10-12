local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
ReplicatedFirst:RemoveDefaultLoadingScreen()

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local LoadingScreen = ReplicatedFirst:WaitForChild("LoadingScreen"):Clone()
LoadingScreen.Parent = PlayerGui

local BG = LoadingScreen:WaitForChild("BG")
local ViewportFrame = BG:WaitForChild("ViewportFrame")
local PlayerModel = ViewportFrame:WaitForChild("WorldModel"):WaitForChild("LoadingScreenDancer")
local Description = Players:GetHumanoidDescriptionFromUserId(Player.UserId)
PlayerModel:WaitForChild("Humanoid"):ApplyDescription(Description)

local function CleanCharacter()
	-- remove face decal from the Head
	local head = PlayerModel:FindFirstChild("Head")
	if head then
		for _, obj in ipairs(head:GetChildren()) do
			if obj:IsA("Decal") or obj:IsA("Texture") then
				obj:Destroy()
			end
		end
	end

	-- keep accessories, remove textures/decals from their Handles
	for _, accessory in ipairs(PlayerModel:GetChildren()) do
		if accessory:IsA("Accessory") then
			local handle = accessory:FindFirstChild("Handle")
			if handle then
				for _, obj in ipairs(handle:GetDescendants()) do
					if obj:IsA("Decal") or obj:IsA("Texture") then
						obj:Destroy()
					end
				end
				handle.Color = Color3.new(1, 1, 1)
			end
		end
	end

	for _, mesh in ipairs(PlayerModel:GetDescendants()) do
		if mesh:IsA("CharacterMesh") then
			mesh.OverlayTextureId = ""
		end
	end

	-- remove clothes
	for _, item in ipairs(PlayerModel:GetChildren()) do
		if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
			item:Destroy()
		elseif item:IsA("BodyColors") then
			-- white body parts
			local white = Color3.new(1, 1, 1)
			item.HeadColor3 = white
			item.LeftArmColor3 = white
			item.RightArmColor3 = white
			item.LeftLegColor3 = white
			item.RightLegColor3 = white
			item.TorsoColor3 = white
		end
	end

	-- remove layered clothing textures/surface appearances
	for _, descendant in ipairs(PlayerModel:GetDescendants()) do
		if descendant:IsA("SurfaceAppearance") or descendant:IsA("Texture") then
			descendant:Destroy()
		end
	end
end
CleanCharacter()
local assets = game:GetChildren()

for idx, asset in ipairs(assets) do
	ContentProvider:PreloadAsync({ asset })
	local progress = idx / #assets
	local goalTransparency = 1 - progress

	TweenService:Create(
		ViewportFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ ImageTransparency = goalTransparency }
	):Play()
end
Player.CharacterAdded:Wait()

LoadingScreen:Destroy()
