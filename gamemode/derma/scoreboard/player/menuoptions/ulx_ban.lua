--- @class DR_ScoreboardPlayerMenuOptionULXBanBase : DR_ScoreboardPlayerMenuOptionULXBase
local DR_ScoreboardPlayerMenuOptionULXBanBase = {
	["Caption"] = "Ban from server",
	["IconPath"] = "icon16/clock.png",
	["Command"] = "ban",
	["Minutes"] = -1,
	["BanMessage"] = "",
}

function DR_ScoreboardPlayerMenuOptionULXBanBase:Init()
	self:RefreshSettings()
end

function DR_ScoreboardPlayerMenuOptionULXBanBase:ValidClick()
	LocalPlayer():ConCommand("ulx ban \"" .. self.Player:Nick() .. "\" " .. self.Minutes .. " \"Banned by server staff " .. self.BanMessage .. ".\"")
end

--- @class DR_ScoreboardPlayerMenuOptionULXBan30m : DR_ScoreboardPlayerMenuOptionULXBanBase
local DR_ScoreboardPlayerMenuOptionULXBan30m = {
	["Caption"] = "Ban for 30 minutes",
	["Minutes"] = 30,
	["BanMessage"] = "for half an hour",
}

function DR_ScoreboardPlayerMenuOptionULXBan30m:Init()
	self:RefreshSettings()
end

--- @class DR_ScoreboardPlayerMenuOptionULXBan2h : DR_ScoreboardPlayerMenuOptionULXBanBase
local DR_ScoreboardPlayerMenuOptionULXBan2h = {
	["Caption"] = "Ban for 2 hours",
	["Minutes"] = 120,
	["BanMessage"] = "for two hours",
}

function DR_ScoreboardPlayerMenuOptionULXBan2h:Init()
	self:RefreshSettings()
end

--- @class DR_ScoreboardPlayerMenuOptionULXBan1d : DR_ScoreboardPlayerMenuOptionULXBanBase
local DR_ScoreboardPlayerMenuOptionULXBan1d = {
	["Caption"] = "Ban for 1 day",
	["Minutes"] = 1440,
	["BanMessage"] = "for one day",
}

function DR_ScoreboardPlayerMenuOptionULXBan1d:Init()
	self:RefreshSettings()
end

--- @class DR_ScoreboardPlayerMenuOptionULXBan1w : DR_ScoreboardPlayerMenuOptionULXBanBase
local DR_ScoreboardPlayerMenuOptionULXBan1w = {
	["Caption"] = "Ban for 1 week",
	["Minutes"] = 10080,
	["BanMessage"] = "for one week",
}

function DR_ScoreboardPlayerMenuOptionULXBan1w:Init()
	self:RefreshSettings()
end

--- @class DR_ScoreboardPlayerMenuOptionULXBanPerm : DR_ScoreboardPlayerMenuOptionULXBanBase
local DR_ScoreboardPlayerMenuOptionULXBanPerm = {
	["Caption"] = "Ban permanently",
	["IconPath"] = "icon16/clock_red.png",
	["Minutes"] = 0,
	["BanMessage"] = "permanently",
}

function DR_ScoreboardPlayerMenuOptionULXBanPerm:Init()
	self:RefreshSettings()
end

derma.DefineControl("DR_ScoreboardPlayerMenuOptionULXBanBase","",DR_ScoreboardPlayerMenuOptionULXBanBase,"DR_ScoreboardPlayerMenuOptionULXBase")

derma.DefineControl("DR_ScoreboardPlayerMenuOptionULXBan30m","",DR_ScoreboardPlayerMenuOptionULXBan30m,"DR_ScoreboardPlayerMenuOptionULXBanBase")
derma.DefineControl("DR_ScoreboardPlayerMenuOptionULXBan2h","",DR_ScoreboardPlayerMenuOptionULXBan2h,"DR_ScoreboardPlayerMenuOptionULXBanBase")
derma.DefineControl("DR_ScoreboardPlayerMenuOptionULXBan1d","",DR_ScoreboardPlayerMenuOptionULXBan1d,"DR_ScoreboardPlayerMenuOptionULXBanBase")
derma.DefineControl("DR_ScoreboardPlayerMenuOptionULXBan1w","",DR_ScoreboardPlayerMenuOptionULXBan1w,"DR_ScoreboardPlayerMenuOptionULXBanBase")
derma.DefineControl("DR_ScoreboardPlayerMenuOptionULXBanPerm","",DR_ScoreboardPlayerMenuOptionULXBanPerm,"DR_ScoreboardPlayerMenuOptionULXBanBase")
