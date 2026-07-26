local DR = DR

local ConVars = DR.ConVars

--- @class RoundStateData
local RoundStateDefault = {
	["OnEnter"] = DR.EmptyFunction,
	["OnThink"] = DR.EmptyFunction,
	["OnExit"] = DR.EmptyFunction,
}
local KillfeedTbl_Meta = {
	["__index"] = RoundStateDefault,
}

ROUND = ROUND or {}

-- Create round state constants
ROUND_CURRENT = ROUND_CURRENT or ROUND_WAITING

--- @type RoundStateData[]
ROUND_STATES = ROUND_STATES or {} -- heheh

ROUND_WAITING = 1
ROUND_PREP = 2
ROUND_ACTIVE = 3
ROUND_OVER = 4

ROUND_PREPARING = ROUND_PREP
ROUND_ENDING = ROUND_OVER

-- win constants
WIN_RUNNERS = TEAM_RUNNER
WIN_DEATHS = TEAM_DEATH
WIN_STALEMATE = 3

WINNER_BITS = DR.CalcMaxBits(WIN_STALEMATE)

-- for the round timer
-- have a shared ROUND_TIMER variable which continuously counts down each .2 second
-- timer going every .2s updating ROUND_TIMER so we have a precision of 1/5th of a second ?????
-- network each time the timer is set, but calculate the timer on server and client individually
ROUND_TIMER = ROUND_TIMER or 0

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
function ROUND.AddState(state,fOnEnter,fOnThink,fOnExit) -- constant int, and 3 functions
	ROUND_STATES[state] = setmetatable({
		["OnEnter"] = fOnEnter,
		["OnThink"] = fOnThink,
		["OnExit"] = fOnExit,
	},KillfeedTbl_Meta)
end

function ROUND.RoundThink(state)
	local roundTbl = ROUND_STATES[state]
	if not roundTbl then return end

	roundTbl.OnThink()
end

function ROUND.GetCurrent()
	return ROUND_CURRENT
end

-- keep thinking for the current round, i.e. to check for living players
hook.Add("Think","ROUND_THINK",function()
	ROUND.RoundThink(ROUND_CURRENT)
end)

function ROUND.GetTimer()
	return ROUND_TIMER or 0
end

local TimerInterval = .2

timer.Create("DeathrunRoundTimerCalculate",TimerInterval,0,function()
	ROUND_TIMER = math.max(0,ROUND_TIMER - TimerInterval)
end)

DR.RoundsPlayed = DR.RoundsPlayed or 0

function ROUND.GetRoundsPlayed()
	return DR.RoundsPlayed
end

local DeathTeamStreaks = DR.DeathTeamStreaks or {}
local DeathTimes = DR.DeathTimes or {}
DR.DeathTeamStreaks = DeathTeamStreaks
DR.DeathTimes = DeathTimes

local function WaitingStateCheck()
	if #DR.GetAllPlaying() < 2 then return end

	ROUND.RoundSwitch(ROUND_PREP)

	timer.Remove("DeathrunWaitingStateCheck")
end

ROUND.AddState(
	ROUND_WAITING,
	function()
		print("Round State: WAITING")

		hook.Run("DeathrunBeginWaiting")

		if not SERVER then return end

		for _,ply in ipairs(DR.GetAllPlaying()) do
			ply:StripWeapons()
			ply:RemoveAllAmmo()
			ply:SetTeam(TEAM_RUNNER)
			ply:Spawn()
		end

		timer.Create("DeathrunWaitingStateCheck",5,0,WaitingStateCheck)
	end,
	nil,
	function()
		print("Exiting: WAITING")
	end
)

