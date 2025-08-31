local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetGroceryListFromServer = ReplicatedStorage.Shared.Remotes.Cashier.GetGroceryItems

local function HasCorrectGrocery()
	print("Checking if correct groceries...")

	-- Combine Backpack and Character tools
	local containers = { Player.Backpack }
	if Player.Character then
		table.insert(containers, Player.Character)
	end

	for _, container in ipairs(containers) do
		for _, item in pairs(container:GetChildren()) do
			if item:IsA("Tool") and item.Name == "GroceryBag" then
				local currentGroceries = GetGroceryListFromServer:InvokeServer()
				if not currentGroceries or next(currentGroceries) == nil then
					warn("Current groceries is nil or empty")
					return false
				end

				local requiredQuantities = {
					RebelCola = 10,
					FrozenFood = 1,
					IceCream = 4,
					ToxicWaste = 1,
					Chocolate = 1,
					Crisps = 5,
				}

				for product, requiredQty in pairs(requiredQuantities) do
					local grocery = currentGroceries[product]
					print(product, grocery and grocery.Quantity or "nil")
					if not grocery or grocery.Quantity ~= requiredQty then
						warn("Failed, no correct grocery quantity/item")
						return false
					end
				end

				return true
			end
		end
	end

	return false -- no GroceryBag found
end

local function DetermineDialogue()
	if not HasCorrectGrocery() then
		return {
			Name = "Homeless GEEZA",
			Portrait = "rbxassetid://84999542418956",
			Dialogue = "Please ROBUX kind fellow.",
			VoiceId = 3,
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "HomelessTheme",
			Responses = {
				{
					Text = "You're just gonna use the money<br/>to fuel your addiction aren't you?",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "Sory no Engish.",
					Type = "Close",
				},
			},
		}
	else
		return {
			Name = "Homeless GEEZA",
			Portrait = "rbxassetid://84999542418956",
			Dialogue = "Did you keep your promise?",
			VoiceId = 3,
			Pitch = 1,
			Speed = 1,
			Volume = 1,
			PlayTheme = "HomelessTheme",
			Responses = {
				{
					Text = "Here it is, doing my part here!",
					Type = "NextMessage",
					NextId = "CorrectOne",
					RemoveTools = { "GroceryBag" },
				},
				{
					Text = "No, bye.",
					Type = "Close",
				},
			},
		}
	end
end

return {
	Nodes = {
		Homeless = DetermineDialogue,
		-- default
		One = {
			Name = "Homeless GEEZA",
			Portrait = "rbxassetid://15223036035",
			Dialogue = "No, I am just a humble homeless fella trying to make ends meet.<br/><b>Please humble citizen, just a small donation of 10 thousand robux.</b>",
			Responses = {
				{
					Text = "10,000? ARE YOU CRAZY?<br/>I COULD BUY A CHEAP CAR WITH THAT!",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "(Walk away)",
					Type = "Close",
				},
			},
		},
		Two = {
			Name = "Homeless Geezer",
			Portrait = "rbxassetid://9649195617",
			Dialogue = "I can take crypto as well or pounds.<br/><b>Please please please please please please please please please please please please please please</b>",
			Responses = {
				{
					Text = "RELAX I GOT AN IDEA!",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "(Run)",
					Type = "Close",
				},
			},
		},

		Three = {
			Name = "Homeless Gazza",
			Portrait = "rbxassetid://1664931187",
			Dialogue = "What idea kind potential benefactor?<br/>",
			Responses = {
				{
					Text = "I'll go in the shop and buy you some food.<br/>That way I know you're not using my money for anything bad.",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "I walk away. BYEEEEEEE",
					Type = "Close",
				},
			},
		},

		Four = {
			Name = "omeless' eeza'",
			Portrait = "rbxassetid://247126974",
			Dialogue = "DAMITAGEETNERLYGOTTEM.<br/>Sorry had to clear my throat <b>kind</b> benefactor, good idea!<br/>I couldn't get anything due to the store only accepting pounds sterling!",
			Responses = {
				{
					Text = "What food do you want?",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},
		Five = {
			Name = "OmELeZZGezAAAAH",
			Portrait = "rbxassetid://18455760798",
			Dialogue = "Please can I get:<br/>10 RebelCola<br/>1 Frozen Food<br/>4 Ice Creams<br/>1 Toxic Waste<br/>1 Chocolate<br/>5 Chips",
			Responses = {
				{
					Text = "JESUS TAKING ADVANTAGE ARE WE?",
					Type = "NextMessage",
					NextId = "Six",
				},
				{
					Text = "(Leave, greedy bat.)",
					Type = "Close",
				},
			},
		},
		Six = {
			Name = "HOMELESS",
			Portrait = "rbxassetid://6749370850",
			Dialogue = "It's shared between other fellow homeless men or women, believe it you generous guli guli, guli guli, guli, ram sam sam.",
			Responses = {
				{
					Text = "I won't promise you anything.",
					Type = "NextMessage",
					NextId = "Seven",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},

		Seven = {
			Name = "Houseless Geezer",
			Portrait = "rbxassetid://102630924355734",
			Dialogue = "That's a promise!, don't betray me, benefactor!",
			Responses = {
				{
					Text = "(Leave)",
					Type = "Close",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},

		--Has correct grocery
		CorrectOne = {
			Name = "Homeless Individual",
			Portrait = "rbxassetid://102630924355734",
			Dialogue = "Thank you so much benefactor.<br/>Thank you so much benefactor.<br/>Thank you so much benefactor.<br/>Thank you so much benefactor.<br/>Thank you so much benefactor.",
			Responses = {
				{
					Text = "Alright calm down and enjoy.",
					Type = "Close",
				},
				{
					Text = "(Leave)",
					Type = "Close",
				},
			},
		},
	},
}
