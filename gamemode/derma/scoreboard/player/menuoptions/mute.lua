--- @class DR_ScoreboardPlayerMenuOptionMute : DR_ScoreboardPlayerMenuOptionBase
local DR_ScoreboardPlayerMenuOptionMute = {
	["Caption"] = "Toggle voice",
	["IconPath"] = "icon16/sound.png",
}

function DR_ScoreboardPlayerMenuOptionMute:Init()
	self:RefreshSettings()
end

function DR_ScoreboardPlayerMenuOptionMute:ValidClick()
	local player = self.Player

	RunConsoleCommand("deathrun_toggle_mute",player:SteamID())
end

derma.DefineControl("DR_ScoreboardPlayerMenuOptionMute","",DR_ScoreboardPlayerMenuOptionMute,"DR_ScoreboardPlayerMenuOptionBase")
