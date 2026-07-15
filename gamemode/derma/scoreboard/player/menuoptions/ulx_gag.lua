--- @class DR_ScoreboardPlayerMenuOptionULXGag : DR_ScoreboardPlayerMenuOptionULXBase
local DR_ScoreboardPlayerMenuOptionULXGag = {
	["Caption"] = "Gag player voice",
	["IconPath"] = "icon16/sound.png",
	["Command"] = "gag",
}

function DR_ScoreboardPlayerMenuOptionULXGag:Init()
	self:RefreshSettings()
end

function DR_ScoreboardPlayerMenuOptionULXGag:ValidClick()
	LocalPlayer():ConCommand("ulx gag \"" .. self.Player:Nick() .. "\"")
end

--- @class DR_ScoreboardPlayerMenuOptionULXUngag : DR_ScoreboardPlayerMenuOptionULXBase
local DR_ScoreboardPlayerMenuOptionULXUngag = {
	["Caption"] = "Ungag player voice",
	["IconPath"] = "icon16/sound.png",
	["Command"] = "ungag",
}

function DR_ScoreboardPlayerMenuOptionULXUngag:Init()
	self:RefreshSettings()
end

function DR_ScoreboardPlayerMenuOptionULXUngag:ValidClick()
	LocalPlayer():ConCommand("ulx ungag \"" .. self.Player:Nick() .. "\"")
end

derma.DefineControl("DR_ScoreboardPlayerMenuOptionULXGag","",DR_ScoreboardPlayerMenuOptionULXGag,"DR_ScoreboardPlayerMenuOptionULXBase")
derma.DefineControl("DR_ScoreboardPlayerMenuOptionULXUngag","",DR_ScoreboardPlayerMenuOptionULXUngag,"DR_ScoreboardPlayerMenuOptionULXBase")
