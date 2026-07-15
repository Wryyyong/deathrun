local DR = DR

local Colors = DR.Colors
local ColorAlizarin = Colors.Alizarin
local ColorClouds = Colors.Clouds

local ConVarsAnnouncements = DR.ConVars.Announcements
local CvAnnouncements_Enabled = ConVarsAnnouncements.Enabled
local CvAnnouncements_Interval = ConVarsAnnouncements.Interval

local AnnouncementCounter = 1

DR.AnnouncerName = DR.AnnouncerName or "HELP" -- incase the file refreshes
DR.AnnouncerColor = DR.AnnouncerColor or ColorAlizarin

local AnnouncementMessages = {
	"Don't hesitate to ask the staff any questions, they are here to help.",
	"Type !rtv to force a mapchange.",
	"Type !crosshair to customize your crosshair settings and achieve different designs.",
	"Type !help or press F1 for help and information about the gamemode.",
	"Change the position of the HUD by pressing F2 or typing !settings.",
	"Change how long player names stay on the screen by pressing F2 or typing !settings.",
	"Buttons are claimed automatically. Just walk up to them!",
	"Did you know the weapons have recoil patterns? Pull down gently to concentrate your spray!",
	"Too many squeakers? Mute players from the scoreboard by holding TAB.",
	"Disable these messages through the !settings menu or by pressing F2.",
	"Enable Thirdperson, disable Autojump, change HUD position and more by pressing F2.",
	"Change your HUD theme in the F2 menu.",
	"Disconnecting while on the Death team is not allowed and will be considered death avoidance. You will be forced to play extra rounds as Death.",
}

--- @param announcement string
function DR.AddAnnouncement(announcement)
	AnnouncementMessages[#AnnouncementMessages + 1] = announcement
end

timer.Create("DeathrunAnnouncementTimer",CvAnnouncements_Interval:GetFloat(),0,function()
	if not CvAnnouncements_Enabled:GetBool() then return end

	chat.AddText(
		ColorClouds,
		"[",
		DR.AnnouncerColor,
		DR.AnnouncerName,
		ColorClouds,
		"] " .. AnnouncementMessages[AnnouncementCounter]
	)

	AnnouncementCounter = next(AnnouncementMessages,AnnouncementCounter) or 1
end)

cvars.AddChangeCallback("deathrun_announcement_interval",function(_,_,new)
	if not timer.Exists("DeathrunAnnouncementTimer") then return end

	timer.Adjust("DeathrunAnnouncementTimer",tonumber(new))
end,"DeathrunAnnouncementInterval")
