local Iterator = ipairs({})

local setmetatable = setmetatable
local tonumber = tonumber

local CurTime = CurTime
local DrawMotionBlur = DrawMotionBlur
local DrawSharpen = DrawSharpen
local FrameTime = FrameTime
local IsValid = IsValid
local Lerp = Lerp
local LocalPlayer = LocalPlayer
local Matrix = Matrix
local MsgC = MsgC
local ScrH = ScrH
local ScrW = ScrW

local DrawRoundedBox = draw.RoundedBox

local HookRun = hook.Run

local MathClamp = math.Clamp
local MathFloor = math.floor
local MathRound = math.Round
local MathSin = math.sin

local NetReadInt = net.ReadInt
local NetReadString = net.ReadString
local NetReadTable = net.ReadTable

local PlayerIterator = player.Iterator

local StringToMinutesSeconds = string.ToMinutesSeconds
local StringToMinutesSecondsMilliseconds = string.ToMinutesSecondsMilliseconds

local SurfaceDrawRect = surface.DrawRect
local SurfacePlaySound = surface.PlaySound
local SurfaceSetAlphaMultiplier = surface.SetAlphaMultiplier
local SurfaceSetDrawColor = surface.SetDrawColor

local TableInsert = table.insert
local TableRemove = table.remove

local TeamGetColor = team.GetColor
local TeamGetName = team.GetName

local DR = DR

local Colors = DR.Colors
local ConVars = DR.ConVars
local RoundSystem = DR.RoundSystem
local UI = DR.UI

local ColorClouds = Colors.Clouds
local ColorGrey = Colors.Grey

local CvFinishDuration = ConVars.FinishDuration
local CvPlayRoundCues = ConVars.PlayRoundCues

local CvAutoJump_Allowed = ConVars.AutoJump.Allow

local ConVarsCrosshair = ConVars.Crosshair
local CvCrosshair_Thickness = ConVarsCrosshair.Thickness
local CvCrosshair_Gap = ConVarsCrosshair.Gap
local CvCrosshair_Size = ConVarsCrosshair.Size
local CvCrosshair_ColorR = ConVarsCrosshair.ColorR
local CvCrosshair_ColorG = ConVarsCrosshair.ColorG
local CvCrosshair_ColorB = ConVarsCrosshair.ColorB
local CvCrosshair_ColorA = ConVarsCrosshair.ColorA

local ConVarsHud = ConVars.Hud
local CvHud_Alpha = ConVarsHud.Alpha
local CvHud_PosAmmo = ConVarsHud.PosAmmo
local CvHud_PosMain = ConVarsHud.PosMain
local CvHud_TargetIdFadeTime = ConVarsHud.TargetIdFadeTime
local CvHud_Theme = ConVarsHud.Theme
local CvHud_Vhs7Mode = ConVarsHud.Vhs7Mode

local CvThirdPerson_Enabled = ConVars.ThirdPerson.Enabled

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

local HUD = UI.HUD or {}
UI.HUD = HUD

local HideElements = {
	["CHudAmmo"] = false,
	["CHudBattery"] = false,
	["CHudCrosshair"] = false,
	["CHudDamageIndicator"] = false,
	["CHudHealth"] = false,
}

hook.Add("HUDPaint","FixCHudAmmo",function()
	HideElements["CHudAmmo"] = CvHud_Theme:GetInt() == HUDTHEME_CLASSIC

	hook.Remove("HUDPaint","FixCHudAmmo")
end)

cvars.AddChangeCallback("deathrun_hud_theme",function(_,_,new)
	HideElements["CHudAmmo"] = MathFloor(tonumber(new)) == HUDTHEME_CLASSIC
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
	HUD.AddKillNote(NetReadString(),NetReadInt(8))
end)

function HUD.AddKillNote(msg,mod)
	TableInsert(KillfeedQueue,1,setmetatable({
		["text"] = msg,
		["mode"] = mod,
	},KillfeedTbl_Meta))
end

local KillfeedModeColors = {
	color_white,
	Color(0,255,0),
	Color(255,0,0),
}

