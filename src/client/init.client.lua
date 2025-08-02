local ReplicatedStorage = game:GetService("ReplicatedStorage")
local generalRemotes = ReplicatedStorage.Shared.Remotes
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")
local movementHandler = require(script:WaitForChild("MovementHandler"))
local soundModule = require(script:WaitForChild("SoundModule"))
-- disable reset button
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

-- set player's collision group
for _, descendant in pairs(character:GetDescendants()) do
	if descendant:IsA("BasePart") then
		descendant.CollisionGroup = "Player"
	end
end

-- play main
soundModule.PlayTheme("Main")
