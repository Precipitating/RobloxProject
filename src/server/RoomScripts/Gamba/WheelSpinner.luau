local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local CurrencyHandler = require(ServerScriptService.Server.CurrencyHandler)
local Wheel = nil
local Prizes = { 10, 25, 10, 0, 100, 10, "double", 25, 0, 1000, "bankrupt", 50, 0 }
local numSlices = #Prizes
local AnglePerSlice = 360 / numSlices
local StartAngle = nil
local SpinConn = nil
local Cost = 50
local Active = false
local WheelSpinner = {}

local function Award(player, prize)
	if prize == "double" then
		CurrencyHandler.AddMoney(player, CurrencyHandler.GetMoney() * 2)
	elseif prize == "bankrupt" then
		CurrencyHandler.ReduceMoney(player, CurrencyHandler.GetMoney())
	else
		CurrencyHandler.AddMoney(player, prize)
	end
end

local function StartSpinning(player)
	local hinge = Wheel:FindFirstChild("SpinMotor"):FindFirstChild("HingeConstraint")
	local base = Wheel:FindFirstChild("Base")
	if not hinge or not base then
		error("Hinge/Base not found in wheel")
	end
	StartAngle = hinge.CurrentAngle
	Active = true
	hinge.ActuatorType = Enum.ActuatorType.Motor
	hinge.AngularVelocity = math.random(-20, -5)
	task.wait(math.random(1, 2))
	hinge.ActuatorType = Enum.ActuatorType.None

	SpinConn = RunService.Heartbeat:Connect(function(_)
		-- check for premature room exit while wheel spins and disconnect if so
		if not hinge or not hinge.Parent then
			SpinConn:Disconnect()
			Active = false
		end
		if base.RotVelocity.Magnitude < 0.05 then
			-- wheel stopped
			local angle = (hinge.CurrentAngle - StartAngle + 360) % 360
			local adjustedAngle = (angle + AnglePerSlice / 2) % 360
			local index = math.floor(adjustedAngle / AnglePerSlice) + 1
			index = math.clamp(index, 1, numSlices)
			print("Prize:", Prizes[index])
			print("Wheel fully stopped")
			Award(player, Prizes[index])
			Active = false
			SpinConn:Disconnect()
		end
	end)
end

function WheelSpinner.Start(player)
	if (CurrencyHandler.GetMoney() < Cost) or Active then
		print("Can't afford or still active!")
		return
	end

	Wheel = CollectionService:GetTagged("WheelSpinner")
	for _, model in Wheel do
		if model:IsDescendantOf(workspace) then
			Wheel = model
			break
		end
	end
	if not Wheel then
		error("Wheel ref failed to obtain")
	end
	StartSpinning(player)
end

function WheelSpinner.Finished() end
return WheelSpinner
