local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local BadgeHandler = require(ServerScriptService.Server.BadgeHandler)
local ServerHelperFunctions = require(ServerScriptService.Server.ServerHelperFunctions)
local GeneralRemotes = ReplicatedStorage.Remotes
local BossRef = nil
local MapRef = nil
local BossHP = nil
local FireballPos = nil
local BuildingFolder = nil
local Lava = nil
local PlayerAttached = false
local InitiatingAttack = false
local FireballSpeed = 20
local SoulFetcherSpeed = 6
local SoulFetcherCount = 6
local FireballDamage = 20
local MinigunDamage = 55
local SoulFetchers = {}
local PlayerDead = false
local CanHurtPlayer = true
local DamagePlayerCooldown = 0.1
local GameFinished = false
local PrevPos = nil

local BossAttacks = nil

local PumpkinBossFight = {}

function PumpkinBossFight.Initialize(player)
	MapRef = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "CupcakeLover", "PumpkinMap", nil)
	Lava = MapRef:FindFirstChild("Lava")
	BossRef = MapRef:FindFirstChild("PumpkinBoss")
	BuildingFolder = MapRef:FindFirstChild("Building")
	PrevPos = player.Character:GetPivot()
	player.Character:PivotTo(MapRef:FindFirstChild("SpawnLoc").CFrame)
	PumpkinBossFight.LavaFunctionality(player)
	-- give minigun
	ServerHelperFunctions.GiveTool(player, { "Minigun", true })
	task.wait(3)
	PumpkinBossFight.BossInitialize(player)
end

function PumpkinBossFight.LavaFunctionality(player)
	local lavaConn
	lavaConn = Lava.Touched:Connect(function(hit)
		if not CanHurtPlayer then
			return
		end
		local name = hit.Name
		if name == "Left Leg" or name == "Right Leg" then
			PumpkinBossFight.BurnPart(hit)
			return
		end

		if name == "Torso" or name == "Head" then
			print("hit lava")
			GeneralRemotes.CupcakeLover.DamagePlayer:FireClient(player, 100)
			lavaConn:Disconnect()
			lavaConn = nil
		end
	end)
end

function PumpkinBossFight.BossInitialize(player)
	BossRef = MapRef:FindFirstChild("PumpkinBoss")
	-- tween pumpkin boss up to start
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear)
	local goal = { Position = BossRef.Position + vector.create(0, 33, 0) }
	local tween = TweenService:Create(BossRef, tweenInfo, goal)
	tween:Play()
	GeneralRemotes.PlaySound:InvokeClient(player, "PumpkinBossLaugh")
	-- set references
	BossHP = BossRef:FindFirstChild("Health")
	FireballPos = BossRef:FindFirstChild("FireballPos")

	BossAttacks = { PumpkinBossFight.LavaWave, PumpkinBossFight.SoulFetcher, PumpkinBossFight.Fireball }

	tween.Completed:Wait()

	-- start boss loop
	PumpkinBossFight.BossLoop(player)
end

