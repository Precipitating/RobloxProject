local player = game.Players.LocalPlayer
local lastDisabledBy = nil
local lastEnabledBy = nil
local controls = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
local MovementHandler = {}

function MovementHandler.DisableControls(caller)
	lastDisabledBy = caller
	controls:Disable()
	print("Movement disabled")
end

function MovementHandler.EnableControls(caller)
	if caller == "UI" and lastDisabledBy == "Cutscene" then
		warn("UI tried to re-enable movement but we're on a cutscene")
		return
	end
	lastEnabledBy = caller
	controls:Enable()
	print("Movement Enabled")
end
return MovementHandler
