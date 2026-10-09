local NetStart = net.Start
local NetSend = net.Send
local NetWriteBool = net.WriteBool

local PlayerIterator = player.Iterator

local DR = DR

local RoundSystem = DR.RoundSystem

local GHOST_COMMAND_BASE = "ghost"
local GHOST_COMMAND_EXCLAMATION = "!" .. GHOST_COMMAND_BASE
local GHOST_COMMAND_SLASH = "/" .. GHOST_COMMAND_BASE

RunConsoleCommand("mp_show_voice_icons",0)

util.AddNetworkString("GhostModeSendNotif")
util.AddNetworkString("GhostModeSendStart")
util.AddNetworkString("GhostModeSendEnd")

local function AddGhost(ply)
	ply:SetNWFloat("GhostPrevTeam",ply:Team())
	ply:SetTeam(DR_TEAM_GHOST)
	ply:Spawn()
	ply:SetBloodColor(DONT_BLEED)
	ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

	NetStart("GhostModeSendStart")
	NetSend(ply)
end

local function RemoveGhost(ply,silent)
	ply:KillSilent()
	ply:SetBloodColor(BLOOD_COLOR_RED)
	ply:SetCollisionGroup(COLLISION_GROUP_NONE)
	ply:SetTeam(ply:GetNWFloat("GhostPrevTeam"))
	ply:SetNWFloat("GhostPrevTeam",-1)
	ply:BeginSpectate()

	NetStart("GhostModeSendEnd")
		NetWriteBool(silent)
	NetSend(ply)
end

--- @param ply Player
--- @param status boolean
--- @param silent boolean?
local function SetGhost(ply,status,silent)
	ply:SetNWBool("IsGhost",status)
	ply:DrawShadow(not status)
	ply:SetAvoidPlayers(status)

	if status then
		AddGhost(ply)
	else
		RemoveGhost(ply,silent)
	end
end

hook.Add("PlayerSay","PlayerRequestGhostCheck",function(ply,text)
	text = text:lower()

	if text == GHOST_COMMAND_EXCLAMATION or text == GHOST_COMMAND_SLASH then
		if not ply:Alive() and RoundSystem.CurrentState == DR_ROUND_ACTIVE then
			SetGhost(ply,true)
		elseif ply:IsGhost() then
			SetGhost(ply,false)
		else
			ply:ChatPrint("You can't do that right now.")
		end

		return ""
	end
end)

local function ResetGhosts()
	for _,ply in PlayerIterator() do
		if not ply:IsGhost() then continue end

		SetGhost(ply,false,true)
	end
end

hook.Add("DeathrunBeginWaiting","ResetGhosts",ResetGhosts)
hook.Add("DeathrunBeginPrep","ResetGhosts",ResetGhosts)

hook.Add("PlayerDeath","GhostModeNotif",function(ply)
	NetStart("GhostModeSendNotif")
	NetSend(ply)
end)
