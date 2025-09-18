local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local mouse = Player:GetMouse()

local originalCircle = ReplicatedStorage.Models.GreenCircle

local clonedCircle = nil
local canMove = false
local maxDistance = 55
local enabled = false
local clicktowalkcircle
local enabledRemote = ReplicatedStorage.Remotes.EnableClickToMove
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
		if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
			return
		end

		local distance = (Player.Character.HumanoidRootPart.Position - mouse.Hit.p).Magnitude

		canMove = distance <= maxDistance
		clicktowalkcircle.Transparency = canMove and 0 or 1
		clicktowalkcircle.Position = mouse.Hit.p
	end)

	clickConn = mouse.Button1Down:Connect(function()
		if canMove and Player.Character and Player.Character:FindFirstChild("Humanoid") then
			removeClonedCircle()

			clonedCircle = clicktowalkcircle:Clone()
			clonedCircle.Parent = workspace
			clonedCircle.Name = "poscircle"

			local humanoid = Player.Character.Humanoid
			humanoid:MoveTo(mouse.Hit.p)

			humanoid.MoveToFinished:Connect(function()
				removeClonedCircle()
			end)
		end
	end)

	charConn = Player.CharacterAdded:Connect(removeClonedCircle)
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
