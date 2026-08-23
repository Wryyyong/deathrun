local Iterator = ipairs({})

local tonumber = tonumber

local IsValid = IsValid

local EntsCreate = ents.Create

local GameCleanUpMap = game.CleanUpMap

local HookRun = hook.Run

local MathRand = math.Rand

local NetBroadcast = net.Broadcast
local NetSend = net.Send
local NetStart = net.Start
local NetWriteBool = net.WriteBool
local NetWritePlayer = net.WritePlayer
local NetWriteUInt = net.WriteUInt

local PlayerGetCount = player.GetCount
local PlayerIterator = player.Iterator

local UtilTraceHull = util.TraceHull

local DR = DR

local ConVars = DR.ConVars
local PlayerFilters = DR.PlayerFilters
local RoundSystem = DR.RoundSystem

util.AddNetworkString("DeathrunUpdateRoundState")
util.AddNetworkString("DeathrunSyncRoundTimer")
util.AddNetworkString("DeathrunSendMVPs")

-- this can be used to switch or restart states
-- send this each time round state changes so that the player can update themselves
function RoundSystem.RoundSwitch(newState)
	RoundSystem.CurrentStateData:Exit()
	RoundSystem.UpdateState(newState):Enter()

	NetStart("DeathrunUpdateRoundState")
		NetWriteUInt(newState,DR_ROUND_BITS)
	NetBroadcast()

	-- compatibility
	HookRun("OnRoundSet",newState)
end

-- commands
concommand.Add("round_switch",function(ply,_,args)
	if IsValid(ply) then return end

	RoundSystem.RoundSwitch(tonumber(args[1]))
end)

hook.Add("DeathrunClientInitialized","DeathrunSyncRoundsWithNewClient",function(ply)
	NetStart("DeathrunUpdateRoundState")
		NetWriteUInt(RoundSystem.CurrentState,DR_ROUND_BITS)
	NetSend(ply)

	RoundSystem.SyncTimer(ply)

	if PlayerGetCount() > 1 then return end

	GameCleanUpMap()

	DR.ChatBroadcast("Cleaned up the map.")
end)

--- @param ply Player?
function RoundSystem.SyncTimer(ply)
	NetStart("DeathrunSyncRoundTimer")
		NetWriteUInt(RoundSystem.GetTimer(),16)

	if ply then
		NetSend(ply)
	else
		NetBroadcast()
	end
end

--- @param seconds number
function RoundSystem.SetTimer(seconds)
	RoundSystem.RoundTimer = seconds

	RoundSystem.SyncTimer()
end

-- handle death avoidance here, using the functions defined in init.lua
hook.Add("PlayerDisconnected","DeathrunWatchDeathAvoid",function(ply)
	local roundState = RoundSystem.CurrentState

	if
		roundState == DR_ROUND_WAITING
	or	roundState == DR_ROUND_OVER
	or	ply:IsBot()
	or	not ply:Alive()
	or	ply:Team() ~= DR_TEAM_DEATH
	then return end

	DR.PunishDeathAvoid(ply,ConVars.DeathAvoidPunishment:GetInt())

	DR.ChatBroadcast("Player " .. ply:Nick() .. " will be punished for attempting to avoid being on the Death team!")
end)

hook.Add("PlayerDeath","DeathrunMVPs",function(ply,_,attacker)
	if
		not attacker:IsPlayer()
	or	ply == attacker
	then return end

	attacker.KillsThisRound = (attacker.KillsThisRound or 0) + 1
end)

hook.Add("DeathrunBeginPrep","DeathrunMVPs",function()
	for _,ply in PlayerIterator() do
		ply.KillsThisRound = 0
	end
end)

local WinnerAnnouncements = {
	[DR_WIN_STALEMATE] = "It's a stalemate!",
	[DR_WIN_RUNNERS] = "Runners win!",
	[DR_WIN_DEATHS] = "Deaths win!",
}

--- @param winningTeam integer
function RoundSystem.FinishRound(winningTeam)
	DR.ChatBroadcast(WinnerAnnouncements[winningTeam])

	RoundSystem.RoundSwitch(DR_ROUND_OVER)

	-- calculate MVPs
	local survivorList = PlayerFilters.WinningTeamsAlive[winningTeam]:GetPlayers()
	local mostKills = 0
	local mostKillsMvp

	for _,ply in Iterator,survivorList,0 do
		local killCount = ply.KillsThisRound or 0

		if killCount <= mostKills then continue end

		mostKills = killCount
		mostKillsMvp = ply
	end

	local doMostKills =
		mostKillsMvp
	and	winningTeam == DR_TEAM_RUNNER

	NetStart("DeathrunSendMVPs")
		NetWriteUInt(winningTeam,DR_TEAM_BITS)

		for _,survivor in Iterator,survivorList,0 do
			NetWriteBool(true)
			NetWritePlayer(survivor)
		end

		NetWriteBool(false)

		-- Most kills
		NetWriteBool(doMostKills)

		if doMostKills then
			NetWritePlayer(mostKillsMvp)
			NetWriteUInt(mostKills,MAX_PLAYER_BITS)
		end
	NetBroadcast()

	HookRun("DeathrunRoundWin",winningTeam)

	-- compatibility
	HookRun("OnRoundSet",DR_ROUND_OVER,winningTeam ~= DR_WIN_STALEMATE and winningTeam or -1)
end

-- initial round
hook.Add("InitPostEntity","DeathrunInitialRoundState",function()
	RoundSystem.RoundSwitch(DR_ROUND_WAITING)
end)

local BalloonDir = Vector()
local BalloonAngle = Angle()

local BalloonEndPosMul = 92
local BalloonDistCheck = 30 ^ 2

local BalloonTraceCache = {
	["start"] = vector_origin,
	["endpos"] = vector_origin,
	["mins"] = vector_origin,
	["maxs"] = vector_origin,
}

hook.Add("DeathrunPlayerFinishMap","Balloons",function(ply)
	local balloonCount = ConVars.FinishBalloons:GetInt()

	if balloonCount <= 0 then return end

	local shootPos = ply:GetShootPos()

	for _ = 1,balloonCount do
		local balloon = EntsCreate("ent_deathrun_balloon") --- @cast balloon -NULL

		balloon:Spawn()

		BalloonDir:Random(-100,100)
		BalloonDir:Normalize()
		BalloonDir:Mul(BalloonEndPosMul)

		BalloonAngle[2] = MathRand(-180,180)
		balloon:SetAngles(BalloonAngle)

		BalloonTraceCache.start = shootPos
		BalloonTraceCache.endpos = shootPos + BalloonDir
		BalloonTraceCache.filter = ply
		BalloonTraceCache.mins = balloon:OBBMins()
		BalloonTraceCache.maxs = balloon:OBBMaxs()

		local trace = UtilTraceHull(BalloonTraceCache)
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
