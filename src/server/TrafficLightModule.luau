local TrafficLightModule = {}
function TrafficLightModule.StartTrafficLight(lightModel)
	local interval = lightModel:GetAttribute("interval") or 30

	local states = { "Green", "Yellow", "Red" }
	local onPeriod = interval * 0.5
	local stateLengths = {
		Green = onPeriod * 0.9,
		Yellow = onPeriod * 0.1,
		Red = interval - onPeriod,
	}

	local lights = {}
	local signage = {}
	local currentState
	local changeEvent = lightModel:FindFirstChild("LightChanged")

	-- Helper: get lights
	local function getLights()
		local results = {}
		local lightContainer = lightModel:FindFirstChild("Lights")
		if not lightContainer then
			return results
		end

		for _, light in ipairs(lightContainer:GetChildren()) do
			local stateName = light.Name
			results[stateName] = results[stateName] or {}
			table.insert(results[stateName], { obj = light, color = light.Color })
		end

		return results
	end

	-- Helper: get signage
	local function getSignage()
		local results = {}
		local signageContainer = lightModel:FindFirstChild("Signage")
		if not signageContainer then
			return results
		end

		for _, obj in ipairs(signageContainer:GetDescendants()) do
			if obj:IsA("TextLabel") then
				local container = obj.Parent.Parent
				results[container] = results[container] or {}
				results[container][obj.Name] = obj
			end
		end

		return results
	end

	-- Helpers reused from your code
	local function timeOffsetFromFacing(forward)
		local dot = forward:Dot(Vector3.new(0, 0, 1))
		if math.abs(dot) < 0.25 then
			return interval * 0.5
		end
		return 0
	end

	local function stateFromTime(globalTime, offset)
		local currentState
		local deltaTime = (globalTime + offset) % interval
		for _, name in pairs(states) do
			currentState = name
			deltaTime -= stateLengths[name]
			if deltaTime < 0 then
				break
			end
		end
		return currentState, deltaTime
	end

	local function updateLightColors(activeState, lightGroups)
		for state, lights in pairs(lightGroups) do
			local activeValue = (state == activeState) and 1 or 95 / 255
			for _, lightData in ipairs(lights) do
				local h, s = lightData.color:ToHSV()
				lightData.obj.Color = Color3.fromHSV(h, s, activeValue)
			end
		end
	end

	local function updateSignVisibility(globalTime, signage)
		for container, sign in pairs(signage) do
			local offset = timeOffsetFromFacing(container.CFrame.LookVector)
			local state = stateFromTime(globalTime, offset)
			local stop = state == "Red"
			sign.Stop.Visible = stop
			sign.Walk.Visible = not stop
		end
	end

	local function updateState(globalTime)
		local timeOffset = timeOffsetFromFacing(lightModel.PrimaryPart.CFrame.LookVector)
		local state, timeRemaining = stateFromTime(globalTime, timeOffset)
		updateLightColors(state, lights)

		if state ~= currentState then
			currentState = state
			if changeEvent then
				changeEvent:Fire(state)
			end
		end

		updateSignVisibility(globalTime, signage)
		return timeRemaining
	end

	-- Initialize
	lights = getLights()
	signage = getSignage()

	-- Run loop for this light
	task.spawn(function()
		while lightModel.Parent do
			local t = updateState(tick())
			task.wait(t)
		end
	end)
end

return TrafficLightModule
