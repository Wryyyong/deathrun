if not file.Exists("deathrun","DATA") then -- creates a folder in data for the gamemode
	file.CreateDir("deathrun")
end

-- init
AddCSLuaFile("config.lua")

include("config.lua")

-- convars
AddCSLuaFile("convars/sh_convars.lua")
AddCSLuaFile("convars/cl_convars.lua")

include("convars/sh_convars.lua")
include("convars/sv_convars.lua")

-- init
AddCSLuaFile("shared.lua")

include("shared.lua")

-- fonts
AddCSLuaFile("cl_fonts.lua")

-- base
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_menus.lua")

-- scoreboard
AddCSLuaFile("cl_scoreboard.lua")

-- map votes
AddCSLuaFile("mapvote/sh_mapvote.lua")
AddCSLuaFile("mapvote/cl_mapvote.lua")

include("mapvote/sh_mapvote.lua")
include("mapvote/sv_mapvote.lua")

-- derma
AddCSLuaFile("cl_derma.lua")

for _,fileName in ipairs(file.Find("gamemodes/deathrun/gamemode/derma/dr_*.lua","GAME") or {}) do
	AddCSLuaFile("derma/" .. fileName)
end

-- commands
include("sv_commands.lua")

-- Round System
AddCSLuaFile("roundsystem/sh_roundsystem.lua")
AddCSLuaFile("roundsystem/cl_roundsystem.lua")

include("roundsystem/sh_roundsystem.lua")
include("roundsystem/sv_roundsystem.lua")

-- zones
AddCSLuaFile("zones/sh_zone.lua")
AddCSLuaFile("zones/cl_zone.lua")

include("zones/sh_zone.lua")
include("zones/sv_zone.lua")

-- player
include("sv_player.lua")

-- button claiming
AddCSLuaFile("buttonclaiming/sh_buttonclaiming.lua")
AddCSLuaFile("buttonclaiming/cl_buttonclaiming.lua")

include("buttonclaiming/sh_buttonclaiming.lua")
include("buttonclaiming/sv_buttonclaiming.lua")

-- announcements
AddCSLuaFile("cl_announcer.lua")

-- pointshop support
include("sv_pointshopsupport.lua")

-- statistics
AddCSLuaFile("statistics/sh_statistics.lua")
AddCSLuaFile("statistics/cl_statistics.lua")

include("statistics/sh_statistics.lua")
include("statistics/sv_statistics.lua")

util.AddNetworkString("DeathrunChatMessage")
util.AddNetworkString("DeathrunSyncMutelist")
util.AddNetworkString("DeathrunNotification")
util.AddNetworkString("DeathrunSpectatorNotification")
util.AddNetworkString("DeathrunForceSpectator")
util.AddNetworkString("DeathrunAddKillNote")

-- required configz
RunConsoleCommand("sv_friction",8)
RunConsoleCommand("sv_sticktoground",0)
RunConsoleCommand("sv_airaccelerate",0)
RunConsoleCommand("sv_gravity",800)

local ConVars = DR.ConVars

local CvAllTalk = ConVars.AllTalk
local CvDeathModel = ConVars.DeathModel
local CvDrownTimer = ConVars.DrownTimer
local CvIdleTimer = ConVars.IdleTimer
local CvDisableDefaultDeathSpeed = DR.ConVars.DisableDefaultDeathSpeed

local PlayerModels = {
	"models/player/group01/male_01.mdl",
	"models/player/group01/male_02.mdl",
	"models/player/group01/male_03.mdl",
	"models/player/group01/male_04.mdl",
	"models/player/group01/male_05.mdl",
	"models/player/group01/male_06.mdl",
	"models/player/group01/male_07.mdl",
	"models/player/group01/male_08.mdl",
	"models/player/group01/male_09.mdl",
	"models/player/group01/female_01.mdl",
	"models/player/group01/female_02.mdl",
	"models/player/group01/female_03.mdl",
	"models/player/group01/female_04.mdl",
	"models/player/group01/female_05.mdl",
	"models/player/group01/female_06.mdl",
}
local PlayerModelCount = #PlayerModels

