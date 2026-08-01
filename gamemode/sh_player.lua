local TeamGetColor = team.GetColor

local PlyMeta = FindMetaTable("Player")

function PlyMeta:GetTeamColor()
	return TeamGetColor(self:Team())
end
