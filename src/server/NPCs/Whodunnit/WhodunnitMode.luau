local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local WhodunnitGuest = require(script.Parent.WhodunnitGuest)
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local GeneralRemotes = ReplicatedStorage.Remotes
local HostLocationIdx = 1
local Host = nil
local MapRef = nil
local HostLocations = nil
local UFORef = nil
local HostTTSIdx = 0
local HostDistortion = nil
local PlayerRef = nil
local SleepAreaUnlocked = false
local HostTTSDialogue = {
	"Welcome guests to my mansion! Lets get settled in quickly. But first, an little chat in the assembly hall to the right. Let's go in and sit down shall we?",
	"As I said, welcome to my mansion, This is a prestigious mansion with top of the quality service.",
	"This mansion was built by top paid workers, with top paid benefits, with top of the notch treatment, I swear.",
	"We hope you enjoy your stay at the Wilson mansion, but first can you guys turn off your base stations, I can hear something.",
	"How did you get btools you hacking liar. ban pre!",
	"Ignore what transpired fellow guests, you should go to sleep and prepare for the next day. Rooms are up the stairs. Pick any room and bed. See you tommorow.",
	"Go to the left room and get some shut eye.",
	"Blind all",
	"Congratulations. I have chosen you to be the killer. Pick a victim and i'll do the rest.",
	"By the way, everyone's blind, so they can't see this.",
	"OH MY GOD EVERYONE COME TO THE MAIN AREA",
	"GUEST NUMBER 67 HAS BEEN MURDERED! WHO COULD DO SUCH A THING!",
	"IT SEEMS THAT ONE OF YOU IS THE KILLER, WHO COULD IT POSSIBLY BE?",
	"What is that on the floor?",
	"An accessory, the murderer was caught lacking. I wonder who could possibly wear this. I wonder.",
	"How can you leave obvious evidence out like that. What a donkey you are!",
}

local WhodunnitMode = {}

local function MoveHostNextLocation()
	if HostLocations[HostLocationIdx] then
		Host:PivotTo(HostLocations[HostLocationIdx].CFrame)
		HostLocationIdx += 1
		return
	end

	warn("Can't move host to next location, there isn't any!")
end

function WhodunnitMode.SleepAreaUnlocked()
	return SleepAreaUnlocked
end

function WhodunnitMode.Cleanup()
	Host = nil
	MapRef = nil
	HostLocations = nil
	HostDistortion = nil
	PlayerRef = nil
	UFORef = nil
end

local function PlayNextHostTTS()
	HostTTSIdx += 1
	local success = GeneralRemotes.Whodunnit.HostTalk:InvokeClient(PlayerRef, HostTTSDialogue[HostTTSIdx])
	if not success then
		error("Missing AudioTextToSpeech reference on host!")
	end
end

local function SetHostReferences()
	-- set host refs
	Host = MapRef:FindFirstChild("WhodunnitHost")
	HostLocations = MapRef:FindFirstChild("HostLocs"):GetChildren()
	HostDistortion = Host:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("AudioDistortion")
end
function WhodunnitMode.Start(player)
	MapRef = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Whodunnit", "ZapsMansion", nil)
	PlayerRef = player
	task.wait(1)

	player.Character:PivotTo(MapRef:FindFirstChild("SpawnLoc").CFrame)
	GeneralRemotes.PlayTheme:FireClient(player, "HappyTheme")

	SetHostReferences()
	HostDistortion.Level = 0.1
	PlayNextHostTTS()
	task.wait(1)
	MoveHostNextLocation()
	GeneralRemotes.EnableControls:FireClient(player)
end

local function StartUFOTween()
	UFORef = MapRef:FindFirstChild("AssemblyRoom"):FindFirstChild("UFO")
	local ufoHRP = UFORef:FindFirstChild("Me"):FindFirstChild("HumanoidRootPart")
	local ufoScream = ufoHRP:FindFirstChildOfClass("AudioPlayer")
	local destroyWall = MapRef:FindFirstChild("Walls"):FindFirstChild("DestroyWall")
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
	local goal = { CFrame = UFORef.PrimaryPart.CFrame * CFrame.new(72, 0, 0) }
	local tween = TweenService:Create(UFORef.PrimaryPart, tweenInfo, goal)
	tween:Play()
	ufoScream:Play()
	destroyWall:Destroy()
	tween.Completed:Wait()
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 0, 0)
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "CarCrash")
	ufoScream:Stop()
	ufoHRP.Parent:Destroy()
end

local function UFOConfrontEvent()
	local me = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Whodunnit", "MeConfront", nil)
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 1, 1)
	local tts = me:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("AudioTextToSpeech")
	tts:Play()
	tts.Ended:Wait()
	PlayNextHostTTS()
	me:Destroy()
	UFORef:Destroy()
