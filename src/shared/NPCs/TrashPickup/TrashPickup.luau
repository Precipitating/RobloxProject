local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local RunService = game:GetService("RunService")
local IS_SERVER = RunService:IsServer()
local ServerScriptService = IS_SERVER and game:GetService("ServerScriptService")
local CurrencyHandler = IS_SERVER and require(ServerScriptService.Server.CurrencyHandler)
local ServerHelperFunctions = IS_SERVER and require(ServerScriptService.Server.ServerHelperFunctions)
local ServerStorage = IS_SERVER and game:GetService("ServerStorage")
local GeneralRemotes = ReplicatedStorage.Remotes
local TrashPickedUp = 0
local TotalTrashSpawned = 0
local TrashPickup = {}

function TrashPickup.TrashData()
	return { PickedUp = TrashPickedUp, TotalTrash = TotalTrashSpawned }
end

function TrashPickup.PickedUp(trashModel)
	TrashPickedUp = TrashPickedUp + 1
	trashModel:Destroy()
	return TrashPickup.TrashData()
end

function TrashPickup.ServerInit()
	local trashModel = ServerStorage.MissionModels.TrashPickup
	local spawnPoints = ServerStorage.MissionModels.TrashPickup.TrashPoints:GetChildren()

	if not trashModel or not spawnPoints then
		error("TrashModel and TrashPoints failed to get reference")
		return
	end

	-- 50% chance to spawn trash at preset trash points
	for _, trash in ipairs(spawnPoints) do
		if math.random() > 0.5 then
			local model = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "TrashPickup", "Trash", nil)
			model:PivotTo(trash.CFrame)
			TotalTrashSpawned = TotalTrashSpawned + 1
		end
	end
end

function TrashPickup.ClientInit(player)
	-- clone the GUI to player's GUI
	local gui = ReplicatedStorage.GUI.TrashPickup.TrashCounter:Clone()
	local playerGUI = player:WaitForChild("PlayerGui")
	gui.Parent = playerGUI

	task.wait(0.5)
	-- set trash counter values
	local result = GeneralRemotes.PickupTrash.TrashData:InvokeServer()
	local guiLabel = gui:WaitForChild("Counter")
	guiLabel.Text = `Trash Picked:<br/>{tostring(result.PickedUp)}/{tostring(result.TotalTrash)}`
end

function TrashPickup.ServerFinishedGame(player)
	-- add the money (£10 per item)
	CurrencyHandler.AddMoney(player, TrashPickedUp * 10)
	TrashPickedUp = 0
	TotalTrashSpawned = 0
	return true
end

return TrashPickup
