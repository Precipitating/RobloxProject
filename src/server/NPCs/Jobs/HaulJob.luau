local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TouchInputService = game:GetService("TouchInputService")
local HelperFunctions = require(ServerScriptService.Server.HelperFunctions)
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local LaunchPosition = nil
local HaulJob = {}

function HaulJob.Init(player)
	local model = HelperFunctions.SpawnModelAtPosition("MissionModels", "Jobs", "HaulHob", nil)
	GeneralRemotes.ChangeCameraSubject:FireClient(player, model:FindFirstChild("CameraPos"))
	LaunchPosition = model:FindFirstChild("Van"):FindFirstChild("LaunchPos")
	Pallet = model:FindFirstChild("pallet"):FindFirstChild("palletCollision")
end
