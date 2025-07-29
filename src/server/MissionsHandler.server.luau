local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local Missions = require(ReplicatedStorage.Missions.Server.Missions)
local Types = require(ReplicatedStorage.Missions.Configs.Types)
local MissionEventHandlers = require(ServerScriptService.Server.MissionsLogicHandler)
local HelperFunctions = require(ServerScriptService.Server.HelperFunctions)
local MissionCompleteHandlers = require(ServerScriptService.Server.MissionsCompleteHandler)

-- mission handlers
local function unlockHandler(player: Player, missionId: Types.MissionId)
	print(` {player} calling mission event {missionId}...`)
	local handler = MissionEventHandlers[missionId]

	if handler then
		handler()
	else
		print("Mission handler not found. Check spelling")
	end
end

local function completeHandler(player: Player, missionId: Types.MissionId)
	print(`{player} completed mission {missionId}`)
	local handler = MissionCompleteHandlers[missionId]
	if handler then
		handler(player)
	else
		print("Failed to claim rewards")
	end
end

local function failHandler(player: Player, missionId: Types.MissionId)
	print(`{player} failed mission {missionId}`)
end

-- handle remote events
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

ReplicatedStorage.Missions.Events.GiveToolEvent.OnServerEvent:Connect(function(player, toolName)
	print(`Server received GiveToolEvent, attempting to give you the tool {toolName} `)
	if typeof(toolName) == "string" then
		HelperFunctions.GiveTool(player, toolName)
	end
end)

ReplicatedStorage.Missions.Events.ForceEquipEvent.OnServerEvent:Connect(function(player, toolName)
	print("Force equip tool arrived at server")
	if typeof(toolName) == "string" then
		HelperFunctions.ForceEquip(player, toolName)
	end
end)

ReplicatedStorage.Missions.Events.RemoveToolsEvent.OnServerEvent:Connect(function(player, toolsStringList)
	print("Remove tool arrived at server")
	if typeof(toolsStringList) == "table" then
		HelperFunctions.RemoveTools(player, toolsStringList)
	end
end)

ReplicatedStorage.Missions.Events.SetMeshVisibilityEvent.OnServerEvent:Connect(function(_, meshTagList)
	print("Set mesh visibility arrived at server")
	if typeof(meshTagList) == "table" then
		HelperFunctions.SetMeshVisibility(meshTagList)
	end
end)

ReplicatedStorage.Missions.Events.SetDialogueFileEvent.OnServerEvent:Connect(function(_, fromToTable)
	print("Set dialogue arrived at server")
	if typeof(fromToTable) == "table" then
		HelperFunctions.SetNPCDialogueFile(fromToTable)
	end
end)

ReplicatedStorage.Missions.Events.ExecuteScenarioEvent.OnServerEvent:Connect(function(player, eventName)
	print(` {player} calling mission event {eventName}...`)
	local handler = MissionEventHandlers[eventName]
	if handler then
		handler(player)
	else
		print("Event handler not found. Check spelling")
	end
end)

ReplicatedStorage.Missions.Events.DestroyObjectEvent.OnServerEvent:Connect(function(_, objectTagList)
	print("Destroy object arrived at server")
	if typeof(objectTagList) == "table" then
		HelperFunctions.DestroyObject(objectTagList)
	end
end)

local function initialize()
	for missionId in Missions.Missions do
		Missions.setUnlockHandler(missionId, unlockHandler)
		Missions.setCompletionHandler(missionId, completeHandler)
		Missions.setFailureHandler(missionId, failHandler)
	end
end

initialize()
