local Iterator = ipairs({})

local DR = DR

local PlayerFilters = DR.PlayerFilters

--- @alias DeathrunSteamIDDict table<string,Player>
--- @alias DeathrunFilterDictTeam table<integer,CRecipientFilter>
--- @alias DeathrunFilterDictStatus table<boolean,CRecipientFilter>

--- @type DeathrunSteamIDDict
local SteamIDs = PlayerFilters.SteamIDs or {}
--- @type DeathrunSteamIDDict
local SteamID64s = PlayerFilters.SteamID64s or {}
PlayerFilters.SteamIDs = SteamIDs
PlayerFilters.SteamID64s = SteamID64s

--- @type CRecipientFilter
local All = PlayerFilters.All or RecipientFilter()
--- @type CRecipientFilter
local Alive = PlayerFilters.Alive or RecipientFilter()
--- @type CRecipientFilter
local Dead = PlayerFilters.Dead or RecipientFilter()
PlayerFilters.All = All
PlayerFilters.Alive = Alive
PlayerFilters.Dead = Dead

--- @type CRecipientFilter
local Playing = PlayerFilters.Playing or RecipientFilter()
--- @type CRecipientFilter
local PlayingAlive = PlayerFilters.PlayingAlive or RecipientFilter()
--- @type CRecipientFilter
local PlayingDead = PlayerFilters.PlayingDead or RecipientFilter()
PlayerFilters.Playing = Playing
PlayerFilters.PlayingAlive = PlayingAlive
PlayerFilters.PlayingDead = PlayingDead

--- @type CRecipientFilter
local Runners = PlayerFilters.Runners or RecipientFilter()
--- @type CRecipientFilter
local RunnersAlive = PlayerFilters.RunnersAlive or RecipientFilter()
--- @type CRecipientFilter
local RunnersDead = PlayerFilters.RunnersDead or RecipientFilter()
PlayerFilters.Runners = Runners
PlayerFilters.RunnersAlive = RunnersAlive
PlayerFilters.RunnersDead = RunnersDead

--- @type CRecipientFilter
local Deaths = PlayerFilters.Deaths or RecipientFilter()
--- @type CRecipientFilter
local DeathsAlive = PlayerFilters.DeathsAlive or RecipientFilter()
--- @type CRecipientFilter
local DeathsDead = PlayerFilters.DeathsDead or RecipientFilter()
PlayerFilters.Deaths = Deaths
PlayerFilters.DeathsAlive = DeathsAlive
PlayerFilters.DeathsDead = DeathsDead

--- @type CRecipientFilter
local Ghosts = PlayerFilters.Ghosts or RecipientFilter()
--- @type CRecipientFilter
local Spectators = PlayerFilters.Spectators or RecipientFilter()
PlayerFilters.Ghosts = Ghosts
PlayerFilters.Spectators = Spectators

--- @type CRecipientFilter
local Connecting = PlayerFilters.Connecting or RecipientFilter()
--- @type CRecipientFilter
local Unassigned = PlayerFilters.Unassigned or RecipientFilter()
--- @type CRecipientFilter
local NotPlaying = PlayerFilters.NotPlaying or RecipientFilter()
PlayerFilters.Connecting = Connecting
PlayerFilters.Unassigned = Unassigned
PlayerFilters.NotPlaying = NotPlaying

--- @type CRecipientFilter
local Empty = PlayerFilters.Empty or RecipientFilter()
PlayerFilters.Empty = Empty

--- @type CRecipientFilter[]
local FilterList = {
	All,
	Alive,
	Dead,

	Playing,
	PlayingAlive,
	PlayingDead,

	Runners,
	RunnersAlive,
	RunnersDead,

	Deaths,
	DeathsAlive,
	DeathsDead,

	Ghosts,
	Spectators,

	Connecting,
	Unassigned,
	NotPlaying,

	Empty,
}

--- @type DeathrunFilterDictTeam
local AllByTeam = {
	[DR_TEAM_CONNECTING] = Connecting,
	[DR_TEAM_RUNNER] = Runners,
	[DR_TEAM_DEATH] = Deaths,
	[DR_TEAM_GHOST] = Ghosts,
	[DR_TEAM_UNASSIGNED] = Unassigned,
	[DR_TEAM_SPECTATOR] = Spectators,
}
PlayerFilters.AllByTeam = AllByTeam

--- @type DeathrunFilterDictTeam
local PlayingByTeam = {
	[DR_TEAM_CONNECTING] = NotPlaying,
	[DR_TEAM_RUNNER] = Playing,
	[DR_TEAM_DEATH] = Playing,
	[DR_TEAM_GHOST] = NotPlaying,
	[DR_TEAM_UNASSIGNED] = NotPlaying,
	[DR_TEAM_SPECTATOR] = NotPlaying,
}
PlayerFilters.PlayingByTeam = PlayingByTeam

