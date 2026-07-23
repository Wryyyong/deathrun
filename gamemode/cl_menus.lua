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

function DR.OpenSettings()
	local frame = vgui.Create("DR_SettingsFrame")
	local inner = frame:Add("DR_MenuInner")
	frame.InnerWindow = inner

	local controls = inner:Add("DR_MenuControls")
	local scroll = controls:Add("DR_CustomScrollPanel")
	local list = scroll:Add("DR_MenuList")

	SetupMenuList(list,Settings)
end

concommand.Add("deathrun_open_settings",DR.OpenSettings)

local SettingsCrosshair = {
	{SETTINGTYPE_TOP,"Crosshair Options"},

	{SETTINGTYPE_HEADER,"Color"},
	{SETTINGTYPE_CROSSHAIRCOLORMIXER},

	{SETTINGTYPE_HEADER,"Dimensions"},
	{SETTINGTYPE_NUMBER,"Stroke Length",Crosshair.Size,8},
	{SETTINGTYPE_NUMBER,"Stroke Thickness",Crosshair.Thickness,8},
	{SETTINGTYPE_NUMBER,"Inner Gap",Crosshair.Gap,8},
}

function DR.OpenCrosshairCreator()
	local frame = vgui.Create("DR_CrosshairCreatorFrame")
	local inner = frame:Add("DR_MenuInner")
	frame.InnerWindow = inner

	inner:Add("DR_CrosshairPreview")
	local controls = inner:Add("DR_CrosshairControls")
	local scroll = controls:Add("DR_CustomScrollPanel")
	local list = scroll:Add("DR_MenuList")

	SetupMenuList(list,SettingsCrosshair)
end

concommand.Add("deathrun_open_crosshair_creator",DR.OpenCrosshairCreator)

function DR.OpenHelp()
	vgui.Create("DR_HelpFrame")
end

concommand.Add("deathrun_open_help",DR.OpenHelp)

