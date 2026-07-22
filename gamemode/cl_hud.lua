print("Loading cl_hud.lua")

local DR = DR
local Colors = DR.Colors

local HUDTHEME_DEFAULT = 1
local HUDTHEME_DEFAULTTIMER = 2
local HUDTHEME_SASS = 3
local HUDTHEME_CLASSIC = 4

local HUDPOS_LEFT_TOP      = 1
local HUDPOS_LEFT_MIDDLE   = 4
local HUDPOS_LEFT_BOTTOM   = 7

local HUDPOS_CENTRE_TOP    = 2
local HUDPOS_CENTRE_MIDDLE = 5
local HUDPOS_CENTRE_BOTTOM = 8

local HUDPOS_RIGHT_TOP     = 3
local HUDPOS_RIGHT_MIDDLE  = 6
local HUDPOS_RIGHT_BOTTOM  = 9

local CvThirdPerson_Enabled = DR.ConVars.ThirdPerson.Enabled

local CvCrosshairThickness = DR.ConVars.Crosshair.Thickness
local CvCrosshairGap = DR.ConVars.Crosshair.Gap
local CvCrosshairSize = DR.ConVars.Crosshair.Size
local CvCrosshairColorR = DR.ConVars.Crosshair.ColorR
local CvCrosshairColorG = DR.ConVars.Crosshair.ColorG
local CvCrosshairColorB = DR.ConVars.Crosshair.ColorB
local CvCrosshairColorA = DR.ConVars.Crosshair.ColorA

-- start and end cues
local CvPlayRoundCues = DR.ConVars.PlayRoundCues

-- different themes
local CvHudTheme = DR.ConVars.Hud.Theme
local CvHudAlpha = DR.ConVars.Hud.Alpha

-- convars to adjust hud positioning
local CvHudMainPos = DR.ConVars.Hud.PosMain
local CvHudAmmoPos = DR.ConVars.Hud.PosAmmo

local HideElements = {
	["CHudAmmo"] = false,
	["CHudBattery"] = false,
	["CHudCrosshair"] = false,
	["CHudDamageIndicator"] = false,
	["CHudHealth"] = false,
}

hook.Add("HUDPaint","FixCHudAmmo",function()
	HideElements["CHudAmmo"] = CvHudTheme:GetInt() == HUDTHEME_CLASSIC

	hook.Remove("HUDPaint","FixCHudAmmo")
end)

cvars.AddChangeCallback("deathrun_hud_theme",function(_,_,new)
	HideElements["CHudAmmo"] = math.floor(tonumber(new)) == HUDTHEME_CLASSIC
end)

hook.Add("HUDShouldDraw","Deathrun_HUDShouldDraw",function(element)
	return HideElements[element]
end)

--- @param weapon Weapon
local function GetWeaponHUDData(ply,weapon)
	local data = {}
	local weaponTbl = weapon:GetTable()

	data.Name = weapon:GetPrintName() or "Weapon"

	data.Clip1 = weapon:Clip1() or -1
	data.Clip2 = weapon:Clip2() or -1

	data.Clip1Max = 1
	data.Clip2Max = 1

	data.Remaining1 = ply:GetAmmoCount(weapon:GetPrimaryAmmoType()) or weapon:Ammo1() or 0
	data.Remaining2 = ply:GetAmmoCount(weapon:GetSecondaryAmmoType()) or weapon:Ammo2() or 0

	data.HoldType = weaponTbl.HoldType or "melee"

	if weaponTbl.Primary then
		data.Clip1Max =
			weaponTbl.Primary.ClipSize
		or	data.Clip2Max
	end

	if weaponTbl.Secondary then
		data.Clip2Max =
			weaponTbl.Secondary.ClipSize
		or	data.Clip2Max
	end

	data.ShouldDrawHUD = data.Clip1 >= 0

	return data
end

local Distance = 0

-- redo killfeed
local KillfeedQueue = {}
local KillfeedsToCleanup = {}

local KillfeedTbl_Default = {
	["text"] = "",
	["mode"] = 1,
	["hp"] = 6,
}
local KillfeedTbl_Meta = {
	["__index"] = KillfeedTbl_Default,
}

net.Receive("DeathrunAddKillNote",function()
	DR.AddKillNote(net.ReadString(),net.ReadInt(8))
end)

function DR.AddKillNote(msg,mod)
	table.insert(KillfeedQueue,1,setmetatable({
		["text"] = msg,
		["mode"] = mod,
	},KillfeedTbl_Meta))
end

local KillfeedModeColors = {
	color_white,
	Color(0,255,0),
	Color(255,0,0),
}

function DR.DrawKillfeed(x,y)
	local dy = 0

--[[
	for _,obj in ipairs(KillfeedQueue) do
		local hp = obj.hp

		if hp <= 0 then continue end

		local fade = 1

		if hp <= 1 then
			fade = hp
		elseif hp > 5.7 then
			fade = DR.InverseLerp(hp,6,5.7)
		end

		dy = dy - 24 * fade
	end
--]]

	--local queueCountHalf = #KillfeedQueue * .5 * Distance

	for idx,obj in ipairs(KillfeedQueue) do
		obj.hp = obj.hp - Distance

		local hp = obj.hp

		if hp <= 0 then
			KillfeedsToCleanup[idx] = true

			continue
		end

		local fade = 1
		local sh = 0

		if hp <= 1 then
			fade = hp
		elseif hp > 5.7 then
			fade = DR.InverseLerp(hp,6,5.7)
			sh = 1 - fade
		end

		dy = dy + 24 * fade

		surface.SetAlphaMultiplier(fade * .75)
		DR.ShadowTextSimple(
			obj.text,
			"Deathrun_DefaultHUD_Medium",
			x,
			y + dy + sh * 16,
			KillfeedModeColors[obj.mode] or color_black,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_BOTTOM,
			1
		)
	end

	-- Handle notification cleanup separately for safety against undefined behaviour
	-- from removing and shifting table entries while iterating over the table
	for idx in next,KillfeedsToCleanup do
		table.remove(KillfeedQueue,idx)

		KillfeedsToCleanup[idx] = nil
	end

	surface.SetAlphaMultiplier(1)
end

