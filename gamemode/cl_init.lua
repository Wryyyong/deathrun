-- thirdperson support -- from arizard_thirdperson.lua
local CvThirdpersonEnabled = CreateClientConVar("deathrun_thirdperson_enabled",0,true,false,nil,0,1)
local CvThirdpersonOffsetX = CreateClientConVar("deathrun_thirdperson_offset_x",0,true,false,nil,-40,40)
local CvThirdpersonOffsetY = CreateClientConVar("deathrun_thirdperson_offset_y",0,true,false,nil,-40,40)
local CvThirdpersonOffsetZ = CreateClientConVar("deathrun_thirdperson_offset_z",0,true,false,nil,-75,75)
local CvThirdpersonOffsetPitch = CreateClientConVar("deathrun_thirdperson_offset_pitch",0,true,false,nil,-75,75)
local CvThirdpersonOffsetYaw = CreateClientConVar("deathrun_thirdperson_offset_yaw",0,true,false,nil,-75,75)
local CvThirdpersonOffsetRoll = CreateClientConVar("deathrun_thirdperson_offset_roll",0,true,false,nil,-75,75)
local CvThirdpersonOpacity = CreateClientConVar("deathrun_thirdperson_opacity",255,true,false,nil,5,255)
local CvThirdpersonFadeDistance = CreateClientConVar("deathrun_teammate_fade_distance",75,true,false,nil,0,512)

include("hexcolor.lua")
include("config.lua")
include("cl_fonts.lua")
include("cl_derma.lua")
include("shared.lua")
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
include("sh_buttonclaiming.lua")
include("cl_announcer.lua")
include("sh_pointshopsupport.lua")
include("sh_statistics.lua")

concommand.Add("deathrun_test_menu",function()
	local frame = vgui.Create("Panel")

	frame:SetSize(640,480)
	frame:Center()
	frame:MakePopup()

	frame:SetTitle("Test Window Please Ignore")
end)

function DR.ChatMessage(msg)
	chat.AddText(
		DR.Colors.Text.Clouds,
		"[",
		DR.Colors.Text.Turq,
		"DEATHRUN",
		DR.Colors.Text.Clouds,
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

local PosEndOFfset = Vector(0,0,9)

local TraceTable = {
	["mins"] = Vector(-5,-5,-5),
	["maxs"] = Vector(5,5,5),
	["mask"] = MASK_SHOT_HULL,
}

local function ThirdpersonCheck(ply)
	return
		CvThirdpersonEnabled:GetBool()
	and	ply:Alive()
	and	ply:Team() ~= TEAM_SPECTATOR
end

function GM:CalcView(ply,pos,ang,fov,znear,zfar)
	if not ThirdpersonCheck(ply) then return end

	local angRight = ang:Right()
	angRight:Mul(CvThirdpersonOffsetX:GetFloat())

	local angUp = ang:Up()
	angUp:Mul(CvThirdpersonOffsetY:GetFloat())

	local posEnd = pos + ang:Forward()
	posEnd:Mul(-(CvThirdpersonOffsetZ:GetFloat() + 100))
	posEnd:Add(PosEndOFfset)
	posEnd:Add(angRight)
	posEnd:Add(angUp)

	local eyeAngles = ply:EyeAngles()
	ang:RotateAroundAxis(eyeAngles:Right(),CvThirdpersonOffsetPitch:GetFloat())
	ang:RotateAroundAxis(eyeAngles:Up(),CvThirdpersonOffsetYaw:GetFloat())
	ang:RotateAroundAxis(eyeAngles:Forward(),CvThirdpersonOffsetRoll:GetFloat())

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

	return {
		["origin"] = util.TraceHull(TraceTable).HitPos,
		["angles"] = ang,
		["fov"] = targetFov,
		["znear"] = znear,
		["zfar"] = zfar,
		["drawviewer"] = true,
	}
end

function GM:ShouldDrawLocalPlayer()
	return ThirdpersonCheck(LocalPlayer())
end

local function ThirdpersonToggle()
	CvThirdpersonEnabled:SetBool(not CvThirdpersonEnabled:GetBool())
end

concommand.Add("deathrun_toggle_thirdperson",ThirdpersonToggle)

function GM:CreateMove(cmd)
	if not cmd:KeyDown(KEY_F8) then return end

	ThirdpersonToggle()
end

function GM:PrePlayerDraw(ply)
	local localPly = LocalPlayer()

	if ply:GetRenderMode() ~= RENDERMODE_TRANSALPHA then
		ply:SetRenderMode(RENDERMODE_TRANSALPHA)
	end

	local distFade = CvThirdpersonFadeDistance:GetFloat()
	local distEye = localPly:EyePos():Distance(ply:EyePos())

	local color = ply:GetColor()
	local plyIsLocalPly = ply == localPly

	if distEye < distFade and not plyIsLocalPly and ply:Team() == localPly:Team() then
		color.a = Lerp(DR.InverseLerp(distEye,5,distFade),20,255)
	elseif plyIsLocalPly then
		color.a = CvThirdpersonOpacity:GetInt()
	else
		color.a = 255
	end

	ply:SetColor(color)
end

function GM:PreDrawViewModel(vm,ply,wep)
	local obsMode = LocalPlayer():GetObserverMode()

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

--[[
concommand.Add("+menu",function()
	RunConsoleCommand("deathrun_dropweapon")
end)
--]]