end

local function AnnounceSleepTime()
	PlayNextHostTTS()
	HostDistortion.Level = 0.1
	SleepAreaUnlocked = true
	GeneralRemotes.EnableControls:FireClient(PlayerRef)
	MoveHostNextLocation()
end

function WhodunnitMode.SleepArea()
	PlayNextHostTTS()
end

function WhodunnitMode.Sleeping()
	HostDistortion.Level = 1
	task.wait(3)
	PlayNextHostTTS()
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 0, 0)
	GeneralRemotes.StopAllMusic:InvokeClient(PlayerRef)

	MoveHostNextLocation()
	GeneralRemotes.PlayTheme:FireClient(PlayerRef, "CreepyNightTheme")
	local guests = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Whodunnit", "WhodunnitGuests", nil)

	-- npc bubble chat spam
	WhodunnitGuest.SetPanicking(true)
	for _, guest in ipairs(guests:GetChildren()) do
		WhodunnitGuest.StartPanicking(guest.Head)
	end

	WhodunnitMode.PickKiller()
end

function WhodunnitMode.PickKiller()
	task.wait(5)
	GeneralRemotes.Whodunnit.HostTalk:InvokeClient(PlayerRef, `Unblind {PlayerRef.DisplayName}`)
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 0, 1)
	HostDistortion.Level = 0.5
	PlayNextHostTTS()
	PlayNextHostTTS()
	GeneralRemotes.EnableControls:FireClient(PlayerRef)
end

local function PositionGuestsToMurderSpot(modelName)
	local victim = workspace:FindFirstChild("WhodunnitGuests"):FindFirstChild(modelName)

	-- spawn dead body
	local deadBody = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Whodunnit", "DeadBody", nil)
	deadBody
		:FindFirstChild("DeadVictim")
		:FindFirstChildOfClass("Humanoid")
		:ApplyDescription(victim.Humanoid:GetAppliedDescription())
	WhodunnitGuest.RemoveHeadFromTable(victim.Name)
	victim:Destroy()

	-- move guests
	local positions = MapRef:FindFirstChild("GuestMurderPos")
	local positionList = positions:GetChildren()
	local guests = workspace:FindFirstChild("WhodunnitGuests"):GetChildren()
	for idx, guest in guests do
		guest.ProximityPrompt.Enabled = false
		guest:PivotTo(positionList[idx].CFrame)
	end

	-- put a player accessory as murder evidence

	local accessory = PlayerRef.Character:FindFirstChildWhichIsA("Accessory")
	if not accessory then
		return false
	end
	local clone = accessory:Clone()
	local handle = clone:FindFirstChild("Handle") or clone:FindFirstChildWhichIsA("BasePart")

	if handle then
		handle.Parent = workspace
		handle:BreakJoints()
		handle.Anchored = true
		handle.CanCollide = false
		handle:PivotTo(positions.AccessoryPos.CFrame)
		handle.Parent = deadBody
	end

	return true
end

function WhodunnitMode.KillVictim(modelName)
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 0, 0)
	GeneralRemotes.DisableControls:FireClient(PlayerRef)
	WhodunnitGuest.SetPanicking(false)

	local hasAccessory = PositionGuestsToMurderSpot(modelName)
	MoveHostNextLocation()
	task.wait(5)
	if hasAccessory then
		WhodunnitMode.MorningMurderEvidence()
	end
end

function WhodunnitMode.MorningMurderEvidence()
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 1, 1)
	task.wait(1)
	GeneralRemotes.PlayTheme:FireClient(PlayerRef, "Mysterious")
	HostDistortion.Level = 1
	PlayNextHostTTS()
	GeneralRemotes.EnableControls:FireClient(PlayerRef)
end

function WhodunnitMode.ArrivedAtMurder()
	HostDistortion.Level = 0.3
	GeneralRemotes.DisableControls:FireClient(PlayerRef)
	PlayNextHostTTS()
	PlayNextHostTTS()
	PlayNextHostTTS()
	PlayNextHostTTS()

	-- victims head turn to you
	WhodunnitGuest.TurnGuestHeadsToPlayer(PlayerRef.Character.Head)

	task.wait(1)
	GeneralRemotes.Whodunnit.HostTalk:InvokeClient(
		PlayerRef,
		`Seems like a decision has been made huh, {PlayerRef.DisplayName} You really are bad killer aren't you?`
	)
	PlayNextHostTTS()
end

function WhodunnitMode.AssemblyHall()
	HostDistortion.Level = 0.8
	--
	PlayNextHostTTS()
	PlayNextHostTTS()
	PlayNextHostTTS()
	--
	StartUFOTween()
	task.wait(2)
	UFOConfrontEvent()
	--
	AnnounceSleepTime()
end
return WhodunnitMode