concommand.Add("deathrun_testkillnote",function()
	DR.AddKillNote("Hello World",1)
end)

local RoundNames = {
	[ROUND_WAITING] = "Waiting for players",
	[ROUND_PREP] = "Preparing",
	[ROUND_ACTIVE] = "Time Left",
	[ROUND_OVER] = "Round Over",
}

local RoundEndData = {
	["Active"] = false,
	["BeginTime"] = 0,
}

sound.Add({
	["name"] = "DR.RoundEnd.Normal",
	["sound"] = "ambient/alarms/warningbell1.wav",
	["channel"] = CHAN_AUTO,
	["level"] = SNDLVL_NORM,
})

sound.Add({
	["name"] = "DR.RoundEnd.Stalemate",
	["sound"] = {
		"ambient/animal/cow.wav",
		"ambient/animal/dog_med_inside_bark_2.wav",
		"ambient/misc/flush1.wav",
		"npc/crow/alert2.wav",
	},
	["channel"] = CHAN_AUTO,
	["level"] = SNDLVL_NORM,
})

net.Receive("DeathrunSendMVPs",function()
	RoundEndData = net.ReadTable()

	RoundEndData.Active = true
	RoundEndData.BeginTime = CurTime()

	if CvPlayRoundCues:GetBool() then
		surface.PlaySound(
			"DR.RoundEnd." .. (
				RoundEndData.winteam == 1
			and	"Stalemate"
			or	"Normal"
			)
		)
	end

	hook.Run("DeathrunRoundWin",RoundEndData.winteam)
end)

local LastTime = CurTime()

local HudPositions = {
	[HUDPOS_LEFT_TOP]      = {},
	[HUDPOS_LEFT_MIDDLE]   = {},
	[HUDPOS_LEFT_BOTTOM]   = {},

	[HUDPOS_CENTRE_TOP]    = {},
	[HUDPOS_CENTRE_MIDDLE] = {},
	[HUDPOS_CENTRE_BOTTOM] = {},

	[HUDPOS_RIGHT_TOP]     = {},
	[HUDPOS_RIGHT_MIDDLE]  = {},
	[HUDPOS_RIGHT_BOTTOM]  = {},
}

local Vaporwave_Translate1 = Vector(0,0,0)
local Vaporwave_Translate2 = Vector(-0,-0,-0)
local Vaporwave_Rotate = Angle(0,0,0)
local Vaporwave_Scale = Vector(0,0,0)

--- @param width integer
--- @param height integer
local function UpdateScreenSize(_,_,width,height)
	DR.ScreenWidth = width
	DR.ScreenHeight = height

	local widthHalf = width * .5
	local heightHalf = height * .5

	Vaporwave_Translate1[1] = widthHalf
	Vaporwave_Translate1[2] = heightHalf
	Vaporwave_Translate2[1] = -widthHalf
	Vaporwave_Translate2[2] = -heightHalf

	local Base_Left = 8
	local Base_Centre = widthHalf - 114 -- 228 * .5
	local Base_Right = width - 236 -- 228 - 8

	local Base_Top = 8
	local Base_Middle = heightHalf - 54 -- 108 * .5
	local Base_Bottom = height - 116 -- 108 - 8

	local posLeftTop = HudPositions[HUDPOS_LEFT_TOP]
	posLeftTop[1] = Base_Left
	posLeftTop[2] = Base_Top

	local posLeftMiddle = HudPositions[HUDPOS_LEFT_MIDDLE]
	posLeftMiddle[1] = Base_Left
	posLeftMiddle[2] = Base_Middle

	local posLeftBottom = HudPositions[HUDPOS_LEFT_BOTTOM]
	posLeftBottom[1] = Base_Left
	posLeftBottom[2] = Base_Bottom

	local posCentreTop = HudPositions[HUDPOS_CENTRE_TOP]
	posCentreTop[1] = Base_Centre
	posCentreTop[2] = Base_Top

	local posCentreMiddle = HudPositions[HUDPOS_CENTRE_MIDDLE]
	posCentreMiddle[1] = Base_Centre
	posCentreMiddle[2] = Base_Middle

	local posCentreBottom = HudPositions[HUDPOS_CENTRE_BOTTOM]
	posCentreBottom[1] = Base_Centre
	posCentreBottom[2] = Base_Bottom

	local posRightTop = HudPositions[HUDPOS_RIGHT_TOP]
	posRightTop[1] = Base_Right
	posRightTop[2] = Base_Top

	local posRightMiddle = HudPositions[HUDPOS_RIGHT_MIDDLE]
	posRightMiddle[1] = Base_Right
	posRightMiddle[2] = Base_Middle

	local posRightBottom = HudPositions[HUDPOS_RIGHT_BOTTOM]
	posRightBottom[1] = Base_Right
	posRightBottom[2] = Base_Bottom
end

hook.Add("OnScreenSizeChanged","Deathrun_UpdateHudPositions",UpdateScreenSize)
UpdateScreenSize(nil,nil,ScrW(),ScrH())

function DR.DrawCrosshair(x,y)
	local thick = CvCrosshairThickness:GetFloat()
	local thickHalf = thick * .5
	local thickModX = x - thickHalf
	local thickModY = y - thickHalf

	local gap = CvCrosshairGap:GetFloat()
	local gapHalf = gap * .5

	local size = CvCrosshairSize:GetFloat()
	local sizeMod = size + gapHalf

	surface.SetDrawColor(
		CvCrosshairColorR:GetInt(),
		CvCrosshairColorG:GetInt(),
		CvCrosshairColorB:GetInt(),
		CvCrosshairColorA:GetInt()
	)
	surface.DrawRect(
		thickModX,
		y - sizeMod,
		thick,
		size
	)
	surface.DrawRect(
		thickModX,
		y + gapHalf,
		thick,
		size
	)
	surface.DrawRect(
		x + gapHalf,
		thickModY,
		size,
		thick
	)
	surface.DrawRect(
		x - sizeMod,
		thickModY,
		size,
		thick
	)
end

DR.TargetIDAlpha = 0
DR.TargetIDName = ""
DR.TargetIDColor = Color(255,255,255)

local LastTargetCycle = CurTime()
local CvHudTargetIdFadeTime = DR.ConVars.Hud.TargetIdFadeTime