function PumpkinBossFight.BossLoop(player)
	task.spawn(function()
		while BossHP.Value > 0 and not PlayerDead do
			if not InitiatingAttack then
				BossAttacks[math.random(1, #BossAttacks)](player)
			end
			task.wait(10)
		end
	end)
end

function PumpkinBossFight.BurnPart(part)
	task.spawn(function()
		part.Color = Color3.fromRGB(0, 0, 0)
		for i = 1, 10 do
			part.Transparency = i / 10
			task.wait(0.05)
		end

		part.Transparency = 0
		part:Destroy()
	end)
end
function PumpkinBossFight.Finished(player, bossDead)
	if bossDead then
		ServerHelperFunctions.SetNPCDialogueFile({ CupcakeLoverNameTag = "CupcakeLoverBossDefeat" })
		player.Character:PivotTo(PrevPos)
		MapRef:Destroy()
		GeneralRemotes.BlackFade:FireClient(player, 1, 1)
	else
		ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "CupcakeLover", "BossFailedPlayer", nil)
		player.Character:PivotTo(workspace:FindFirstChild("BlackRoom"):FindFirstChild("SpawnLoc").CFrame)
		MapRef:Destroy()
		PlayerDead = true
		GeneralRemotes.BlackFade:FireClient(player, 1, 1)
		task.wait(1)
		GeneralRemotes.PlayCutscene:FireClient(player, "CupcakeLoverBossFailed")
		BadgeHandler.awardBadge(player, 1699948559468830)
	end
	GameFinished = true
end

function PumpkinBossFight.LavaWave(_)
	if workspace:FindFirstChild("Wave") then
		return
	end
	InitiatingAttack = true

	-- boss jump
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
	local goal = { Position = BossRef.Position + vector.create(0, 30, 0) }
	local tween = TweenService:Create(BossRef, tweenInfo, goal)
	tween:Play()
	tween.Completed:Wait()
	tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
	goal = { Position = BossRef.Position + vector.create(0, -30, 0) }
	tween = TweenService:Create(BossRef, tweenInfo, goal)
	tween:Play()
	tween.Completed:Wait()

	local wave = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "CupcakeLover", "Wave", nil)
	local conn = nil
	conn = wave.Touched:Connect(function(hit)
		print("wave hit")
		local player = game.Players:GetPlayerFromCharacter(hit:FindFirstAncestorOfClass("Model"))
		if player and CanHurtPlayer then
			GeneralRemotes.CupcakeLover.DamagePlayer:FireClient(player, 100)
			conn:Disconnect()
			conn = nil
		elseif hit:IsA("BasePart") and hit:IsDescendantOf(BuildingFolder) then
			print("should destroy brticks")
			PumpkinBossFight.BurnPart(hit)
		end
	end)

	task.wait(5)
	wave:Destroy()

	InitiatingAttack = false
end

local function SoulFetcherMove(player, soulFetcher, grabbing, flipDir)
	-- move
	task.spawn(function()
		local directionTimer = 6
		local changeInterval = 6
		local randomDirection = vector.create(0, 0, 0)
		local dropDelayActivated = false

		while soulFetcher and not GameFinished do
			-- if grabbing player initiate drop countdown
			if grabbing and grabbing.Value and not dropDelayActivated then
				dropDelayActivated = true
				print("drop timer activated")
				task.delay(math.random(3, 10), function()
					local attachment = soulFetcher:FindFirstChild("AlignPosition")
					if attachment then
						attachment.Attachment0 = nil
					end
					if grabbing then
						grabbing.Value = false
						task.delay(1, function()
							PlayerAttached = false
						end)
					end
					dropDelayActivated = false
				end)
			else
				-- countdown until we change direction again
				directionTimer -= task.wait()
				if directionTimer <= 0 then
					-- either a random direction or towards player
					if math.random() < 0.6 then
						randomDirection = vector.normalize(
							vector.create(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1)
						)
						soulFetcher.CFrame = CFrame.lookAt(soulFetcher.Position, soulFetcher.Position + randomDirection)
					else
						soulFetcher.CFrame = CFrame.lookAt(soulFetcher.Position, player.Character:GetPivot().Position)
					end

					-- reset timer
					directionTimer = changeInterval
				end
			end

			if flipDir.Value then
				soulFetcher.CFrame *= CFrame.Angles(0, math.rad(180), 0)
				flipDir.Value = false
			end

			soulFetcher.AssemblyLinearVelocity = soulFetcher.CFrame.LookVector * SoulFetcherSpeed
		end
	end)
end
function PumpkinBossFight.SoulFetcher(player)
	InitiatingAttack = true
	TweenService:Create(BossRef, TweenInfo.new(1), { Transparency = 0.8 }):Play()
	task.wait(1)

	-- spawn 6 soul fetchers
	for _ = 1, SoulFetcherCount do
		local soulFetcher =
			ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "CupcakeLover", "SoulFetcher", nil)
		local uniqueId = HttpService:GenerateGUID()
		soulFetcher:SetAttribute("Id", uniqueId)
		SoulFetchers[uniqueId] = soulFetcher

		-- spawn offset so not all in one place
		local offset = vector.create(math.random(-7, 7), math.random(-7, 7), math.random(-7, 7))
		local newPos = BossRef:GetPivot().Position + offset
		local newCFrame = CFrame.new(newPos)

		local grabbing = soulFetcher:FindFirstChild("Grabbing")
		local flipDir = soulFetcher:FindFirstChild("FlipDir")
		soulFetcher:PivotTo(newCFrame)
		-- set initial fetcher direction to look up
		soulFetcher.CFrame = CFrame.new(soulFetcher.Position, soulFetcher.Position + vector.create(0, 1, 0))
		soulFetcher.Parent = MapRef

		soulFetcher.Touched:Connect(function(hit)
			local hitPlayer = game.Players:GetPlayerFromCharacter(hit:FindFirstAncestorOfClass("Model"))

			if hitPlayer and not PlayerAttached and not grabbing.Value then
				-- attach player to soul fetcher
				local root = player.Character:FindFirstChild("HumanoidRootPart")
				local attachment = soulFetcher:FindFirstChild("AlignPosition")

				if root and attachment then
					attachment.Attachment0 = root:FindFirstChild("RootAttachment")
					attachment.Attachment1 = soulFetcher:FindFirstChild("Attachment")
					PlayerAttached = true
					grabbing.Value = true
					GeneralRemotes.PlaySound:InvokeClient(player, "Namaste", soulFetcher)
				end
			end
			-- determines if touched wall, and flips opposite dir if so
			if CollectionService:HasTag(hit, "Boundary") then
				if flipDir then
					flipDir.Value = true
				end
			end
		end)

		SoulFetcherMove(player, soulFetcher, grabbing, flipDir)
	end
	TweenService:Create(BossRef, TweenInfo.new(1), { Transparency = 0 }):Play()
	InitiatingAttack = false
