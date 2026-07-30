--- @class DR_MapVoteFrameVoting : DR_MenuFrame
local DR_MapVoteFrameVoting = {
	["Title"] = "Map List",
	["Width"] = 230 * 1.618 + 4,
}

function DR_MapVoteFrameVoting:Init()
	self:RefreshSettings()

	-- GOLDEN RATIO FIBONACCI SPIRAL OMG
	self:SetTall(MV.MaxMaps * 24 + (MV.MaxMaps - 1) * 4 + 44)
	self:SetPos(4,0)
	self:CenterVertical()
	self:SetTitle("Mapvote")
end

derma.DefineControl("DR_MapVoteFrameVoting","",DR_MapVoteFrameVoting,"DR_MenuFrame")