hook.Add("PlayerInitialSpawn","DeathrunPlayerInitialSpawn",function(ply)
	ply.FirstSpawn = true
	ply:SetTeam(DR_TEAM_SPECTATOR)

	DR.ChatBroadcast(ply:Nick() .. " has joined the server.")
end)

hook.Add("PlayerDisconnected","DeathrunPlayerDisconnectMessage",function(ply)
	DR.ChatBroadcast(ply:Nick() .. " has left the server.")
end)

hook.Add("PlayerSpawn","DeathrunSetPlayerModels",function(ply)
	local plyTeam = ply:Team()

	if plyTeam == DR_TEAM_DEATH then
		local mdl = CvDeathModel:GetString()

		if string.sub(mdl,-4,-1) == ".mdl" then
			ply:SetModel(mdl)
		else
			print("The default death model is not a valid .mdl file ('" .. mdl .. "'). Please change the deathrun_death_model ConVar.")
		end
	elseif plyTeam == DR_TEAM_RUNNER then
		ply:SetModel(PlayerModels[PlayerModelCount])
	end

	local mdl = hook.Run("ChangePlayerModel",ply)

	if mdl then
		ply:SetModel(mdl)
	else
		-- don't override the current set model if there is one
		if not ply:GetModel() or ply:GetModel() == "models/player.mdl" then
			print("Player " .. ply:Nick() .. " did not have a model - setting them a new one.")

			ply:SetModel(PlayerModels[PlayerModelCount])
		end
	end
end)

local function SpawnSpectator(ply)
	ply:KillSilent()
	ply:SetTeam(DR_TEAM_SPECTATOR)
	ply:BeginSpectate()

	return GAMEMODE:PlayerSpawnAsSpectator(ply)
end

local SpecBuffer = DR.SpecBuffer or {}
DR.SpecBuffer = SpecBuffer

local function FixSpecBuffer()
	-- SUDDENTLY SPECTATOR IS MAGICALLY FIXED
	for idx,spectator in ipairs(SpecBuffer) do
		if not IsValid(spectator) then continue end

		SpawnSpectator(spectator)
		SpecBuffer[idx] = nil
	end
end

