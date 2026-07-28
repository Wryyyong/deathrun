--- @class DR_ScoreboardPlayerMenuOptionULXKick : DR_ScoreboardPlayerMenuOptionULXBase
local DR_ScoreboardPlayerMenuOptionULXKick = {
	["Caption"] = "Kick from server",
	["IconPath"] = "icon16/sport_football.png",
	["Command"] = "kick",
}

function DR_ScoreboardPlayerMenuOptionULXKick:Init()
	self:RefreshSettings()
end

function DR_ScoreboardPlayerMenuOptionULXKick:ValidClick()
	LocalPlayer():ConCommand("ulx ban \"" .. self.Player:Nick() .. "\" \"Kicked by server staff.\"")
end

derma.DefineControl("DR_ScoreboardPlayerMenuOptionULXKick","",DR_ScoreboardPlayerMenuOptionULXKick,"DR_ScoreboardPlayerMenuOptionULXBase")
