local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local originalCircle = ReplicatedStorage.Shared.Models.GreenCircle

local clonedCircle = nil
local canMove = false
local maxDistance = 55
local enabled = false
local clicktowalkcircle
local enabledRemote = ReplicatedStorage.Shared.Remotes.EnableClickToMove
local loop
local clickConn
local charConn

-- cleanup function
local function removeClonedCircle()
	if clonedCircle then
		clonedCircle:Destroy()
		clonedCircle = nil
	end
end

local function disconnectAll()
	if loop then
		loop:Disconnect()
		loop = nil
	end
	if clickConn then
		clickConn:Disconnect()
		clickConn = nil
	end
	if charConn then
		charConn:Disconnect()
		charConn = nil
	end
	removeClonedCircle()
	if clicktowalkcircle then
		clicktowalkcircle:Destroy()
		clicktowalkcircle = nil
	end
end
-- movement logic
local function startClickToMove()
	clicktowalkcircle = originalCircle:Clone()
	clicktowalkcircle.Parent = workspace
	loop = RunService.RenderStepped:Connect(function()
		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
			return
		end

		local distance = (player.Character.HumanoidRootPart.Position - mouse.Hit.p).Magnitude

		canMove = distance <= maxDistance
		clicktowalkcircle.Transparency = canMove and 0 or 1
		clicktowalkcircle.Position = mouse.Hit.p
	end)

	clickConn = mouse.Button1Down:Connect(function()
		if canMove and player.Character and player.Character:FindFirstChild("Humanoid") then
			removeClonedCircle()

			clonedCircle = clicktowalkcircle:Clone()
			clonedCircle.Parent = workspace
			clonedCircle.Name = "poscircle"

			local humanoid = player.Character.Humanoid
			humanoid:MoveTo(mouse.Hit.p)

			humanoid.MoveToFinished:Connect(function()
				removeClonedCircle()
			end)
		end
	end)

	charConn = player.CharacterAdded:Connect(removeClonedCircle)
end

-- listen for toggle from server
enabledRemote.OnClientEvent:Connect(function(val)
	enabled = val
	if enabled then
		startClickToMove()
	else
		disconnectAll()
	end
end)
