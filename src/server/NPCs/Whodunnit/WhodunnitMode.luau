local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local BadgeHandler = require(ServerScriptService.Server.BadgeHandler)
local ConnectionManager = require(ServerScriptService.Server.ConnectionManager)
local CurrencyHandler = require(ServerScriptService.Server.CurrencyHandler)
local WhodunnitGuest = require(script.Parent.WhodunnitGuest)
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local GeneralRemotes = ReplicatedStorage.Remotes
local HostLocationIdx = 1
local Host = nil
local MapRef = nil
local HostLocations = nil
local UFORef = nil
local HostTTSIdx = 0
local HostTTSHandle = nil
local HostDistortion = nil
local PlayerRef = nil
local SleepAreaUnlocked = false
local PoolUnlocked = false
local BoothPos = nil
local HasAccessory = nil
local Guests = nil
local CanVote = false
local SatOnBed = false
local HostTTSDialogue = {
	"Welcome guests to my mansion! Lets get settled in quickly. But first, an little chat in the assembly hall to the right. Let's go in and sit down shall we?",
	"As I said, welcome to my mansion, This is a prestigious mansion with top of the quality service.",
	"This mansion was built by top paid workers, with top paid benefits, with top of the notch treatment, I swear.",
	"We hope you enjoy your stay at the Wilson mansion, but first can you guys turn off your base stations, I can hear something.",
	"How did you get btools you hacking liar. ban pre!",
	"Ignore what transpired fellow guests, you should go to sleep and prepare for the next day. Rooms are up the stairs. Go to the left room. See you tommorow.",
	"Your bed is on the far left, go get some shut eye.",
	-- KILLER CHOOSE
	"Blind all",
	"Congratulations. I have chosen you to be the killer. Pick a victim and i'll do the rest.",
	"By the way, everyone's blind, so they can't see this.",
	-- FIRST MURDER ON MAIN HALL
	"OH MY GOD EVERYONE COME TO THE MAIN AREA",
	"GUEST NUMBER SIX SEVEN HAS BEEN MURDERED! WHO COULD DO SUCH A THING!",
	"IT SEEMS THAT ONE OF YOU IS THE KILLER, WHO COULD IT POSSIBLY BE?",
	-- ACCESSORY EXISTS
	"What is that on the floor?",
	"An accessory, the murderer was caught lacking. I wonder who could possibly wear this. I wonder.",
	"Well well well, looks like you've been selected. Lets find out if he's the killer.",
	-- NO ACCESSORY
	"Looks like the killer left no evidence. This is scary guys. Who done it?",
	"Anyways, go have fun in the pool which is in the room to the left of the assembly hall while I figure out what is going on!",
	"Blind all",
	"You know the drill, pick a victim.",
	-- POOL MURDER
	"Oh my god guys, guest twenny wan has drowned! Could he not swim or was it another murder?",
	"Shall we discuss on who the murderer could be? We need to vote one out or the killer wins!",
	"Start clicking on the person to vote and we'll continue from there!",
	-- VOTED
	"Results are in, and there are no ties. Lets make it dramatic. I will kill the chosen individual with the most votes! Ready...",
	-- VOTED OUT GUEST
	"Oh dear, looks like that individual was eliminated, but is it the right one?",
	"But was that guest really the killer? I will give a sword to the killer after the suspense if they exist, if not, guests win! Ready...",
	-- KILLER REVEALED
	"Oh my god the killer is still here! the guests have failed!",
	"I have god mode on, you donkey!",
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
function WhodunnitMode.PoolUnlocked()
	return PoolUnlocked
end
function WhodunnitMode.CanVote()
	return CanVote
end
function WhodunnitMode.SatOnBed()
	return SatOnBed
end
function WhodunnitMode.Cleanup()
	Host = nil
	HostTTSHandle = nil
	MapRef = nil
	HostLocations = nil
	HostDistortion = nil
	PlayerRef = nil
	UFORef = nil
	BoothPos = nil
	HostLocationIdx = 1
	SleepAreaUnlocked = false
	HasAccessory = nil
	PoolUnlocked = false
	Guests = nil
	CanVote = false
	SatOnBed = false
	HostTTSIdx = 0

	local mansion = workspace:FindFirstChild("ZapsMansion")
	if mansion then
		mansion:Destroy()
	end

	local guests = workspace:FindFirstChild("WhodunnitGuests")
	if guests then
		guests:Destroy()
	end

	local deadBody = workspace:FindFirstChild("DeadBody")
	if deadBody then
		deadBody:Destroy()
	end

	local deadBodyPool = workspace:FindFirstChild("DeadBodyDrowned")
	if deadBodyPool then
		deadBodyPool:Destroy()
	end
end

local function PlayNextHostTTS()
	HostTTSIdx += 1
	local success = GeneralRemotes.Whodunnit.Speak3D:InvokeClient(PlayerRef, HostTTSHandle, HostTTSDialogue[HostTTSIdx])
	if not success then
		warn("Failed to play Host TTS, skipping.")
	end
end

local function SetHostReferences()
	-- set host refs
	Host = MapRef:FindFirstChild("WhodunnitHost")
	HostTTSHandle = Host:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("AudioTextToSpeech")
	HostLocations = MapRef:FindFirstChild("HostLocs"):GetChildren()
	HostDistortion = Host:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("AudioDistortion")
end
function WhodunnitMode.Start(player)
	GeneralRemotes.Whodunnit.ResetHostTTS:FireClient(player)
	CurrencyHandler.ReduceMoney(player, 100)
	PlayerRef = player
	BoothPos = player.Character:GetPivot()
	--
	MapRef = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Whodunnit", "ZapsMansion", nil)
	task.wait(1)
	player.Character:PivotTo(MapRef:FindFirstChild("SpawnLoc").CFrame)
	--
	GeneralRemotes.PlayTheme:FireClient(player, "HappyTheme")
	SetHostReferences()
	HostDistortion.Level = 0.1
	PlayNextHostTTS()
	--
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
	--
	tween:Play()
	ufoScream:Play()
	destroyWall:Destroy()
	--
	tween.Completed:Wait()
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 0, 0)
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "CarCrash")
	ufoScream:Stop()
	ufoHRP.Parent:Destroy()
