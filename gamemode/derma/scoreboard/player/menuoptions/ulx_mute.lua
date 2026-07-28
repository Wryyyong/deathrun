--- @class DR_ScoreboardPlayerMenuOptionULXMute : DR_ScoreboardPlayerMenuOptionULXBase
local DR_ScoreboardPlayerMenuOptionULXMute = {
	["Caption"] = "Mute player chat",
	["IconPath"] = "icon16/style_delete.png",
	["Command"] = "mute",
}

function DR_ScoreboardPlayerMenuOptionULXMute:Init()
	self:RefreshSettings()
end

function DR_ScoreboardPlayerMenuOptionULXMute:ValidClick()
	LocalPlayer():ConCommand("ulx mute \"" .. self.Player:Nick() .. "\"")
end

--- @class DR_ScoreboardPlayerMenuOptionULXUnmute : DR_ScoreboardPlayerMenuOptionULXBase
local DR_ScoreboardPlayerMenuOptionULXUnmute = {
	["Caption"] = "Unmute player chat",
	["IconPath"] = "icon16/style_delete.png",
	["Command"] = "unmute",
}

function DR_ScoreboardPlayerMenuOptionULXUnmute:Init()
	self:RefreshSettings()
end

function DR_ScoreboardPlayerMenuOptionULXUnmute:ValidClick()
	LocalPlayer():ConCommand("ulx unmute \"" .. self.Player:Nick() .. "\"")
end

derma.DefineControl("DR_ScoreboardPlayerMenuOptionULXMute","",DR_ScoreboardPlayerMenuOptionULXMute,"DR_ScoreboardPlayerMenuOptionULXBase")
derma.DefineControl("DR_ScoreboardPlayerMenuOptionULXUnmute","",DR_ScoreboardPlayerMenuOptionULXUnmute,"DR_ScoreboardPlayerMenuOptionULXBase")
