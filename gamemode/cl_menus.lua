local Iterator = ipairs({})

local IsFirstTimePredicted = IsFirstTimePredicted

local VguiCreate = vgui.Create

local DR = DR

local ConVars = DR.ConVars
local ZoneSystem = DR.ZoneSystem
local UI = DR.UI
local HUD = UI.HUD

local CvPlayRoundCues = ConVars.PlayRoundCues
local CvRenderZones = ConVars.RenderZones
local CvShowInfo = ConVars.ShowInfo
local CvSpectateOnly = ConVars.SpectateOnly

local ConVarsAnnouncements = ConVars.Announcements
local CvAnnouncements_Enabled = ConVarsAnnouncements.Enabled
local CvAnnouncements_Interval = ConVarsAnnouncements.Interval

local CvAutoJump_Enabled = ConVars.AutoJump.Enabled

local ConVarsCrosshair = ConVars.Crosshair
local CvCrosshair_Size = ConVarsCrosshair.Size
local CvCrosshair_Thickness = ConVarsCrosshair.Thickness
local CvCrosshair_Gap = ConVarsCrosshair.Gap

local ConVarsHud = ConVars.Hud
local CvHud_Alpha = ConVarsHud.Alpha
local CvHud_PosAmmo = ConVarsHud.PosAmmo
local CvHud_PosMain = ConVarsHud.PosMain
local CvHud_TargetIdFadeTime = ConVarsHud.TargetIdFadeTime
local CvHud_Theme = ConVarsHud.Theme
local CvHud_Vhs7Mode = ConVarsHud.Vhs7Mode

local CvMotD_Enabled = ConVars.MotD.Enabled

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

local SETTINGTYPE_TOP = 1
local SETTINGTYPE_HEADER = 2
local SETTINGTYPE_BOOLEAN = 3
local SETTINGTYPE_NUMBER = 4
local SETTINGTYPE_INTEGER = 5
local SETTINGTYPE_CROSSHAIRCOLORMIXER = 6
local SETTINGTYPE_UPDATETEXT = 7

--- @param list DR_MenuList
--- @param settings table
local function SetupMenuList(list,settings)
	for _,data in Iterator,settings,0 do
		-- ConVar type
		local cvType = data[1]

		if cvType == SETTINGTYPE_TOP then
			list:AddTop(data[2])
		elseif cvType == SETTINGTYPE_HEADER then
			list:AddHeader(data[2])
		elseif cvType == SETTINGTYPE_BOOLEAN then
			list:AddBoolean(data[2],data[3])
		elseif cvType == SETTINGTYPE_NUMBER then
			list:AddNumber(data[2],data[3],data[4])
		elseif cvType == SETTINGTYPE_INTEGER then
			list:AddInteger(data[2],data[3],data[4])
		elseif cvType == SETTINGTYPE_CROSSHAIRCOLORMIXER then
			list:Add("DR_MenuSpacerSmall")
			list:Add("DR_CrosshairColorMixer")
		elseif cvType == SETTINGTYPE_UPDATETEXT then
			list:AddUpdateText()
		end
	end
end

