local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local SoundLocation = SoundService
local CurrentTheme = ReplicatedStorage.Sounds.CurrentTheme
local ThemeLocked = false
local GeneralRemotes = ReplicatedStorage.Remotes
local MainSounds = {
	"rbxassetid://101468716959778",
	"rbxassetid://98394237109741",
	"rbxassetid://86335096116258",
	"rbxassetid://94378181487716",
	"rbxassetid://1841647093",
	"rbxassetid://1842000022",
}
local PreviousThemeName = "HomeTheme"
local CurrentThemeName = "HomeTheme"

local Themes = {
	AirSiren = {
		SoundId = "rbxassetid://9113073742",
		Volume = 0.5,
	},
	Alarm = {
		SoundId = "rbxassetid://7084812679",
		Volume = 0.3,
	},
	AngelTheme = {
		SoundId = "rbxassetid://1846115874",
		Volume = 0.1,
	},
	ArmyTheme = {
		SoundId = "rbxassetid://1840899338",
		Volume = 0.1,
	},
	BosniaTheme = {
		SoundId = "rbxassetid://1845030010",
		Volume = 0.1,
	},
	Breathing = {
		SoundId = "rbxassetid://180315285",
		Volume = 0.3,
	},
	Vader = {
		SoundId = "rbxassetid://105233980391021",
		Volume = 0.3,
	},
	Calm = {
		SoundId = "rbxassetid://1848354536",
		Volume = 0.1,
	},
	CashierTheme = {
		SoundId = "rbxassetid://15689439732",
		Volume = 0.2,
	},
	Chill = {
		SoundId = "rbxassetid://96514160496746",
		Volume = 0.1,
	},
	Comedy = {
		SoundId = "rbxassetid://1847418399",
		Volume = 0.1,
	},
	CoolTheme = {
		SoundId = "rbxassetid://1840684529",
		Volume = 0.1,
	},
	EatingTheme = {
		SoundId = "rbxassetid://72827859819212",
		Volume = 0.3,
	},
	Gloomy = {
		SoundId = "rbxassetid://1843617641",
		Volume = 0.3,
	},
	GuestTheme = {
		SoundId = "rbxassetid://9048376021",
		Volume = 0.1,
	},
	HighStakes = {
		SoundId = "rbxassetid://9039721351",
		Volume = 0.2,
	},
	HomelessTheme = {
		SoundId = "rbxassetid://9043211293",
		Volume = 0.1,
	},
	Intense = {
		SoundId = "rbxassetid://1842940253",
		Volume = 0.1,
	},
	Maccies = {
		SoundId = "rbxassetid://125225899259441",
		Volume = 0.5,
	},
	Main = {
		SoundId = MainSounds[math.random(1, #MainSounds)],
		Volume = 0.1,
	},
	ManCry = {
		SoundId = "rbxassetid://688596285",
		Volume = 0.5,
	},
	McDonaldTheme = {
		SoundId = "rbxassetid://99774300113395",
		Volume = 0.3,
	},
	OldTheme = {
		SoundId = "rbxassetid://1839336128",
		Volume = 0.05,
	},
	PoliceCaught = {
		SoundId = "rbxassetid://1405324865",
		Volume = 0.1,
	},
	PoshTheme = {
		SoundId = "rbxassetid://1837460580",
		Volume = 0.1,
	},
	Prestigious = {
		SoundId = "rbxassetid://9045352704",
		Volume = 0.1,
	},
	PrisonTheme = {
		SoundId = "rbxassetid://9112848659",
		Volume = 0.5,
	},
	RoadmanTune = {
		SoundId = "rbxassetid://86276342994615",
		Volume = 0.5,
	},
	SadTheme = {
		SoundId = "rbxassetid://1838635121",
		Volume = 0.05,
	},
	Saloon = {
		SoundId = "rbxassetid://1835519330",
		Volume = 0.5,
	},
	Scary = {
		SoundId = "rbxassetid://130567774352763",
		Volume = 0.1,
	},
	ScaryAmbience = {
		SoundId = "rbxassetid://9119386571",
		Volume = 0.1,
	},
	SchizoTheme = {
		SoundId = "rbxassetid://1838827997",
		Volume = 0.3,
	},
	StoreBackground = {
		SoundId = "rbxassetid://9112787259",
		Volume = 0.3,
	},
	StreetAmbience = {
		SoundId = "rbxassetid://6669610130",
		Volume = 0.1,
	},
	SuspiciousTheme = {
		SoundId = "rbxassetid://1838969178",
		Volume = 0.3,
	},
	Toilet = {
		SoundId = "rbxassetid://129102729060609",
		Volume = 0.1,
	},
	Mysterious = {
		SoundId = "rbxassetid://1838974004",
		Volume = 0.1,
	},
	PumpkinBossTheme = {
		SoundId = "rbxassetid://98069162367799",
		Volume = 0.4,
	},
	TimeTheme = {
		SoundId = "rbxassetid://1835350683",
		Volume = 1,
	},
	Running = {
		SoundId = "rbxassetid://79250663775359",
		Volume = 1,
	},
	Aerobics = {
		SoundId = "rbxassetid://108835432226455",
		Volume = 0.1,
	},
	VietnamSong = {
		SoundId = "rbxassetid://107478221402452",
		Volume = 0.1,
	},
	Creepy = {
		SoundId = "rbxassetid://1843700415",
		Volume = 0.1,
	},
	SpineSong = {
		SoundId = "rbxassetid://106675975785347",
		Volume = 0.1,
		PlaybackRegionsEnabled = true,
		PlaybackRegion = NumberRange.new(60, 60000),
	},
	SupermarketTheme = {
		SoundId = "rbxassetid://1841212678",
		Volume = 0.3,
	},
	SneakyTheme = {
		SoundId = "rbxassetid://9045117303",
		Volume = 0.1,
	},
	CreepyNightTheme = {
		SoundId = "rbxassetid://1846999567",
		Volume = 0.5,
	},
	WindAmbience = {
		SoundId = "rbxassetid://5799870105",
		Volume = 0.5,
	},
	HomeTheme = {
		SoundId = "rbxassetid://105416600746220",
		Volume = 0.5,
	},
	KawaiiTheme = {
		SoundId = "rbxassetid://130431219868919",
		Volume = 0.2,
	},
	WorkRoomTheme = {
		SoundId = "rbxassetid://9043114637",
		Volume = 0.1,
	},
	CyberNoir = {
		SoundId = "rbxassetid://19005873599",
		Volume = 0.2,
	},
	GuestRoomTheme = {
		SoundId = "rbxassetid://1837768333",
		Volume = 0.2,
	},
	OldTimerTheme = {
		SoundId = "rbxassetid://9043033868",
		Volume = 0.2,
	},
	HappyTheme = {
		SoundId = "rbxassetid://1845756489",
		Volume = 0.05,
	},
	Eerie = {
		SoundId = "rbxassetid://9112775414",
		Volume = 0.5,
	},
}
local OneShots = {
	Anvil = {
		SoundId = "rbxassetid://8899349982",
		Volume = 0.5,
	},
	Baa = {
		SoundId = "rbxassetid://855133159",
		Volume = 0.5,
	},
	LongBurp = {
		SoundId = "rbxassetid://83871962012333",
		Volume = 10,
	},
	BananaSlip = {
		SoundId = "rbxassetid://129432532096499",
		Volume = 0.5,
	},
	BlocklandBan = {
		SoundId = "rbxassetid://4988109918",
		Volume = 0.5,
	},
	BloodSpurt = {
		SoundId = "rbxassetid://9113464462",
		Volume = 0.5,
	},
	BoneSnap = {
		SoundId = "rbxassetid://9994997529",
		Volume = 0.5,
	},
	Bruh = {
		SoundId = "rbxassetid://102132939108968",
		Volume = 0.5,
	},
	CPUError = {
		SoundId = "rbxassetid://2626561747",
		Volume = 0.5,
	},
	CartoonRun = {
		SoundId = "rbxassetid://132581469184781",
		Volume = 0.5,
	},
	CashRegister = {
		SoundId = "rbxassetid://131886985",
		Volume = 0.5,
	},
	CashierCustomerTroll = {
		SoundId = "rbxassetid://100073173804575",
		Volume = 0.3,
	},
	CashierManager = {
		SoundId = "rbxassetid://120672250052315",
		Volume = 0.5,
	},
	Chomp = {
		SoundId = "rbxassetid://430285057",
		Volume = 0.5,
	},
	Contactless = {
		SoundId = "rbxassetid://17525579508",
		Volume = 0.3,
	},
	Correct = {
		SoundId = "rbxassetid://100754383843032",
		Volume = 0.5,
	},
	Correct2 = {
		SoundId = "rbxassetid://3422389728",
		Volume = 0.5,
	},
	Cough = {
		SoundId = "rbxassetid://72861611511867",
		Volume = 0.5,
	},
	ElectricExplosion = {
		SoundId = "rbxassetid://91191741418347",
		Volume = 0.5,
	},
	Error = {
		SoundId = "rbxassetid://3779045779",
		Volume = 0.5,
	},
	EvilLaugh = {
		SoundId = "rbxassetid://2958525572",
		Volume = 0.5,
		Chorus = {
			Depth = 1,
			Mix = 0.5,
			Rate = 0.5,
		},
	},
	FBI = {
		SoundId = "rbxassetid://3302969109",
		Volume = 0.5,
		Pitch = {
			Octave = 2,
		},
	},
	LongFart = {
		SoundId = "rbxassetid://73860369392765",
		Volume = 10,
	},
	FailTrombone = {
		SoundId = "rbxassetid://190705984",
		Volume = 0.5,
	},
	GlassBreak = {
		SoundId = "rbxassetid://6737582037",
		Volume = 0.5,
	},
	Jackpot = {
		SoundId = "rbxassetid://90589517168414",
		Volume = 0.5,
	},
	Jumpscare = {
		SoundId = "rbxassetid://85271883712040",
		Volume = 10,
	},
	Keypad = {
		SoundId = "rbxassetid://18452359732",
		Volume = 0.5,
	},
	Knock = {
		SoundId = "rbxassetid://5236308259",
		Volume = 0.5,
	},
	Land = {
		SoundId = "rbxassetid://268933841",
		Volume = 0.5,
	},
	Laugh = {
		SoundId = "rbxassetid://2397128106",
		Volume = 0.5,
	},
	Lever = {
		SoundId = "rbxassetid://9125626281",
		Volume = 0.5,
	},
	License = {
		SoundId = "rbxassetid://85107675554155",
		Volume = 0.5,
	},
	LightningBolt = {
		SoundId = "rbxassetid://97298035203612",
		Volume = 0.5,
	},
	Llanfair = {
		SoundId = "rbxassetid://134317370490922",
		Volume = 1,
	},
	MetalPipe = {
		SoundId = "rbxassetid://6729922069",
		Volume = 0.5,
		PlaybackRegionsEnabled = true,
		PlaybackRegion = NumberRange.new(0, 0.5),
	},
	NewMission = {
		SoundId = "rbxassetid://76029655852111",
		Volume = 1,
		Tag = "Unstoppable",
	},
	Nuke = {
		SoundId = "rbxassetid://123108046559579",
		Volume = 0.5,
	},
	OldButton = {
		SoundId = "rbxasset://sounds/button.wav",
		Volume = 0.5,
	},
	OldSplat = {
		SoundId = "rbxasset://sounds/splat.wav",
		Volume = 0.5,
	},
	OpenDoor = {
		SoundId = "rbxassetid://157167203",
		Volume = 0.5,
	},
	PCPowerOn = {
		SoundId = "rbxassetid://9117868197",
		Volume = 0.5,
		PlaybackRegionsEnabled = true,
		PlaybackRegion = NumberRange.new(0, 7),
	},
	Ping = {
		SoundId = "rbxassetid://18261237568",
		Volume = 0.5,
	},
	PsychoMantisTruthDialogue1 = {
		SoundId = "rbxassetid://70929665931711",
		Volume = 0.5,
	},
	PsychoMantisTruthDialogue2 = {
		SoundId = "rbxassetid://135746871233578",
		Volume = 0.5,
	},
	PsychoMantisWinEnd = {
		SoundId = "rbxassetid://82875471334124",
		Volume = 0.5,
	},
	RadioBeep = {
		SoundId = "rbxassetid://2734269544",
		Volume = 0.5,
	},
	RebelsOverLads = {
		SoundId = "rbxassetid://6131440436",
		Volume = 0.5,
		Pitch = {
			Octave = 2,
		},
	},
	RevolverEmpty = {
		SoundId = "rbxassetid://116664883827057",
		Volume = 0.5,
	},
	RevolverShot = {
		SoundId = "rbxassetid://1583819337",
		Volume = 0.5,
		PlaybackRegionsEnabled = true,
		PlaybackRegion = NumberRange.new(0, 0.5),
	},
	Rustle = {
		SoundId = "rbxassetid://8437199163",
		Volume = 0.5,
	},
	SlotWin = {
		SoundId = "rbxassetid://119452123812313",
		Volume = 0.5,
	},
	SoGood = {
		SoundId = "rbxassetid://114087931134204",
		Volume = 0.5,
	},
	Static = {
		SoundId = "rbxassetid://6351509719",
		Volume = 0.5,
	},

	Surprise = {
		SoundId = "rbxassetid://7111749816",
		Volume = 0.5,
	},

	TypeSound = {
		SoundId = "rbxassetid://9116156872",
		Volume = 0.5,
	},

	WhatDogDoin = {
		SoundId = "rbxassetid://7147641250",
		Volume = 0.5,
	},
	Wrong = {
		SoundId = "rbxassetid://5521959695",
		Volume = 0.5,
	},
	GirlGreeting = {
		SoundId = "rbxassetid://110461437455800",
		Volume = 1,
	},
	PumpkinBossLaugh = {
		SoundId = "rbxassetid://4810729995",
		Volume = 0.5,
	},
	CupcakeLoverGossip = {
		SoundId = "rbxassetid://117576879768339",
		Volume = 0.5,
	},
	Oi = {
		SoundId = "rbxassetid://109660701821480",
		Volume = 10,
		PlaybackRegion = NumberRange.new(0.25, 1.503),
	},
	RecordScratch = {
		SoundId = "rbxassetid://78519387192089",
		Volume = 10,
	},
	Namaste = {
		SoundId = "rbxassetid://90892943099699",
		Volume = 1,
	},
	BlanketPull = {
		SoundId = "rbxassetid://9117373365",
		Volume = 0.5,
	},
	Confused = {
		SoundId = "rbxassetid://154157416",
		Volume = 0.5,
	},
	MetalSnap = {
		SoundId = "rbxassetid://9113764330",
		Volume = 0.5,
		PlaybackRegion = NumberRange.new(0, 0.7),
	},
	Dig = {
		SoundId = "rbxassetid://180163752",
		Volume = 0.5,
	},
	Electrocution = {
		SoundId = "rbxassetid://139635783652659",
		Volume = 10,
	},
	PaperScrunch = {
		SoundId = "rbxassetid://9117204119",
		Volume = 1,
	},
	CloseElevator = {
		SoundId = "rbxassetid://2506816593",
		Volume = 0.5,
	},
	MoveElevator = {
		SoundId = "rbxassetid://2560232460",
		Volume = 0.5,
	},
	GateRip = {
		SoundId = "rbxassetid://9116630729",
		Volume = 5,
	},
	Spotted = {
		SoundId = "rbxassetid://2386822675",
		Volume = 0.5,
		PlaybackRegion = NumberRange.new(0, 0.7),
	},
	CarCrash = {
		SoundId = "rbxassetid://7340406550",
		Volume = 5,
	},
	GoodMorningVietnam = {
		SoundId = "rbxassetid://8295016126",
		Volume = 5,
	},
	VietcongVoiceline = {
		SoundId = "rbxassetid://9120429951",
		Volume = 10,
	},
	Censor = {
		SoundId = "rbxassetid://3106518815",
		Volume = 1,
	},
	NeckSnap = {
		SoundId = "rbxassetid://198606040",
		Volume = 10,
	},
	Punch = {
		SoundId = "rbxassetid://8595980577",
		Volume = 5,
	},
	Scream = {
		SoundId = "rbxassetid://9043346124",
		Volume = 5,
	},
	Oof = {
		SoundId = "rbxassetid://79348298352567",
		Volume = 0.5,
	},
	Yay = {
		SoundId = "rbxassetid://8304443672",
		Volume = 0.5,
	},
	ScaryRiser = {
		SoundId = "rbxassetid://9040554805",
		Volume = 1,
	},
	ForKingAndCountry = {
		SoundId = "rbxassetid://113115964475039",
		Volume = 1,
	},
	BattleCry = {
		SoundId = "rbxassetid://5291644593",
		Volume = 3,
	},
	Parry = {
		SoundId = "rbxassetid://75099255490892",
		Volume = 1,
	},
	Pop = {
		SoundId = "rbxassetid://1289263994",
		Volume = 1,
	},
	CameraFlash = {
		SoundId = "rbxassetid://131275645840932",
		Volume = 1,
	},
	HorrorSting = {
		SoundId = "rbxassetid://1014740409",
		Volume = 3,
	},
}
local SoundHandler = {}

function SoundHandler.StopTheme()
	if ThemeLocked then
		print(`Cannot stop theme, its locked`)
		return
	end
	if CurrentTheme and CurrentTheme.IsPlaying then
		print(`Stopped CurrentTheme`)

		CurrentTheme:Stop()
	end
end
function SoundHandler.StopSound(soundName)
	print(`Stopping {soundName}`)
	if soundName then
		SoundLocation:FindFirstChild(soundName):Stop()
		soundName = nil
	else
		warn("No sound to stop, it's nil")
	end
end
function SoundHandler.UnlockTheme()
	if ThemeLocked then
		print("Theme unlocked!")
		ThemeLocked = false
	end
end
function SoundHandler.StopAllSounds()
	print("Stopping all sounds...")
	SoundHandler.StopTheme()
	local sounds = SoundLocation:GetChildren()
	for _, sound in pairs(sounds) do
		if sound:IsA("Sound") and sound.IsPlaying then
			if CollectionService:HasTag(sound, "Unstoppable") then
				continue
			end
			print(`Stopped {sound.Name}`)
			sound:Stop()
		end
	end

	return true
end

function SoundHandler.PlayTheme(name, lockTheme)
	if ThemeLocked then
		return
	end
	if lockTheme then
		print(`{name} theme locked`)
		ThemeLocked = true
	end
	-- save playback position to emulate pausing
	-- we have only 1 sound instance hence why normal pausing wont work when we switch sounds thru this
	Themes[CurrentThemeName].LastPlaybackPosition = CurrentTheme.TimePosition
	SoundHandler.StopTheme()
	CurrentTheme.PlaybackSpeed = 1

	if Themes[name] then
		local themeData = Themes[name]

		-- basic setters
		CurrentTheme.SoundId = themeData.SoundId
		CurrentTheme.Volume = themeData.Volume

		-- recover sound time position if we have one (resume)
		if themeData.LastPlaybackPosition then
			CurrentTheme.TimePosition = themeData.LastPlaybackPosition
		end

		-- playback region
		if themeData.PlaybackRegionsEnabled and themeData.PlaybackRegion then
			CurrentTheme.PlaybackRegionsEnabled = themeData.PlaybackRegionsEnabled
			CurrentTheme.PlaybackRegion = themeData.PlaybackRegion
		end

		CurrentTheme:Play()
		CurrentThemeName = name

		print(`Theme set {name}, should play`)
	else
		print("Theme not found")
	end
end

function SoundHandler.PlayPreviousTheme()
	if ThemeLocked then
		return
	end
	SoundHandler.StopTheme()
	CurrentTheme.PlaybackSpeed = 1

	SoundHandler.PlayTheme(PreviousThemeName)
end

function SoundHandler.PauseTheme()
	if CurrentTheme then
		if CurrentTheme.IsPlaying then
			CurrentTheme:Pause()
			if PreviousThemeName ~= CurrentThemeName then
				PreviousThemeName = CurrentThemeName
			end
		else
			print("Theme cannot be found to be paused")
		end
	end
end

function SoundHandler.ResumeTheme()
	if CurrentTheme then
		if not CurrentTheme.IsPlaying then
			CurrentTheme:Resume()
		end
	end
end

function SoundHandler.PlaySound(soundName, parent, waitUntilDone)
	print(`Playing {soundName}`)

	-- if the sound currently exists, just reuse it instead of a new sound instance.
	local exists = SoundService:FindFirstChild(soundName)

	if exists then
		exists.TimePosition = 0
		return
	end

	-- new instance of sound in SoundService
	if OneShots[soundName] then
		local soundData = OneShots[soundName]
		local sound = Instance.new("Sound")

		-- set basic data
		sound.SoundId = soundData.SoundId
		sound.Volume = soundData.Volume
		sound.Name = soundName

		-- playback regions
		if soundData.PlaybackRegionsEnabled and soundData.PlaybackRegion then
			sound.PlaybackRegionsEnabled = soundData.PlaybackRegionsEnabled
			sound.PlaybackRegion = soundData.PlaybackRegion
		end
		-- pitch child object
		if soundData.Pitch then
			local soundPitchShifter = Instance.new("PitchShiftSoundEffect")
			soundPitchShifter.Octave = soundData.Pitch.Octave
			soundPitchShifter.Parent = sound
		end
		-- chorus child object
		if soundData.Chorus then
			local chorusObject = Instance.new("ChorusSoundEffect")
			chorusObject.Depth = soundData.Chorus.Depth
			chorusObject.Mix = soundData.Chorus.Mix
			chorusObject.Rate = soundData.Chorus.Rate
			chorusObject.Parent = sound
		end

		-- tag
		if soundData.Tag then
			CollectionService:AddTag(sound, soundData.Tag)
		end

		-- auto destroy after finished playing
		if parent then
			sound.Parent = parent
		else
			sound.Parent = SoundService
		end

		sound:Play()
		print(`{soundName} should play`)

		sound.Ended:Connect(function()
			GeneralRemotes.SoundEnded:FireServer(soundName)
			sound:Destroy()
		end)

		if waitUntilDone then
			sound.Ended:Wait()
		end

		return sound
	else
		warn(`Failed to play {soundName}.`)
		return nil
	end
end

function SoundHandler.ChangeThemePlaybackSpeed(val)
	if CurrentTheme then
		CurrentTheme.PlaybackSpeed = val
	end
end

return SoundHandler