hook.Add("PlayerSpawn","DeathrunPlayerSpawn",function(ply)
	local plyTeam = ply:Team()

	-- GhostMode compatibility
	if GhostMode and plyTeam == DR_TEAM_GHOST then
		ply:ConCommand("deathrun_spectate_only 0")
		ply:StopSpectate()

		return
	elseif ply:ShouldStaySpectating() then
		return SpawnSpectator(ply)
	end

	ply:SetRenderMode(RENDERMODE_TRANSALPHA)
	ply:AllowFlashlight(true)
	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetNoCollideWithTeammates(true) -- so we don't block eachother's bhopes
	ply:SetLagCompensated(true)

	if ply.FirstSpawn then
		ply.FirstSpawn = false

		local roundState = ROUND.GetCurrent()

		if roundState == DR_ROUND_ACTIVE or roundState == DR_ROUND_OVER then
			--print("firstspawn, spawning as spectator.")
			SpecBuffer[#SpecBuffer + 1] = ply

			timer.Simple(0,FixSpecBuffer)

			return SpawnSpectator(ply)
		else
			ply:SetTeam(DR_TEAM_RUNNER)
		end

		hook.Run("PlayerLoadout",ply)
	elseif ply.JustDied then
		ply:BeginSpectate()
	elseif ply:ShouldStaySpectating() then
		return SpawnSpectator(ply)
	else
		ply:StopSpectate()

		hook.Run("PlayerLoadout",ply)
	end

	if
		plyTeam ~= DR_TEAM_RUNNER
	and	plyTeam ~= DR_TEAM_DEATH
	and	plyTeam ~= DR_TEAM_SPECTATOR
	then
		ply:SetTeam(DR_TEAM_RUNNER)
	end

	local spawns = team.GetSpawnPoints(plyTeam) or {}
	local spawnsCount = #spawns

	if spawnsCount <= 0 then return end

	ply:SetPos(spawns[math.random(spawnsCount)]--[[@cast -?]]:GetPos())
end)

function GM:PlayerLoadout(ply)
	local plyTeam = ply:Team()

	ply:StripWeapons()
	ply:RemoveAllAmmo()
	ply:Give(ConVars.StartingWeapon:GetString() or "weapon_crowbar")

	ply:SetPlayerColor(team.GetColor(plyTeam):ToVector())

	-- run speeds and jump powah
	ply:SetRunSpeed(250)
	ply:SetWalkSpeed(250)
	ply:SetJumpPower(290)

	if plyTeam == DR_TEAM_DEATH then
		ply:SetRunSpeed(ConVars.DeathSprint:GetFloat())
	end

	ply:DrawViewModel(true)
	ply:SetupHands(ply)

	hook.Run("DeathrunPlayerLoadout",ply)
end

hook.Add("AcceptInput","DeathrunKillers",function(ent,_,_,caller)
	ent.LastCaller = caller
end)

local CausesOfDeath = {
	"Natural causes",
	"Inappropriate yelling",
	"Vehicular homicide",
	"Bio-engineered assault turtles with acid breath",
	"Dark and mysterious forces beyond our control",
	"Joe Biden",
	"The cool, refreshing taste of Pepsi®",
	"The Patriarchy",
	"The rains down in Africa",
	"The horses",
	"A saxophone solo",
}

function GM:PlayerDeath(ply,inflictor,attacker)
	ply:Extinguish()

	ply:EmitSound("Deathrun.PlayerDeath")
	ply:SetupHands(nil)
	ply:DrawViewModel(false)
	if ply:Team() == DR_TEAM_SPECTATOR then
		ply:Spawn()
		ply:BeginSpectate()
		return
	end

	timer.Simple(5,function()
		-- incase they die and disconnect, prevents console errors.
		if not IsValid(ply) then return end

		if not ply:Alive() then
			ply.JustDied = true

			ply:BeginSpectate()

			local pool = {}

			for _,tPly in player.Iterator() do
				if
					not tPly:Alive()
				or	tPly:GetSpectate()
				then continue end

				pool[#pool + 1] = tPly
			end

			local poolCount = #pool

			if poolCount > 0 then
				local randPly = pool[math.random(poolCount)]

				ply:SpectateEntity(randPly)
				ply:SetupHands(randPly)
				ply:SetObserverMode(OBS_MODE_IN_EYE)
				ply:SetPos(randPly--[[@cast -?]]:GetPos())
			end

			ply.JustDied = false
			hook.Run("DeathrunDeadToSpectator",ply)
		end
	end)

	local lastCaller = inflictor.LastCaller

	if lastCaller and lastCaller.User then
		attacker = lastCaller.User
	end

	-- support for when traps kill players
	hook.Run("DeathrunPlayerDeath",ply,inflictor,attacker)

	if IsValid(attacker) then
		if attacker:IsPlayer() then
			attackerName = attacker:Nick()
		else
			attackerName = CausesOfDeath[math.random(#CausesOfDeath)]
		end
	end

	DR.DeathNotification(attackerName .. "\t" .. "✕" .. "\t" .. ply:Nick(),1)
end

function DR.DeathNotification(msg,mod)
	net.Start("DeathrunAddKillNote")
		net.WriteString(msg or 'nil')
		net.WriteInt(mod or 1,8)
	net.Broadcast()
end

function GM:PlayerDeathThink(ply)
	return false
end

function GM:CanPlayerSuicide(ply)
	local plyTeam = ply:Team()

	if
		( -- don't let dead players or spectators suicide
			not ply:Alive()
		or	ply:GetSpectate()
		)
	or	plyTeam == DR_TEAM_DEATH -- never allow suicide on death team
	or	plyTeam == DR_TEAM_GHOST -- never allow suicide on ghost team
	or	ROUND.GetCurrent() == DR_ROUND_PREP -- players cannot suicide during round prep time
	then
		return false
	end
end

-- damage hooks
function GM:EntityTakeDamage(target,dmgInfo)
	local dmgOrig = dmgInfo:GetDamage()

	if target:IsPlayer() then
		local roundState = ROUND.GetCurrent()

		if
			roundState == DR_ROUND_WAITING
		or	roundState == DR_ROUND_PREP
		then
			target:DeathrunChatPrint("You took " .. dmgInfo:GetDamage() .. " damage.")

			dmgInfo:SetDamage(0)
		end

		local attacker = dmgInfo:GetAttacker()

		if
			attacker ~= target
		and	attacker:IsPlayer()
		and attacker:Team() == target:Team()
		then
			dmgInfo:SetDamage(0)

			hook.Run("DeathrunTeamDamage",attacker,target,dmgInfo,dmgOrig)
		end
	end

	--damage sounds
	if
		dmgOrig <= 0
	or	not dmgInfo:IsDamageType(DMG_DROWN)
	then return end

	-- drowning noisess
	target:EmitSound("Deathrun.PlayerDrowning")
end

-- player muting
function GM:PlayerCanHearPlayersVoice(listener,talker)
	local muteList = listener.mutelist or {}
	local result = true

	if
		table.HasValue(muteList,talker:SteamID()) -- dont transmit voices which are on the mutelist
	or	(
			not CvAllTalk:GetBool()
		and	(
				(
					talker:GetSpectate()
				and	not listener:GetSpectate()
				)
			or	(
					not talker:Alive()
				and	listener:Alive()
				)
			or	(
					talker:GetObserverMode() ~= OBS_MODE_NONE
				and	listener:GetObserverMode() == OBS_MODE_NONE
				)
			)
		)
	then
		result = false
	end

	return result,false
end

-- player muting
concommand.Add("deathrun_toggle_mute",function(ply,_,args)
	local id = args[1]
	if not id then return end

	local muteList = ply.MuteList or {}
	ply.MuteList = muteList

	local found = false

	for idx,tPly in pairs(muteList) do
		if tPly ~= id then continue end

		muteList[idx] = nil
		ply:DeathrunChatPrint("Player was unmuted.")

		found = true

		break
	end

	if not found then
		muteList[#muteList + 1] = id

		ply:DeathrunChatPrint("Player was muted.")
	end

	net.Start("DeathrunSyncMutelist")
		net.WriteTable(muteList)
	net.Send(ply)
end)

concommand.Add("strip",function(ply)
	ply:StripWeapons()
end)

local FallDamageByTeam = {
	[DR_TEAM_DEATH] = 0,
	[DR_TEAM_GHOST] = 0,
}

function GM:GetFallDamage(ply,speed)
	return
		FallDamageByTeam[ply:Team()]
	or	hook.Run("DeathrunFallDamage",ply,speed)
	or 	math.max(0,math.ceil(.2418 * speed - 141.75))
end

function GM:OnPlayerHitGround(ply)
	return ply:Team() == DR_TEAM_GHOST or nil
end

-- Function Key Binds
hook.Add("ShowTeam","DeathrunSettingsBind",function(ply)
	ply:ConCommand("deathrun_open_settings")
end)

hook.Add("ShowHelp","DeathrunHelpBind",function(ply)
	ply:ConCommand("deathrun_open_help")
end)

local UndroppableWeapons = {
	["weapon_crowbar"] = true,
	["weapon_knife"] = true,
}

concommand.Add("deathrun_dropweapon",function(ply)
	local weapon = ply:GetActiveWeapon()

	if
		not (
			ply:Alive()
		and	IsValid(weapon)
		and not UndroppableWeapons[weapon:GetClass()]
		)
	then return end

	ply:DropWeapon(weapon)
end)

-- stop people whoring the weapons
hook.Add("PlayerCanPickupWeapon","StopWeaponAbuseAustraliaSaysNo",function(ply,wep)
	local wepClass = wep:GetClass()

	if
		ply:HasWeapon(wepClass)
	or	ply:Team() == DR_TEAM_GHOST
	then
		return false
	end

	--- @type table<integer,bool>
	local inventory = {}

	for _,wepInv in ipairs(ply:GetWeapons()) do
		local slot = wepInv:GetSlot()
		if slot == nil then continue end

		inventory[slot] = true
	end

	return not inventory[wep:GetSlot()]
end)

-- Something to check how long it's been since the player last did something
hook.Add("SetupMove","DeathrunIdleCheck",function(ply,mv)
	ply.LastActiveTime = ply.LastActiveTime or CurTime()

	local curButtons = mv:GetButtons()

	-- when the player stands still, mv:GetButtons() == 0, at least in binary
	-- so we can check when no keys are being pressed, or when they keys haven't changed for a while
	ply.LastButtons = ply.LastButtons or curButtons

	if
		ply.LastButtons ~= curButtons
	or	ply:GetObserverMode() ~= OBS_MODE_NONE
	then
		-- if there's a change in buttons, then they must not be afk.
		-- sometimes they can type +forward, but we know they are afk because it's constant +forward and no other keys
		ply.LastActiveTime = CurTime()
	end

	ply.LastButtons = curButtons
end)

-- return how long the player has been idle for
function DR.CheckIdleTime(ply)
	-- hotfix to prevent autokick after 22-02-2016 update
	return 0

	-- ply.LastActiveTime = ply.LastActiveTime or CurTime()
	-- return CurTime() - ply.LastActiveTime
end

timer.Create("CheckIdlePlayers",1,0,function()
	local idleTimer = CvIdleTimer:GetInt()
	local idleWarn = idleTimer - 20

	for _,ply in ipairs(DR.GetAllPlaying()) do
		local idlePly = DR.CheckIdleTime(ply)

		if math.floor(idlePly) == idleWarn then
			ply:DeathrunChatPrint("If you do not move in 20 seconds, you will be forced into spectator for being idle.")
		end

		if
			idleTimer <= idlePly
		or	ply:IsBot()
		or	ply:IsAdmin()
		or	ply:GetObserverMode() ~= OBS_MODE_NONE
		then continue end

		ply:ConCommand("deathrun_spectate_only 1")

		net.Start("DeathrunSpectatorNotification")
		net.Send(ply)

		DR.ChatBroadcast(ply:Nick() .. " was specced for being idle too long.")
	end
end)

-- Punish death avoiders
-- Bar the player for the next 3 rounds if they disconnect or idle while death.
-- this stuff gets handled in sh_definerounds.lua and shared.lua
-- Barred players are not included in DR.GetAllPlaying()
local DeathAvoidersFile = "deathrun/deathavoiders.json"

if not file.Exists(DeathAvoidersFile,"DATA") then
	file.Write(DeathAvoidersFile,"")
end

--- @alias DeathAvoiderData {
--- 	RoundsLeft: integer,
--- 	LastPunished: number,
--- }

--- @type table<string,DeathAvoiderData>
local DeathAvoiders = DR.DeathAvoiders or util.JSONToTable(file.Read(DeathAvoidersFile,"DATA")) or {
	["STEAMID_EXAMPLE"] = {
		["RoundsLeft"] = 3,
		["LastPunished"] = os.time(),
	},
}
DR.DeathAvoiders = DeathAvoiders

function DR.SaveDeathAvoiders()
	local oneDayAgo = os.time() - 86400

	for id64,data in pairs(DeathAvoiders) do
		if
			data.RoundsLeft > 0 -- remove all players with 0 rounds left
		or	data.LastPunished > oneDayAgo -- remove all players punished 24 hours ago
		then continue end

		DeathAvoiders[id64] = nil
	end

	file.Write(DeathAvoidersFile,util.TableToJSON(DeathAvoiders,true))
end

hook.Add("PostCleanupMap","SaveDeathAvoid",DR.SaveDeathAvoiders)
DR.SaveDeathAvoiders()

function DR.GetDeathAvoiderData(ply)
	local id64 = ply:SteamID64()

	--- @type DeathAvoiderData
	local data = DeathAvoiders[id64] or {
		["RoundsLeft"] = 0,
		["LastPunished"] = -1,
	}
	DeathAvoiders[id64] = data

	return data
end

function DR.PunishDeathAvoid(ply,amt)
	local data = DR.GetDeathAvoiderData(ply)

	data.RoundsLeft = data.RoundsLeft + (amt or 1)
	data.LastPunished = os.time()
end

function DR.PardonDeathAvoid(ply,amt)
	DR.PunishDeathAvoid(ply,-(amt or 1))
end

-- returns how many rounds they still need to serve as punishment
function DR.GetDeathAvoiderRounds(ply)
	local data = DR.GetDeathAvoiderData(ply)

	return
		data ~= nil
	and	data.RoundsLeft
	or	0
end

function DR.GetOnlineDeathAvoiders()
	--- @type Player[]
	local poolPly = {}

	for _,ply in player.Iterator() do
		if
			DR.GetDeathAvoiderRounds(ply) <= 0
		or	ply:ShouldStaySpectating()
		then continue end

		poolPly[#poolPly + 1] = ply
	end

	return poolPly
end

concommand.Add("test_avoid",function(ply)
	DR.PunishDeathAvoid(ply,10)
end)

-- Drowning compatibility
-- Needs a timer to check for last time not submerged
-- If it exceeds <drowntime> then start taking 10 damage per second

local DrowningViewPunch = Angle(0,0,0)

timer.Create("DeathrunDrowningStuff",.5,0,function()
	local curTime = CurTime()
	local drownTimer = CvDrownTimer:GetInt()

	for _,ply in player.Iterator() do
		local lastOxygenTime = ply.LastOxygenTime or curTime

		if
			not ply:Alive()
		or	ply:GetSpectate()
		or	ply:WaterLevel() < 3 -- Completely submerged
		then
			lastOxygenTime = curTime
		elseif curTime - lastOxygenTime > drownTimer then
			local dmgInfo = DamageInfo()

			dmgInfo:SetDamage(5)
			dmgInfo:SetDamageType(DMG_DROWN)

			DrowningViewPunch[3] = math.random(-1,1)

			ply:TakeDamageInfo(dmgInfo)
			ply:ViewPunch(DrowningViewPunch)
		end

		ply.LastOxygenTime = lastOxygenTime
	end
end)

concommand.Add("deathrun_not_amused",function(ply)
	if
		not ply:Alive()
	or	ply:GetSpectate()
	then return end

	local curTime = CurTime()
	local lastNotAmused = ply.LastNotAmused or 0

	if curTime - lastNotAmused > 3 then
		ply:EmitSound("Deathrun.NotAmused")

		lastNotAmused = curTime
	end

	ply.LastNotAmused = lastNotAmused
end)

net.Receive("DeathrunForceSpectator",function(len,ply)
	if DR.CanAccessCommand(ply,"deathrun_force_spectate") then
		local target = net.ReadPlayer()
		if not target then return end
		--- @cast target -boolean

		target:ConCommand("deathrun_spectate_only 1")

		ply:DeathrunChatPrint("Forced " .. target:Nick() .. " to the spectator team!")
	else
		ply:DeathrunChatPrint("You don't have access to this.")
	end
end)

function DR.RemoveSpeedMods()
	if not CvDisableDefaultDeathSpeed:GetBool() then return end

	for _,ent in ipairs(ents.FindByClass("player_speedmod")) do
		SafeRemoveEntity(ent)
	end
end

hook.Add("InitPostEntity","DeathrunRemoveSpeedMods",DR.RemoveSpeedMods)
hook.Add("PostCleanupMap","DeathrunRemoveSpeedMods",DR.RemoveSpeedMods)

concommand.Add("deathrun_internal_set_autojump",function(ply,_,args)
	local bool = args[1]
	if not bool then return end

	ply.AutoJumpEnabled = tobool(bool)
end)