end

local function UFOConfrontEvent()
	local me = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Whodunnit", "MeConfront", nil)
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 1, 1)
	--
	local tts = me:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("AudioTextToSpeech")
	task.wait(1)
	GeneralRemotes.Whodunnit.Speak3D:InvokeClient(PlayerRef, tts, nil)
	--
	PlayNextHostTTS()
	--
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
	SatOnBed = true
	HostDistortion.Level = 1
	task.wait(3)
	PlayNextHostTTS()
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 0, 0)
	GeneralRemotes.StopAllMusic:InvokeClient(PlayerRef)

	MoveHostNextLocation()

	GeneralRemotes.PlayTheme:FireClient(PlayerRef, "CreepyNightTheme")
	Guests = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Whodunnit", "WhodunnitGuests", nil)

	-- npc bubble chat spam
	WhodunnitMode.SetGuestsPanicking()
	WhodunnitMode.PickKiller()
end

function WhodunnitMode.PickKiller()
	task.wait(5)
	WhodunnitMode.Unblind(0.7, true)
	--
	PlayNextHostTTS()
	PlayNextHostTTS()
	--
	GeneralRemotes.EnableControls:FireClient(PlayerRef)
	WhodunnitGuest.ToggleCanKillPrompt(true)
end

local function MoveGuests(folderName)
	-- move guests
	local positions = MapRef:FindFirstChild(folderName)
	local positionList = positions:GetChildren()

	for idx, guest in Guests:GetChildren() do
		guest:PivotTo(positionList[idx].CFrame)
	end
end
function WhodunnitMode.SpawnDeadBody(victimName, deadModelName)
	local victim = Guests:FindFirstChild(victimName)
	-- spawn dead body
	local deadBody = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "Whodunnit", deadModelName, nil)
	deadBody
		:FindFirstChild("DeadVictim")
		:FindFirstChildOfClass("Humanoid")
		:ApplyDescription(victim.Humanoid:GetAppliedDescription())
	victim:Destroy()
	return deadBody
end
local function PositionGuestsToMurderSpot(victimName)
	local deadBody = WhodunnitMode.SpawnDeadBody(victimName, "DeadBody")

	MoveGuests("GuestMurderPos")
	-- put a player accessory as murder evidence if exists
	HasAccessory = PlayerRef.Character:FindFirstChildWhichIsA("Accessory")
	if not HasAccessory then
		return
	end
	local clone = HasAccessory:Clone()
	local handle = clone:FindFirstChild("Handle") or clone:FindFirstChildWhichIsA("BasePart")

	if handle then
		handle.Parent = workspace
		handle:BreakJoints()
		handle.Anchored = true
		handle.CanCollide = false
		handle:PivotTo(MapRef:FindFirstChild("GuestMurderPos").AccessoryPos.CFrame)
		handle.Parent = deadBody
	end
