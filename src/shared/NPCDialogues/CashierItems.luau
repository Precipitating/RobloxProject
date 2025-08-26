local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShopBasketModule = require(ReplicatedStorage.Shared.NPCs.Cashier.ShopBasketModule)

local function AddUpItemsDialogue()
	local items = ShopBasketModule.GetItemsInBasket()
	local text = "Let's see what we have here:<br/>"

	for itemName, info in pairs(items) do
		text ..= `{tostring(info.Quantity)} {itemName} priced at £{string.format("%.2f", info.Price)} each, equalling £{string.format(
			"%.2f",
			info.Quantity * info.Price
		)}<br/>`
	end

	return text
end

local function GetFakeTotalDialogue()
	local items = ShopBasketModule.GetItemsInBasket()
	local total: number = 0

	for _, info in pairs(items) do
		total += info.Price * info.Quantity
	end

	local text = `The total is: £{string.format("%.2f", total * 2)} apparently.`
	return text
end

return {

	Nodes = {
		CashierItems = {
			Name = "Shayden",
			Portrait = "rbxassetid://10418960920",
			Dialogue = "I see you have items in the basket.",
			VoiceId = 6,
			Pitch = 12,
			Speed = 1,
			Volume = 1,
			PlayTheme = "StoreBackground",
			Responses = {
				{
					Text = "Scan it then...",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Hold on, missing something.",
					Type = "Close",
				},
			},
		},

		One = {
			Name = "Shayden",
			Portrait = "rbxassetid://10418960920",
			Dialogue = AddUpItemsDialogue,
			Responses = {
				{
					Text = "Just give me the total...",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "Hold on, missing something.",
					Type = "Close",
				},
			},
		},

		Two = {
			Name = "Shayden",
			Portrait = "rbxassetid://12830317928",
			Dialogue = "The system is lagging today, wait...",
			Responses = {
				{
					Text = "...It's simple math.<b>sir</b>",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "...",
					Type = "NextMessage",
					NextId = "Three",
				},
			},
		},

		Three = {
			Name = "Shayden",
			Portrait = "rbxassetid://785538449",
			Dialogue = "..................................",
			PlaySound = "CPUError",
			Responses = {
				{
					Text = "...",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "...",
					Type = "NextMessage",
					NextId = "Four",
				},
			},
		},

		Four = {
			Name = "Shayden",
			Portrait = "rbxassetid://14875151473",
			Dialogue = ".......................................",
			PlaySound = "CPUError",
			Responses = {
				{
					Text = ".............",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = ".............",
					Type = "NextMessage",
					NextId = "Five",
				},
			},
		},

		Five = {
			Name = "Shayden",
			Portrait = "rbxassetid://18396655493",
			Dialogue = "..............................",
			PlaySound = "Cough",
			Responses = {
				{
					Text = ".............",
					Type = "NextMessage",
					NextId = "Six",
				},
				{
					Text = ".............",
					Type = "NextMessage",
					NextId = "Six",
				},
			},
		},

		Six = {
			Name = "Shayden",
			Portrait = "rbxassetid://2678352699",
			Dialogue = ".......",
			PlaySound = "Keypad",
			Responses = {
				{
					Text = "How much?",
					Type = "NextMessage",
					NextId = "Seven",
				},
				{
					Text = "...Done?",
					Type = "NextMessage",
					NextId = "Seven",
				},
			},
		},

		Seven = {
			Name = "Shayden",
			Portrait = "rbxassetid://2678352699",
			Dialogue = GetFakeTotalDialogue,
			Responses = {
				{
					Text = "You're joking right?<br/>Thats like DOUBLE!",
					Type = "NextMessage",
					NextId = "FakePrice",
				},
				{
					Text = "Whatever, here you go.<br/>You're taking ages...",
					Type = "NextMessage",
					NextId = "Scammed",
				},
			},
		},

		FakePrice = {
			Name = "Shayden",
			Portrait = "rbxassetid://9181273951",
			Dialogue = "You no like?<br/>YOU NO BUY!",
			Responses = {
				{
					Text = "Yeah i'm paying £0.<br/> Thanks & bye",
					Type = "Close",
					ExecuteScenarioEvent = "CashierShopLift",
				},
				{
					Text = "Yeah not buying this BYE!",
					Type = "Close",
				},
			},
		},

		Scammed = {
			Name = "Shayden",
			Portrait = "rbxassetid://5842977421",
			Dialogue = "Thank you for shopping at <b>Rebelism Essentials</b>",
			Responses = {
				{
					Text = "(Why does he have a smug face? )",
					Type = "Close",
					ExecuteScenarioEvent = "CashierScammed",
				},
				{
					Text = "...Sure.",
					Type = "Close",
					ExecuteScenarioEvent = "CashierScammed",
				},
			},
		},
	},
}
