--- @class DR_ScoreboardPlayerMenuOptionOpenProfile : DR_ScoreboardPlayerMenuOptionBase
local DR_ScoreboardPlayerMenuOptionOpenProfile = {
	["Caption"] = "Open Steam profile",
	["IconPath"] = "icon16/page_world.png",
}

function DR_ScoreboardPlayerMenuOptionOpenProfile:Init()
	self:RefreshSettings()
end

function DR_ScoreboardPlayerMenuOptionOpenProfile:ValidClick()
	gui.OpenURL("http://steamcommunity.com/profiles/" .. self.Player:SteamID64())
end

derma.DefineControl("DR_ScoreboardPlayerMenuOptionOpenProfile","",DR_ScoreboardPlayerMenuOptionOpenProfile,"DR_ScoreboardPlayerMenuOptionBase")
