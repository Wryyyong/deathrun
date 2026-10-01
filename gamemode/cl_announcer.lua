local next = next
local tonumber = tonumber

local ChatAddText = chat.AddText

local DR = DR

local Colors = DR.Colors
local ColorAlizarin = Colors.Alizarin
local ColorClouds = Colors.Clouds

local ConVarsAnnouncements = DR.ConVars.Announcements
local CvAnnouncements_Enabled = ConVarsAnnouncements.Enabled
local CvAnnouncements_Interval = ConVarsAnnouncements.Interval

local Announcer = DR.Announcer or {}
DR.Announcer = Announcer

Announcer.Counter = Announcer.Counter or 1

Announcer.Name = Announcer.Name or "HELP"
Announcer.Color = Announcer.Color or ColorAlizarin

local Messages = Announcer.Messages or {
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
Announcer.Messages = Messages

local MessageHashes = Announcer.MessageHashes or {}
Announcer.MessageHashes = MessageHashes

for _,msg in ipairs(Messages) do
	MessageHashes[msg] = true
end

--- @param msg string
function DR.AddAnnouncement(msg)
	if MessageHashes[msg] then return end

	MessageHashes[msg] = true
	Messages[#Messages + 1] = msg
end

timer.Create("DeathrunAnnouncementTimer",CvAnnouncements_Interval:GetFloat(),0,function()
	if not CvAnnouncements_Enabled:GetBool() then return end

	local counter = Announcer.Counter

	ChatAddText(
		ColorClouds,
		"[",
		Announcer.Color,
		Announcer.Name,
		ColorClouds,
		"] " .. Messages[counter]
	)

	Announcer.Counter = next(Messages,counter) or 1
end)

cvars.AddChangeCallback("deathrun_announcement_interval",function(_,_,new)
	if not timer.Exists("DeathrunAnnouncementTimer") then return end

	timer.Adjust("DeathrunAnnouncementTimer",tonumber(new))
end,"DeathrunAnnouncementInterval")
