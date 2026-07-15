--- @class DR_ScoreboardPlayerMenuOptionULXSlay : DR_ScoreboardPlayerMenuOptionULXBase
local DR_ScoreboardPlayerMenuOptionULXSlay = {
	["Caption"] = "Slay player",
	["IconPath"] = "icon16/newspaper.png",
	["Command"] = "slay",
}

function DR_ScoreboardPlayerMenuOptionULXSlay:Init()
	self:RefreshSettings()
end

function DR_ScoreboardPlayerMenuOptionULXSlay:ValidClick()
	LocalPlayer():ConCommand("ulx slay \"" .. self.Player:Nick() .. "\"")
end

derma.DefineControl("DR_ScoreboardPlayerMenuOptionULXSlay","",DR_ScoreboardPlayerMenuOptionULXSlay,"DR_ScoreboardPlayerMenuOptionULXBase")
