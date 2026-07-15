--- @class DR_ScoreboardPlayerMenuOptionForceSpectator : DR_ScoreboardPlayerMenuOptionBase
local DR_ScoreboardPlayerMenuOptionForceSpectator = {
	["Caption"] = "Force to Spectator",
	["IconPath"] = "icon16/status_offline.png",
}

function DR_ScoreboardPlayerMenuOptionForceSpectator:Init()
	self:RefreshSettings()
end

function DR_ScoreboardPlayerMenuOptionForceSpectator:ValidClick()
	net.Start("DeathrunForceSpectator")
		net.WritePlayer(self.Player)
	net.SendToServer()
end

derma.DefineControl("DR_ScoreboardPlayerMenuOptionForceSpectator","",DR_ScoreboardPlayerMenuOptionForceSpectator,"DR_ScoreboardPlayerMenuOptionBase")