local Settings = {
	{SETTINGTYPE_TOP,"Local Settings"},

	{SETTINGTYPE_HEADER,"HUD"},
	{SETTINGTYPE_INTEGER,"Theme",CvHud_Theme,#HUD.DrawFunctions},
	{SETTINGTYPE_INTEGER,"Position of the Main HUD (HP, Velocity, Time)",CvHud_PosMain},
	{SETTINGTYPE_INTEGER,"Position of the Ammo HUD",CvHud_PosAmmo},
	{SETTINGTYPE_INTEGER,"Transparency of the HUD background",CvHud_Alpha},
	{SETTINGTYPE_NUMBER,"TargetID fade duration",CvHud_TargetIdFadeTime,5},
	{SETTINGTYPE_BOOLEAN,"Render Zones",CvRenderZones},
	{SETTINGTYPE_BOOLEAN,"Render the \"YOUR STATS\" popup at the start of each round",CvRenderZones},
	{SETTINGTYPE_BOOLEAN,"Enable VHS Mode",CvHud_Vhs7Mode},

	{SETTINGTYPE_HEADER,"Spectating"},
	{SETTINGTYPE_BOOLEAN,"Spectate-only mode",CvSpectateOnly},

	{SETTINGTYPE_HEADER,"Thirdperson view"},
	{SETTINGTYPE_BOOLEAN,"Enabled",CvThirdPerson_Enabled},
	{SETTINGTYPE_INTEGER,"Transparency of your playermodel",CvThirdPerson_Opacity},
	{SETTINGTYPE_INTEGER,"Teammate fade distance",CvThirdPerson_FadeDistance},
	{SETTINGTYPE_NUMBER,"Camera horizontal offset",CvThirdPerson_OffsetX},
	{SETTINGTYPE_NUMBER,"Camera vertical offset",CvThirdPerson_OffsetY},
	{SETTINGTYPE_NUMBER,"Camera forward-backward offset",CvThirdPerson_OffsetZ},
	{SETTINGTYPE_NUMBER,"Camera Pitch offset",CvThirdPerson_OffsetPitch},
	{SETTINGTYPE_NUMBER,"Camera Yaw offset",CvThirdPerson_OffsetYaw},
	{SETTINGTYPE_NUMBER,"Camera Roll offset",CvThirdPerson_OffsetRoll},

	{SETTINGTYPE_HEADER,"Help messages"},
	{SETTINGTYPE_BOOLEAN,"Enable help messages",CvAnnouncements_Enabled},
	{SETTINGTYPE_INTEGER,"Interval between help messages (in seconds)",CvAnnouncements_Interval},

	{SETTINGTYPE_HEADER,"Miscellaneous"},
	{SETTINGTYPE_BOOLEAN,"Show the info menu when joining the server",CvShowInfo},
	{SETTINGTYPE_BOOLEAN,"Play audible round cues at the start and end of each round",CvPlayRoundCues},
	{SETTINGTYPE_BOOLEAN,"Enable AutoJump (Max velocity is capped depending on server settings)",CvAutoJump_Enabled},

	{SETTINGTYPE_UPDATETEXT},
}

function DR.AddSetting(tbl)
	Settings[#Settings + 1] = tbl
end

concommand.Add("deathrun_open_settings",function()
	local frame = VguiCreate("DR_SettingsFrame")
	local inner = frame:Add("DR_MenuInner")
	frame.InnerWindow = inner

	local controls = inner:Add("DR_MenuControls")
	local scroll = controls:Add("DR_MenuScrollPanel")
	local list = scroll:Add("DR_MenuList")

	SetupMenuList(list,Settings)
end)

local SettingsCrosshair = {
	{SETTINGTYPE_TOP,"Crosshair Options"},

	{SETTINGTYPE_HEADER,"Color"},
	{SETTINGTYPE_CROSSHAIRCOLORMIXER},

	{SETTINGTYPE_HEADER,"Dimensions"},
	{SETTINGTYPE_NUMBER,"Stroke Length",CvCrosshair_Size,8},
	{SETTINGTYPE_NUMBER,"Stroke Thickness",CvCrosshair_Thickness,8},
	{SETTINGTYPE_NUMBER,"Inner Gap",CvCrosshair_Gap,8},
}

concommand.Add("deathrun_open_crosshair_creator",function()
	local frame = VguiCreate("DR_CrosshairCreatorFrame")
	local inner = frame:Add("DR_MenuInner")
	frame.InnerWindow = inner

	inner:Add("DR_CrosshairPreview")
	local controls = inner:Add("DR_CrosshairControls")
	local scroll = controls:Add("DR_MenuScrollPanel")
	local list = scroll:Add("DR_MenuList")

	SetupMenuList(list,SettingsCrosshair)
end)

concommand.Add("deathrun_open_help",function()
	VguiCreate("DR_HelpFrame")
end)

concommand.Add("deathrun_open_zone_editor",function(ply,cmd)
	if not DR.CanAccessCommand(ply,cmd) then return end

	local frame = VguiCreate("DR_ZoneEditorFrame")
	local inner = frame:Add("DR_MenuInner")
	frame.InnerWindow = inner

	local scroll = inner:Add("DR_MenuScrollPanel")
	local list = scroll:Add("DR_ZoneEditorList")

	list:AddHeader("Create Zone",true)

	local zoneNameEntry = list:AddZoneNameEntry()
	local zoneTypeCombo = list:AddComboBox("Zone Type:",ZoneSystem.ZoneTypes,"start")

	local buttonCreate = list:Add("DR_ZoneEditorButtonCreate")

	buttonCreate.ZoneName = zoneNameEntry
	buttonCreate.ZoneType = zoneTypeCombo

	zoneNameEntry.CreateButton = buttonCreate

	-- edit zones
	list:AddHeader("Modify Zone")

	local zoneEditCombo = list:Add("DR_ZoneEditComboBox")

	buttonCreate.ZoneEdit = zoneEditCombo

	local zoneDataText = list:Add("DR_ZoneData")

	zoneDataText.ZoneEdit = zoneEditCombo
	zoneEditCombo.ZoneData = zoneDataText

	local buttonTeleport = list:Add("DR_ZoneEditorButtonTeleport")
	buttonTeleport.ZoneEdit = zoneEditCombo

	list:Add("DR_MenuSpacerSmall")

	local buttonSetPosWang1,buttonSetPosEyeTrace1 = list:AddPosWangSet(1)
	local buttonSetPosWang2,buttonSetPosEyeTrace2 = list:AddPosWangSet(2)

	list:Add("DR_MenuSpacerSmall")

	local buttonSetDir = list:Add("DR_ZoneEditorButtonSetDir")

	buttonSetPosWang1.ZoneEdit = zoneEditCombo
	buttonSetPosWang2.ZoneEdit = zoneEditCombo
	buttonSetPosEyeTrace1.ZoneEdit = zoneEditCombo
	buttonSetPosEyeTrace2.ZoneEdit = zoneEditCombo
	buttonSetDir.ZoneEdit = zoneEditCombo

	zoneEditCombo.Pos1Wangs = buttonSetPosWang1
	zoneEditCombo.Pos2Wangs = buttonSetPosWang2

	local colorMixer = list:Add("DR_ZoneEditorColorMixer")

	local buttonSetColor = list:Add("DR_ZoneEditorButtonSetColor")
	local buttonRemove = list:Add("DR_ZoneEditorButtonRemove")

	buttonSetColor.Mixer = colorMixer

	colorMixer.ZoneEdit = zoneEditCombo
	buttonSetColor.ZoneEdit = zoneEditCombo
	buttonRemove.ZoneEdit = zoneEditCombo

	zoneEditCombo:ChooseOption(LocalPlayer().LastSelectZone or "Select Zone")
end)

local function OpenQuickInfo()
	VguiCreate("DR_QuickInfoFrame")
end

concommand.Add("deathrun_open_quickinfo",OpenQuickInfo)
concommand.Add("deathrun_open_motd",OpenQuickInfo)

hook.Add("InitPostEntity","DeathrunOpenQuickInfo",function()
	if
		not (
			CvMotD_Enabled:GetBool()
		and	CvShowInfo:GetBool()
		)
	then return end

	OpenQuickInfo()
end)

-- waiting menu
function UI.OpenWaitingMenu()
	local frame = VguiCreate("DR_WaitingMenuFrame")

	frame:Add("DR_WaitingMenuInner")
end

concommand.Add("deathrun_open_waitingmenu",UI.OpenWaitingMenu)

--- @param returning boolean?
function UI.OpenMovedToSpectatorMenu(returning)
	local frame = VguiCreate("DR_MovedToSpectatorFrame")

	local inner = frame:Add("DR_MovedToSpectatorInner" .. (returning and "Returning" or "AFK"))

	inner:Add("DR_MovedToSpectatorButtonContinue")
	inner:Add("DR_MovedToSpectatorButtonBack")
end

local function WrapperFunctionForSpecMenuToAppeaseMyLangServer()
	UI.OpenMovedToSpectatorMenu()
end

concommand.Add("deathrun_open_forcespectatormenu",WrapperFunctionForSpecMenuToAppeaseMyLangServer)

net.Receive("DeathrunSpectatorNotification",WrapperFunctionForSpecMenuToAppeaseMyLangServer)

hook.Add("PlayerButtonDown","DeathrunOpenMenus",function(ply,btn)
	if not IsFirstTimePredicted() then return end

	local command

	if btn == KEY_F2 then
		command = "deathrun_open_settings"
	elseif btn == KEY_F4 then
		command = "deathrun_open_crosshair_creator"
	elseif btn == KEY_F9 then
		command = "deathrun_open_zone_editor"
	else return end

	ply:ConCommand(command)
end)
