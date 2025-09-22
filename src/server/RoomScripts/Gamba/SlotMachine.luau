local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local CurrencyHandler = require(ServerScriptService.Server.CurrencyHandler)
local GeneralRemotes = ReplicatedStorage.Remotes
local SlotMachine = {}
local ActiveMachines = {}

function SlotMachine.MakeCombo(state, icons)
	state.C.Slot1 = icons[math.random(#icons)]
	state.C.Slot2 = icons[math.random(#icons)]
	state.C.Slot3 = icons[math.random(#icons)]
end

function SlotMachine.UpdateBet(state)
	local bet, betInt, minBet, maxBet, moneySymbol =
		state.Bet, state.BetIntervals, state.MinimumBet, state.MaximumBet, state.MoneySymbol
	local SpinProx, UpProx, DownProx = state.SpinProx, state.UpProx, state.DownProx

	SpinProx.ActionText = "Bet: " .. moneySymbol .. bet
	if bet + betInt > maxBet then
		UpProx.ActionText = "MAX"
	else
		UpProx.ActionText = "+" .. moneySymbol .. betInt
	end
	if bet - betInt < minBet then
		DownProx.ActionText = "MIN"
	else
		DownProx.ActionText = "-" .. moneySymbol .. betInt
	end
	if bet == 0 then
		SpinProx.ActionText = "Spin!"
	end
end
function SlotMachine.IncreaseBetPrompt(stateName)
	local state = ActiveMachines[stateName]
	if not state then
		warn("Slot machine not found!")
		return
	end

	if state.CanChangeBet then
		if state.OnCooldown then
			return
		end
		if state.Bet + state.BetIntervals >= state.MaximumBet then
			state.Bet = state.MaximumBet
		else
			state.Bet += state.BetIntervals
		end
		SlotMachine.UpdateBet(state)
		print("Increased bet")
	else
		state.UpProx.Enabled = false
		state.DownProx.Enabled = false
	end
end

function SlotMachine.DecreaseBetPrompt(stateName)
	local state = ActiveMachines[stateName]
	if not state then
		return
	end

	if state.CanChangeBet then
		if state.OnCooldown then
			return
		end
		if state.Bet - state.BetIntervals <= state.MinimumBet then
			state.Bet = state.MinimumBet
		else
			state.Bet -= state.BetIntervals
		end
		SlotMachine.UpdateBet(state)
		print("Decreased bet")
	else
		print("Can't reduce bet")
		state.UpProx.Enabled = false
		state.DownProx.Enabled = false
	end
end

function SlotMachine.SpinPrompt(player, stateName)
	local state = ActiveMachines[stateName]
	if SlotMachine.CanUseMachine(player, state) then
		SlotMachine.RunMachine(player, state)
		print("Spin machine")
	end
end

function SlotMachine.FindCombo(state, icons, superCombos, jackpotCombo, doubleMult, tripleMult)
	local C = state.C

	-- jackpot
	if
		C.Slot1.Name == jackpotCombo.Combo[1]
		and C.Slot2.Name == jackpotCombo.Combo[2]
		and C.Slot3.Name == jackpotCombo.Combo[3]
	then
		return { jackpotCombo.Prize, "JACKPOT" }
	end

	-- super combos
	for _, co in pairs(superCombos) do
		local success = false
		if co.HardCombo then
			if C.Slot1.Name == co.Combo[1] and C.Slot2.Name == co.Combo[2] and C.Slot3.Name == co.Combo[3] then
				success = true
			end
		else
			local arr = { C.Slot1.Name, C.Slot2.Name, C.Slot3.Name }
			table.sort(arr)
			local sortedCombo = { table.unpack(co.Combo) }
			table.sort(sortedCombo)
			if table.concat(arr) == table.concat(sortedCombo) then
				success = true
			end
		end
		if success then
			return { co.Prize, "Super" }
		end
	end

	-- doubles / triples
	local counts = {}
	for _, slot in pairs({ C.Slot1, C.Slot2, C.Slot3 }) do
		counts[slot.Name] = (counts[slot.Name] or 0) + 1
	end
	for _, icon in pairs(icons) do
		if counts[icon.Name] == 3 then
			return { icon.Value * tripleMult, "Triple" }
		elseif counts[icon.Name] == 2 then
			return { icon.Value * doubleMult, "Double" }
		end
	end
	return { 0, "None" }
end

function SlotMachine.CanUseMachine(player, state)
	local currentMoney = CurrencyHandler.GetMoney()

	if currentMoney >= state.Bet then
		CurrencyHandler.ReduceMoney(player, state.Bet)
		return true
	end
	print("Can't afford this bet!")
	return false
end

function SlotMachine.RunMachine(player, state)
	if state.OnCooldown then
		return
	end
	GeneralRemotes.PlaySound:InvokeClient(player, "Lever")
	state.OnCooldown = true

	state.SpinProx.Enabled = false
	state.UpProx.Enabled = false
	state.DownProx.Enabled = false

	if state.BetsAddToJackpot then
		state.TotalBetsCollected += state.Bet
	end

	SlotMachine.MakeCombo(state, state.Icons)
	local prize = SlotMachine.FindCombo(
		state,
		state.Icons,
		state.SuperCombos,
		state.SuperJackpotCombo,
		state.DoubleComboMult,
		state.TripleComboMult
	)

	if prize[1] > 0 then
		if prize[2] == "JACKPOT" then
			state.TotalBetsCollected = 0
		else
			prize[1] = state.Bet * prize[1]
		end

		CurrencyHandler.AddMoney(player, prize[1])
		GeneralRemotes.PlaySound:InvokeClient(player, "SlotWin")
	end

	state.Image1.Image = state.im .. state.C.Slot1.ImgID
	state.Image2.Image = state.im .. state.C.Slot2.ImgID
	state.Image3.Image = state.im .. state.C.Slot3.ImgID

	print("Prize: £" .. prize[1])
	task.wait(state.CooldownTime)
	state.OnCooldown = false
	state.SpinProx.Enabled = true
	if state.CanChangeBet then
		state.UpProx.Enabled = true
		state.DownProx.Enabled = true
	end
end

function SlotMachine.RemoveAll()
	table.clear(ActiveMachines)
end

--=== Init function ===--
function SlotMachine.Init(model)
	local state = {
		Model = model,
		CooldownTime = model:GetAttribute("CooldownTime") or 1.2,
		Bet = model:GetAttribute("Bet") or 25,
		BetIntervals = model:GetAttribute("BetIntervals") or 25,
		MinimumBet = model:GetAttribute("MinimumBet") or 25,
		MaximumBet = model:GetAttribute("MaximumBet") or 1000,
		BetsAddToJackpot = model:GetAttribute("BetsAddToJackpot") or false,
		CanChangeBet = model:GetAttribute("CanChangeBet") or false,
		DoubleComboMult = 1,
		TripleComboMult = 5,
		MachineTheftProtection = false,
		TheftProtectionLength = 10,
		StopMultiSlots = false,
		MultiSlotPreventionTime = 6,
		MoneySymbol = model:GetAttribute("CurrencySymbol") or "$",
		Icons = {
			{ Name = "BigWin", Value = 6, ImgID = 6975072324 },
			{ Name = "Seven", Value = 5, ImgID = 15875352210 },
			{ Name = "Pound", Value = 10, ImgID = 8562492127 },
			{ Name = "Bell", Value = 8, ImgID = 15875353729 },
			{ Name = "Horseshoe", Value = 6, ImgID = 15875353610 },
			{ Name = "Bar3", Value = 4, ImgID = 15875352641 },
			{ Name = "Bar2", Value = 3, ImgID = 15875352543 },
			{ Name = "Bar1", Value = 2, ImgID = 15875352432 },
			{ Name = "Diamond", Value = 1, ImgID = 15875353047 },
			{ Name = "Club", Value = 1, ImgID = 15875353216 },
			{ Name = "Spade", Value = 1, ImgID = 15875352858 },
			{ Name = "Heart", Value = 1, ImgID = 15875352758 },
		},
		SuperCombos = {
			{ Combo = { "Seven", "Seven", "Seven" }, Prize = 250, HardCombo = true },
			{ Combo = { "Pound", "Pound", "Pound" }, Prize = 125, HardCombo = true },
		},
		SuperJackpotCombo = {
			Combo = { "BigWin", "BigWin", "BigWin" },
			Prize = 500,
		},
		C = { Slot1 = "", Slot2 = "", Slot3 = "" },
		Slots = { model.Slot1, model.Slot2, model.Slot3 },
		im = "rbxassetid://",
		SpinProx = model.ActivationPart.SpinProx,
		UpProx = model.ActivationPart.UpProx,
		DownProx = model.ActivationPart.DownProx,
		Image1 = model.Slot1.Sur.Lab,
		Image2 = model.Slot2.Sur.Lab,
		Image3 = model.Slot3.Sur.Lab,
		OnCooldown = false,
		TotalBetsCollected = 0,
		Debris = game:GetService("Debris"),
	}
	ActiveMachines[model.Name] = state

	-- init visuals
	SlotMachine.MakeCombo(state, state.Icons)
	state.Image1.Image = state.im .. state.C.Slot1.ImgID
	state.Image2.Image = state.im .. state.C.Slot2.ImgID
	state.Image3.Image = state.im .. state.C.Slot3.ImgID
	SlotMachine.UpdateBet(state)
end

return SlotMachine
