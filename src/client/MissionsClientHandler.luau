local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HaulJob = require(ReplicatedStorage.Shared.NPCs.ManualLabor.HaulJob)

local MissionsClientHandler = {}

MissionsClientHandler["HaulJob"] = function()
	print("Local logic called for HaulJob")
	HaulJob.ClientInit()
end

return MissionsClientHandler