end

function WhodunnitMode.KillVictim(victimName)
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 0, 0)
	GeneralRemotes.DisableControls:FireClient(PlayerRef)
	WhodunnitGuest.SetPanicking(false)
	WhodunnitGuest.RemoveHeadFromTable(victimName)
	WhodunnitGuest.ToggleCanKillPrompt(false)
	if SleepAreaUnlocked then
		if not PoolUnlocked then
			PositionGuestsToMurderSpot(victimName)
			MoveHostNextLocation()
			task.wait(5)
			WhodunnitMode.MorningMurder()
		elseif PoolUnlocked then
			WhodunnitMode.PoolMurder(victimName)
		end
	end
end

function WhodunnitMode.MorningMurder()
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "Scream")
	task.wait(3)
	--
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 1, 1)
	task.wait(1)
	GeneralRemotes.PlayTheme:FireClient(PlayerRef, "Mysterious")

	HostDistortion.Level = 1
	PlayNextHostTTS()
	GeneralRemotes.EnableControls:FireClient(PlayerRef)
end

function WhodunnitMode.HasAccessory()
	return HasAccessory
end
function WhodunnitMode.ArrivedAtMurderEvidence()
	HostDistortion.Level = 0.3
	GeneralRemotes.DisableControls:FireClient(PlayerRef)

	for _ = 1, 4 do
		PlayNextHostTTS()
	end

	-- victims head turn to you
	WhodunnitGuest.TurnGuestHeadsToPlayer(PlayerRef.Character.Head)
	task.wait(1)
	GeneralRemotes.Whodunnit.Speak3D:InvokeClient(
		PlayerRef,
		HostTTSHandle,
		`Seems like a decision has been made huh, what we saying guys?`
	)

	WhodunnitGuest.AnnouncePlayerIsMurderer(PlayerRef)
	PlayNextHostTTS()
	task.wait(1)
	WhodunnitMode.VotedOut()
end

function WhodunnitMode.ArrivedAtMurderNoEvidence()
	PoolUnlocked = true
	HostDistortion.Level = 0.7
	GeneralRemotes.DisableControls:FireClient(PlayerRef)
	--
	PlayNextHostTTS()
	PlayNextHostTTS()
	HostTTSIdx += 3
	PlayNextHostTTS()
	PlayNextHostTTS()
	--

	GeneralRemotes.PlayTheme:FireClient(PlayerRef, "HappyTheme")
	MoveGuests("PoolMurderPos")
	Host:PivotTo(MapRef:FindFirstChild("PoolMurderPos").HostPos.CFrame)
	GeneralRemotes.EnableControls:FireClient(PlayerRef)
end

function WhodunnitMode.SetGuestsPanicking()
	WhodunnitGuest.SetPanicking(true)
	for _, guest in ipairs(Guests:GetChildren()) do
		WhodunnitGuest.StartPanicking(guest.Head)
	end
end

function WhodunnitMode.PoolAreaEvent()
	print("Touched pool")
	GeneralRemotes.DisableControls:FireClient(PlayerRef)
	HostDistortion.Level = 1
	PlayNextHostTTS()
	--
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 0, 0)
	WhodunnitMode.SetGuestsPanicking()
	GeneralRemotes.PlayTheme:FireClient(PlayerRef, "CreepyNightTheme")
	task.wait(3)
	WhodunnitMode.Unblind(0.7, true)
	--
	PlayNextHostTTS()
	GeneralRemotes.EnableControls:FireClient(PlayerRef)
	WhodunnitGuest.ToggleCanKillPrompt(true)
end

-- occurs when prompt is selected
function WhodunnitMode.PoolMurder(victimName)
	WhodunnitGuest.SetPanicking(false)
	local body = WhodunnitMode.SpawnDeadBody(victimName, "DeadBodyDrowned")
	local victimHumanoid = body:FindFirstChild("DeadVictim"):FindFirstChild("Humanoid")
	victimHumanoid.DisplayName = `{PlayerRef.DisplayName} Waz Here.`
	task.wait(1)
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "Scream", false, true)
	--
	WhodunnitMode.Unblind(0.7)
	GeneralRemotes.PlayTheme:FireClient(PlayerRef, "Mysterious")
	--
	PlayNextHostTTS()
	GeneralRemotes.Whodunnit.Speak3D:InvokeClient(
		PlayerRef,
		HostTTSHandle,
		`Guys, theres something inscribed on his head! It says {PlayerRef.DisplayName} waz here! I wonder what that could mean!`
	)
	PlayNextHostTTS()
	PlayNextHostTTS()
	--
	WhodunnitGuest.DiscussVoteSelection(PlayerRef)
	CanVote = true
	GeneralRemotes.EnableControls:FireClient(PlayerRef)
