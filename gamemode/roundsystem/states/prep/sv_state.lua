local Iterator = ipairs({})

local IsValid = IsValid

local GameCleanUpMap = game.CleanUpMap

local MathCeil = math.ceil
local MathRandom = math.random

local PlayerIterator = player.Iterator

local TableCopy = table.Copy
local TableRemove = table.remove
local TableRemoveByValue = table.RemoveByValue

local TimerSimple = timer.Simple

local DR = DR

local ConVars = DR.ConVars

local CvDeathMax = ConVars.DeathMax
local CvDeathRatio = ConVars.DeathRatio
local CvPrepDuration = ConVars.PrepDuration

local RoundSystem = DR.RoundSystem

local DeathTeamStreaks = RoundSystem.DeathTeamStreaks or {}
RoundSystem.DeathTeamStreak = DeathTeamStreaks

local DeathTimes = RoundSystem.DeathTimes or {}
RoundSystem.DeathTimes = DeathTimes

function ROUNDSTATE:EnterRealm()
	GameCleanUpMap()

	TimerSimple(CvPrepDuration:GetInt(),function()
		RoundSystem.RoundSwitch(DR_ROUND_ACTIVE)
	end)

	RoundSystem.SetTimer(CvPrepDuration:GetInt())

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
end
