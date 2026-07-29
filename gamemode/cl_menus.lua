print("Loaded cl_menus.lua...")

local DR = DR

local ConVars = DR.ConVars
local Hud = ConVars.Hud
local Crosshair = ConVars.Crosshair
local ThirdPerson = ConVars.ThirdPerson
local Announcements = ConVars.Announcements
local MotD = ConVars.MotD

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
	for _,data in ipairs(settings) do
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
	{SETTINGTYPE_INTEGER,"Theme",Hud.Theme,#DR.HudDrawFunctions},
	{SETTINGTYPE_INTEGER,"Position of the Main HUD (HP, Velocity, Time)",Hud.PosMain},
	{SETTINGTYPE_INTEGER,"Position of the Ammo HUD",Hud.PosAmmo},
	{SETTINGTYPE_INTEGER,"Transparency of the HUD background",Hud.Alpha},
	{SETTINGTYPE_NUMBER,"TargetID fade duration",Hud.TargetIdFadeTime,5},
	{SETTINGTYPE_BOOLEAN,"Render Zones",ConVars.RenderZones},
	{SETTINGTYPE_BOOLEAN,"Render the \"YOUR STATS\" popup at the start of each round",ConVars.RenderYourStats},
	{SETTINGTYPE_BOOLEAN,"Enable VHS Mode",Hud.Vhs7Mode},

	{SETTINGTYPE_HEADER,"Spectating"},
	{SETTINGTYPE_BOOLEAN,"Spectate-only mode",ConVars.SpectateOnly},

	{SETTINGTYPE_HEADER,"Thirdperson view"},
	{SETTINGTYPE_BOOLEAN,"Enabled",ThirdPerson.Enabled},
	{SETTINGTYPE_INTEGER,"Transparency of your playermodel",ThirdPerson.Opacity},
	{SETTINGTYPE_INTEGER,"Teammate fade distance",ThirdPerson.FadeDistance},
	{SETTINGTYPE_NUMBER,"Camera horizontal offset",ThirdPerson.OffsetX},
	{SETTINGTYPE_NUMBER,"Camera vertical offset",ThirdPerson.OffsetY},
	{SETTINGTYPE_NUMBER,"Camera forward-backward offset",ThirdPerson.OffsetZ},
	{SETTINGTYPE_NUMBER,"Camera Pitch offset",ThirdPerson.OffsetPitch},
	{SETTINGTYPE_NUMBER,"Camera Yaw offset",ThirdPerson.OffsetYaw},
	{SETTINGTYPE_NUMBER,"Camera Roll offset",ThirdPerson.OffsetRoll},

	{SETTINGTYPE_HEADER,"Help messages"},
	{SETTINGTYPE_BOOLEAN,"Enable help messages",Announcements.Enabled},
	{SETTINGTYPE_INTEGER,"Interval between help messages (in seconds)",Announcements.Interval},

	{SETTINGTYPE_HEADER,"Miscellaneous"},
	{SETTINGTYPE_BOOLEAN,"Show the info menu when joining the server",ConVars.ShowInfo},
	{SETTINGTYPE_BOOLEAN,"Play audible round cues at the start and end of each round",ConVars.PlayRoundCues},
	{SETTINGTYPE_BOOLEAN,"Enable AutoJump (Max velocity is capped depending on server settings)",ConVars.AutoJump.Enabled},

	{SETTINGTYPE_UPDATETEXT},
}