end

local function FireballExplosionHandler(fireball)
	local explosion = Instance.new("Explosion")
	explosion.Position = fireball.Position
	explosion.BlastRadius = 10
	explosion.BlastPressure = 250000
	explosion.DestroyJointRadiusPercent = 0
	explosion.Parent = workspace
	local explodeSignal
	explodeSignal = explosion.Hit:Connect(function(explodeHit)
		if CollectionService:HasTag(explodeHit, "SoulFetcher") then
			explodeHit.Anchored = true
			task.delay(1, function()
				explodeHit.Anchored = false
			end)
			return
		end
		local player = game.Players:GetPlayerFromCharacter(explodeHit:FindFirstAncestorOfClass("Model"))
		if player and CanHurtPlayer then
			CanHurtPlayer = false
			GeneralRemotes.CupcakeLover.DamagePlayer:FireClient(player, FireballDamage)
			print("EXPLOSION HIT PLAYER")
			explodeSignal:Disconnect()
			task.delay(DamagePlayerCooldown, function()
				CanHurtPlayer = true
			end)
		elseif explodeHit:IsA("BasePart") and explodeHit:IsDescendantOf(BuildingFolder) then
			if explodeHit.Anchored then
				explodeHit.Anchored = false
			end
			local hasWeld = explodeHit:FindFirstChildWhichIsA("WeldConstraint")
				or explodeHit:FindFirstChildWhichIsA("Weld")
			if hasWeld then
				hasWeld:Destroy()
			end
		end
	end)
end
function PumpkinBossFight.Fireball(player)
	InitiatingAttack = true
	-- spawn 3 fireballs
	for _ = 1, 3 do
		local fireball = ServerHelperFunctions.SpawnModelAtPosition("MissionModels", "CupcakeLover", "Fireball", nil)
		fireball:PivotTo(FireballPos.WorldCFrame)
		fireball.CFrame = CFrame.lookAt(fireball.Position, player.Character:GetPivot().Position)

		local sound = fireball:FindFirstChild("FireballSound")
		if sound then
			sound:Play()
		end

		fireball.Touched:Once(function(fireballTouch)
			if CollectionService:HasTag(fireballTouch, "SoulFetcher") then
				return
			end
			fireball:Destroy()
			FireballExplosionHandler(fireball)
			fireball = nil
		end)

		-- fireball move
		task.spawn(function()
			while fireball do
				fireball.AssemblyLinearVelocity = fireball.CFrame.LookVector * FireballSpeed
				task.wait()
			end
		end)

		task.wait(1)
	end

	InitiatingAttack = false
end

function PumpkinBossFight.ReduceHP(type, id)
	if BossHP.Value > 0 and type == "Boss" then
		BossHP.Value = BossHP.Value - MinigunDamage
	elseif type == "SoulFetcher" and id then
		SoulFetchers[id].Health.Value = SoulFetchers[id].Health.Value - MinigunDamage
		if SoulFetchers[id].Health.Value <= 0 then
			local attachment = SoulFetchers[id]:FindFirstChild("Grabbing")
			if attachment and attachment.Value then
				PlayerAttached = false
			end
			SoulFetchers[id]:Destroy()
			SoulFetchers[id] = nil
		end
	end
end

return PumpkinBossFight
