local Player = game.Players.LocalPlayer
local LastDisabledBy = nil
local LastEnabledBy = nil
local Controls = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
local MovementHandler = {}

function MovementHandler.DisableControls(caller)
	LastDisabledBy = caller
	Controls:Disable()
	print("Movement disabled")
end

function MovementHandler.EnableControls(caller)
	if caller == "UI" and LastDisabledBy == "Cutscene" then
		warn("UI tried to re-enable movement but we're on a cutscene")
		return
	end
	LastEnabledBy = caller
	Controls:Enable()
	print("Movement Enabled")
end
return MovementHandler
