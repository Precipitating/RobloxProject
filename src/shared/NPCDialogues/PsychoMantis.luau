local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local generalRemotes = ReplicatedStorage.Shared.Remotes
local playerData = generalRemotes.GetBasicPlayerData:InvokeServer()
local friendsList = generalRemotes.GetFriendsList:InvokeServer()
local gotBio, bioData = generalRemotes.GetPlayerBio:InvokeServer()
local randomFriend = friendsList[math.random(1, #friendsList)]
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function Introduction()
	local text

	if not player.DisplayName then
		text = `Interesting {playerData.Name}, very interesting...`
	else
		text = `Interesting {player.DisplayName}, very interesting...`
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
	local text
	if randomFriend.Username == "Account Deleted" then
		text = "Friends with a criminal huh? their account's deleted... interesting..."
	elseif randomFriend.Username == randomFriend.DisplayName then
		text =
			`You're not here with {randomFriend.Username}? Seems like they didn't set a nickname for themselves.. Interesting...`
	else
		text =
			`You're not here with {randomFriend.Username}? Or shall I refer to them as {randomFriend.DisplayName}...?`
	end

	return text
end

local function OnlineFriendsDialogue()
	local text
	local success, result = pcall(player.GetFriendsOnline, player, 10)
	if not success then
		warn("Getting online friends failed")
		result = {}
	end

	local randomOnlineFriend = (#result > 0) and result[math.random(1, #result)] or nil

	if not randomOnlineFriend then
		text = "No 'connections' online right now huh? very interesting... "
	elseif randomOnlineFriend.UserName == "Account Deleted" then
		text =
			"Why is your terminated 'connection' online..? Desperation at its finest. Roblox Support ain't gonna reverse the decision ha ha ha... Interessant..."
	else
		local lastGamePlayed = GetGameNameFromId(randomOnlineFriend.PlaceId)
		if lastGamePlayed then
			text =
				`Not playing with {randomOnlineFriend.Username}? He's online you know.. The last game he played was {lastGamePlayed}. Zanimljivo... `
		else
			text = `Not mingling with {randomOnlineFriend.UserName}? He's online you know...?`
		end
	end

	return text
end

local function PlayersBio()
	local text
	if gotBio then
		local data = HttpService:JSONDecode(bioData)
		if not data.description or data.description == "" then
			text = "Didn't set a profile biography? shame, it's nice to let other's know who you are... ha ha ha ha"
		else
			text = data.description
		end
	else
		text = "Interesting profile biography..."
	end
	return text
end

return {
	Nodes = {
		PsychoMantis = {
			Name = "??????",
			Portrait = "rbxassetid://7129644829",
			Dialogue = Introduction(),
			VoiceId = 1,
			Pitch = 12,
			Speed = 0.5,
			Volume = 1,
			PlayTheme = "Calm",
			Responses = {
				{
					Text = "How do you know my name..?",
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
			Name = "H?????",
			Portrait = "rbxassetid://7129644829",
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
			Name = "Ha????",
			Portrait = "rbxassetid://7129644829",
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
			Name = "Hack??",
			Portrait = "rbxassetid://7129644829",
			Dialogue = PlayersBio(),
			Responses = {
				{
					Text = "WHAT THE....",
					Type = "NextMessage",
					NextId = "Safechatter2",
				},
				{
					Text = "A####pt to w##k o#f s##wl#",
					Type = "NextMessage",
					NextId = "Safechatter3",
				},
			},
		},
	},
}
