local tobool = tobool
local tonumber = tonumber

local Lerp = Lerp
local LocalPlayer = LocalPlayer
local RunConsoleCommand = RunConsoleCommand

local ChatAddText = chat.AddText

local InputWasKeyPressed = input.WasKeyPressed

local NetReadString = net.ReadString
local NetReadTable = net.ReadTable

local PlayerGetAll = player.GetAll

local UtilTraceHull = util.TraceHull

include("sh_init.lua")

include("convars/sh_convars.lua")
include("convars/cl_convars.lua")

include("config.lua")

include("shared.lua")

include("roundsystem/sh_roundsystem.lua")
include("roundsystem/cl_roundsystem.lua")

include("statistics/sh_statistics.lua")
include("statistics/cl_statistics.lua")

include("zones/sh_zone.lua")
include("zones/cl_zone.lua")

include("buttonclaiming/sh_buttonclaiming.lua")
include("buttonclaiming/cl_buttonclaiming.lua")

include("mapvote/sh_mapvote.lua")
include("mapvote/cl_mapvote.lua")

include("cl_fonts.lua")

include("cl_derma.lua")

include("cl_hud.lua")
include("cl_menus.lua")
include("cl_scoreboard.lua")

include("cl_announcer.lua")

local DR = DR

local Colors = DR.Colors
local ConVars = DR.ConVars

local ColorClouds = Colors.Clouds
local ColorTurq = Colors.Turq

local CvSpectateOnly = ConVars.SpectateOnly

local CvAutoJump_Enabled = ConVars.AutoJump.Enabled

local ConVarsThirdPerson = ConVars.ThirdPerson
local CvThirdPerson_Enabled = ConVarsThirdPerson.Enabled
local CvThirdPerson_OffsetX = ConVarsThirdPerson.OffsetX
local CvThirdPerson_OffsetY = ConVarsThirdPerson.OffsetY
local CvThirdPerson_OffsetZ = ConVarsThirdPerson.OffsetZ
local CvThirdPerson_OffsetPitch = ConVarsThirdPerson.OffsetPitch
local CvThirdPerson_OffsetYaw = ConVarsThirdPerson.OffsetYaw
local CvThirdPerson_OffsetRoll = ConVarsThirdPerson.OffsetRoll
local CvThirdPerson_Opacity = ConVarsThirdPerson.Opacity
local CvThirdPerson_FadeDistance = ConVarsThirdPerson.FadeDistance

concommand.Add("deathrun_test_menu",function()
	local frame = vgui.Create("Panel")

	frame:SetSize(640,480)
	frame:Center()
	frame:MakePopup()

	frame:SetTitle("Test Window Please Ignore")
end)

function DR.ChatMessage(msg)
	ChatAddText(
		ColorClouds,
		"[",
		ColorTurq,
		"DEATHRUN",
		ColorClouds,
		"] ",
		msg
	)
end

net.Receive("DeathrunChatMessage",function()
	DR.ChatMessage(NetReadString())
end)

LocalPlayer().MuteList = LocalPlayer().MuteList or {}

net.Receive("DeathrunSyncMutelist",function()
	LocalPlayer().MuteList = NetReadTable()
end)

local function ThirdpersonCheck(ply)
	return
		CvThirdPerson_Enabled:GetBool()
	and	ply:Alive()
	and	ply:Team() ~= DR_TEAM_SPECTATOR
end

local PosEndOffset = Vector(0,0,9)

local TraceCache = {
	["start"] = vector_origin,
	["endpos"] = vector_origin,
	["mins"] = Vector(-5,-5,-5),
	["maxs"] = Vector(5,5,5),
	["mask"] = MASK_SHOT_HULL,
}

local CalcViewTable = {
	["drawviewer"] = true,
}