function DR.DrawTargetID()
	local localPly = LocalPlayer()
	local curTime = CurTime()

	local dt = curTime - LastTargetCycle
	LastTargetCycle = curTime

	local fps = 1 / dt
	local fmul = 100 / fps

	local trace = localPly and localPly:GetEyeTrace() or {}
	local ent = trace.Entity

	if
		trace.Hit
	and	ent:IsPlayer()
	and	ent:Team() ~= TEAM_GHOST
	then
		DR.TargetIDAlpha = 255
		DR.TargetIDPlayer = ent
		DR.TargetIDName = ent:Nick()
		DR.TargetIDColor = team.GetColor(ent:Team())
	end

	local ply = DR.TargetIDPlayer

	local x = ScrW() * .5
	local y = ScrH() * .5 + 16

	local alpha = DR.TargetIDAlpha ^ .3 * 255 / 255 ^ .3
	DR.TargetIDColor.a = alpha

	local tidText =
		DR.TargetIDName
	..	(
			IsValid(ply)
		and	" - " .. tostring(math.Round(ply:Health() / ply:GetMaxHealth() * 100)) .. "%"
		or	""
		)

	DR.ShadowTextSimple(
		tidText,
		"Deathrun_DefaultHUD_Medium",
		x,
		y,
		DR.TargetIDColor,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)
	DR.ShadowTextSimple(
		tidText,
		"Deathrun_DefaultHUD_Medium",
		x,
		y,
		Color(255,255,255,alpha * .2),
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER
	)

	-- our benchmark is 100fps
	-- e.g. our fade time is 3s
	-- so each frame at 100fps the alpha is: alpha - 1 / (3s * 100f) * 255 * fmul
	DR.TargetIDAlpha = math.Clamp(DR.TargetIDAlpha - (1 / (CvHudTargetIdFadeTime:GetFloat() * 100)) * 255 * fmul,0,255)
end

local ColorDummyPlayerName = color_white:Copy()
local FadeOutDist_Start = 200 ^ 2
local FadeOutDist_End   = 750 ^ 2