function HUD.DrawKillfeed(x,y)
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

	for idx,obj in Iterator,KillfeedQueue,0 do
		local hp = obj.hp - Distance
		obj.hp = hp

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

		SurfaceSetAlphaMultiplier(fade * .75)
		UI.ShadowTextSimple(
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
		TableRemove(KillfeedQueue,idx)

		KillfeedsToCleanup[idx] = nil
	end

	SurfaceSetAlphaMultiplier(1)
end

concommand.Add("deathrun_testkillnote",function()
	HUD.AddKillNote("Hello World",1)
end)

local RoundNames = {
	[DR_ROUND_WAITING] = "Waiting for players",
	[DR_ROUND_PREP] = "Preparing",
	[DR_ROUND_ACTIVE] = "Time Left",
	[DR_ROUND_OVER] = "Round Over",
}

--- @class RoundEndData
local RoundEndData = {
	["Active"] = false,
	["BeginTime"] = 0,
	["winteam"] = DR_WIN_STALEMATE,

	--- @type Player[]
	["mvps"] = {},
}

sound.Add({
	["name"] = "Deathrun.RoundEnd.Normal",
	["sound"] = "ambient/alarms/warningbell1.wav",
	["channel"] = CHAN_AUTO,
	["level"] = SNDLVL_NORM,
})

sound.Add({
	["name"] = "Deathrun.RoundEnd.Stalemate",
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
	RoundEndData = NetReadTable()

	RoundEndData.Active = true
	RoundEndData.BeginTime = CurTime()

	if CvPlayRoundCues:GetBool() then
		SurfacePlaySound(
			"Deathrun.RoundEnd." .. (
				RoundEndData.winteam == DR_WIN_STALEMATE
			and	"Stalemate"
			or	"Normal"
			)
		)
	end

	HookRun("DeathrunRoundWin",RoundEndData.winteam)
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

function HUD.DrawCrosshair(x,y)
	local thick = CvCrosshair_Thickness:GetFloat()
	local thickHalf = thick * .5
	local thickModX = x - thickHalf
	local thickModY = y - thickHalf

	local gap = CvCrosshair_Gap:GetFloat()
	local gapHalf = gap * .5

	local size = CvCrosshair_Size:GetFloat()
	local sizeMod = size + gapHalf

	SurfaceSetDrawColor(
		CvCrosshair_ColorR:GetInt(),
		CvCrosshair_ColorG:GetInt(),
		CvCrosshair_ColorB:GetInt(),
		CvCrosshair_ColorA:GetInt()
	)
	SurfaceDrawRect(
		thickModX,
		y - sizeMod,
		thick,
		size
	)
	SurfaceDrawRect(
		thickModX,
		y + gapHalf,
		thick,
		size
	)
	SurfaceDrawRect(
		x + gapHalf,
		thickModY,
		size,
		thick
	)
	SurfaceDrawRect(
		x - sizeMod,
		thickModY,
		size,
		thick
	)
end

DR.TargetIDAlpha = 255
DR.TargetIDColor = color_white:Copy()
DR.TargetIDName = ""
DR.TargetIDPlayer =  NULL

function HUD.DrawTargetID()
	local localPly = LocalPlayer()
	if not IsValid(localPly) then return end

	local framesPerSecond = 1 / FrameTime()
	local fadeMultiplier = 100 / framesPerSecond

	local alpha = DR.TargetIDAlpha
	local color = DR.TargetIDColor
	local name
	local ply

	local trace = localPly:GetEyeTrace()
	local ent = trace.Entity

	if
		trace.Hit
	and	ent:IsPlayer()
	and	ent:Team() ~= DR_TEAM_GHOST
	then
		alpha = 255
		ply = ent
	else
		ply = DR.TargetIDPlayer
	end

	if
		alpha > 0
	and	IsValid(ply)
	then
		name = ply:Nick()

		color = TeamGetColor(ply:Team())
		color.a = alpha ^ .3 * 255 / 255 ^ .3

		UI.ShadowText(
			name .. "\n" .. MathRound(ply:Health() / ply:GetMaxHealth() * 100) .. "%",
			"Deathrun_DefaultHUD_Medium",
			DR.ScreenWidth * .5,
			DR.ScreenHeight * .5 + 16,
			color,
			TEXT_ALIGN_CENTER
		)
	else
		ply = NULL
	end

	-- our benchmark is 100fps
	-- e.g. our fade time is 3s
	-- so each frame at 100fps the alpha is: alpha - 1 / (3s * 100f) * 255 * fmul
	DR.TargetIDAlpha = MathClamp(alpha - (1 / (CvHud_TargetIdFadeTime:GetFloat() * 100)) * 255 * fadeMultiplier,0,255)
	DR.TargetIDColor = color
	DR.TargetIDName = name
	DR.TargetIDPlayer = ply
end

local ColorDummyPlayerName = color_white:Copy()
local FadeOutDist_Start = 200 ^ 2
local FadeOutDist_End   = 750 ^ 2

function HUD.DrawPlayerNames()
	local localPly = LocalPlayer()

	-- draw floating names if you're on the Death team and they are not a ghost
	-- draw them for Runners as well, but not thru walls
	local localPlyTeam = localPly:Team()
	local localPlyRunner = localPlyTeam == DR_TEAM_RUNNER
	local localPlyAlive = localPly:Alive()

	local localPlyObsTarget = localPly:GetObserverTarget()
	local localPlyIsNotObsInEye = localPly:GetObserverMode() ~= OBS_MODE_IN_EYE

	local localPlyEyePos = localPly:EyePos()

	for _,ply in PlayerIterator() do
		local plyTeam = ply:Team()
		local plyAlive = ply:Alive()
		local plyActive =
			plyAlive
		and	plyTeam ~= DR_TEAM_SPECTATOR
		and	plyTeam ~= DR_TEAM_GHOST

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
					and	plyTeam ~= DR_TEAM_GHOST
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

		local teamColor = TeamGetColor(ply:Team())
		teamColor.a = alpha
		ColorDummyPlayerName.a = alpha

		local x = data.x
		local y = data.y

		UI.ShadowTextSimple(
			ply:Nick(),
			"Deathrun_DefaultHUD_Medium",
			x,
			y - 32,
			ColorDummyPlayerName,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
		UI.ShadowTextSimple(
			TeamGetName(ply:Team()),
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
local DefaultHud_Alizarin = Colors.Alizarin:Copy()
local DefaultHud_Turq = Colors.Turq:Copy()

local DefaultHud_Clouds_Main = ColorClouds:Copy()
local DefaultHud_Clouds_Ammo = ColorClouds:Copy()

local DefaultHud_Orange = Colors.Orange:Copy()
local DefaultHud_Orange_Transparent = Colors.Orange:Copy()

local VelocityMax = 1000
local VelocityMaxStr = ">" .. VelocityMax

-- 228x16 text size 12
-- 228x16 text size 12
-- 32x32 text 18, 192x32 text 30
-- 32x32 text 18, 192x32 text 30
-- spacing of 4 between all
local function DrawPlayerHUDMain(x,y,alpha)
	local localPly = LocalPlayer()
	local ply = localPly

	if
		ply:GetObserverMode() ~= OBS_MODE_NONE
	and	IsValid(ply:GetObserverTarget())
	then
		ply = ply:GetObserverTarget()
	end

	local isLocalPly = ply == localPly
	local plyTeam = ply:Team()

	local shouldDrawTime =
		isLocalPly
	and	CvHud_Theme:GetInt() == HUDTHEME_DEFAULTTIMER
	and	RoundSystem.GetCurrent() == DR_ROUND_ACTIVE
	and	plyTeam == DR_TEAM_RUNNER

	local teamColor = TeamGetColor(plyTeam)
	local teamColorOrig = teamColor:Copy()
	teamColor.a = alpha

	if shouldDrawTime then
		y = y - 36 -- 32 - 4
	end

	DefaultHud_Clouds_Main.a = alpha
	DefaultHud_Alizarin.a = alpha
	DefaultHud_Turq.a = alpha

	-- Team box
	SurfaceSetDrawColor(teamColor)
	SurfaceDrawRect(
		x,
		y,
		228,
		16
	)

	SurfaceSetDrawColor(0,0,0,100)
	SurfaceDrawRect(
		x,
		y + 14,
		228,
		2
	)

	-- Team name
	local teamName

	if isLocalPly then
		teamName = TeamGetName(plyTeam)
	else
		teamName = ply:Nick()
	end

	UI.ShadowTextSimple(
		teamName:upper(),
		"Deathrun_DefaultHUD_Small",
		x + 114, -- 228 * .5
		y + 8, -- 16 * .5
		ColorClouds,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)

	y = y + 20 -- 16 + 4

	-- Time Left
	SurfaceSetDrawColor(DefaultHud_Clouds_Main)
	SurfaceDrawRect(
		x,
		y,
		228,
		16
	)

	local roundState = RoundNames[RoundSystem.GetCurrent()]
	local yTimeLeftText = y + 8 -- 16 * .5

	UI.ShadowTextSimple(
		roundState and roundState:upper() or "TIME LEFT",
		"Deathrun_DefaultHUD_Small",
		x + 4,
		yTimeLeftText,
		teamColorOrig,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER
	)
	UI.ShadowTextSimple(
		StringToMinutesSeconds(RoundSystem.GetTimer()),
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
	local hpMax = ply:GetMaxHealth()

	SurfaceSetDrawColor(DefaultHud_Alizarin)
	SurfaceDrawRect(
		x,
		y,
		32,
		32
	)

	SurfaceSetDrawColor(255,255,255,barAlpha)
	SurfaceDrawRect(
		x,
		y,
		32,
		32
	)

	SurfaceSetDrawColor(DefaultHud_Alizarin)
	SurfaceDrawRect(
		x,
		y,
		32,
		32
	)
	SurfaceDrawRect(
		xBar,
		y,
		192,
		32
	)

	SurfaceSetDrawColor(255,255,255,barAlpha)
	SurfaceDrawRect(
		xBar,
		y,
		192,
		32
	)

	SurfaceSetDrawColor(DefaultHud_Alizarin)
	SurfaceDrawRect(
		xBar,
		y,
		DR.InverseLerp(MathClamp(hpCur,0,hpMax),0,hpMax) * 192,
		32
	)

	-- HP text
	local yHpText = y + textPosShared

	UI.ShadowTextSimple(
		"HP",
		"Deathrun_DefaultHUD_Medium",
		xText,
		yHpText,
		ColorClouds,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)
	UI.ShadowTextSimple(
		hpCur,
		"Deathrun_DefaultHUD_Large",
		xBarLarge,
		yHpText,
		ColorClouds,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER,
		1
	)

	y = y + 36 -- 32 + 4

	-- Velocity bar
	-- TODO: Find a way to utitilize Length2DSqr instead
	local velCur = ply:GetVelocity():Length2D()
	local velStr =
		velCur > VelocityMax
	and	VelocityMaxStr
	or	MathFloor(velCur)

	if
		ply.AutoJumpEnabled
	and	CvAutoJump_Allowed:GetBool()
	then
		velStr = velStr .. " AUTO"
	end

	SurfaceSetDrawColor(DefaultHud_Turq)
	SurfaceDrawRect(
		x,
		y,
		32,
		32
	)

	SurfaceSetDrawColor(255,255,255,barAlpha)
	SurfaceDrawRect(
		x,
		y,
		32,
		32
	)

	SurfaceSetDrawColor(DefaultHud_Turq)
	SurfaceDrawRect(
		x,
		y,
		32,
		32
	)
	SurfaceDrawRect(
		xBar,
		y,
		192,
		32
	)

	SurfaceSetDrawColor(255,255,255,barAlpha)
	SurfaceDrawRect(
		xBar,
		y,
		192,
		32
	)

	SurfaceSetDrawColor(DefaultHud_Turq)
	SurfaceDrawRect(
		xBar,
		y,
		DR.InverseLerp(MathClamp(velCur,0,VelocityMax),0,VelocityMax) * 192,
		32
	)

	-- Velocity text
	local yVelText = y + textPosShared

	UI.ShadowTextSimple(
		"VL",
		"Deathrun_DefaultHUD_Medium",
		xText,
		yVelText,
		ColorClouds,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)
	UI.ShadowTextSimple(
		velStr,
		"Deathrun_DefaultHUD_Large",
		xBarLarge,
		yVelText,
		ColorClouds,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER,
		1
	)

	if not shouldDrawTime then return end

	y = y + 36 -- 32 + 4

	SurfaceSetDrawColor(255,182,0,alpha)
	SurfaceDrawRect(
		x,
		y,
		32,
		32
	)

	SurfaceSetDrawColor(255,255,255,barAlpha)
	SurfaceDrawRect(
		x,
		y,
		32,
		32
	)

	SurfaceSetDrawColor(255,182,0,alpha)
	SurfaceDrawRect(
		x,
		y,
		32,
		32
	)
	SurfaceDrawRect(
		xBar,
		y,
		192,
		32
	)

	SurfaceSetDrawColor(255,255,255,barAlpha)
	SurfaceDrawRect(
		xBar,
		y,
		192,
		32
	)

	-- Time text
	local yTimeText = y + textPosShared

	UI.ShadowTextSimple(
		"TM",
		"Deathrun_DefaultHUD_Medium",
		xText,
		yTimeText,
		ColorClouds,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)
	UI.ShadowTextSimple(
		StringToMinutesSecondsMilliseconds(CurTime() - (ply.StartTime or 0)),
		"Deathrun_DefaultHUD_Large",
		xBarLarge,
		yTimeText,
		ColorClouds,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER,
		1
	)
end

-- 228x16 text size 12
-- 228x16 text size 12
-- 32x32 text 18, 192x32 text 30
-- 32x32 text 18, 192x32 text 30
-- spacing of 4 between all
local function DrawPlayerHUDAmmo(x,y,alpha)
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

	DefaultHud_Orange.a = alpha
	DefaultHud_Clouds_Ammo.a = alpha
	DefaultHud_Orange_Transparent.a = alphaPercent * 200

	SurfaceSetDrawColor(DefaultHud_Clouds_Ammo)
	SurfaceDrawRect(
		x,
		y,
		228,
		16
	)

	SurfaceSetDrawColor(DefaultHud_Orange_Transparent)
	SurfaceDrawRect(
		x,
		y,
		228,
		16
	)

	y = y + 20 -- 16 + 4

	-- Weapon name
	SurfaceSetDrawColor(DefaultHud_Orange)
	SurfaceDrawRect(
		x,
		y,
		228,
		32
	)

	SurfaceSetDrawColor(255,255,255,barAlpha)
	SurfaceDrawRect(
		x,
		y,
		228,
		32
	)

	SurfaceSetDrawColor(DefaultHud_Orange)
	SurfaceDrawRect(
		x,
		y,
		228,
		32
	)
	UI.ShadowTextSimple(
		weaponData.Name,
		"Deathrun_DefaultHUD_Large",
		x + 224,
		y + textPosSharedMinusOne,
		ColorClouds,
		TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_CENTER,
		1
	)

	y = y + 36 -- 32 + 4

	local clipPercent = MathClamp(weaponData.Clip1 / weaponData.Clip1Max,0,1)
	SurfaceSetDrawColor(DefaultHud_Orange)
	SurfaceDrawRect(
		x,
		y,
		32,
		32
	)

	SurfaceSetDrawColor(255,255,255,barAlpha)
	SurfaceDrawRect(
		x,
		y,
		32,
		32
	)

	SurfaceSetDrawColor(DefaultHud_Orange)
	SurfaceDrawRect(
		x,
		y,
		32,
		32
	)
	SurfaceDrawRect(
		xBar,
		y,
		192,
		32
	)

	SurfaceSetDrawColor(255,255,255,barAlpha)
	SurfaceDrawRect(
		xBar,
		y,
		192,
		32
	)

	SurfaceSetDrawColor(DefaultHud_Orange)
	SurfaceDrawRect(
		xBar,
		y,
		clipPercent * 192,
		32
	)
	UI.ShadowTextSimple(
		"AM",
		"Deathrun_DefaultHUD_Medium",
		x + textPosShared,
		y + textPosShared,
		ColorClouds,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)

	if weaponData.ShouldDrawHUD then
		UI.ShadowTextSimple(
			weaponData.Clip1 .. " +" .. weaponData.Remaining1,
			"Deathrun_DefaultHUD_Large",
			xBar + 192,
			y + textPosSharedMinusOne,
			ColorClouds,
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_CENTER,
			1
		)
	end

	y = y + 36 -- 32 + 4

	SurfaceSetDrawColor(DefaultHud_Clouds_Ammo)
	SurfaceDrawRect(
		x,
		y,
		228,
		16
	)

	SurfaceSetDrawColor(DefaultHud_Orange_Transparent)
	SurfaceDrawRect(
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

local ColorNotif = Color(0,255,0)

--- @param msg string
--- @param x number
--- @param y number
--- @param dx number
--- @param dy number
--- @param ddx number
--- @param ddy number
--- @param dur number
function HUD.AddNotification(msg,x,y,dx,dy,ddx,ddy,dur)
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

	HUD.AddNotification(
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

local ColorNotifBlack = color_black:Copy()
local ColorNotifWhite = color_white:Copy()

function HUD.DrawNotifications()
	local fadeMul = 100 / (1 / FrameTime())

	for idx,notif in Iterator,NotificationQueue,0 do
		local text = notif.text
		local x = notif.x
		local y = notif.y
		local dx = notif.dx
		local dy = notif.dy
		local timeElapsed = CurTime() - notif.born

		local fadeIn = MathClamp(Lerp(DR.InverseLerp(timeElapsed,0,.5),0,255),0,255)
		ColorNotifBlack.a = fadeIn
		ColorNotifWhite.a = fadeIn

		UI.ShadowTextSimple(
			text,
			"Deathrun_DefaultHUD_Medium",
			x + 1,
			y + 1,
			ColorNotifBlack,
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_BOTTOM
		)
		UI.ShadowTextSimple(
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
		TableRemove(NotificationQueue,idx)

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

local function DrawWinners(winteam,tbl_mvps,x,y,stalemate)
	local teamColor =
		stalemate
	and	ColorGrey
	or	TeamGetColor(winteam)

	local xWidthHalf = x + WinnerWidth * .5
	local yHeightGap = y + WinnerHeightGap
	local yHeightGapPlusMhHalfMinusOne = yHeightGap + WinnerMhHalfMinusOne

	SurfaceSetDrawColor(teamColor)
	SurfaceDrawRect(
		x,
		y,
		WinnerWidth,
		WinnerHeight
	)
	UI.ShadowTextSimple(
		stalemate and "STALEMATE!" or (TeamGetName(winteam) .. " win the round!"):upper(),
		"Deathrun_DefaultHUD_ExtraLarge",
		xWidthHalf,
		y + WinnerHeightHalf,
		ColorClouds,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)

	SurfaceSetDrawColor(ColorClouds)
	SurfaceDrawRect(
		x,
		yHeightGap,
		WinnerWidth,
		WinnerMh
	)
	UI.ShadowTextSimple(
		stalemate and "YOU'RE ALL TERRIBLE!" or "MOST VALUABLE PLAYERS",
		"Deathrun_DefaultHUD_Medium",
		xWidthHalf,
		yHeightGapPlusMhHalfMinusOne,
		teamColor,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		0
	)

	if stalemate then return end

	SurfaceSetDrawColor(ColorClouds)
	SurfaceDrawRect(
		x,
		yHeightGap,
		WinnerWidth,
		WinnerMh
	)
	UI.ShadowTextSimple(
		"MOST VALUABLE PLAYERS",
		"Deathrun_DefaultHUD_Medium",
		xWidthHalf,
		yHeightGapPlusMhHalfMinusOne,
		ColorGrey,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)

	-- Draw MVPs
	SurfaceSetDrawColor(teamColor)

	for idx,mvp in Iterator,tbl_mvps,0 do
		local offsetY = yHeightGap + WinnerGapMh * idx

		SurfaceDrawRect(
			x,
			offsetY,
			WinnerWidth,
			WinnerMh
		)
		UI.ShadowTextSimple(
			mvp,
			"Deathrun_DefaultHUD_Medium",
			xWidthHalf,
			offsetY + WinnerMhHalfMinusOne,
			ColorClouds,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER,
			1
		)
	end
end

function GM:HUDWeaponPickedUp(wep)
	HUD.AddKillNote("+ " .. (wep.PrintName or "Weapon"),2)
end

function GM:HUDAmmoPickedUp(name,amt)
	HUD.AddKillNote("+ " .. (amt or 0) .. " " .. (name or "Ammo"),2)
end

if IsValid(DR.HudAvatar) then
	DR.HudAvatar:Remove()
end

local Avatar = vgui.Create("AvatarImage")
DR.HudAvatar = Avatar

Avatar:SetSize(48,48)
Avatar:SetPos(0,0)
Avatar:SetPlayer(LocalPlayer(),64)
Avatar.Player = LocalPlayer()
Avatar.Visible = true
Avatar.DesiredPos = {
	-128,
	0,
}

function Avatar:Think()
	local ply = LocalPlayer()
	local desiredPos = self.DesiredPos

	if
		not (
			IsValid(ply)
		and	desiredPos
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

	self:SetAlpha(CvHud_Alpha:GetInt())

	local hudThemeIsSass = CvHud_Theme:GetInt() == HUDTHEME_SASS
	local posX,newVal
	local isVisible = self.Visible

	if hudThemeIsSass and not isVisible then
		posX = desiredPos[1] or 0
		newVal = true
	elseif not hudThemeIsSass and isVisible then
		posX = -128
		newVal = false
	else return end

	self:SetPos(
		posX,
		desiredPos[2] or 0
	)

	self.Visible = newVal
end

local SassHud_DarkGrey = Colors.DarkGrey:Copy()
local SassHud_LightGrey = Colors.LightGrey:Copy()

-- dimensions:
-- 228 x 108
local SassHud_Width = 228
local SassHud_WidthHalf = SassHud_Width * .5

local SassHud_BarOuter_Width = SassHud_Width - 64 -- 16 - 48
local SassHud_BarInner_Width = SassHud_BarOuter_Width - 2

local SassHud_Height = 108
local SassHud_HeightHalf = SassHud_Height * .5

local function DrawPlayerHUDMainSass(x,y,alpha)
	local localPly = LocalPlayer()
	local ply = localPly

	if
		ply:GetObserverMode() ~= OBS_MODE_NONE
	and	IsValid(ply:GetObserverTarget())
	then
		ply = ply:GetObserverTarget()
	end

	local isLocalPly = ply == localPly
	local plyTeam = ply:Team()

	y = y + SassHud_HeightHalf

	local alphaMult = alpha / 255

	SassHud_DarkGrey.a = alpha
	SassHud_LightGrey.a = alpha * .5

	-- size of avatar: 48x48
	-- size of container: 52x52
	SurfaceSetDrawColor(SassHud_DarkGrey)
	DrawRoundedBox(
		2,
		x + 4,
		y - 34,
		52,
		52,
		SassHud_DarkGrey
	)

	local xBar = x + 56

	local yHpBar = y - 8
	local yVelBar = y + 10

	-- hp bar
	-- width 164
	-- height 20
	DrawRoundedBox(
		2,
		xBar,
		y - 10,
		SassHud_BarOuter_Width,
		20,
		SassHud_DarkGrey
	)

	SurfaceSetDrawColor(SassHud_LightGrey)
	SurfaceDrawRect(
		xBar,
		yHpBar,
		SassHud_BarInner_Width,
		16
	)

	-- velocity
	DrawRoundedBox(
		2,
		xBar,
		y + 8,
		SassHud_BarOuter_Width,
		10,
		SassHud_DarkGrey
	)

	SurfaceSetDrawColor(SassHud_LightGrey)
	SurfaceDrawRect(
		xBar,
		yVelBar,
		SassHud_BarInner_Width,
		6
	)

	-- TODO: Find a way to utitilize Length2DSqr instead
	local velCur = ply:GetVelocity():Length2D()
	local velCurBreaksCap = velCur > VelocityMax

	local velCurCap =
		velCurBreaksCap
	and	VelocityMax
	or	velCur

	local velPercent = DR.InverseLerp(velCurCap,0,VelocityMax) * SassHud_BarInner_Width
	local velStr =
		(
			velCurBreaksCap
		and	VelocityMaxStr
		or	MathFloor(velCur)
		)
	..	" VL"

	SurfaceSetDrawColor(50,50,255,alpha)
	SurfaceDrawRect(
		xBar,
		yVelBar,
		velPercent,
		6
	)

	SurfaceSetDrawColor(255,255,255,5 * alphaMult)
	SurfaceDrawRect(
		xBar,
		yVelBar,
		velPercent,
		2
	)

	local hpCur = ply:Health()
	local hpMax = ply:GetMaxHealth()

	local hpPercent = DR.InverseLerp(MathClamp(hpCur,0,hpMax),0,hpMax) * SassHud_BarInner_Width

	SurfaceSetDrawColor(50,255,50,alpha)
	SurfaceDrawRect(
		xBar,
		yHpBar,
		hpPercent,
		16
	)
	SurfaceSetDrawColor(255,255,255,40 * alphaMult)
	SurfaceDrawRect(
		xBar,
		yHpBar,
		hpPercent,
		7
	)

	local xLowerText = x + 216
	local yLowerText = y + 25

	-- HP TEXT
	UI.ShadowTextSimple(
		hpCur,
		"Deathrun_SassHUD_Large",
		xLowerText - 22,
		y + 19,
		color_white,
		TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_BOTTOM,
		2
	)
	UI.ShadowTextSimple(
		"HP",
		"Deathrun_SassHUD_Small",
		xLowerText,
		yVelBar,
		color_white,
		TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_BOTTOM,
		2
	)
	UI.ShadowTextSimple(
		velStr,
		"Deathrun_SassHUD_Small",
		xLowerText,
		yLowerText,
		color_white,
		TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_TOP,
		2
	)

	-- Team name
	local teamName

	if isLocalPly then
		teamName = TeamGetName(plyTeam)
	else
		teamName = ply:Nick()
	end

	UI.ShadowTextSimple(
		teamName .. " - " .. StringToMinutesSeconds(RoundSystem.GetTimer()),
		"Deathrun_SassHUD_Small",
		x + 8,
		yLowerText,
		color_white,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_TOP,
		2
	)

	-- position avatar
	local avatarPosX,avatarPosY = Avatar:GetPos()

	local xAvatar = x + 6
	local yAvatar = y - 32

	if
		avatarPosX ~= xAvatar
	or	avatarPosY ~= yAvatar
	then
		Avatar:SetPos(
			xAvatar,
			yAvatar
		)
	end

	local desiredPos = Avatar.DesiredPos
	desiredPos[1] = avatarPosX
	desiredPos[2] = avatarPosY
end

local function DrawPlayerHUDAmmoSass(x,y)
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
	if not weaponData.ShouldDrawHUD then return end

	local xOffset = x + SassHud_Width - 4
	local yOffset = y + SassHud_Height

	UI.ShadowTextSimple(
		weaponData.Name,
		"Deathrun_SassHUD_Small",
		xOffset,
		yOffset - 68,
		color_white,
		TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_BOTTOM,
		2
	)
	UI.ShadowTextSimple(
		weaponData.Clip1 .. " +" .. weaponData.Remaining1,
		"Deathrun_SassHUD_Large",
		xOffset,
		yOffset - 20,
		color_white,
		TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_BOTTOM,
		2
	)
end

local ClassicHud_Width = 204
local ClassicHud_WidthHalf = ClassicHud_Width * .5
local ClassicHud_WidthMinus8 = ClassicHud_Width - 8
local ClassicHud_WidthQuar = ClassicHud_Width * .25

local ClassicHud_Height = 36
local ClassicHud_HeightMinus8 = ClassicHud_Height - 8
local ClassicHud_HeightMod = SassHud_Height - ClassicHud_Height

local ClassicHud_Timer_Height = ClassicHud_Height * 1.25

local ClassicHud_Background = Color(44,44,44)
local ClassicHud_HpBar_Bg = Color(180,80,80)
local ClassicHud_HpBar_Fg = Color(80,180,60)

local function DrawPlayerHUDClassic(x,y,alpha)
	local localPly = LocalPlayer()
	local ply = localPly

	if
		ply:GetObserverMode() ~= OBS_MODE_NONE
	and	IsValid(ply:GetObserverTarget())
	then
		ply = ply:GetObserverTarget()
	end

	x = x + SassHud_WidthHalf
	y = y + ClassicHud_HeightMod

	local xMinusWidthHalf = x - ClassicHud_WidthHalf
	local xMinusWidthHalfPlus4 = xMinusWidthHalf + 4

	local xMinusWidthQuar = x - ClassicHud_WidthQuar
	local xMinusWidthQuarPlusClassicHudWidthQuar = xMinusWidthQuar + ClassicHud_WidthQuar

	local yPlus4 = y + 4

	local alphaMult = alpha / 255

	ClassicHud_Background.a = 175 * alphaMult
	ClassicHud_HpBar_Bg.a = 255 * alphaMult ^ 2
	ClassicHud_HpBar_Fg.a = 255 * alphaMult

	DrawRoundedBox(
		4,
		xMinusWidthHalf,
		y,
		ClassicHud_Width,
		ClassicHud_Height,
		ClassicHud_Background
	)
	DrawRoundedBox(
		0,
		xMinusWidthHalfPlus4,
		yPlus4,
		ClassicHud_WidthMinus8,
		ClassicHud_HeightMinus8,
		ClassicHud_HpBar_Bg
	)

	local hpCur = ply:Health()
	local hpMax = ply:GetMaxHealth()

	DrawRoundedBox(
		0,
		xMinusWidthHalfPlus4,
		yPlus4,
		DR.InverseLerp(MathClamp(hpCur,0,hpMax),0,hpMax) * ClassicHud_WidthMinus8,
		ClassicHud_HeightMinus8,
		ClassicHud_HpBar_Fg
	)
	UI.ShadowText(
		hpCur,
		"Deathrun_ClassicHUD_Large",
		xMinusWidthHalf + 5,
		y,
		color_white,
		nil,
		nil,
		1
	)

	-- timer
	local timerY = y - 4 - ClassicHud_Timer_Height

	DrawRoundedBox(
		4,
		xMinusWidthQuar,
		timerY,
		ClassicHud_WidthHalf,
		ClassicHud_Timer_Height,
		ClassicHud_Background
	)
	UI.ShadowText(
		StringToMinutesSeconds(RoundSystem.GetTimer()),
		"Deathrun_ClassicHUD_Large",
		xMinusWidthQuarPlusClassicHudWidthQuar,
		timerY + 4,
		color_white,
		TEXT_ALIGN_CENTER,
		nil,
		1
	)

	UI.ShadowTextSimple(
		ply == localPly
	and	""
	or	ply:Nick()
		,
		"Deathrun_ClassicHUD_Small",
		xMinusWidthQuarPlusClassicHudWidthQuar,
		timerY,
		color_white,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1
	)
end

hook.Add("DeathrunBeginActive","ResetStartTime",function()
	LocalPlayer().StartTime = CurTime()
end)

local function RenderVhs7Mode()
	DrawSharpen(1.1,1.7)
	DrawMotionBlur(.4,.8,.005)
end

local function UpdateVhs7Mode()
	if IsValid(DR.TVBorder) then
		DR.TVBorder:Remove()

		hook.Remove("RenderScreenspaceEffects","DeathrunTVBorder")
	end

	if not CvHud_Vhs7Mode:GetBool() then return end

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

	Vaporwave_Rotate[2] = MathSin(curTime * .5) * 5
	matrix:Rotate(Vaporwave_Rotate)

	local scale = MathSin(curTime * .3) * .2 + .9
	Vaporwave_Scale:SetUnpacked(
		scale,
		scale,
		scale
	)
	matrix:Scale(Vaporwave_Scale)

	matrix:Translate(Vaporwave_Translate2)
end)

-- NOTE:
-- For those who want to add custom HUDs to the gamemode:
-- Create a function to draw your left-side hud (e.g. health, velocity, avatar) and substitute it for leftfunc.
-- Create a function to draw your righ-side hud (e.g. ammo, points) and substitute it for rightfunc.
-- leftfunc and rightfunc are both passed the parameters x and y, designating the position of their top-left corner
-- width and height should be within the values 228 and 108 respectively, e.g. 228 wide and 108 high, otherwise some clipping may occur with the edges of the screen.

--- @alias DeathrunDrawFunc fun(x: number,y: number,alpha: number)
--- @alias DeathrunDrawFuncTable DeathrunDrawFunc[]

--- @param x number
--- @param y number
--- @param alpha number
local function HudDrawDefault(x,y,alpha)
end

--- @type DeathrunDrawFuncTable
local HudDrawFuncs_Default = {HudDrawDefault,HudDrawDefault}
local HudDrawFuncs_Meta = {
	["__index"] = HudDrawFuncs_Default,
}

--- @param hudFuncMain DeathrunDrawFunc?
--- @param hudFuncAmmo DeathrunDrawFunc?
local function CreateHudMetaTable(hudFuncMain,hudFuncAmmo)
	return setmetatable({hudFuncMain,hudFuncAmmo},HudDrawFuncs_Meta)
end

local HudFuncTable_DefaultHUD = CreateHudMetaTable(DrawPlayerHUDMain,DrawPlayerHUDAmmo)

--- @type DeathrunDrawFuncTable[]
local DrawFunctions = {
	[HUDTHEME_DEFAULT]      = HudFuncTable_DefaultHUD,
	[HUDTHEME_DEFAULTTIMER] = HudFuncTable_DefaultHUD,
	[HUDTHEME_SASS]         = CreateHudMetaTable(DrawPlayerHUDMainSass,DrawPlayerHUDAmmoSass),
	[HUDTHEME_CLASSIC]      = CreateHudMetaTable(DrawPlayerHUDClassic),
}
HUD.DrawFunctions = DrawFunctions

-- make it easy to add new HUDs
--- @param hudFuncMain DeathrunDrawFunc? health, velocity
--- @param hudFuncAmmo DeathrunDrawFunc? ammo, points
function HUD.AddCustomHUD(hudFuncMain,hudFuncAmmo)
	DrawFunctions[#DrawFunctions + 1] = CreateHudMetaTable(hudFuncMain,hudFuncAmmo)
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

	HUD.DrawCrosshair(x,y)
	HUD.DrawTargetID()
	HUD.DrawPlayerNames()
	HUD.DrawNotifications()
	HUD.DrawKillfeed(scrW_Half,scrH * TWO_THIRDS)

	local hudTheme = DrawFunctions[CvHud_Theme:GetInt()]

	if hudTheme then
		local hudMainPos = HudPositions[CvHud_PosMain:GetInt()] --- @cast hudMainPos -?
		local hudAmmoPos = HudPositions[CvHud_PosAmmo:GetInt()] --- @cast hudAmmoPos -?
		local alpha = CvHud_Alpha:GetInt()

		hudTheme[1](hudMainPos[1],hudMainPos[2],alpha)
		hudTheme[2](hudAmmoPos[1],hudAmmoPos[2],alpha)
	end

	-- check if it's stalemate, and don't do the thing, zhu li!
	if RoundEndData.Active then
		DrawWinners(
			RoundEndData.winteam,
			RoundEndData.mvps,
			scrW_Half - WinnerOffset,
			24,
			RoundEndData.winteam == DR_WIN_STALEMATE
		)

		if curTime > RoundEndData.BeginTime + CvFinishDuration:GetInt() then
			RoundEndData.Active = false
		end
	end
end
