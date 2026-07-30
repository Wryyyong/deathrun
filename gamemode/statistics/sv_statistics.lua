local Iterator = ipairs({})

local DR = DR

local RoundSystem = DR.RoundSystem
local Stats = DR.Stats
local ZoneSystem = DR.ZoneSystem

--- @enum (key) DeathrunPlayerStats
local StatColumns = {
	[DR_STATS_KILLS] = [["Kills"]],
	[DR_STATS_DEATHS] = [["Deaths"]],
	[DR_STATS_WINSRUNNER] = [["WinsRunner"]],
	[DR_STATS_WINSDEATH] = [["WinsDeath"]],
}

local WinningTeamToStats = {
	[DR_WIN_RUNNERS] = DR_STATS_WINSRUNNER,
	[DR_WIN_DEATHS] = DR_STATS_WINSDEATH,
}

--- @alias DeathrunMapRecord_Server {
--- 	Name: string,
--- 	Seconds: number,
--- }

--- @type DeathrunMapRecord_Server[]
local MapRecordsCache = Stats.MapRecordsCache or {}
Stats.MapRecordsCache = MapRecordsCache

local MostWinsCache = Stats.MostWinsCache or {}
Stats.MostWinsCache = MostWinsCache

-- script to keep track of all statistics for players
-- kills, deaths, round wins
-- if a runner dies, then that's 1 kill for everyone on the Death team.
util.AddNetworkString("DeathrunSendStats")
util.AddNetworkString("DeathrunSendEndZone")
util.AddNetworkString("DeathrunDisplayStats")
util.AddNetworkString("DeathrunSendMapRecords")
util.AddNetworkString("DeathrunSendMapPersonalBest")

local TableName_MapRecords = [["DeathrunRecords-]] .. sql.SQLStr(game.GetMap(),true) .. [["]]

-- Setup database tables
sql.Query(
	[[
		PRAGMA foreign_keys = TRUE;

		CREATE TABLE IF NOT EXISTS "DeathrunSteamID64Index" (
			"SteamID64"  TEXT  NOT NULL  PRIMARY KEY  ON CONFLICT REPLACE,
			"Name"       TEXT  NOT NULL
		) WITHOUT ROWID
		;

		CREATE TABLE IF NOT EXISTS "DeathrunStats" (
			"SteamID64"   TEXT     NOT NULL  PRIMARY KEY  REFERENCES "DeathrunSteamID64Index",
			"Kills"       INTEGER  NOT NULL  DEFAULT 0,
			"Deaths"      INTEGER  NOT NULL  DEFAULT 0,
			"WinsRunner"  INTEGER  NOT NULL  DEFAULT 0,
			"WinsDeath"   INTEGER  NOT NULL  DEFAULT 0
		) WITHOUT ROWID
		;

		CREATE TABLE IF NOT EXISTS ]] .. TableName_MapRecords .. [[ (
			"SteamID64"  TEXT  NOT NULL  PRIMARY KEY  REFERENCES "DeathrunSteamID64Index",
			"Seconds"    REAL  NOT NULL  DEFAULT 0
		)
		;
	]]
)

function Stats.ReturnStats(ply)
	return sql.QueryRow(
		[[
			SELECT
				*,
				("WinsRunner" + "WinsDeath") AS "WinsTotal"

			FROM "DeathrunStats"
			WHERE "SteamID64" = ']] .. ply:SteamID64() .. [['
			;
		]]
	)
end

--- @param ply Player
--- @param stat DeathrunPlayerStats
local function UpdateStats(ply,stat)
	if ply:IsBot() then return end

	local column = StatColumns[stat]

	sql.QueryTyped(
		[[UPDATE "DeathrunStats" SET ]] .. column .. [[ = ]] .. column .. [[ + 1 WHERE "SteamID64" = ?;]],
		ply:SteamID64()
	)
end

local function UpdateMostWins()
	local mostWins = sql.QueryRow(
		[[
			SELECT
				"DeathrunSteamID64Index"."Name",
				("WinsRunner" + "WinsDeath") AS "WinsTotal"

			FROM "DeathrunStats" AS "Stats"

			INNER JOIN "DeathrunSteamID64Index" ON
				"DeathrunSteamID64Index"."SteamID64" = "Stats"."SteamID64"

			WHERE "WinsTotal" > 0
			ORDER BY "WinsTotal" DESC LIMIT 1
			;
		]]
	) or {}

	local name = mostWins.Name or "---"
	local winsTotal = mostWins.WinsTotal or "--"

	MostWinsCache.Name = name
	MostWinsCache.WinsTotal = winsTotal
	MostWinsCache.FullString = name .. " (" .. winsTotal .. ")"
end

local function UpdatePlayerPersonalBest(ply)
	local data = sql.QueryRow([[SELECT "Seconds" FROM ]] .. TableName_MapRecords .. [[ WHERE "SteamID64" = ']] .. ply:SteamID64() .. [[';]])
	if not data then return end

	net.Start("DeathrunSendMapPersonalBest")
		net.WriteFloat(data.Seconds)
	net.Send(ply)
end

