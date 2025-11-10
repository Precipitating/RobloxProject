local SoundModule = require(script:WaitForChild("SoundModule"))
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local RunService = game:GetService("RunService")
local SetMonitorPicture = require(script.NPCs.PsychoMantis.SetMonitorPicture)
local StarterGui = game:GetService("StarterGui")
local TimeOfDay = require(ReplicatedStorage.TimeOfDay.TimeOfDay)
local ClientRemotes = require(script.ClientRemotes)
local Thief = require(ReplicatedStorage.NPCs.Thief.Thief)
local AnimationController = require(script.NPCs.MoveableNPCAnimate.AnimationController)

local function RespawnDisabler()
	-- disable respawn button
	local coreCall
	do
		local MAX_RETRIES = 8
		function coreCall(method, ...)
			local result = {}
			for _ = 1, MAX_RETRIES do
				result = { pcall(StarterGui[method], StarterGui, ...) }
				if result[1] then
					break
				end
				RunService.Stepped:Wait()
			end
			return unpack(result)
		end
	end

	coreCall("SetCore", "ResetButtonCallback", false)
end

local function Startup()
	-- play main theme
	SoundModule.PlayTheme("HomeTheme")
	SetMonitorPicture.Set()
	Thief.Initialize()
	TimeOfDay.StartSyncing()
	AnimationController.ApplyToMoveableNPCS()

	--GeneralRemotes.AddMoney:FireServer(10000)
end

RespawnDisabler()
ClientRemotes.Initialize()
Startup()
