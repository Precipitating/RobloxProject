local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Missions = require(ReplicatedStorage.Missions.Server.Missions)
local Types = require(ReplicatedStorage.Missions.Configs.Types)

local function unlockHandler(player: Player, missionId: Types.MissionId)
	print(`{player} unlocked mission {missionId}`)
end

local function completeHandler(player: Player, missionId: Types.MissionId)
	print(`{player} completed mission {missionId}`)
end

local function failHandler(player: Player, missionId: Types.MissionId)
	print(`{player} failed mission {missionId}`)
end

local function initialize()
	for missionId in Missions.Missions do
		Missions.setUnlockHandler(missionId, unlockHandler)
		Missions.setCompletionHandler(missionId, completeHandler)
		Missions.setFailureHandler(missionId, failHandler)
	end
end

initialize()
