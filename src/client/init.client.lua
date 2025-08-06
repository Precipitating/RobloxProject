local DebuggerManager = game:GetService("DebuggerManager")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local generalRemotes = ReplicatedStorage.Shared.Remotes
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")
local movementHandler = require(script:WaitForChild("MovementHandler"))
local soundModule = require(script:WaitForChild("SoundModule"))
local UIHelperFunctions = require(script:WaitForChild("UIHelperFunctions"))
-- disable respawn button
local coreCall
do
	local MAX_RETRIES = 8

	local StarterGui = game:GetService("StarterGui")
	local RunService = game:GetService("RunService")

	function coreCall(method, ...)
		local result = {}
		for retries = 1, MAX_RETRIES do
			result = { pcall(StarterGui[method], StarterGui, ...) }
			if result[1] then
				break
			end
			RunService.Stepped:Wait()
		end
		return unpack(result)
	end
end
coreCall("SetCore", "ResetButtonCallback", false)

-- handle general remotes
generalRemotes.DisableControls.OnClientEvent:Connect(function(caller)
	print(`Client received disable controls from server: {caller}`)
	movementHandler.DisableControls(caller)
end)

generalRemotes.EnableControls.OnClientEvent:Connect(function(caller)
	print(`Client received enable controls from server: {caller}`)
	movementHandler.EnableControls(caller)
end)

generalRemotes.PlayAnimation.OnClientEvent:Connect(function(animId)
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. animId
	local animTrack = animator:LoadAnimation(anim)
	animTrack:Play()
	print("Animation playing...")
end)

generalRemotes.ChangeFOV.OnClientEvent:Connect(function(val)
	local cam = workspace.CurrentCamera
	cam.FieldOfView = val
end)

generalRemotes.Trip.OnClientEvent:Connect(function()
	print("Tripped!")
	local rootPart = character.PrimaryPart
	humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
	rootPart.AssemblyLinearVelocity += rootPart.CFrame.LookVector * 50 + Vector3.new(0, 25, 0)
end)

generalRemotes.Blur.OnClientEvent:Connect(function(time, blurTarget)
	UIHelperFunctions.AdjustBlur(time, blurTarget)
end)

generalRemotes.ChangeClothes.OnClientEvent:Connect(function(shirt, pants)
	local hasTShirt = character:FindFirstChild("Shirt Graphic")

	if hasTShirt then
		hasTShirt:Remove()
	end

	if shirt then
		local hasShirt = character:FindFirstChildOfClass("Shirt")
		if hasShirt then
			hasShirt.ShirtTemplate = shirt
		end
		local hasPants = character:FindFirstChildOfClass("Pants")
		if hasPants then
			hasPants.PantsTemplate = pants
		end
	end
end)

-- set player's collision group
for _, descendant in pairs(character:GetDescendants()) do
	if descendant:IsA("BasePart") then
		descendant.CollisionGroup = "Player"
	end
end

-- play main theme
soundModule.PlayTheme("Main")
