--- @class DR_ScoreboardPlayerData : DR_ScoreboardItemBase
--- @field Player Player
local DR_ScoreboardPlayerData = {
	["Player"] = NULL,
}

function DR_ScoreboardPlayerData:Init()
	local width,height = self.Parent:GetSize()
	local heightDouble = height * 2

	self:SetSize(
		width - heightDouble - 8,
		height
	)
	self:SetX(heightDouble + 8)
end

derma.DefineControl("DR_ScoreboardPlayerData","",DR_ScoreboardPlayerData,"DR_ScoreboardItemBase")
