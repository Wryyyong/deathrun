--- @class DR_ScoreboardPlayerPanel : DR_ScoreboardItemSmallBase
--- @field Player Player
--- @field Avatar DR_ScoreboardPlayerAvatar
--- @field Data DR_ScoreboardPlayerData
--- @field Icon DR_ScoreboardPlayerIcon
--- @field Button DR_ScoreboardPlayerButton
local DR_ScoreboardPlayerPanel = {
	["Player"] = NULL,
}

function DR_ScoreboardPlayerPanel:Init()
	self:SetTall(self.SmallMode and 22 or 28)
end

function DR_ScoreboardPlayerPanel:Paint(width,height)
	self.BaseClass.Paint(self,width,height)

	local ply = self.Player

	if
		not IsValid(ply)
	or	ply:Alive()
	then return end

	surface.SetDrawColor(255,255,255,70)
	surface.DrawRect(0,0,width,height)
end

derma.DefineControl("DR_ScoreboardPlayerPanel","",DR_ScoreboardPlayerPanel,"DR_ScoreboardItemSmallBase")
