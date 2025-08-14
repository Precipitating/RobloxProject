local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeneralRemotes = ReplicatedStorage.Shared.Remotes
local PlayerData = GeneralRemotes.GetBasicPlayerData:InvokeServer()
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local CustomDialogue = require(ReplicatedStorage.Shared.NPCDialogues.PsychoMantisHelpers.CustomPsychoMantisDialogue)
local function Introduction()
	local text
	if not Player.DisplayName then
		text = `Interesting {PlayerData.Name}, very interesting...`
	else
		text = `Interesting {Player.DisplayName}, very interesting...`
	end
	return text
end

local function GetGameNameFromId(id)
	local success, result = pcall(function()
		return MarketplaceService:GetProductInfo(id)
	end)
	if success and result then
		return result.Name
	else
		warn("Game name not found for id:", id)
		return nil
	end
end

local function FriendDialogue()
	local friendsList = GeneralRemotes.GetFriendsList:InvokeServer()
	local randomFriend = friendsList[math.random(1, #friendsList)]
	local text

	if randomFriend.Username == "Account Deleted" then
		text =
			"Friends with a <font color='#FF0000'><b>criminal</b></font> huh? their account's deleted... interesting..."
	elseif randomFriend.Username == randomFriend.DisplayName then
		text =
			`You're not here with <b>{randomFriend.Username}</b>? Seems like they didn't set a nickname for themselves..<br/>Interesting...`
	else
		text =
			`You're not here with <b><font color='#FF0000'>{randomFriend.Username}</font></b>? Or shall I refer to them as <font color='#FF0000'><b>{randomFriend.DisplayName}</b></font>...?`
	end

	return text
end

local function OnlineFriendsDialogue()
	local text
	local success, result = pcall(Player.GetFriendsOnline, Player, 10)
	if not success then
		warn("Getting online friends failed")
		result = {}
	end

	local randomOnlineFriend = (#result > 0) and result[math.random(1, #result)] or nil

	if not randomOnlineFriend then
		text = "No <i>'connections'</i> online right now huh? very interesting..."
	elseif randomOnlineFriend.UserName == "Account Deleted" then
		text =
			"Why is your terminated <b>'connection'</b> online..? Desperation at its finest. <b><font color='#FF0000'>ROBLOX</font></b> Support ain't gonna reverse the decision ha ha ha... Interessant..."
	else
		local lastGamePlayed = GetGameNameFromId(randomOnlineFriend.PlaceId)
		if lastGamePlayed then
			text =
				`Not playing with <b>{randomOnlineFriend.UserName}</b>? He's online playing <b>{lastGamePlayed}</b>. <i>Zanimljivo</i>...`
		else
			text = `Not mingling with <b>{randomOnlineFriend.UserName}</b>? He's online you know...?`
		end
	end

	return text
end

local function PlayersBio()
	local gotBio, bioData = GeneralRemotes.GetPlayerBio:InvokeServer()
	local text = "<b>Interesting</b> profile biography... <b>Interestiiiiiingg</b>..."
	if gotBio then
		local data = HttpService:JSONDecode(bioData)
		if data.description and data.description ~= "" then
			text = "<i>" .. data.description .. "</i>"
		else
			text = "Didn't set a profile biography? shame, it's nice to let others know who you are... ha ha ha ha"
		end
	end
	return text
end

local function PlayersFavourites()
	local gotFav, favData = GeneralRemotes.GetPlayerFavourites:InvokeServer()
	local text = "You haven't favourited any games? Maybe this one will be your first.. interesting..."
	if gotFav then
		local result = HttpService:JSONDecode(favData)
		local randomFavGame = (#result.data > 0) and result.data[math.random(1, #result.data)] or nil

		local hasCustomDialogue = CustomDialogue[randomFavGame.id]
		if hasCustomDialogue then
			text = hasCustomDialogue
		else
			text =
				`I see you like playing <font color='#FF0000'>'{randomFavGame.name}'</font>... interesting choice, very interesting...`
		end
	end

	return text
end

local function PlayersGroup()
	local text = "You're not in any groups huh? looks like you haven't found a game that rewards you for joining them."
	if PlayerData.Groups then
		local randomGroup = (#PlayerData.Groups > 0) and PlayerData.Groups[math.random(1, #PlayerData.Groups)] or nil
		text =
			`I see you're a <font color='#ff4500'><b>{randomGroup.Role}</b></font> in '<font color='#ff4500'><b>{randomGroup.Name}</b></font>'... Care to explain..?`
	end
	return text
end

local function PlayersAge()
	local ageInYears = math.floor(PlayerData.Age / 365)
	local ageTag = "inexperienced <font color='#e3f542'>fr00b</font> who's wet behind the ears"
	if ageInYears >= 4 and ageInYears < 8 then
		ageTag = "inbetweener! not too <b>young</b> and not too <b>old</b>"
	elseif ageInYears >= 8 then
		ageTag = "old <font color='#41526a'><b>COOT</b></font>.<br/>That is <b>OUTRAGEOUS</b>"
	end

	local text = `You joined this platform for about <b>{tostring(ageInYears)}</b> years huh?<br/>You're an {ageTag}!!!`
	return text
end

local function PlayerCountry()
	local text =
		"Fine, I had your location, but I'll keep that under wraps to keep this... interesting...<br/><font color='#000000'>Ze-ha-ha-ha-ha</font>"
	local country, flagFact = GeneralRemotes.GetCountryData:InvokeServer(PlayerData.Country)

	if country then
		if flagFact then
			text = `And finally, you live in <b>{country}</b> don't you?<br/>Fun fact: {flagFact}.<br/>How interesting!`
		else
			text = `You live in <b>{country}</b> don't you? Shall I pay a visit? Peek-a-boo.`
		end
	end

	return text
end

return {
	Nodes = {
		PsychoMantis = {
			Name = "?????? ???",
			Portrait = "rbxassetid://7129644829",
			Dialogue = Introduction(),
			VoiceId = 1,
			Pitch = 12,
			Speed = 0.5,
			Volume = 1,
			PlayTheme = "Calm",
			Responses = {
				{
					Text = "How do you know my <b>name</b>..?",
					Type = "NextMessage",
					NextId = "One",
				},
				{
					Text = "(RUN)",
					Type = "Close",
				},
			},
		},

		One = {
			Name = "H????? ???",
			Portrait = "rbxassetid://17425818639",
			Dialogue = FriendDialogue(),
			Responses = {
				{
					Text = "... Who are you.",
					Type = "NextMessage",
					NextId = "Two",
				},
				{
					Text = "Attempt to walk off slowly",
					Type = "NextMessage",
					NextId = "Two",
				},
			},
		},

		Two = {
			Name = "Ha???? ???",
			Portrait = "rbxassetid://7937261481",
			Dialogue = OnlineFriendsDialogue(),
			Responses = {
				{
					Text = "I SAID WHO ARE YOU?!?!",
					Type = "NextMessage",
					NextId = "Three",
				},
				{
					Text = "At##mpt to wa#k off s##wly",
					Type = "NextMessage",
					NextId = "Three",
				},
			},
		},

		Three = {
			Name = "Hacke? ???",
			Portrait = "rbxassetid://9104107231",
			Dialogue = PlayersBio(),
			Responses = {
				{
					Text = "WHAT THE....",
					Type = "NextMessage",
					NextId = "Four",
				},
				{
					Text = "A####pt to w##k o#f s##wl#",
					Type = "NextMessage",
					NextId = "Four",
				},
			},
		},
		Four = {
			Name = "Hacker ???",
			Portrait = "rbxassetid://14316492370",
			Dialogue = PlayersFavourites(),
			Responses = {
				{
					Text = "IM BEGGIN' YA!!",
					Type = "NextMessage",
					NextId = "Five",
				},
				{
					Text = "A####p# ## w### o#f ###wl#",
					Type = "NextMessage",
					NextId = "Five",
				},
			},
		},

		Five = {
			Name = "Hacker H",
			Portrait = "rbxassetid://3293972814",
			Dialogue = PlayersGroup(),
			Responses = {
				{
					Text = "N-NEIN",
					Type = "NextMessage",
					NextId = "Six",
				},
				{
					Text = "#####p# ## w### o## ######",
					Type = "NextMessage",
					NextId = "Six",
				},
			},
		},

		Six = {
			Name = "Hacker Ha",
			Portrait = "rbxassetid://4929384371",
			Dialogue = PlayersAge(),
			Responses = {
				{
					Text = "HOW MUCH LONGER???",
					Type = "NextMessage",
					NextId = "Seven",
				},
				{
					Text = "####### ## #### ### ######",
					Type = "NextMessage",
					NextId = "Seven",
				},
			},
		},

		Seven = {
			Name = "TTS Message Limit LOL!",
			Portrait = "rbxassetid://4929384371",
			Dialogue = PlayerCountry(),
			Responses = {
				{
					Text = "AAHHHHHHHHHH!!!",
					Type = "NextMessage",
					NextId = "Eight",
				},
				{
					Text = "####### ## #### ### ######",
					Type = "NextMessage",
					NextId = "Eight",
				},
			},
		},

		Eight = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://7129644829",
			Dialogue = "Right, you get the point, so you need to do a little task for me, or else, heh... you know.",
			PlaySound = "Knock",
			Responses = {
				{
					Text = "Y-ys-sh- S-hiire!",
					Type = "NextMessage",
					NextId = "Nine",
				},
				{
					Text = "OK PLZ ANYTHING SIRE",
					Type = "NextMessage",
					NextId = "Nine",
				},
			},
		},

		Nine = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://7129644829",
			Dialogue = "Let's get to the point, I need you to compete in a typing competition.<br/>My fingers are injured due to me getting your information, so take responsibility and win.",
			Responses = {
				{
					Text = "M-me?",
					Type = "NextMessage",
					NextId = "MissionStart",
				},
				{
					Text = "Interesting...",
					Type = "NextMessage",
					NextId = "MissionStart",
				},
			},
		},

		MissionStart = {
			Name = "Hacker Ham",
			Portrait = "rbxassetid://7129644829",
			Dialogue = "Exactly. If you fail, well.. Refer to previous point... Now get going.<br/>I'll set your Camera to the location, be grateful.",
			PlaySound = "Knock",
			Responses = {
				{
					Text = "YESSIRTHANKYOUSIR",
					UnlockMission = "TypingCompetition",
					SetDialogueFile = { { PsychoMantisNameTag = "PsychoMantisAccepted" } },
					Type = "CloseCutscene",
				},
				{
					Text = "y-y-y-y-y-y--y-y-",
					UnlockMission = "TypingCompetition",
					SetDialogueFile = { { PsychoMantisNameTag = "PsychoMantisAccepted" } },
					Type = "CloseCutscene",
				},
			},
		},
	},
}
