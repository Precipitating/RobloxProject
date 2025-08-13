local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HelperFunctions = require(ServerScriptService.Server.HelperFunctions)
local playThemeRemote = ReplicatedStorage.Shared.Remotes.PlayTheme
local APIs = { "https://random-word-api.vercel.app/api?words=", "https://random-word-api.herokuapp.com/word?number=" }
local generalRemotes = ReplicatedStorage.Shared.Remotes
local Missions = require(ReplicatedStorage.Shared.Missions.Server.Missions)

local WORD_AMOUNT = 1
local DURATION = 60

local wordList = { "The", "API", "Failed", "To", "Load", "So", "Enjoy", "This", "Easy", "Win" }
local whiteBoard = nil
local examRoom = nil
local currentScore = nil
local targetScore = nil
local clockText = nil
local WordType = {}
local currentWordIdx = 1
local finishedExecuted = false
function WordType.GenerateWordList(amount)
	for _, api in APIs do
		api = api .. amount
		local success, response = pcall(function()
			return HttpService:GetAsync(api)
		end)

		if success then
			local data = HttpService:JSONDecode(response)
			return data
		end
	end

	return nil
end

function WordType.StartTimer(textToModify, duration, async, player)
	local function timerLogic()
		for i = duration, 0, -1 do
			if textToModify == clockText then
				-- stop timer if reached target
				if currentWordIdx > #wordList then
					return
				end
			end
			textToModify.Text = tostring(i)
			task.wait(1)
		end

		-- if we reached here, it means timer went to 0, meaning fail
		if textToModify == clockText then
			WordType.Finished(false, player)
		end
	end

	if async then
		task.spawn(timerLogic)
	else
		timerLogic()
	end
end

function WordType.Init(player)
	-- get refs
	wordList = WordType.GenerateWordList(WORD_AMOUNT)
	examRoom = HelperFunctions.SpawnModelAtPosition("PsychoMantis", "ExamRoom", nil)
	clockText = examRoom.Clock.Screen.SurfaceGui.TextLabel
	whiteBoard = examRoom.Whiteboard.SurfaceGui.TextLabel
	currentScore = examRoom.CurrentScore.Screen.SurfaceGui.TextLabel
	targetScore = examRoom.RequiredScore.Screen.SurfaceGui.TextLabel
	local spawnPos = examRoom:FindFirstChild("CameraPos")

	clockText.Text = DURATION

	-- change cam to mission area
	if spawnPos then
		generalRemotes.ChangeCameraSubject:FireClient(player, spawnPos.CFrame)
	else
		error("Part not found for camera to move to")
	end

	-- start
	if wordList then
		-- add onFocusLost connection, aim is to detect if enter is pressed + check if matches current word
		generalRemotes.PsychoMantis.OnFocusLostConnect:FireClient(player, wordList[currentWordIdx])
		task.wait(1)

		-- set target
		targetScore.Text = tostring(#wordList)
		-- whiteboard timer
		whiteBoard.Text = "Get ready..."
		WordType.StartTimer(whiteBoard, 3, false, player)
		targetScore = tostring(#wordList)
		return true
	else
		return false
	end
end

function WordType.Begin(player)
	-- clock timer
	playThemeRemote:FireClient(player, "Intense")
	warn("Intense playing?")
	WordType.StartTimer(clockText, DURATION, true, player)
	whiteBoard.Text = wordList[currentWordIdx]

	generalRemotes.PsychoMantis.GetNextWord.OnServerInvoke = function()
		if currentWordIdx >= #wordList then
			currentWordIdx = currentWordIdx + 1
			currentScore.Text = tostring(currentWordIdx - 1)
			WordType.Finished(true, player)
			print("Competition Complete!")
			return "(Finished)"
		end

		currentWordIdx = currentWordIdx + 1
		currentScore.Text = tostring(currentWordIdx - 1)
		whiteBoard.Text = wordList[currentWordIdx]

		return wordList[currentWordIdx]
	end
end

function WordType.Finished(won, player)
	if finishedExecuted then
		return
	end
	-- disconnect events
	finishedExecuted = true
	generalRemotes.PsychoMantis.GetNextWord.OnServerInvoke = nil
	generalRemotes.PsychoMantis.PsychoMantisEventCleanup:FireClient(player)

	if won then
		whiteBoard.Text = "YOU WIN!"
		local model = HelperFunctions.SpawnModelAtPosition("PsychoMantis", "ExamWin", nil)
		model.Parent = workspace.ExamRoom
		Missions.addProgressToTask(player, "TypingCompetition", "Type", 1)
	else
		whiteBoard.Text = "YOU LOSE!"
		local model = HelperFunctions.SpawnModelAtPosition("PsychoMantis", "ExamLose", nil)
		model.Parent = workspace.ExamRoom
		Missions.FailMission(player, "TypingCompetition")
	end
	task.wait(7)
	generalRemotes.Blur:FireClient(player, 1, 100)
	generalRemotes.StopAllMusic:InvokeClient(player)
	generalRemotes.EnableControls:FireClient(player, nil)
	examRoom:Destroy()
	playThemeRemote:FireClient(player, "Main")
	generalRemotes.ChangeCameraSubject:FireClient(player, nil)
	task.wait(1)
	generalRemotes.Blur:FireClient(player, 2, 0)

	--
end

return WordType