ROUND.AddState(
	ROUND_PREP,
	function()
		print("Round State: PREP")

		hook.Run("DeathrunBeginPrep")

		if CLIENT then
			-- round start cue
			if ConVars.PlayRoundCues:GetBool() then
				surface.PlaySound("Deathrun.RoundStart")
			end

			return
		end

		game.CleanUpMap()

		timer.Simple(ConVars.PrepDuration:GetInt(),function()
			ROUND.RoundSwitch(ROUND_ACTIVE)
		end)

		ROUND.SetTimer(ConVars.PrepDuration:GetInt())

		for _,ply in player.Iterator() do
			-- for some reason we need to do this otherwise people spawn as spec when they shouldnt!
			if not ply:ShouldStaySpectating() then
				ply:KillSilent()
				ply:SetTeam(TEAM_RUNNER)
			end

			DeathTeamStreaks[ply] = DeathTeamStreaks[ply] or 0
			DeathTimes[ply] = DeathTimes[ply] or 0
		end

		-- let's pick deaths at random, but ignore if they have been death the 2 previous rounds
		local deaths = {}

		local plyList = DR.GetAllPlaying()
		local pool = table.Copy(plyList)

		local deathsNeeded = math.ceil(ConVars.DeathRatio:GetFloat() * #plyList)
		local deathsMax = ConVars.DeathMax:GetInt()

		if deathsNeeded > deathsMax then
			deathsNeeded = deathsMax
		end

		-- get a list of players, ordered by how many death rounds they have had, lowest to highest
		local listOrdered = {}
		local listUnordered = table.Copy(plyList)

		for _ = 1,#listUnordered do
			local lowest = math.huge
			local lowestIdx = 0
			local lowestPly

			for idx,ply in pairs(listUnordered) do
				local deathTime = DeathTimes[ply]
				if deathTime >= lowest then continue end

				lowest = deathTime
				lowestIdx = idx
				lowestPly = ply
			end

			listOrdered[#listOrdered + 1] = lowestPly
			listUnordered[lowestIdx] = nil
		end

		print("\nList of Death counters:")
		PrintTable(listOrdered)

		local poolPunishment = DR.GetOnlineDeathAvoiders()

		-- remove players from orderedpool and pool if they have been death 2 rounds in a row
		for _,ply in ipairs(plyList) do
			local streak = DeathTeamStreaks[ply] or 0
			if streak <= 0 then continue end

			print(ply:Nick() .. " has a streak greater than 0, removing from pool(s).")

			table.RemoveByValue(listOrdered,ply)
			table.RemoveByValue(pool,ply)
		end

		PrintTable(listOrdered)
		PrintTable(pool)

		local timesLooped = 0

		while timesLooped < 100 and #deaths < deathsNeeded do
			local punishmentCount = #poolPunishment

			if punishmentCount > 0 then
				local ply = poolPunishment[punishmentCount]

				DR.PardonDeathAvoid(ply,1)
				DR.ChatBroadcast("Player " .. ply:Nick() .. " is being punished for death avoidance! They have " .. DR.GetDeathAvoiderRounds(ply) .. " Death rounds remaining.")

				deaths[#deaths + 1] = ply -- add players to the deaths if they are being punishd for death avoid

				table.RemoveByValue(pool,ply)
				table.remove(poolPunishment,punishmentCount)
			elseif #listOrdered > 0 then
				local ply = listOrdered[1]

				print("A death has been chosen through orderedpool: " .. ply:Nick())

				deaths[#deaths + 1] = ply

				table.remove(listOrdered,1)
				table.RemoveByValue(pool,ply)
			else
				local randNum = math.random(#pool)
				local randPly = pool[randNum]

				if randPly then
					print("A death has been chosen: " .. randPly)

					deaths[#deaths + 1] = randPly

					table.remove(pool,randNum)
				end
			end

			timesLooped = timesLooped + 1
		end

		if timesLooped >= 100 then
			print("---WARNING!!!!! WHILE LOOP EXCEEDED ALLOWED LOOP TIME!!!!-----")
		end

		-- Set our selected Deaths
		for _,death in ipairs(deaths) do
			death:SetTeam(TEAM_DEATH)
		end

		-- Set everyone left in the pool as Runners
		for _,runner in ipairs(pool) do
			runner:SetTeam(TEAM_RUNNER)
		end

		-- make sure nobody is dead??????
		for _,ply in ipairs(plyList) do
			ply:StripWeapons()
			ply:RemoveAllAmmo()
			ply:Spawn()
		end

		for _,ply in player.Iterator() do
			local deathTime = DeathTimes[ply] or 0
			local deathTeamStreak = DeathTeamStreaks[ply] or 0

			if ply:Team() == TEAM_DEATH then
				deathTime = deathTime + 1
				deathTeamStreak = deathTeamStreak + 1
			else
				deathTeamStreak = 0
			end

			DeathTimes[ply] = deathTime
			DeathTeamStreaks[ply] = deathTeamStreak

			print(ply:Nick(),team.GetName(ply:Team()))
		end

		print("\nDeathTimes table:")

		for ply,time in pairs(DeathTimes) do
			if not IsValid(ply) then
				DeathTimes[ply] = nil
			else
				print(ply:Nick(),time)
			end
		end

		print("\nDeathTeamStreaks:")
		PrintTable(DeathTeamStreaks)
	end,
	nil,
	function()
		print("Exiting: PREP")
	end
)

local function AutoslayDelay()
	for _,ply in ipairs(DR.GetAllPlaying()) do
		local idleTime = DR.CheckIdleTime(ply)

		print(ply,idleTime)

		if idleTime <= ConVars.AutoslayDelay:GetInt() then continue end

		net.Start("DeathrunSpectatorNotification")
		net.Send(ply)

		if ply:Team() == TEAM_DEATH then
			DR.PunishDeathAvoid(ply,ConVars.DeathAvoidPunishment:GetInt())

			DR.ChatBroadcast("Player " .. ply:Nick() .. " went AFK during a Death round! They will be punished.")
		end

		ply:ConCommand("deathrun_spectate_only 1")
	end
end

ROUND.AddState(
	ROUND_ACTIVE,
	function()
		print("Round State: ACTIVE")

		hook.Run("DeathrunBeginActive")

		if not SERVER then return end

		ROUND.SetTimer(ConVars.RoundDuration:GetInt())

		timer.Create("DeathrunAutoslay",ConVars.AutoslayDelay:GetInt() + 5,1,AutoslayDelay)
	end,
	function()
		if not SERVER then return end

		local playing = DR.GetAllPlaying()

		if #playing < 2 then
			ROUND.RoundSwitch(ROUND_WAITING)

			return
		end

		local deaths = {}
		local runners = {}

		for _,ply in ipairs(playing) do
			if not ply:Alive() then continue end

			local targetTbl
			local plyTeam = ply:Team()

			if plyTeam == TEAM_RUNNER then
				targetTbl = runners
			elseif plyTeam == TEAM_DEATH then
				targetTbl = deaths
			else continue end

			targetTbl[#targetTbl + 1] = ply
		end

		local allGoneDeaths = #deaths == 0
		local allGoneRunners = #runners == 0
		local winTeam

		if allGoneDeaths and allGoneRunners or ROUND.GetTimer() == 0 then
			winTeam = WIN_STALEMATE
		elseif allGoneDeaths then
			winTeam = WIN_RUNNERS
		elseif allGoneRunners then
			winTeam = WIN_DEATHS
		else return end

		ROUND.FinishRound(winTeam)
	end,
	function()
		print("Exiting: ACTIVE")
	end
)

local function RestartRound()
	ROUND.RoundSwitch(ROUND_PREP)
end

ROUND.AddState(
	ROUND_OVER,
	function()
		print("Round State: OVER")

		hook.Run("DeathrunBeginOver")

		local roundsPlayed = DR.RoundsPlayed + 1
		DR.RoundsPlayed = roundsPlayed

		if not SERVER then return end

		local roundLimit = ConVars.RoundLimit:GetInt()

		if
			not hook.Run("DeathrunShouldMapSwitch",roundsPlayed)
		and	roundsPlayed < roundLimit
		then
			DR.ChatBroadcast("Round " .. roundsPlayed .. " over. " .. (roundLimit - roundsPlayed) .. " rounds to go!")

			local finishDur = ConVars.FinishDuration:GetInt()

			ROUND.SetTimer(finishDur)

			timer.Simple(finishDur,RestartRound)
		else
			--DR.ChatBroadcast("Round limit reached. Initiating RTV...")

			timer.Simple(3,function()
				if hook.Run("DeathrunStartMapvote",roundsPlayed) then return end

				MV:BeginMapVote()
			end)
		end
	end,
	nil,
	function()
		print("Exiting: OVER")
	end
)

local BalloonDir = Vector()
local BalloonAngle = Angle()

local BalloonEndPosMul = 92
local BalloonDistCheck = 30 ^ 2

local BalloonTraceData = {}

hook.Add("DeathrunPlayerFinishMap","Balloons",function(ply)
	local balloonCount = ConVars.FinishBalloons:GetInt()

	if balloonCount <= 0 then return end

	local shootPos = ply:GetShootPos()

	for _ = 1,balloonCount do
		local balloon = ents.Create("ent_deathrun_balloon") --- @cast balloon -NULL

		balloon:Spawn()

		BalloonDir[1] = math.Rand(-100,100)
		BalloonDir[2] = math.Rand(-100,100)
		BalloonDir[3] = math.Rand(-100,100)
		BalloonDir:Normalize()
		BalloonDir:Mul(BalloonEndPosMul)

		BalloonAngle[2] = math.Rand(-180,180)
		balloon:SetAngles(BalloonAngle)

		BalloonTraceData.start = shootPos
		BalloonTraceData.endpos = shootPos + BalloonDir
		BalloonTraceData.filter = ply
		BalloonTraceData.mins = balloon:OBBMins()
		BalloonTraceData.maxs = balloon:OBBMaxs()

		local trace = util.TraceHull(BalloonTraceData)
		local hitPos = trace.HitPos

		if hitPos:DistToSqr(shootPos) > BalloonDistCheck then
			BalloonDir:Div(BalloonEndPosMul)
			BalloonDir:Mul(2.5)

			balloon:SetPos(hitPos)

			balloon:GetPhysicsObject():ApplyForceCenter(BalloonDir)
		else
			balloon:Remove()
		end
	end
end)
