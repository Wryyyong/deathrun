local MapVote = DR.MapVote

--- @class DR_MapVoteFrameVoting : DR_MenuFrame
local DR_MapVoteFrameVoting = {
	["Title"] = "Map List",
	["Width"] = 230 * 1.618 + 4,
}

function DR_MapVoteFrameVoting:Init()
	local maxMaps = MapVote.MaxMaps

	self:RefreshSettings()

	-- GOLDEN RATIO FIBONACCI SPIRAL OMG
	self:SetTall(maxMaps * 24 + (maxMaps - 1) * 4 + 44)
	self:SetPos(4,0)
	self:CenterVertical()
	self:SetTitle("Mapvote")
end

derma.DefineControl("DR_MapVoteFrameVoting","",DR_MapVoteFrameVoting,"DR_MenuFrame")