function DR.AddSetting(tbl)
	Settings[#Settings + 1] = tbl
end

concommand.Add("deathrun_open_settings",function()
	local frame = vgui.Create("DR_SettingsFrame")
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
	{SETTINGTYPE_NUMBER,"Stroke Length",Crosshair.Size,8},
	{SETTINGTYPE_NUMBER,"Stroke Thickness",Crosshair.Thickness,8},
	{SETTINGTYPE_NUMBER,"Inner Gap",Crosshair.Gap,8},
}

concommand.Add("deathrun_open_crosshair_creator",function()
	local frame = vgui.Create("DR_CrosshairCreatorFrame")
	local inner = frame:Add("DR_MenuInner")
	frame.InnerWindow = inner

	inner:Add("DR_CrosshairPreview")
	local controls = inner:Add("DR_CrosshairControls")
	local scroll = controls:Add("DR_MenuScrollPanel")
	local list = scroll:Add("DR_MenuList")

	SetupMenuList(list,SettingsCrosshair)
end)

concommand.Add("deathrun_open_help",function()
	vgui.Create("DR_HelpFrame")
end)

concommand.Add("deathrun_open_zone_editor",function(ply,cmd)
	if not DR.CanAccessCommand(ply,cmd) then return end

	local frame = vgui.Create("DR_ZoneEditorFrame")
	local inner = frame:Add("DR_MenuInner")
	frame.InnerWindow = inner

	local scroll = inner:Add("DR_MenuScrollPanel")
	local list = scroll:Add("DR_ZoneEditorList")

	list:AddHeader("Create Zone",true)

	local zoneNameEntry = list:AddZoneNameEntry()
	local zoneTypeCombo = list:AddComboBox("Zone Type:",ZONE.ZoneTypes,"start")

	local buttonCreate = list:Add("DR_ZoneEditorButtonCreate")

	buttonCreate.ZoneName = zoneNameEntry
	buttonCreate.ZoneType = zoneTypeCombo

	zoneNameEntry.CreateButton = buttonCreate

	-- edit zones
	list:AddHeader("Modify Zone")

	local zoneEditCombo = list:Add("DR_ZoneEditComboBox")

	local zoneDataText = list:Add("DR_ZoneData")

	zoneDataText.ZoneEdit = zoneEditCombo
	zoneEditCombo.ZoneData = zoneDataText

	local colorMixer = list:Add("DR_ZoneEditorColorMixer")

	local buttonSetColor = list:Add("DR_ZoneEditorButtonSetColor")
	local buttonSetPos1 = list:Add("DR_ZoneEditorButtonSetPos1")
	local buttonSetPos2 = list:Add("DR_ZoneEditorButtonSetPos2")
	local buttonRemove = list:Add("DR_ZoneEditorButtonRemove")

	colorMixer.ZoneEdit = zoneEditCombo
	buttonSetColor.ZoneEdit = zoneEditCombo
	buttonSetColor.Mixer = colorMixer
	buttonSetPos1.ZoneEdit = zoneEditCombo
	buttonSetPos2.ZoneEdit = zoneEditCombo
	buttonRemove.ZoneEdit = zoneEditCombo
end)

local function OpenQuickInfo()
	vgui.Create("DR_QuickInfoFrame")
end

concommand.Add("deathrun_open_quickinfo",OpenQuickInfo)
concommand.Add("deathrun_open_motd",OpenQuickInfo)

hook.Add("InitPostEntity","DeathrunOpenQuickInfo",function()
	if
		not (
			MotD.Enabled:GetBool()
		and	ConVars.ShowInfo:GetBool()
		)
	then return end

	OpenQuickInfo()
end)

-- waiting menu
function DR.OpenWaitingMenu()
	local frame = vgui.Create("DR_WaitingMenuFrame")

	frame:Add("DR_WaitingMenuInner")
end

concommand.Add("deathrun_open_waitingmenu",DR.OpenWaitingMenu)

--- @param returning boolean?
function DR.OpenMovedToSpectatorMenu(returning)
	local frame = vgui.Create("DR_MovedToSpectatorFrame")

	local inner = frame:Add("DR_MovedToSpectatorInner" .. (returning and "Returning" or "AFK"))

	inner:Add("DR_MovedToSpectatorButtonContinue")
	inner:Add("DR_MovedToSpectatorButtonBack")
end

local function WrapperFunctionForSpecMenuToAppeaseMyLangServer()
	DR.OpenMovedToSpectatorMenu()
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