--- @param plyFinish Player?
local function UpdateMapRecords(plyFinish)
	local endZone = Stats.EndZone
	if not endZone then return end

	local newRecords = sql.Query(
		[[
			SELECT
				"DeathrunSteamID64Index"."Name",
				"Records"."Seconds"

			FROM ]] .. TableName_MapRecords .. [[ AS "Records"

			INNER JOIN "DeathrunSteamID64Index" ON
				"DeathrunSteamID64Index"."SteamID64" = "Records"."SteamID64"

			WHERE "Seconds" > 0
			ORDER BY "Seconds" LIMIT 3
			;
		]]
	) or {} --- @cast newRecords -boolean

	MapRecordsCache = newRecords

	net.Start("DeathrunSendMapRecords")
		for _,data in Iterator,MapRecordsCache,0 do
			net.WriteBool(true)
			net.WriteString(data.Name:sub(1,24))
			net.WriteFloat(data.Seconds)
		end

		net.WriteBool(false)
	net.Broadcast()

	if plyFinish then
		UpdatePlayerPersonalBest(plyFinish)
	else
		for _,ply in player.Iterator() do
			UpdatePlayerPersonalBest(ply)
		end
	end
end

--- @param plyFinish Player?
local function SendEndZone(ply)
	local endZone = Stats.EndZone
	if not endZone then return end

	net.Start("DeathrunSendEndZone")
		local location = endZone.pos1 + endZone.pos2
		location:Mul(.5)
		location[1] = location[1] - 90

		net.WriteDouble(location[1])
		net.WriteDouble(location[2])
		net.WriteDouble(location[3])

	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

local function FindEndZone()
	if not ZoneSystem.MapZones then return end

	for _,zone in next,ZoneSystem.MapZones do
		if zone.type ~= "end" then continue end

		Stats.EndZone = zone

		break
	end

	SendEndZone()
end

hook.Add("DeathrunPlayerFinishMap","DeathrunMapRecords",function(ply,_,_,_,seconds)
	sql.QueryTyped(
		"INSERT INTO " .. TableName_MapRecords
	..	[[
			VALUES
				(?,?)

			ON CONFLICT("SteamID64")
			DO UPDATE SET
				"Seconds" = "excluded"."Seconds"
			WHERE
				"Seconds" > "excluded"."Seconds"
			;
		]],
		ply:SteamID64(),
		seconds
	)

	local current3rd = MapRecordsCache[3]

	if
		current3rd
	and	current3rd.Seconds >= seconds
	then return end

	UpdateMapRecords(ply)
end)

hook.Add("InitPostEntity","DeathrunFindEndZone",function()
	UpdateMostWins()
	FindEndZone()
	SendEndZone()
end)

hook.Add("DeathrunZonesUpdated","DeathrunFindEndZone",FindEndZone)

FindEndZone()

hook.Add("DeathrunBeginPrep","DeathrunSendRecords",UpdateMapRecords)

hook.Add("player_connect","UpdatePlayerIDs",function(data)
	if data.bot == 1 then return end

	local id64 = util.SteamIDTo64(data.networkid)

	sql.QueryTyped(
		[[INSERT INTO "DeathrunSteamID64Index" VALUES (?,?);]],
		id64,
		data.name
	)
	sql.QueryTyped(
		[[INSERT OR IGNORE INTO "DeathrunStats" ("SteamID64") VALUES (?);]],
		id64
	)
end)

hook.Add("PlayerDeath","DeathrunUpdateKillDeathStats",function(victim,_,attacker)
	if RoundSystem.GetCurrent() ~= DR_ROUND_ACTIVE then return end

	local victimTeam = victim:Team()

	sql.Begin()

	if attacker:IsPlayer() then
		if victimTeam ~= attacker:Team() then
			UpdateStats(attacker,DR_STATS_KILLS)
		end
	elseif victimTeam == DR_TEAM_RUNNER then
		for _,ply in Iterator,team.GetPlayers(DR_TEAM_DEATH),0 do
			UpdateStats(ply,DR_STATS_KILLS)
		end
	end

	if victim:IsPlayer() then
		UpdateStats(victim,DR_STATS_DEATHS)
	end

	sql.Commit()
end)

hook.Add("DeathrunRoundWin","DeathrunUpdateWinStats",function(winningTeam)
	if winningTeam == DR_WIN_STALEMATE then return end

	local column = WinningTeamToStats[winningTeam]
	local plyList = team.GetPlayers(winningTeam)

	sql.Begin()

	for _,ply in Iterator,plyList,0 do
		UpdateStats(ply,column)
	end

	sql.Commit()

	UpdateMostWins()
end)

-- displays a player's stats in front of their face
function Stats.DisplayStats(ply)
	if not IsValid(ply) then return end

	local data = Stats.ReturnStats(ply)
	if not data then return end

	net.Start("DeathrunDisplayStats")
		-- SQLite databases can handle a variety of "integer"-type numericals up to 64 bits long
		-- We will almost never need to network values that require that many bits to represent
		-- but as along as the support is there we need to handle it anyways
		--
		-- This is one of the rare occasions where just packing everything into a single string
		-- ends up being the cheaper option

		net.WriteString(util.TableToJSON({
			data.Kills,
			data.Deaths,
			data.WinsRunner,
			data.WinsDeath,
			MostWinsCache.FullString,
		}))
	net.Send(ply)
end

hook.Add("PlayerLoadout","DisplayStatsForPlayers",function(ply)
	if
		not ply:Alive()
	or	ply:GetSpectate()
	then return end

	timer.Simple(.5,function()
		Stats.DisplayStats(ply)
	end)
end)

concommand.Add("stats_test",function(ply,_,_)
	PrintTable(Stats.ReturnStats(ply) or {})
end)