function DR.DrawPlayerNames()
	local localPly = LocalPlayer()

	-- draw floating names if you're on the Death team and they are not a ghost
	-- draw them for Runners as well, but not thru walls
	local localPlyTeam = localPly:Team()
	local localPlyRunner = localPlyTeam == TEAM_RUNNER
	local localPlyAlive = localPly:Alive()

	local localPlyObsTarget = localPly:GetObserverTarget()
	local localPlyIsNotObsInEye = localPly:GetObserverMode() ~= OBS_MODE_IN_EYE

	local localPlyEyePos = localPly:EyePos()

	for _,ply in player.Iterator() do
		local plyTeam = ply:Team()
		local plyAlive = ply:Alive()
		local plyActive =
			plyAlive
		and	plyTeam ~= TEAM_SPECTATOR
		and	plyTeam ~= TEAM_GHOST

		if
			ply == localPly
		or	not (
				plyActive
			and	(
					(
						localPlyAlive
					and	plyTeam == localPlyTeam
					)
				or	(
						not localPlyRunner
					and	plyTeam ~= TEAM_GHOST
					or	not localPlyAlive
					and	(
							localPlyIsNotObsInEye
						or	ply ~= localPlyObsTarget
						)
					)
				)
			)
		then continue end

		local plyEyePos = ply:EyePos()
		local data = plyEyePos:ToScreen()

		if not data.visible then continue end

		local alpha = 0
		local dist = localPlyEyePos:DistToSqr(plyEyePos)

		if dist > FadeOutDist_End then
			continue
		elseif dist < FadeOutDist_Start then
			alpha = 255
		else
			alpha = DR.InverseLerp(dist,FadeOutDist_End,FadeOutDist_Start) * 255
		end

		local teamColor = team.GetColor(ply:Team())
		teamColor.a = alpha
		ColorDummyPlayerName.a = alpha

		local x = data.x
		local y = data.y

		DR.ShadowTextSimple(
			ply:Nick(),
			"Deathrun_DefaultHUD_Medium",
			x,
			y - 32,
			ColorDummyPlayerName,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
		DR.ShadowTextSimple(
			team.GetName(ply:Team()),
			"Deathrun_DefaultHUD_Small",
			x,
			y - 16,
			teamColor,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
	end
end

-- store these separately so we can edit their alpha values
local ColorClouds = Colors.Clouds:Copy()
local ColorAlizarin = Colors.Alizarin:Copy()
local ColorTurq = Colors.Turq:Copy()

local VelocityMax = 1000
local VelocityMaxStr = ">" .. VelocityMax
local CvAutojumpAllowed = GetConVar("deathrun_allow_autojump")

-- 228x16 text size 12
-- 228x16 text size 12
-- 32x32 text 18, 192x32 text 30
-- 32x32 text 18, 192x32 text 30
-- spacing of 4 between all
function DR.DrawPlayerHUD(x,y,alpha)
	local localPly = LocalPlayer()
	local ply = localPly

	if
		ply:GetObserverMode() ~= OBS_MODE_NONE
	and	IsValid(ply:GetObserverTarget())
	then
		ply = ply:GetObserverTarget()
	end

	local isLocalPly = ply == localPly

	local shouldDrawTime =
		isLocalPly
	and	CvHudTheme:GetInt() == HUDTHEME_DEFAULTTIMER
	and	ROUND.GetCurrent() == ROUND_ACTIVE
	and	ply:Team() == TEAM_RUNNER

	local teamColor = team.GetColor(ply:Team())
	local teamColorOrig = teamColor:Copy()
	teamColor.a = alpha

	if shouldDrawTime then
		y = y - 36 -- 32 - 4
	end

	ColorClouds.a = alpha
	ColorAlizarin.a = alpha
	ColorTurq.a = alpha

	-- Team box
	surface.SetDrawColor(teamColor)
	surface.DrawRect(
		x,
		y,
		228,
		16
	)

	surface.SetDrawColor(0,0,0,100)
	surface.DrawRect(
		x,
		y + 14,
		228,
		2
	)

	-- Team name
	local teamName

	if isLocalPly then
		teamName = team.GetName(ply:Team())
	else
		teamName = ply:Nick()
	end

	DR.ShadowTextSimple(
		teamName:upper(),
		"Deathrun_DefaultHUD_Small",
		x + 114, -- 228 * .5
		y + 8, -- 16 * .5
		Colors.Clouds,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)

	y = y + 20 -- 16 + 4

	-- Time Left
	surface.SetDrawColor(ColorClouds)
	surface.DrawRect(
		x,
		y,
		228,
		16
	)

	local roundState = RoundNames[ROUND:GetCurrent()]
	local yTimeLeftText = y + 8 -- 16 * .5

	DR.ShadowTextSimple(
		roundState and roundState:upper() or "TIME LEFT",
		"Deathrun_DefaultHUD_Small",
		x + 4,
		yTimeLeftText,
		teamColorOrig,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER
	)
	DR.ShadowTextSimple(
		string.ToMinutesSeconds(ROUND:GetTimer()),
		"Deathrun_DefaultHUD_Small",
		x + 224, -- 228 - 4
		yTimeLeftText,
		teamColorOrig,
		TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_CENTER
	)

	y = y + 20 -- 16 + 4

	local barAlpha = (alpha / 255) * 50
	local textPosShared = 16 -- 32 * .5

	local xBar = x + 36 -- 32 + 4
	local xBarLarge = xBar + 4 -- 32 + 4 + 4
	local xText = x + textPosShared

	-- HP bar
	local hpCur = ply:Health()

	surface.SetDrawColor(ColorAlizarin)
	surface.DrawRect(
		x,
		y,
		32,
		32
	)

	surface.SetDrawColor(255,255,255,barAlpha)
	surface.DrawRect(
		x,
		y,
		32,
		32
	)

	surface.SetDrawColor(ColorAlizarin)
	surface.DrawRect(
		x,
		y,
		32,
		32
	)
	surface.DrawRect(
		xBar,
		y,
		192,
		32
	)

	surface.SetDrawColor(255,255,255,barAlpha)
	surface.DrawRect(
		xBar,
		y,
		192,
		32
	)

	surface.SetDrawColor(ColorAlizarin)
	surface.DrawRect(
		xBar,
		y,
		DR.InverseLerp(hpCur,0,ply:GetMaxHealth()) * 192,
		32
	)

	-- HP text
	local yHpText = y + textPosShared

	DR.ShadowTextSimple(
		"HP",
		"Deathrun_DefaultHUD_Medium",
		xText,
		yHpText,
		Colors.Clouds,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)
	DR.ShadowTextSimple(
		hpCur,
		"Deathrun_DefaultHUD_Large",
		xBarLarge,
		yHpText,
		Colors.Clouds,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER,
		1
	)

	y = y + 36 -- 32 + 4

	-- Velocity bar
	local velCur = ply:GetVelocity():Length2D() -- Try to figure out a way to use the squared value instead
	local velStr =
		velCur > VelocityMax
	and	VelocityMaxStr
	or	math.floor(velCur)

	if
		ply.AutoJumpEnabled
	and	CvAutojumpAllowed:GetBool()
	then
		velStr = velStr .. " AUTO"
	end

	surface.SetDrawColor(ColorTurq)
	surface.DrawRect(
		x,
		y,
		32,
		32
	)

	surface.SetDrawColor(255,255,255,barAlpha)
	surface.DrawRect(
		x,
		y,
		32,
		32
	)

	surface.SetDrawColor(ColorTurq)
	surface.DrawRect(
		x,
		y,
		32,
		32
	)
	surface.DrawRect(
		xBar,
		y,
		192,
		32
	)

	surface.SetDrawColor(255,255,255,barAlpha)
	surface.DrawRect(
		xBar,
		y,
		192,
		32
	)

	surface.SetDrawColor(ColorTurq)
	surface.DrawRect(
		xBar,
		y,
		DR.InverseLerp(math.Clamp(velCur,0,VelocityMax),0,VelocityMax) * 192,
		32
	)

	-- Velocity text
	local yVelText = y + textPosShared

	DR.ShadowTextSimple(
		"VL",
		"Deathrun_DefaultHUD_Medium",
		xText,
		yVelText,
		Colors.Clouds,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)
	DR.ShadowTextSimple(
		velStr,
		"Deathrun_DefaultHUD_Large",
		xBarLarge,
		yVelText,
		Colors.Clouds,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER,
		1
	)

	if not shouldDrawTime then return end

	y = y + 36 -- 32 + 4

	surface.SetDrawColor(255,182,0,alpha)
	surface.DrawRect(
		x,
		y,
		32,
		32
	)

	surface.SetDrawColor(255,255,255,barAlpha)
	surface.DrawRect(
		x,
		y,
		32,
		32
	)

	surface.SetDrawColor(255,182,0,alpha)
	surface.DrawRect(
		x,
		y,
		32,
		32
	)
	surface.DrawRect(
		xBar,
		y,
		192,
		32
	)

	surface.SetDrawColor(255,255,255,barAlpha)
	surface.DrawRect(
		xBar,
		y,
		192,
		32
	)

	-- Time text
	local yTimeText = y + textPosShared

	DR.ShadowTextSimple(
		"TM",
		"Deathrun_DefaultHUD_Medium",
		xText,
		yTimeText,
		Colors.Clouds,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)
	DR.ShadowTextSimple(
		string.ToMinutesSecondsMilliseconds(CurTime() - (ply.StartTime or 0)),
		"Deathrun_DefaultHUD_Large",
		xBarLarge,
		yTimeText,
		Colors.Clouds,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER,
		1
	)
end

local ColorOrange = Colors.Orange:Copy()
local ColorOrangeTrans = Colors.Orange:Copy()
local ColorCloudsAmmo = Colors.Clouds:Copy()

-- 228x16 text size 12
-- 228x16 text size 12
-- 32x32 text 18, 192x32 text 30
-- 32x32 text 18, 192x32 text 30
-- spacing of 4 between all
function DR.DrawPlayerHUDAmmo(x,y,alpha)
	local localPly = LocalPlayer()
	local ply = localPly

	if
		ply:GetObserverMode() ~= OBS_MODE_NONE
	and	IsValid(ply:GetObserverTarget())
	then
		ply = ply:GetObserverTarget()
	end

	local weapon = ply:GetActiveWeapon()
	if not IsValid(weapon) then return end

	local weaponData = GetWeaponHUDData(ply,weapon)

	local holdType = weaponData.HoldType
	if
		holdType == "melee"
	or	holdType == "knife"
	then return end

	local alphaPercent = alpha / 255
	local barAlpha = alphaPercent * 50

	local textPosShared = 16 -- 32 * .5
	local textPosSharedMinusOne = textPosShared - 1

	local xBar = x + 36 -- 32 + 4

	ColorOrange.a = alpha
	ColorCloudsAmmo.a = alpha
	ColorOrangeTrans.a = alphaPercent * 200

	surface.SetDrawColor(ColorCloudsAmmo)
	surface.DrawRect(
		x,
		y,
		228,
		16
	)

	surface.SetDrawColor(ColorOrangeTrans)
	surface.DrawRect(
		x,
		y,
		228,
		16
	)

	y = y + 20 -- 16 + 4

	-- Weapon name
	surface.SetDrawColor(ColorOrange)
	surface.DrawRect(
		x,
		y,
		228,
		32
	)

	surface.SetDrawColor(255,255,255,barAlpha)
	surface.DrawRect(
		x,
		y,
		228,
		32
	)

	surface.SetDrawColor(ColorOrange)
	surface.DrawRect(
		x,
		y,
		228,
		32
	)
	DR.ShadowTextSimple(
		weaponData.Name,
		"Deathrun_DefaultHUD_Large",
		x + 224,
		y + textPosSharedMinusOne,
		Colors.Clouds,
		TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_CENTER,
		1
	)

	y = y + 36 -- 32 + 4

	local clipPercent = math.Clamp(weaponData.Clip1 / weaponData.Clip1Max,0,1)
	surface.SetDrawColor(ColorOrange)
	surface.DrawRect(
		x,
		y,
		32,
		32
	)

	surface.SetDrawColor(255,255,255,barAlpha)
	surface.DrawRect(
		x,
		y,
		32,
		32
	)

	surface.SetDrawColor(ColorOrange)
	surface.DrawRect(
		x,
		y,
		32,
		32
	)
	surface.DrawRect(
		xBar,
		y,
		192,
		32
	)

	surface.SetDrawColor(255,255,255,barAlpha)
	surface.DrawRect(
		xBar,
		y,
		192,
		32
	)

	surface.SetDrawColor(ColorOrange)
	surface.DrawRect(
		xBar,
		y,
		clipPercent * 192,
		32
	)
	DR.ShadowTextSimple(
		"AM",
		"Deathrun_DefaultHUD_Medium",
		x + textPosShared,
		y + textPosShared,
		Colors.Clouds,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)

	if weaponData.ShouldDrawHUD then
		DR.ShadowTextSimple(
			weaponData.Clip1 .. " +" .. weaponData.Remaining1,
			"Deathrun_DefaultHUD_Large",
			xBar + 192,
			y + textPosSharedMinusOne,
			Colors.Clouds,
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_CENTER,
			1
		)
	end

	y = y + 36 -- 32 + 4

	surface.SetDrawColor(ColorCloudsAmmo)
	surface.DrawRect(
		x,
		y,
		228,
		16
	)

	surface.SetDrawColor(ColorOrangeTrans)
	surface.DrawRect(
		x,
		y,
		228,
		16
	)
end

-- make a notification thing
local NotificationQueue = {}
local NotificationsToCleanup = {}

local NotificationTbl_Default = {
	["text"] = "",
	["x"] = 0,
	["y"] = 0,
	["dx"] = 0,
	["dy"] = 0,
	["ddx"] = 0,
	["ddy"] = 0,
	["dur"] = 10,
	["born"] = 0,
}
local NotificationTbl_Meta = {
	["__index"] = NotificationTbl_Default,
}

--[[
function dirac(x,a)
	if a <= .001 then a = .001 end

	return (1 / (a * math.sqrt(math.pi))) * math.exp(-x ^ 2 / a ^ 2)
end

net.Receive("DeathrunNotification",function()
	DR.AddNotification(net.ReadString(),ScrW() - 32,ScrH() / 6,0,-.35,0,-.00025,10)
end)
--]]

local ColorNotif = Color(0,255,0)

--- @param msg string
--- @param x number
--- @param y number
--- @param dx number
--- @param dy number
--- @param ddx number
--- @param ddy number
--- @param dur number
function DR.AddNotification(msg,x,y,dx,dy,ddx,ddy,dur)
	msg = msg:Replace("%newline%","\n")

	NotificationQueue[#NotificationQueue + 1] = setmetatable({
		["text"] = msg,
		["x"] = x,
		["y"] = y,
		["dx"] = dx,
		["dy"] = dy,
		["ddx"] = ddx,
		["ddy"] = ddy,
		["dur"] = dur,
		["born"] = CurTime(),
	},NotificationTbl_Meta)

	MsgC(ColorNotif,msg .. "\n")
end

concommand.Add("deathrun_test_notification",function(_,_,args)
	local msg = ""

	for idx = 1,#args do
		msg = msg .. args[idx] .. " "
	end

	DR.AddNotification(
		msg,
		ScrW() * .5,
		ScrH() * .5,
		0,
		0,
		0,
		0,
		10
	)
end)

local LastCycle = CurTime()

local ColorNotifBlack = color_black:Copy()
local ColorNotifWhite = color_white:Copy()

function DR.DrawNotifications()
	local curTime = CurTime()

	local fadeMul = 100 / (1 / (curTime - LastCycle))
	LastCycle = curTime

	for idx,notif in ipairs(NotificationQueue) do
		local text = notif.text
		local x = notif.x
		local y = notif.y
		local dx = notif.dx
		local dy = notif.dy
		local timeElapsed = curTime - notif.born

		local fadeIn = math.Clamp(Lerp(DR.InverseLerp(timeElapsed,0,.5),0,255),0,255)
		ColorNotifBlack.a = fadeIn
		ColorNotifWhite.a = fadeIn

		DR.ShadowTextSimple(
			text,
			"Deathrun_DefaultHUD_Medium",
			x + 1,
			y + 1,
			ColorNotifBlack,
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_BOTTOM
		)
		DR.ShadowTextSimple(
			text,
			"Deathrun_DefaultHUD_Medium",
			x,
			y,
			ColorNotifWhite,
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_BOTTOM
		)

		notif.x = x + dx * fadeMul
		notif.y = y + dy * fadeMul
		notif.dx = dx + notif.ddx * fadeMul
		notif.dy = dy + notif.ddy * fadeMul

		if notif.dur > timeElapsed then continue end

		NotificationsToCleanup[idx] = true
	end

	-- Handle notification cleanup separately for safety against undefined behaviour
	-- from removing and shifting table entries while iterating over the table
	for idx in next,NotificationsToCleanup do
		table.remove(NotificationQueue,idx)

		NotificationsToCleanup[idx] = nil
	end
end

local WinnerWidth = 628
local WinnerHeight = 88
local WinnerMh = 24
local WinnerGap = 4

local WinnerHeightHalf = WinnerHeight * .5
local WinnerHeightGap = WinnerHeight + WinnerGap

local WinnerMhHalf = WinnerMh * .5
local WinnerMhHalfMinusOne = WinnerMhHalf - 1

local WinnerGapMh = WinnerGap + WinnerMh

local ColorStalemate = Colors.Grey

function DR.DrawWinners(winteam,tbl_mvps,x,y,stalemate)
	local teamColor = stalemate and ColorStalemate or team.GetColor(winteam)

	local xWidthHalf = x + WinnerWidth * .5
	local yHeightGap = y + WinnerHeightGap

	surface.SetDrawColor(teamColor)
	surface.DrawRect(
		x,
		y,
		WinnerWidth,
		WinnerHeight
	)
	DR.ShadowTextSimple(
		stalemate and "STALEMATE!" or (team.GetName(winteam) .. " win the round!"):upper(),
		"Deathrun_DefaultHUD_ExtraLarge",
		xWidthHalf,
		y + WinnerHeightHalf,
		Colors.Clouds,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)

	surface.SetDrawColor(Colors.Clouds)
	surface.DrawRect(
		x,
		yHeightGap,
		WinnerWidth,
		WinnerMh
	)
	DR.ShadowTextSimple(
		stalemate and "YOU'RE ALL TERRIBLE!" or "MOST VALUABLE PLAYERS",
		"Deathrun_DefaultHUD_Medium",
		xWidthHalf,
		yHeightGap + WinnerMhHalfMinusOne,
		teamColor,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		0
	)

	if stalemate then return end

	surface.SetDrawColor(Colors.Clouds)
	surface.DrawRect(
		x,
		yHeightGap,
		WinnerWidth,
		WinnerMh
	)
	-- DR.ShadowTextSimple( "NOTABLE PLAYERS", "Deathrun_DefaultHUD_Medium", x + w/2, y + h + gap +mh/2 - 1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )

	-- Draw MVPs
	surface.SetDrawColor(teamColor)

	for idx,mvp in ipairs(tbl_mvps) do
		local offsetY = yHeightGap + WinnerGapMh * idx

		surface.DrawRect(
			x,
			offsetY,
			WinnerWidth,
			WinnerMh
		)
		DR.ShadowTextSimple(
			mvp,
			"Deathrun_DefaultHUD_Medium",
			xWidthHalf,
			offsetY + WinnerMhHalfMinusOne,
			Colors.Clouds,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER,
			1
		)
	end
end

function GM:HUDWeaponPickedUp(wep)
	DR.AddKillNote("+ " .. (wep.PrintName or "Weapon"),2)
end

function GM:HUDAmmoPickedUp(name,amt)
	DR.AddKillNote("+ " .. (amt or 0) .. " " .. (name or "Ammo"),2)
end

if IsValid(DR.HudAvatar) then
	DR.HudAvatar:Remove()
end

local Avatar = vgui.Create("AvatarImage")
DR.HudAvatar = Avatar

Avatar:SetSize(46,46)
Avatar:SetPos(0,0)
Avatar:SetPlayer(LocalPlayer(),64)
Avatar.Player = LocalPlayer()
Avatar.Visible = true
Avatar.DesiredPos = {-128,0}

function Avatar:Think()
	local ply = LocalPlayer()

	if
		not (
			IsValid(ply)
		and	self.DesiredPos
		)
	then return end

	local obsTarget = ply:GetObserverTarget()

	if
		ply:GetObserverMode() ~= OBS_MODE_NONE
	and	IsValid(obsTarget)
	then
		ply = obsTarget
	end

	if ply ~= self.Player then
		self.Player = ply

		self:SetPlayer(ply,64)
	end

	self:SetAlpha(CvHudAlpha:GetInt())

	local hudThemeIsSass = CvHudTheme:GetInt() == HUDTHEME_SASS
	local posX,newVal

	if hudThemeIsSass and not self.Visible then
		posX = self.DesiredPos[1] or 0
		newVal = true
	elseif not hudThemeIsSass and self.Visible then
		posX = -128
		newVal = false
	else return end

	self:SetPos(posX,self.DesiredPos[2] or 0)
	self.Visible = newVal
end

local ColorDarkGrey = Colors.DarkGrey:Copy()
local ColorLightGrey = Colors.LightGrey:Copy()

function DR.DrawPlayerHUDMainSass(x,y,alpha)
	-- dimensions:
	-- 228 x 108
	local ply = LocalPlayer()
	if ply:GetObserverMode() ~= OBS_MODE_NONE then if IsValid(ply:GetObserverTarget()) then ply = ply:GetObserverTarget() end end

	local w,h = 228,108
	local amul = alpha / 255
	surface.SetDrawColor(255,0,0)
	-- surface.DrawOutlinedRect( x,y,w,h )
	ColorDarkGrey.a = alpha
	surface.SetDrawColor(ColorDarkGrey)
	-- size of avatar: 46x46
	-- size of container: 48x48
	draw.RoundedBox(2,x + 8,y + h * .5 - 24,48,48,ColorDarkGrey)
	-- hp bar
	-- width 228 - 16 - 48
	-- height 20
	ColorLightGrey.a = alpha * .5
	draw.RoundedBox(2,x + 8 + 48,y + h * .5 - 10,228 - 16 - 48,20,ColorDarkGrey)
	surface.SetDrawColor(ColorLightGrey)
	surface.DrawRect(x + 8 + 48,y + h * .5 - 10 + 2,228 - 16 - 48 - 2,16)
	-- velocity
	draw.RoundedBox(2,x + 8 + 48,y + h * .5 + 8,228 - 16 - 48,10,ColorDarkGrey)
	surface.SetDrawColor(ColorLightGrey)
	surface.DrawRect(x + 8 + 48,y + h * .5 + 8 + 2,228 - 16 - 48 - 2,6)
	local maxvel = 1500 -- yeah fuck yall
	local curvel = math.Round(math.Clamp(ply:GetVelocity():Length2D(),0,maxvel))
	local velfrac = DR.InverseLerp(curvel,0,maxvel)
	surface.SetDrawColor(Color(50,50,255,alpha))
	surface.DrawRect(x + 8 + 48,y + h * .5 + 8 + 2,(228 - 16 - 48 - 2) * velfrac,6)
	surface.SetDrawColor(Color(255,255,255,5 * amul))
	surface.DrawRect(x + 8 + 48,y + h * .5 + 8 + 2,(228 - 16 - 48 - 2) * velfrac,2)
	local maxhp = 100 -- yeah fuck yall
	local curhp = math.Clamp(ply:Health(),0,999)
	local hpfrac = math.Clamp(DR.InverseLerp(curhp,0,maxhp),0,1)
	surface.SetDrawColor(Color(50,255,50,alpha))
	surface.DrawRect(x + 8 + 48,y + h * .5 - 10 + 2,(228 - 16 - 48 - 2) * hpfrac,16)
	surface.SetDrawColor(Color(255,255,255,40 * amul))
	surface.DrawRect(x + 8 + 48,y + h * .5 - 10 + 2,(228 - 16 - 48 - 2) * hpfrac,7)
	-- HP TEXT
	DR.ShadowTextSimple(tostring(curhp),"Deathrun_SassHUD_Large",x + 128,y + h * .5 + 2,Color(255,255,255,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER,2)
	DR.ShadowTextSimple("HP","Deathrun_SassHUD_Small",x + 132,y + h * .5 + 1,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER,2)
	DR.ShadowTextSimple(tostring(curvel) .. " VL","Deathrun_SassHUD_Small",x + w - 12,y + h * .5 + 24 + 1,Color(255,255,255,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP,2)
	-- team text
	local teamtext = team.GetName(ply:Team())
	if ply ~= LocalPlayer() then -- must be spectating
		teamtext = ply:Nick()
	end

	DR.ShadowTextSimple(teamtext .. " - " .. string.ToMinutesSeconds(math.Clamp(ROUND:GetTimer(),0,99999)),"Deathrun_SassHUD_Small",x + 8,y + h * .5 + 24,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2)
	-- position avatar
	local avx,avy = Avatar:GetPos()
	if avx ~= x + 9 or avy ~= y + h * .5 - 24 + 1 then Avatar:SetPos(x + 9,y + h * .5 - 23) end

	Avatar.DesiredPos = {avx,avy}
end

function DR.DrawPlayerHUDAmmoSass(x,y)
	local w,h = 228,108
	surface.SetDrawColor(255,0,0)
	local ply = LocalPlayer()
	if ply:GetObserverMode() ~= OBS_MODE_NONE then if IsValid(ply:GetObserverTarget()) then ply = ply:GetObserverTarget() end end

	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return end

	local wepdata = GetWeaponHUDData(ply,wep)
	local tcol = team.GetColor(ply:Team())
	local dx,dy = x,y
	if IsValid(wep) then
		local frac = wepdata.Clip1 / wepdata.Clip1Max
		frac = math.Clamp(frac,0,1)
		-- print( wepdata.ShouldDrawHUD )
		if wepdata.ShouldDrawHUD == true then
			DR.ShadowTextSimple(wepdata.Name,"Deathrun_SassHUD_Small",x + w - 4,y + h - 68,Color(255,255,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM,2)
			DR.ShadowTextSimple(tostring(wepdata.Clip1) .. " +" .. tostring(wepdata.Remaining1),"Deathrun_SassHUD_Large",x + w - 4,y + h - 20,Color(255,255,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM,2)
		end
	else
		return
	end
end

function DR.DrawPlayerHUDClassic(x,y,alpha)
	local ply = LocalPlayer()
	if ply:GetObserverMode() ~= OBS_MODE_NONE then if IsValid(ply:GetObserverTarget()) then ply = ply:GetObserverTarget() end end

	local w,h = 228,108
	local amul = alpha / 255
	local hw,hh = 204,36
	draw.RoundedBox(4,x + w * .5 - hw * .5,y + h - hh,hw,hh,Color(44,44,44,175 * amul))
	draw.RoundedBox(0,x + w * .5 - hw * .5 + 4,y + h - hh + 4,hw - 8,hh - 8,Color(180,80,80,255 * amul * amul))
	local maxhp = 100 -- yeah fuck yall
	local curhp = math.Clamp(ply:Health(),0,999)
	local hpfrac = math.Clamp(DR.InverseLerp(curhp,0,maxhp),0,1)
	draw.RoundedBox(0,x + w * .5 - hw * .5 + 4,y + h - hh + 4,(hw - 8) * hpfrac,hh - 8,Color(80,180,60,255 * amul))
	DR.ShadowText(tostring(curhp > 999 and "dafuq" or math.max(curhp,0)),"Deathrun_ClassicHUD_Large",x + w * .5 - hw * .5 + 5,y + h - hh,Color(255,255,255),nil,nil,1)
	-- timer
	local timetext = string.ToMinutesSeconds(ROUND:GetTimer())
	local tw,th = hw * .5,hh * 1.25
	local tx,ty = x + w * .5 - tw * .5,y + h - hh - 4 - th
	draw.RoundedBox(4,tx,ty,tw,th,Color(44,44,44,175 * amul))
	DR.ShadowText(timetext,"Deathrun_ClassicHUD_Large",tx + tw * .5,ty + 4,Color(255,255,255),TEXT_ALIGN_CENTER,nil,1)
	local spectext = ""
	if ply ~= LocalPlayer() then spectext = ply:Nick() end

	DR.ShadowTextSimple(spectext,"Deathrun_ClassicHUD_Small",tx + tw * .5,ty,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1)
end

hook.Add("DeathrunBeginActive","ResetStartTime",function()
	LocalPlayer().StartTime = CurTime()
end)

local CvVhs7Mode = DR.ConVars.Hud.Vhs7Mode

local function RenderVhs7Mode()
	DrawSharpen(1.1,1.7)
	DrawMotionBlur(.4,.8,.005)
end

local function UpdateVhs7Mode()
	if IsValid(DR.TVBorder) then
		DR.TVBorder:Remove()

		hook.Remove("RenderScreenspaceEffects","DeathrunTVBorder")
	end

	if not CvVhs7Mode:GetBool() then return end

	local tvBorder = vgui.Create("DHTML")
	DR.TVBorder = tvBorder

	tvBorder:SetSize(ScrW(),ScrH())
	tvBorder:SetPos(0,0)
	tvBorder:OpenURL("http://arizard.github.io/overlay.html")

	hook.Add("RenderScreenspaceEffects","DeathrunTVBorder",RenderVhs7Mode)
end

cvars.AddChangeCallback("deathrun_vhs7",UpdateVhs7Mode,"DR.UpdateVhs7Mode")
UpdateVhs7Mode()

hook.Add("HUDPaintBackground","Vaporwave",function()
	local matrix = Matrix()
	local curTime = CurTime()

	matrix:Translate(Vaporwave_Translate1)

	Vaporwave_Rotate[2] = math.sin(curTime * .5) * 5
	matrix:Rotate(Vaporwave_Rotate)

	local scale = math.sin(curTime * .3) * .2 + .9
	Vaporwave_Scale[1] = scale
	Vaporwave_Scale[2] = scale
	Vaporwave_Scale[3] = scale
	matrix:Scale(Vaporwave_Scale)

	matrix:Translate(Vaporwave_Translate2)
end)

-- NOTE:
-- For those who want to add custom HUDs to the gamemode:
-- Create a function to draw your left-side hud (e.g. health, velocity, avatar) and substitute it for leftfunc.
-- Create a function to draw your righ-side hud (e.g. ammo, points) and substitute it for rightfunc.
-- leftfunc and rightfunc are both passed the parameters x and y, designating the position of their top-left corner
-- width and height should be within the values 228 and 108 respectively, e.g. 228 wide and 108 high, otherwise some clipping may occur with the edges of the screen.

--- @alias HudDrawFunc fun(x: number,y: number,alpha: number)
--- @alias HudDrawFuncTable table<integer,HudDrawFunc>

--- @param x number
--- @param y number
--- @param alpha number
local function HudDrawDefault(x,y,alpha)
end

--- @type HudDrawFuncTable
local HudDrawFuncs_Default = {HudDrawDefault,HudDrawDefault}
local HudDrawFuncs_Meta = {
	["__index"] = HudDrawFuncs_Default,
}

--- @param hudFuncMain HudDrawFunc?
--- @param hudFuncAmmo HudDrawFunc?
local function CreateHudMetaTable(hudFuncMain,hudFuncAmmo)
	return setmetatable({hudFuncMain,hudFuncAmmo},HudDrawFuncs_Meta)
end

local HudFuncTable_DefaultHUD = CreateHudMetaTable(DR.DrawPlayerHUD,DR.DrawPlayerHUDAmmo)

--- @type table<integer,HudDrawFuncTable>
local HudDrawFunctions = {
	[HUDTHEME_DEFAULT]      = HudFuncTable_DefaultHUD,
	[HUDTHEME_DEFAULTTIMER] = HudFuncTable_DefaultHUD,
	[HUDTHEME_SASS]         = CreateHudMetaTable(DR.DrawPlayerHUDMainSass,DR.DrawPlayerHUDAmmoSass),
	[HUDTHEME_CLASSIC]      = CreateHudMetaTable(DR.DrawPlayerHUDClassic),
}
DR.HudDrawFunctions = HudDrawFunctions

-- make it easy to add new HUDs
--- @param hudFuncMain HudDrawFunc? health, velocity
--- @param hudFuncAmmo HudDrawFunc? ammo, points
function DR.AddCustomHUD(hudFuncMain,hudFuncAmmo)
	HudDrawFunctions[#HudDrawFunctions + 1] = CreateHudMetaTable(hudFuncMain,hudFuncAmmo)
end

local TWO_THIRDS = 2 / 3
local WinnerOffset = 628 * .5

function GM:HUDPaint()
	local curTime = CurTime()

	local scrW = ScrW()
	local scrH = ScrH()

	local scrW_Half = scrW * .5

	-- draw the crosshair
	Distance = curTime - LastTime
	LastTime = curTime

	local x,y

	-- draw crosshair and account for thirdperson mode
	if CvThirdPerson_Enabled:GetBool() then
		local hitPos = LocalPlayer():GetEyeTrace().HitPos:ToScreen()

		x = hitPos.x
		y = hitPos.y
	else
		x = scrW_Half
		y = scrH * .5
	end

	DR.DrawCrosshair(x,y)
	DR.DrawTargetID()
	DR.DrawPlayerNames()
	DR.DrawNotifications()
	DR.DrawKillfeed(scrW_Half,scrH * TWO_THIRDS)

	local hudTheme = HudDrawFunctions[CvHudTheme:GetInt()]

	if hudTheme then
		local hudMainPos = HudPositions[CvHudMainPos:GetInt()] --- @cast hudMainPos -?
		local hudAmmoPos = HudPositions[CvHudAmmoPos:GetInt()] --- @cast hudAmmoPos -?
		local alpha = CvHudAlpha:GetInt()

		hudTheme[1](hudMainPos[1],hudMainPos[2],alpha)
		hudTheme[2](hudAmmoPos[1],hudAmmoPos[2],alpha)
	end

	-- check if it's stalemate, and don't do the thing, zhu li!
	if RoundEndData.Active then
		DR.DrawWinners(
			RoundEndData.winteam,
			RoundEndData.mvps,
			scrW_Half - WinnerOffset,
			24,
			RoundEndData.winteam == 1
		)

		if curTime > RoundEndData.BeginTime + RoundEndData.duration then
			RoundEndData.Active = false
		end
	end
end
