local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HaulJob = require(ReplicatedStorage.Shared.NPCs.ManualLabor.HaulJob)
local TrashPickup = require(ReplicatedStorage.Shared.NPCs.TrashPickup.TrashPickup)

local MissionsClientHandler = {}

MissionsClientHandler["HaulJob"] = function()
	print("Local logic called for HaulJob")
	HaulJob.ClientInit()
end

MissionsClientHandler["TrashPickup"] = function()
	print("Local logic called for TrashPickup")
	TrashPickup.ClientInit(Players.LocalPlayer)
end

return MissionsClientHandler
