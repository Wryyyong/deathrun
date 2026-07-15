local DR = DR

local ConVars = DR.ConVars
local RoundSystem = DR.RoundSystem
local HUD = DR.UI.HUD

local CvHelpUrl = ConVars.HelpURL

local ConVarsMotD = ConVars.MotD
local CvMotD_Title = ConVarsMotD.Title
local CvMotD_Url = ConVarsMotD.URL

--- @class DR_MenuFrame : DR_Frame
local DR_MenuFrame = {
	["Width"] = 640,
	["Height"] = 640,
}

-- fucking WHY does this shit not inherit normally
function DR_MenuFrame:Init()
	self.Inner:Remove()
	self.Inner = nil

	self:RefreshSettings()

	self:MakePopup()
end

function DR_MenuFrame:RefreshSettings()
	self:SetSize(self.Width,self.Height)
	self:Center()
end

--- @class DR_SettingsFrame : DR_MenuFrame
local DR_SettingsFrame = {
	["Title"] = "Deathrun Settings",
}

--- @class DR_HelpFrame : DR_MenuFrame
local DR_HelpFrame = {
	["Title"] = "Deathrun Help",
}

function DR_HelpFrame:Init()
	local width,height = DR.ScreenWidth,DR.ScreenHeight
	self.Width,self.Height = width,height

	self:RefreshSettings()

	local background = self:Add("DLabel")
	background:SetText("Please wait while page loads...")
	background:SetFont("Deathrun_Derma_Large")
	background:SizeToContents()
	background:Center()

	local html = self:Add("DHTML")
	html:SetSize(width - 8,height - 44)
	html:SetPos(4,32)
	html:OpenURL(CvHelpUrl:GetString())
end

--- @class DR_QuickInfoFrame : DR_MenuFrame
local DR_QuickInfoFrame = {}

function DR_QuickInfoFrame:Init()
	local width,height = DR.ScreenWidth - 320,DR.ScreenHeight - 240
	self.Width,self.Height = width,height

	self:RefreshSettings()
	self:SetTitle(CvMotD_Title:GetString())

	local background = self:Add("DLabel")
	background:SetText("Please wait while page loads...")
	background:SetFont("Deathrun_Derma_Large")
	background:SizeToContents()
	background:Center()

	local html = self:Add("DHTML")
	html:SetSize(width - 8,height - 44)
	html:SetPos(4,32)
	html:OpenURL(CvMotD_Url:GetString())
	html:SetAllowLua(true)
end

function DR_QuickInfoFrame:OnClose()
	if RoundSystem.GetCurrent() ~= DR_ROUND_WAITING then return end

	HUD.OpenWaitingMenu()
end

derma.DefineControl("DR_MenuFrame","",DR_MenuFrame,"DR_Frame")

derma.DefineControl("DR_SettingsFrame","",DR_SettingsFrame,"DR_MenuFrame")
derma.DefineControl("DR_HelpFrame","",DR_HelpFrame,"DR_MenuFrame")
derma.DefineControl("DR_QuickInfoFrame","",DR_QuickInfoFrame,"DR_MenuFrame")