end

function WhodunnitMode.PoolGuestVoted(guestVotedName)
	ConnectionManager.ClearAll()
	if not guestVotedName then
		error("Guest voted name is nil!")
	end
	CanVote = false
	print(guestVotedName)

	--
	local chosenGuest = Guests:FindFirstChild(guestVotedName)
	if not chosenGuest then
		error("Can't find the chosen guest model!")
	end
	-- kill chosen target
	GeneralRemotes.DisableControls:FireClient(PlayerRef)
	PlayNextHostTTS()
	GeneralRemotes.StopAllMusic:InvokeClient(PlayerRef)
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "ScaryRiser", false, true)
	chosenGuest:Destroy()
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "Pop", nil, true)
	WhodunnitGuest.RemoveHeadFromTable(guestVotedName)
	task.wait(2)
	--
	PlayNextHostTTS()
	PlayNextHostTTS()
	-- reveal killer
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "ScaryRiser", false, true)
	GeneralRemotes.PlayTheme:FireClient(PlayerRef, "CreepyNightTheme")
	ServerHelperFunctions.GiveTool(PlayerRef, { "Sword", true })
	ServerHelperFunctions.ForceEquip(PlayerRef, "Sword")
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "Unsheath")
	PlayNextHostTTS()
	WhodunnitGuest.AllGuestsSpeak(PlayerRef, {
		"This game is rubbish! you rigged this eye zap and im reporting this game for you stealing this idea from ps5 player. See you in court.",
	})
	WhodunnitGuest.DestroyAllGuests()
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "Pop", nil, true)
	GeneralRemotes.StopAllMusic:InvokeClient(PlayerRef)
	GeneralRemotes.Whodunnit.Speak3D:InvokeClient(
		PlayerRef,
		HostTTSHandle,
		`Ahem.Ok tours over guys, remember to buy my admin commands for 1000 robux to become host and host these exciting, not boring and fixed events! You can give that sword back now, {PlayerRef.DisplayName}`
	)
	task.wait(1)
	GeneralRemotes.Whodunnit.Speak3D:InvokeClient(PlayerRef, HostTTSHandle, `{PlayerRef.DisplayName}?`)

	-- end
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 0, 0)
	task.wait(3)
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "ForKingAndCountry", false, true)
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "BattleCry", false, true)
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "Parry", false, true)
	PlayNextHostTTS()
	GeneralRemotes.Whodunnit.Speak3D:InvokeClient(PlayerRef, HostTTSHandle, `Kick {PlayerRef.DisplayName}`)
	BadgeHandler.awardBadge(PlayerRef, 466173560868472)
	PlayerRef:Kick("You really thought you could kill the host?")
end

function WhodunnitMode.Unblind(endPitch, user)
	HostDistortion.Level = 1
	if user then
		GeneralRemotes.Whodunnit.Speak3D:InvokeClient(PlayerRef, HostTTSHandle, `Unblind {PlayerRef.DisplayName}`)
	else
		GeneralRemotes.Whodunnit.Speak3D:InvokeClient(PlayerRef, HostTTSHandle, `Unblind all`)
	end
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 0, 1)
	HostDistortion.Level = endPitch or 0
end

function WhodunnitMode.VotedOut()
	GeneralRemotes.StopAllMusic:InvokeClient(PlayerRef)
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 0, 0)
	GeneralRemotes.DisableControls:FireClient(PlayerRef)
	task.wait(2)
	GeneralRemotes.Whodunnit.Speak3D:InvokeClient(PlayerRef, HostTTSHandle, `Kill {PlayerRef.DisplayName}`)
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "Oof")
	PlayerRef.Character:PivotTo(BoothPos)
	task.wait(3)
	GeneralRemotes.PlaySound:InvokeClient(PlayerRef, "Yay")
	--
	ServerHelperFunctions.SetNPCDialogueFile({ WhodunnitNameTag = "WhodunnitFailed" })
	GeneralRemotes.BlackFade:FireClient(PlayerRef, 3, 1)
	GeneralRemotes.EnableControls:FireClient(PlayerRef)
	GeneralRemotes.PlayTheme:FireClient(PlayerRef, "Main")
	BadgeHandler.awardBadge(PlayerRef, 3480585543377290)
	WhodunnitMode.Cleanup()
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
