local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local DefaultWalk = "http://www.roblox.com/asset/?id=180426354"
local DefaultRun = "run.xml"
local DefaultIdle1 = "http://www.roblox.com/asset/?id=180435571"
local DefaultIdle2 = "http://www.roblox.com/asset/?id=180435792"
local HoldingRealTV = false
local GeneralRemotes = ReplicatedStorage.Remotes
local SodaCanDebounces = {}

local TVRoomInitialize = {}

local function SetAnimationToSneak(player)
	local animate = player.Character:WaitForChild("Animate")
	animate.walk.WalkAnim.AnimationId = "rbxassetid://76046570745035"
	animate.run.RunAnim.AnimationId = "rbxassetid://76046570745035"
	animate.idle.Animation1.AnimationId = "rbxassetid://138692685863658"
	animate.idle.Animation2.AnimationId = "rbxassetid://138692685863658"

	local character = player.Character
	character.Humanoid.WalkSpeed = 5
	character["Left Arm"].CanCollide = true
	character["Right Arm"].CanCollide = true
end

function ConnectDevices(source, target)
	local wire = Instance.new("Wire")
	wire.Parent = source
	wire.SourceInstance = source
	wire.TargetInstance = target
end

local function SetupSoundEmitters(can)
	-- setup audio to play
	local audioPlayer = Instance.new("AudioPlayer")
	audioPlayer.AssetId = "rbxassetid://76179557738638"
	audioPlayer.Parent = can

	-- setup where it will emit from
	local emitter = Instance.new("AudioEmitter")
	emitter.Parent = can

	-- wire them together
	ConnectDevices(audioPlayer, emitter)

	return audioPlayer
end

local function SetupResidentListener()
	-- setup listener
	local listenPart = workspace:FindFirstChild("TVHome"):FindFirstChild("Listener")
	local listener = Instance.new("AudioListener")
	listener.Parent = listenPart
	local deviceOutput = Instance.new("AudioDeviceOutput")
	deviceOutput.Parent = listenPart
	ConnectDevices(listener, deviceOutput)

	-- analyzer
	local analyzer = Instance.new("AudioAnalyzer")
	analyzer.Parent = listenPart
	ConnectDevices(listener, analyzer)

	task.spawn(function()
		while true do
			if analyzer.RmsLevel > 0.1 then
				print("Lil bro heard something")
			end
			task.wait()
		end
	end)
end

function TVRoomInitialize.IsHoldingRealTV()
	return HoldingRealTV
end
function TVRoomInitialize.GrabRealTV(player)
	-- attach tv to player's back
	local realTV = workspace:FindFirstChild("TVHome"):FindFirstChild("RealTV", true)
	realTV.Anchored = false
	realTV:PivotTo(
		player.Character:WaitForChild("Torso"):WaitForChild("BodyBackAttachment").WorldCFrame
			* CFrame.Angles(0, math.rad(-90), 0)
			* CFrame.new(0.7, 0, 0)
	)
	local weld = Instance.new("WeldConstraint")
	weld.Name = "TvWeld"
	weld.Parent = realTV
	weld.Part0 = realTV
	weld.Part1 = player.Character:WaitForChild("Torso")

	HoldingRealTV = true
end

local function ConnectCanTraps(player)
	local cans = ServerHelperFunctions.GetTaggedOfDirectory(workspace, "TVHomeCan")

	if #cans <= 0 then
		error("No can traps detected")
	end
	SetupResidentListener()

	for _, can: Part in ipairs(cans) do
		can:SetNetworkOwner(player)
		local audioPlayer = SetupSoundEmitters(can)

		can.Touched:Connect(function(hit)
			if SodaCanDebounces[can] then
				return
			end
			local hitPlayer = game.Players:GetPlayerFromCharacter(hit:FindFirstAncestorOfClass("Model"))
			if not hitPlayer then
				if not CollectionService:HasTag(hit, "RealTV") then
					return
				end
			end

			print(hit.Name)
			SodaCanDebounces[can] = true
			local canVel = can.AssemblyLinearVelocity
			if canVel.Magnitude > 0 then
				print(`Can moved`)
				audioPlayer:Play()

				-- stop velocity so it doesnt keep calling again and again
				local targetMag = 0.01
				local dir = can.AssemblyLinearVelocity.Unit
				if canVel.Magnitude > 0.1 then
					can.AssemblyAngularVelocity = dir * targetMag
				end
				GeneralRemotes.TVHome.HitCan:FireClient(player, 0.2)
			else
				print("Touch detected but can didn’t move")
			end
			task.delay(2, function()
				SodaCanDebounces[can] = false
			end)
		end)
	end
end

function TVRoomInitialize.Initialize(player)
	SetAnimationToSneak(player)
	ConnectCanTraps(player)
end

function TVRoomInitialize.Exit(player)
	table.clear(SodaCanDebounces)
	local animate = player.Character:WaitForChild("Animate")
	animate.walk.WalkAnim.AnimationId = DefaultWalk
	animate.run.RunAnim.AnimationId = DefaultRun
	animate.idle.Animation1.AnimationId = DefaultIdle1
	animate.idle.Animation2.AnimationId = DefaultIdle2

	local character = player.Character
	character.Humanoid.WalkSpeed = 25
	character["Left Arm"].CanCollide = false
	character["Right Arm"].CanCollide = false
end

return TVRoomInitialize