function DR.OpenZoneEditor()
	local frame = vgui.Create("DR_ZoneEditorFrame")
	local inner = frame:Add("DR_MenuInner")
	frame.InnerWindow = inner

	local scroll = inner:Add("DR_CustomScrollPanel")
	local list = scroll:Add("DR_MenuList_ZoneEditor")

	list:AddHeader("Create Zone",true)

	local _,zoneName = list:AddTextEntry("Zone Name:","New Zone")
	local _,zoneType = list:AddComboBox("Zone Type:",ZONE.ZoneTypes,"start")

	local sbmt = vgui.Create("DR_Button")
	sbmt:SetSize(list:GetWide(),18)
	sbmt:SetText("Create Zone")
	sbmt:SetFont("Deathrun_Derma_ExtraSmall")
	sbmt:SetOffsets()
	list:Add(sbmt)
	sbmt.te = zoneName
	zoneName.sbmt = sbmt
	sbmt.dd = zoneType
	function zoneName:OnTextChanged()
		self.sbmt:SetText("Create Zone '" .. self:GetText() .. "'")
	end

	function sbmt:DoClick()
		LocalPlayer():ConCommand("zone_create " .. self.te:GetText() .. " " .. self.dd:GetValue() .. " ")
		print("zone_create",self.te:GetText() .. " " .. self.dd:GetValue())
	end

	-- edit zones
	local lbl = vgui.Create("DLabel")
	lbl:SetFont("Deathrun_Derma_Small")
	lbl:SetTextColor(DR.Colors.Turq)
	lbl:SetText("Modify Zone")
	lbl:SizeToContents()
	lbl:SetWide(list:GetWide())
	list:Add(lbl)
	local dd = vgui.Create("DComboBox")
	dd:SetSize(list:GetWide(),18)
	dd:SetValue(LocalPlayer().LastSelectZone or "Select Zone")
	for name,z in pairs(ZONE.MapZones) do
		if z.type then dd:AddChoice(name) end
	end

	function dd:OnSelect(index,value)
		LocalPlayer().LastSelectZone = value
	end

	list:Add(dd)
	local pnl = vgui.Create("DPanel")
	pnl:SetSize(list:GetWide(),85)
	list:Add(pnl)
	pnl.dd = dd
	function pnl:Paint(w,h)
		local zone = ZONE.MapZones[self.dd:GetValue()] or nil
		if zone ~= nil then
			if zone.type then
				local col = zone.color
				local info = {"Zone Name: " .. self.dd:GetValue(),"Zone Type: " .. zone.type,"Pos1: " .. tostring(zone.pos1),"Pos2: " .. tostring(zone.pos2),"Color:" .. " " .. tostring(col.r) .. " " .. tostring(col.g) .. " " .. tostring(col.b) .. " " .. tostring(col.a)}
				for i = 1,#info do
					local k = i - 1
					draw.SimpleText(info[i],"Deathrun_Derma_ExtraSmall",0,14 * k,DR.Colors.Grey)
				end
			end
		end
	end

	-- ripped from wiki lmao
	local Mixer = vgui.Create("DColorMixer")
	Mixer:SetSize(list:GetWide(),196)
	Mixer:SetPalette(true) -- Show/hide the palette			DEF:true
	Mixer:SetAlphaBar(true) -- Show/hide the alpha bar		DEF:true
	Mixer:SetWangs(true) -- Show/hide the R G B A indicators 	DEF:true
	Mixer:SetColor(Color(255,255,255)) -- Set the default color
	Mixer.dd = dd
	list:Add(Mixer)
	local but = vgui.Create("DR_Button")
	but:SetSize(list:GetWide(),18)
	but:SetText("Set zone color")
	but:SetFont("Deathrun_Derma_ExtraSmall")
	but:SetOffsets()
	but.dd = dd
	but.mixer = Mixer
	list:Add(but)
	function but:DoClick()
		local col = self.mixer:GetColor()
		LocalPlayer():ConCommand("zone_setcolor " .. self.dd:GetValue() .. " " .. tostring(col.r) .. " " .. tostring(col.g) .. " " .. tostring(col.b) .. " " .. tostring(col.a))
	end

	local but = vgui.Create("DR_Button")
	but:SetSize(list:GetWide(),18)
	but:SetText("Set Pos1 to eyetrace")
	but:SetFont("Deathrun_Derma_ExtraSmall")
	but:SetOffsets()
	but.dd = dd
	list:Add(but)
	function but:DoClick()
		LocalPlayer():ConCommand("zone_setpos1 " .. self.dd:GetValue() .. " eyetrace")
	end

	local but = vgui.Create("DR_Button")
	but:SetSize(list:GetWide(),18)
	but:SetText("Set Pos2 to eyetrace")
	but:SetFont("Deathrun_Derma_ExtraSmall")
	but:SetOffsets()
	but.dd = dd
	list:Add(but)
	function but:DoClick()
		LocalPlayer():ConCommand("zone_setpos2 " .. self.dd:GetValue() .. " eyetrace")
	end

	local but = vgui.Create("DR_Button")
	but:SetSize(list:GetWide(),18)
	but:SetText("Remove this zone")
	but:SetFont("Deathrun_Derma_ExtraSmall")
	but:SetOffsets()
	but.dd = dd
	list:Add(but)
	function but:DoClick()
		LocalPlayer():ConCommand("zone_remove " .. self.dd:GetValue())
	end
end

concommand.Add("deathrun_open_zone_editor",function(ply,cmd)
	if not DR.CanAccessCommand(ply,cmd) then return end

	DR.OpenZoneEditor()
end)

function DR.OpenQuickInfo()
	vgui.Create("DR_QuickInfoFrame")
end

concommand.Add("deathrun_open_quickinfo",DR.OpenQuickInfo)
concommand.Add("deathrun_open_motd",DR.OpenQuickInfo)

hook.Add("InitPostEntity","DeathrunOpenQuickInfo",function()
	if
		not (
			MotD.Enabled:GetBool()
		and	ConVars.ShowInfo:GetBool()
		)
	then return end

	DR.OpenQuickInfo()
end)

