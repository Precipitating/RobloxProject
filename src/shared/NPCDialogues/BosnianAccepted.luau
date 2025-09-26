local function RandomObject()
	local items = {
		"Ultra Heavy Mouse",
		"Brainrot",
		"1950 Crisp Packet",
		"PBT Keycap",
		"Deactivated Landmine",
		"8D Speaker Set",
		"Bronze Fork",
		"Stromatolite",
		"Mansion from Zzap",
		"Trade Bot from Telamon",
	}

	local dialogue =
		`My dad just texted me that he bought a {items[math.random(1, #items)]} from an auction for 10 million marks.<br/>PLEASE GET ME THE LAPTOP!`

	return dialogue
end

return {

	Nodes = {
		BosnianAccepted = {
			Name = "Bosnian Bill",
			Portrait = "rbxassetid://14437808130",
			Dialogue = RandomObject,
			VoiceId = "1",
			Pitch = 5,
			Speed = 1,
			Volume = 3,
			PlayTheme = "BosniaTheme",
			Responses = {
				{
					Text = "Still thinking about it...",
					Type = "Close",
				},
				{
					Text = "...",
					Type = "Close",
				},
			},
		},
	},
}
