local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local GeneralRemotes = ReplicatedStorage.Remotes
local HostLocationIdx = 1
local Host = nil
local HostLocations = nil
local HostTTS = nil
local WhodunnitMode = {}

local function MoveHostNextLocation()
	if HostLocations[HostLocationIdx] then
		Host:PivotTo(HostLocations[HostLocationIdx].CFrame)
		return
	end

	warn("Can't move host to next location, there isn't any!")
end

function WhodunnitMode.Start(player)
	local map = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Whodunnit", "ZapsMansion", nil)
	task.wait(1)
	player.Character:PivotTo(map:FindFirstChild("SpawnLoc").CFrame)
	GeneralRemotes.PlayTheme:FireClient(player, "HappyTheme")
	Host = map:FindFirstChild("WhodunnitHost")
	HostTTS = Host:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("AudioTextToSpeech")
	HostLocations = map:FindFirstChild("HostLocs"):GetChildren()
	HostTTS.Text =
		"Welcome guests to my mansion! Lets get settled in quickly. But first, an little chat in the assembly hall to the right. Let's go in and sit down shall we?"
	HostTTS:Play()
	HostTTS.Ended:Wait()
	MoveHostNextLocation()
	WhodunnitMode.AssemblyHall()
end

function WhodunnitMode.AssemblyHall()
	HostTTS.Text =
		"As I said, welcome to my mansion, This is a prestigious mansion with top of the quality service, you guys have arrived late, so its best for you guys to start sleeping soon."
	HostTTS:Play()
	HostTTS.Ended:Wait()
end
return WhodunnitMode