function GM:CalcView(ply,pos,ang,fov,znear,zfar)
	if not ThirdpersonCheck(ply) then return end

	local angRight = ang:Right()
	angRight:Mul(CvThirdPerson_OffsetX:GetFloat())

	local angUp = ang:Up()
	angUp:Mul(CvThirdPerson_OffsetY:GetFloat())

	local angForward = ang:Forward()
	angForward:Mul(-(CvThirdPerson_OffsetZ:GetFloat() + 100))

	local posEnd = pos + PosEndOffset
	posEnd:Add(angRight)
	posEnd:Add(angUp)
	posEnd:Add(angForward)

	local eyeAngles = ply:EyeAngles()
	ang:RotateAroundAxis(eyeAngles:Right(),CvThirdPerson_OffsetPitch:GetFloat())
	ang:RotateAroundAxis(eyeAngles:Up(),CvThirdPerson_OffsetYaw:GetFloat())
	ang:RotateAroundAxis(eyeAngles:Forward(),CvThirdPerson_OffsetRoll:GetFloat())

	-- test for thirdperson scoped weapons
	local wep = ply:GetActiveWeapon()
	local targetFov = fov

	if
		wep
	and	wep.Scope
	and	wep.ScopedFOV
	and	wep:GetIronsights()
	then
		targetFov = wep.ScopedFOV
	end

	TraceCache.start = pos
	TraceCache.endpos = posEnd
	TraceCache.filter = PlayerGetAll()

	CalcViewTable.origin = UtilTraceHull(TraceCache).HitPos
	CalcViewTable.angles = ang
	CalcViewTable.fov = targetFov
	CalcViewTable.znear = znear
	CalcViewTable.zfar = zfar

	return CalcViewTable
end

function GM:ShouldDrawLocalPlayer()
	return ThirdpersonCheck(LocalPlayer())
end

local function ThirdpersonToggle()
	CvThirdPerson_Enabled:SetBool(not CvThirdPerson_Enabled:GetBool())
end

concommand.Add("deathrun_toggle_thirdperson",ThirdpersonToggle)

function GM:CreateMove()
	if not InputWasKeyPressed(KEY_F8) then return end

	ThirdpersonToggle()
end

function GM:PrePlayerDraw(ply)
	local localPly = LocalPlayer()

	if ply:GetRenderMode() ~= RENDERMODE_TRANSALPHA then
		ply:SetRenderMode(RENDERMODE_TRANSALPHA)
	end

	local color = ply:GetColor()
	local newAlpha = 255

	if ply == localPly then
		newAlpha = CvThirdPerson_Opacity:GetInt()
	elseif ply:Team() == localPly:Team() then
		local distFade = CvThirdPerson_FadeDistance:GetFloat()
		local distEye = localPly:EyePos():Distance(ply:EyePos())

		if distEye < distFade then
			newAlpha = Lerp(
				DR.InverseLerp(distEye,5,distFade),
				20,
				255
			)
		end
	end

	color.a = newAlpha

	ply:SetColor(color)
end

function GM:PreDrawViewModel(vm,ply,wep)
	if self:PreDrawPlayerHands(_,_,ply) then
		return true
	elseif wep and wep.PreDrawViewModel then
		return wep:PreDrawViewModel(vm,wep,ply,STUDIO_RENDER)
	end
end

function GM:PreDrawPlayerHands(_,_,ply)
	local obsMode = ply:GetObserverMode()

	return
		obsMode == OBS_MODE_CHASE
	or	obsMode == OBS_MODE_ROAMING
end

function GM:PlayerFootstep(ply)
	return ply:Team() == DR_TEAM_GHOST
end

cvars.AddChangeCallback("deathrun_autojump",function(_,_,new)
	RunConsoleCommand("deathrun_internal_set_autojump",tonumber(new))

	LocalPlayer().AutoJumpEnabled = tobool(new)
end,"DeathrunAutoJumpConVarChange")

RunConsoleCommand("deathrun_internal_set_autojump",CvAutoJump_Enabled:GetInt())

-- in case some trickery happens on the client we'll sync this right up. They can probably destroy the timer but whatever
timer.Create("DeathrunAutojumpSendToServer",5,0,function()
	RunConsoleCommand("deathrun_internal_set_autojump",CvAutoJump_Enabled:GetInt())
end)

cvars.AddChangeCallback("deathrun_spectate_only",function(_,_,new)
	RunConsoleCommand("deathrun_set_spectate",new)
end)

hook.Add("InitPostEntity","DeathrunSendSpectateConVarInfo",function()
	RunConsoleCommand("deathrun_set_spectate",CvSpectateOnly:GetInt())

	if not CvSpectateOnly:GetBool() then return end

	DR.UI.OpenMovedToSpectatorMenu(true)
end)

function DR.SetClientHullSizes()
	local localPly = LocalPlayer()
	local hulls = DR.Hulls

	localPly:SetHull(hulls.HullMin,hulls.HullStand)
	localPly:SetHullDuck(hulls.HullMin,hulls.HullDuck) -- quack quack
	localPly:SetViewOffset(hulls.ViewStand)
	localPly:SetViewOffsetDucked(hulls.ViewDuck) -- quack
end

concommand.Add("deathrun_reload_hull_client",DR.SetClientHullSizes)
