local Iterator = ipairs({})

local setmetatable = setmetatable

local IsValid = IsValid

local GameCleanUpMap = game.CleanUpMap

local HookRun = hook.Run

local MathCeil = math.ceil
local MathMax = math.max
local MathRandom = math.random

local NetSend = SERVER and net.Send
local NetStart = net.Start

local PlayerIterator = player.Iterator

local SurfacePlaySound = CLIENT and surface.PlaySound

local TableCopy = table.Copy
local TableRemove = table.remove
local TableRemoveByValue = table.RemoveByValue

local TimerCreate = timer.Create
local TimerRemove = timer.Remove
local TimerSimple = timer.Simple

local DR = DR

local ConVars = DR.ConVars
local MapVote = DR.MapVote

local CvAutoslayDelay = ConVars.AutoslayDelay
local CvDeathAvoidPunishment = ConVars.DeathAvoidPunishment
local CvDeathMax = ConVars.DeathMax
local CvDeathRatio = ConVars.DeathRatio
local CvFinishDuration = ConVars.FinishDuration
local CvPlayRoundCues = ConVars.PlayRoundCues
local CvPrepDuration = ConVars.PrepDuration
local CvRoundDuration = ConVars.RoundDuration
local CvRoundLimit = ConVars.RoundLimit

--- @class RoundStateData
local RoundStateDefault = {
	["OnEnter"] = DR.EmptyFunction,
	["OnThink"] = DR.EmptyFunction,
	["OnExit"] = DR.EmptyFunction,
}
local KillfeedTbl_Meta = {
	["__index"] = RoundStateDefault,
}

local RoundSystem = DR.RoundSystem

-- Create round state constants
RoundSystem.CurrentState = RoundSystem.CurrentState or DR_ROUND_WAITING

-- heheh
--- @type RoundStateData[]
local States = RoundSystem.States or {}
RoundSystem.States = States

-- for the round timer
-- have a shared ROUND_TIMER variable which continuously counts down each .2 second
-- timer going every .2s updating ROUND_TIMER so we have a precision of 1/5th of a second ?????
-- network each time the timer is set, but calculate the timer on server and client individually
RoundSystem.RoundTimer = RoundSystem.RoundTimer or 0

sound.Add({
	["name"] = "Deathrun.RoundStart",
	["sound"] = "ui/achievement_earned.wav",
	["channel"] = CHAN_AUTO,
	["level"] = SNDLVL_NORM,
})

--- @param state integer
--- @param fOnEnter function?
--- @param fOnThink function?
--- @param fOnExit function?
function RoundSystem.AddState(state,fOnEnter,fOnThink,fOnExit) -- constant int, and 3 functions
	RoundSystem.States[state] = setmetatable({
		["OnEnter"] = fOnEnter,
		["OnThink"] = fOnThink,
		["OnExit"] = fOnExit,
	},KillfeedTbl_Meta)
end

function RoundSystem.RoundThink(state)
	local roundTbl = RoundSystem.States[state]
	if not roundTbl then return end

	roundTbl.OnThink()
end

function RoundSystem.GetCurrent()
	return RoundSystem.CurrentState
end

-- keep thinking for the current round, i.e. to check for living players
hook.Add("Think","ROUND_THINK",function()
	RoundSystem.RoundThink(RoundSystem.CurrentState)
end)

function RoundSystem.GetTimer()
	return RoundSystem.RoundTimer or 0
end

local TimerInterval = .2

TimerCreate("DeathrunRoundTimerCalculate",TimerInterval,0,function()
	RoundSystem.RoundTimer = MathMax(0,RoundSystem.RoundTimer - TimerInterval)
end)

RoundSystem.RoundsPlayed = RoundSystem.RoundsPlayed or 0

function RoundSystem.GetRoundsPlayed()
	return RoundSystem.RoundsPlayed
end

local DeathTeamStreaks = RoundSystem.DeathTeamStreaks or {}
RoundSystem.DeathTeamStreak = DeathTeamStreaks

local DeathTimes = RoundSystem.DeathTimes or {}
RoundSystem.DeathTimes = DeathTimes

local function WaitingStateCheck()
	if #DR.GetAllPlaying() < 2 then return end

	DR.RoundSystem.RoundSwitch(DR_ROUND_PREP)

	TimerRemove("DeathrunWaitingStateCheck")
