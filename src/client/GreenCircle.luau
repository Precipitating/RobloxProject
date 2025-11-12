local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local OriginalCircle = ReplicatedStorage.ClientModels.SafeChatter.GreenCircle

local ClonedCircle = nil
local CanMove = false
local MaxDistance = 55
local Enabled = false
local ClickToWalkCircle = nil
local Loop = nil
local ClickConn = nil
local CharConn = nil

local GreenCircle = {}

-- cleanup function
local function RemoveClonedCircle()
	if ClonedCircle then
		ClonedCircle:Destroy()
		ClonedCircle = nil
	end
end

function GreenCircle.DisconnectAll()
	if Loop then
		Loop:Disconnect()
		Loop = nil
	end
	if ClickConn then
		ClickConn:Disconnect()
		ClickConn = nil
	end
	if CharConn then
		CharConn:Disconnect()
		CharConn = nil
	end
	RemoveClonedCircle()
	if ClickToWalkCircle then
		ClickToWalkCircle:Destroy()
		ClickToWalkCircle = nil
	end
	if Enabled then
		Enabled = false
	end
end
-- movement logic
function GreenCircle.StartClickToMove()
	if not Enabled then
		return
	end
	ClickToWalkCircle = OriginalCircle:Clone()
	ClickToWalkCircle.Parent = workspace
	Loop = RunService.RenderStepped:Connect(function()
		if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
			return
		end

		local distance = (Player.Character.HumanoidRootPart.Position - Mouse.Hit.p).Magnitude

		CanMove = distance <= MaxDistance
		ClickToWalkCircle.Transparency = CanMove and 0 or 1
		ClickToWalkCircle.Position = Mouse.Hit.p
	end)

	ClickConn = Mouse.Button1Down:Connect(function()
		if CanMove and Player.Character and Player.Character:FindFirstChild("Humanoid") then
			RemoveClonedCircle()

			ClonedCircle = ClickToWalkCircle:Clone()
			ClonedCircle.Parent = workspace
			ClonedCircle.Name = "poscircle"

			local humanoid = Player.Character.Humanoid
			humanoid:MoveTo(Mouse.Hit.p)

			humanoid.MoveToFinished:Connect(function()
				RemoveClonedCircle()
			end)
		end
	end)

	CharConn = Player.CharacterAdded:Connect(RemoveClonedCircle)
end

function GreenCircle.SetEnabled(val)
	Enabled = val
end
function GreenCircle.IsEnabled()
	return Enabled
end

return GreenCircle
