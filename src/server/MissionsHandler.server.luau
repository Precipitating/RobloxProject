local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Missions = require(ReplicatedStorage.Missions.Server.Missions)
local Types = require(ReplicatedStorage.Missions.Configs.Types)
local MissionEventHandlers = require(ServerScriptService.Server.MissionsLogicHandler)

-- handle remote events for unlocking missions manually
ReplicatedStorage.Missions.Events.UnlockMissionEvent.OnServerEvent:Connect(function(player, missionName)
	print(missionName)
	if typeof(missionName) == "string" then
		Missions.unlockMission(player, missionName)
		print("Server unlocked the mission " .. missionName)
	end
end)

ReplicatedStorage.Missions.Events.ProgressMissionEvent.OnServerEvent:Connect(function(player, progressDict)
	if typeof(progressDict) == "table" then
		Missions.addProgressToTask(player, progressDict.MissionName, progressDict.TaskId, progressDict.ProgressVal)
		print("Progress added to " .. progressDict.MissionName)
	end
end)

-- mission handlers
local function unlockHandler(player: Player, missionId: Types.MissionId)
	print(`{player} unlocked mission {missionId}`)
	local handler = MissionEventHandlers[missionId]

	if handler then
		handler()
	else
		print("Mission handler not found. Check spelling")
	end
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