end

RoundSystem.AddState(
	DR_ROUND_WAITING,
	function()
		HookRun("DeathrunBeginWaiting")

		if not SERVER then return end

		for _,ply in Iterator,DR.GetAllPlaying(),0 do
			ply:StripWeapons()
			ply:RemoveAllAmmo()
			ply:SetTeam(DR_TEAM_RUNNER)
			ply:Spawn()
		end

		TimerCreate("DeathrunWaitingStateCheck",5,0,WaitingStateCheck)
	end,
	nil
)

RoundSystem.AddState(
	DR_ROUND_PREP,
	function()
		HookRun("DeathrunBeginPrep")

		if CLIENT then
			-- round start cue
			if CvPlayRoundCues:GetBool() then
				SurfacePlaySound("Deathrun.RoundStart")
			end

			return
		end

		GameCleanUpMap()

		TimerSimple(CvPrepDuration:GetInt(),function()
			DR.RoundSystem.RoundSwitch(DR_ROUND_ACTIVE)
		end)

		DR.RoundSystem.SetTimer(CvPrepDuration:GetInt())

		for _,ply in PlayerIterator() do
			-- for some reason we need to do this otherwise people spawn as spec when they shouldnt!
			if not ply:ShouldStaySpectating() then
				ply:KillSilent()
				ply:SetTeam(DR_TEAM_RUNNER)
			end

			DeathTeamStreaks[ply] = DeathTeamStreaks[ply] or 0
			DeathTimes[ply] = DeathTimes[ply] or 0
		end

		-- let's pick deaths at random, but ignore if they have been death the 2 previous rounds
		local deaths = {}

		local plyList = DR.GetAllPlaying()
		local pool = TableCopy(plyList)

		local deathsNeeded = MathCeil(CvDeathRatio:GetFloat() * #plyList)
		local deathsMax = CvDeathMax:GetInt()

		if deathsNeeded > deathsMax then
			deathsNeeded = deathsMax
		end

		-- get a list of players, ordered by how many death rounds they have had, lowest to highest
		local listOrdered = {}
		local listUnordered = TableCopy(plyList)

		for _ = 1,#listUnordered do
			local lowest = math.huge
			local lowestIdx = 0
			local lowestPly

			for idx,ply in next,listUnordered do
				local deathTime = DeathTimes[ply]
				if deathTime >= lowest then continue end

				lowest = deathTime
				lowestIdx = idx
				lowestPly = ply
			end

			listOrdered[#listOrdered + 1] = lowestPly
			listUnordered[lowestIdx] = nil
		end

		local poolPunishment = DR.GetOnlineDeathAvoiders()

		-- remove players from orderedpool and pool if they have been death 2 rounds in a row
		for _,ply in Iterator,plyList,0 do
			local streak = DeathTeamStreaks[ply] or 0
			if streak <= 0 then continue end

			TableRemoveByValue(listOrdered,ply)
			TableRemoveByValue(pool,ply)
		end

		local timesLooped = 0

		while timesLooped < 100 and #deaths < deathsNeeded do
			local punishmentCount = #poolPunishment

			if punishmentCount > 0 then
				local ply = poolPunishment[punishmentCount]

				DR.PardonDeathAvoid(ply,1)
				DR.ChatBroadcast("Player " .. ply:Nick() .. " is being punished for death avoidance! They have " .. DR.GetDeathAvoiderRounds(ply) .. " Death rounds remaining.")

				deaths[#deaths + 1] = ply -- add players to the deaths if they are being punishd for death avoid

				TableRemoveByValue(pool,ply)
				TableRemove(poolPunishment,punishmentCount)
			elseif #listOrdered > 0 then
				local ply = listOrdered[1]

				if ply then
					deaths[#deaths + 1] = ply

					TableRemove(listOrdered,1)
					TableRemoveByValue(pool,ply)
				end
			else
				local randNum = MathRandom(#pool)
				local randPly = pool[randNum]

				if randPly then
					deaths[#deaths + 1] = randPly

					TableRemove(pool,randNum)
				end
			end

			timesLooped = timesLooped + 1
		end

		-- Set our selected Deaths
		for _,death in Iterator,deaths,0 do
			death:SetTeam(DR_TEAM_DEATH)
		end

		-- Set everyone left in the pool as Runners
		for _,runner in Iterator,pool,0 do
			runner:SetTeam(DR_TEAM_RUNNER)
		end

		-- make sure nobody is dead??????
		for _,ply in Iterator,plyList,0 do
			ply:StripWeapons()
			ply:RemoveAllAmmo()
			ply:Spawn()
		end

		for _,ply in PlayerIterator() do
			local deathTime = DeathTimes[ply] or 0
			local deathTeamStreak = DeathTeamStreaks[ply] or 0

			if ply:Team() == DR_TEAM_DEATH then
				deathTime = deathTime + 1
				deathTeamStreak = deathTeamStreak + 1
			else
				deathTeamStreak = 0
			end

			DeathTimes[ply] = deathTime
			DeathTeamStreaks[ply] = deathTeamStreak
		end

		for ply,time in next,DeathTimes do
			if IsValid(ply) then continue end

			DeathTimes[ply] = nil
		end
	end,
	nil
)

--[[
local function AutoslayDelay()
	for _,ply in Iterator,DR.GetAllPlaying(),0 do
		local idleTime = DR.CheckIdleTime()

		if idleTime <= CvAutoslayDelay:GetInt() then continue end

		NetStart("DeathrunSpectatorNotification")
		NetSend(ply)

		if ply:Team() == DR_TEAM_DEATH then
			DR.PunishDeathAvoid(ply,CvDeathAvoidPunishment:GetInt())

			DR.ChatBroadcast("Player " .. ply:Nick() .. " went AFK during a Death round! They will be punished.")
		end

		ply:ConCommand("deathrun_spectate_only 1")
	end
end
--]]

RoundSystem.AddState(
	DR_ROUND_ACTIVE,
	function()
		HookRun("DeathrunBeginActive")

		if not SERVER then return end

		DR.RoundSystem.SetTimer(CvRoundDuration:GetInt())

		--TimerCreate("DeathrunAutoslay",CvAutoslayDelay:GetInt() + 5,1,AutoslayDelay)
	end,
	function()
		if not SERVER then return end

		local playing = DR.GetAllPlaying()

		if #playing < 2 then
			DR.RoundSystem.RoundSwitch(DR_ROUND_WAITING)

			return
		end

		local deaths = {}
		local runners = {}

		for _,ply in Iterator,playing,0 do
			if not ply:Alive() then continue end

			local targetTbl
			local plyTeam = ply:Team()

			if plyTeam == DR_TEAM_RUNNER then
				targetTbl = runners
			elseif plyTeam == DR_TEAM_DEATH then
				targetTbl = deaths
			else continue end

			targetTbl[#targetTbl + 1] = ply
		end

		local allGoneDeaths = #deaths == 0
		local allGoneRunners = #runners == 0
		local winTeam

		if allGoneDeaths and allGoneRunners or DR.RoundSystem.GetTimer() == 0 then
			winTeam = DR_WIN_STALEMATE
		elseif allGoneDeaths then
			winTeam = DR_WIN_RUNNERS
		elseif allGoneRunners then
			winTeam = DR_WIN_DEATHS
		else return end

		DR.RoundSystem.FinishRound(winTeam)
	end
)

local function RestartRound()
	DR.RoundSystem.RoundSwitch(DR_ROUND_PREP)
end

RoundSystem.AddState(
	DR_ROUND_OVER,
	function()
		HookRun("DeathrunBeginOver")

		local roundsPlayed = RoundSystem.RoundsPlayed + 1
		RoundSystem.RoundsPlayed = roundsPlayed

		if not SERVER then return end

		local roundLimit = CvRoundLimit:GetInt()

		if
			not HookRun("DeathrunShouldMapSwitch",roundsPlayed)
		and	roundsPlayed < roundLimit
		then
			DR.ChatBroadcast("Round " .. roundsPlayed .. " over. " .. (roundLimit - roundsPlayed) .. " rounds to go!")

			local finishDur = CvFinishDuration:GetInt()

			DR.RoundSystem.SetTimer(finishDur)

			TimerSimple(finishDur,RestartRound)
		else
			--DR.ChatBroadcast("Round limit reached. Initiating RTV...")

			TimerSimple(3,function()
				if HookRun("DeathrunStartMapvote",roundsPlayed) then return end

				MapVote.BeginMapVote()
			end)
		end
	end,
	nil
)
