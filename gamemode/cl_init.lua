include("config.lua")
include("convars/sh_convars.lua")
include("convars/cl_convars.lua")
include("shared.lua")
include("cl_fonts.lua")
include("cl_derma.lua")
include("cl_scoreboard.lua")
include("mapvote/sh_mapvote.lua")
include("mapvote/cl_mapvote.lua")
include("roundsystem/sh_round.lua")
include("roundsystem/cl_round.lua")
include("sh_definerounds.lua")
include("zones/sh_zone.lua")
include("zones/cl_zone.lua")
include("cl_hud.lua")
include("cl_menus.lua")
include("buttonclaiming/sh_buttonclaiming.lua")
include("buttonclaiming/cl_buttonclaiming.lua")
include("cl_announcer.lua")
include("sh_pointshopsupport.lua")
include("sh_statistics.lua")

local CvThirdPerson_Enabled = DR.ConVars.ThirdPerson.Enabled
local CvThirdPerson_OffsetX = DR.ConVars.ThirdPerson.OffsetX
local CvThirdPerson_OffsetY = DR.ConVars.ThirdPerson.OffsetY
local CvThirdPerson_OffsetZ = DR.ConVars.ThirdPerson.OffsetZ
local CvThirdPerson_OffsetPitch = DR.ConVars.ThirdPerson.OffsetPitch
local CvThirdPerson_OffsetYaw = DR.ConVars.ThirdPerson.OffsetYaw
local CvThirdPerson_OffsetRoll = DR.ConVars.ThirdPerson.OffsetRoll
local CvThirdPerson_Opacity = DR.ConVars.ThirdPerson.Opacity
local CvThirdPerson_FadeDistance = DR.ConVars.ThirdPerson.FadeDistance

concommand.Add("deathrun_test_menu",function()
	local frame = vgui.Create("Panel")

	frame:SetSize(640,480)
	frame:Center()
	frame:MakePopup()

	frame:SetTitle("Test Window Please Ignore")
end)

function DR.ChatMessage(msg)
	chat.AddText(
		DR.Colors.Clouds,
		"[",
		DR.Colors.Turq,
		"DEATHRUN",
		DR.Colors.Clouds,
		"] ",
		msg
	)
end

net.Receive("DeathrunChatMessage",function()
	DR.ChatMessage(net.ReadString())
end)

LocalPlayer().MuteList = LocalPlayer().MuteList or {}

net.Receive("DeathrunSyncMutelist",function()
	LocalPlayer().MuteList = net.ReadTable()
end)

local function ThirdpersonCheck(ply)
	return
		CvThirdPerson_Enabled:GetBool()
	and	ply:Alive()
	and	ply:Team() ~= TEAM_SPECTATOR
end

local PosEndOffset = Vector(0,0,9)

local TraceTable = {
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

	TraceTable.start = pos
	TraceTable.endpos = posEnd
	TraceTable.filter = player.GetAll()

	CalcViewTable.origin = util.TraceHull(TraceTable).HitPos
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
	if not input.WasKeyPressed(KEY_F8) then return end

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
	return ply:Team() == TEAM_GHOST
end

cvars.AddChangeCallback("deathrun_autojump",function(_,_,new)
	RunConsoleCommand("deathrun_internal_set_autojump",tonumber(new))

	LocalPlayer().AutoJumpEnabled = tobool(new)
end,"DeathrunAutoJumpConVarChange")

RunConsoleCommand("deathrun_internal_set_autojump",DR.ConVars.AutoJump.Enabled:GetInt())

-- in case some trickery happens on the client we'll sync this right up. They can probably destroy the timer but whatever
timer.Create("DeathrunAutojumpSendToServer",5,0,function()
	RunConsoleCommand("deathrun_internal_set_autojump",DR.ConVars.AutoJump.Enabled:GetInt())
end)

cvars.AddChangeCallback("deathrun_spectate_only",function(_,_,new)
	RunConsoleCommand("deathrun_set_spectate",new)
end)

hook.Add("InitPostEntity","DeathrunSendSpectateConVarInfo",function()
	RunConsoleCommand("deathrun_set_spectate",DR.ConVars.SpectateOnly:GetInt())

	if not DR.ConVars.SpectateOnly:GetBool() then return end

	DR.OpenForcedSpectatorMenu(
		[[You are currently in spectator mode.
		To play, click on one of the buttons below,
		or visit the spectator section of the settings menu by pressing F2.
		\n\nWould you like to move back into the game?]]
	)
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