--- @type table<boolean,DeathrunFilterDictTeam>
local TeamByStatus = {
	[true] = {
		[DR_TEAM_CONNECTING] = Connecting,
		[DR_TEAM_RUNNER] = RunnersAlive,
		[DR_TEAM_DEATH] = DeathsAlive,
		[DR_TEAM_GHOST] = Ghosts,
		[DR_TEAM_UNASSIGNED] = Unassigned,
		[DR_TEAM_SPECTATOR] = Spectators,
	},
	[false] = {
		[DR_TEAM_CONNECTING] = Connecting,
		[DR_TEAM_RUNNER] = RunnersDead,
		[DR_TEAM_DEATH] = DeathsDead,
		[DR_TEAM_GHOST] = Ghosts,
		[DR_TEAM_UNASSIGNED] = Unassigned,
		[DR_TEAM_SPECTATOR] = Spectators,
	},
}
PlayerFilters.TeamByStatus = TeamByStatus

--- @type table<integer,DeathrunFilterDictStatus>
local StatusByTeam = {
	[DR_TEAM_CONNECTING] = {
		[true] = Connecting,
		[false] = Connecting,
	},
	[DR_TEAM_RUNNER] = {
		[true] = RunnersAlive,
		[false] = RunnersDead,
	},
	[DR_TEAM_DEATH] = {
		[true] = DeathsAlive,
		[false] = DeathsDead,
	},
	[DR_TEAM_GHOST] = {
		[true] = Ghosts,
		[false] = Ghosts,
	},
	[DR_TEAM_UNASSIGNED] = {
		[true] = Unassigned,
		[false] = Unassigned,
	},
	[DR_TEAM_SPECTATOR] = {
		[true] = Spectators,
		[false] = Spectators,
	},
}
PlayerFilters.StatusByTeam = StatusByTeam

--- @type DeathrunFilterDictTeam
local WinningTeams = {
	[DR_WIN_STALEMATE] = Empty,
	[DR_WIN_RUNNERS] = Runners,
	[DR_WIN_DEATHS] = Deaths,
}
PlayerFilters.WinningTeams = WinningTeams

--- @type DeathrunFilterDictTeam
local WinningTeamsAlive = {
	[DR_WIN_STALEMATE] = Empty,
	[DR_WIN_RUNNERS] = RunnersAlive,
	[DR_WIN_DEATHS] = DeathsAlive,
}
PlayerFilters.WinningTeamsAlive = WinningTeamsAlive

hook.Add("DeathrunClientInitialized","DeathrunFiltersConnect",function(ply)
	print(ply,"Connect")

	All:AddPlayer(ply)

	SteamIDs[ply:SteamID()] = ply
	SteamID64s[ply:SteamID64()] = ply
end)

hook.Add("PlayerDisconnected","DeathrunFiltersDisconnect",function(ply)
	print(ply,"Disconnect")

	--- @param filter CRecipientFilter
	for _,filter in Iterator,FilterList,0 do
		filter:RemovePlayer(ply)
	end

	SteamIDs[ply:SteamID()] = nil
	SteamID64s[ply:SteamID64()] = nil
end)

hook.Add("PlayerChangedTeam","DeathrunFiltersChangeTeam",function(ply,teamOld,teamNew)
	print(ply,"ChangedTeam",teamOld,teamNew)

	AllByTeam[teamOld]:RemovePlayer(ply)
	AllByTeam[teamNew]:AddPlayer(ply)

	local teamStatus = TeamByStatus[ply:Alive()]

	teamStatus[teamOld]:RemovePlayer(ply)
	teamStatus[teamNew]:AddPlayer(ply)

	PlayingByTeam[teamOld]:RemovePlayer(ply)
	PlayingByTeam[teamNew]:AddPlayer(ply)
end)

hook.Add("PlayerSpawn","DeathrunFiltersPlayerSpawn",function(ply)
	print(ply,"Spawn")

	Dead:RemovePlayer(ply)
	Alive:AddPlayer(ply)

	local plyTeam = ply:Team()
	local statusTeam = StatusByTeam[plyTeam]

	statusTeam[false]:RemovePlayer(ply)
	statusTeam[true]:AddPlayer(ply)

	if PlayingByTeam[plyTeam] == NotPlaying then return end

	PlayingDead:RemovePlayer(ply)
	PlayingAlive:AddPlayer(ply)
end)

hook.Add("PostPlayerDeath","DeathrunFiltersPlayerDeath",function(ply)
	print(ply,"Death")

	Alive:RemovePlayer(ply)
	Dead:AddPlayer(ply)

	local plyTeam = ply:Team()
	local statusTeam = StatusByTeam[plyTeam]

	statusTeam[true]:RemovePlayer(ply)
	statusTeam[false]:AddPlayer(ply)

	if PlayingByTeam[plyTeam] == NotPlaying then return end

	PlayingAlive:RemovePlayer(ply)
	PlayingDead:AddPlayer(ply)
end)