function DR.GetWordWrapText(text,width,font)
	local displayText = ""
	local displayLine = ""

	surface.SetFont(font)
	text = string.Replace(text,"\n","")
	text = string.Replace(text,"\t","")
	text = string.Replace(text,[[\n]],"\n")
	text = string.Replace(text,[[\t]],"\t")
	text = string.Replace(text,[[\b]],"• ")

	local args = string.Split(text," ")

	for _,word in ipairs(args) do
		local textWidth = surface.GetTextSize(displayLine .. word .. " ")

		if textWidth > width then
			displayText = displayText .. displayLine .. "\n"
			displayLine = word .. " "
		else
			displayLine = displayLine .. word .. " "
		end
	end

	return displayText .. displayLine
end

-- waiting menu
function DR.OpenWaitingMenu()
	local frame = vgui.Create("DR_Window")
	frame:SetSize(600,270)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Waiting For Players")
	local panel = vgui.Create("panel",frame)
	panel:SetSize(frame:GetWide() - 8,frame:GetTall() - 44)
	panel:SetPos(4,32)
	function panel:Paint(w,h)
		local x,y = 0,0
		surface.SetDrawColor(DR.Colors.Clouds)
		surface.DrawRect(x,y,w,h)
		local ix,iy,iw,ih = x + 8,y + 8,w - 16,h - 16
		local info = [[Welcome to the server! Currently there are no players online.
		This means that you can explore the map at your own pace
		from the safety of godmode, so you can practice
		your Bhop and check for auto-traps with ease.\n\n
		Some useful commands:\n
		\t\b !respawn - Respawn yourself.\n
		\t\b !cleanup - Reset all traps on the map.\n
		\t\b !help - View the help menu.\n\n
		Enjoy, and have fun!]]
		info = DR.GetWordWrapText(info,iw,"Deathrun_DefaultHUD_MediumLight")
		DR.ShadowText(info,"Deathrun_DefaultHUD_MediumLight",ix,iy,DR.Colors.Grey,nil,nil,0)
	end
end

concommand.Add("deathrun_open_waitingmenu",DR.OpenWaitingMenu)
function DR.OpenForcedSpectatorMenu(msg)
	local frame = vgui.Create("DR_Window")
	frame:SetSize(640,200)
	frame:Center()
	frame:SetTitle("Moved to Spectator")
	frame:MakePopup()
	local panel = vgui.Create("Panel",frame)
	panel:SetSize(frame:GetWide() - 8,frame:GetTall() - 44)
	panel:SetPos(4,32)
	function panel:Paint(w,h)
		local x,y = 0,0
		surface.SetDrawColor(DR.Colors.Clouds)
		surface.DrawRect(x,y,w,h)
		local ix,iy,iw,ih = x + 8,y + 8,w - 16,h - 16
		local info = [[You have been moved to the Spectator team for being AFK.
		To move back, either click on one of the buttons below or visit the
		Spectator section of the F2 menu.
		\n\nWould you like to move back into to the game?]]
		if msg then info = msg end

		info = DR.GetWordWrapText(info,iw,"Deathrun_DefaultHUD_MediumLight")
		DR.ShadowText(info,"Deathrun_DefaultHUD_MediumLight",ix,iy,DR.Colors.Grey,nil,nil,0)
	end

	local cont = vgui.Create("DR_Button",panel)
	cont:SetSize((panel:GetWide() - 3 * 4) * .5,32)
	cont:SetPos(4,panel:GetTall() - 32 - 4)
	cont:SetText("No, I'm okay with this.")
	function cont:DoClick()
		self:GetParent():GetParent():Close()
	end

	local back = vgui.Create("DR_Button",panel)
	back:SetSize((panel:GetWide() - 3 * 4) * .5,32)
	back:SetPos(8 + (panel:GetWide() - 3 * 4) * .5,panel:GetTall() - 32 - 4)
	back:SetText("Yes, please move me back.")
	function back:DoClick()
		LocalPlayer():ConCommand("deathrun_spectate_only 0")
		self:GetParent():GetParent():Close()
	end
end

concommand.Add("deathrun_open_forcespectatormenu",DR.OpenForcedSpectatorMenu)
net.Receive("DeathrunSpectatorNotification",DR.OpenForcedSpectatorMenu)
