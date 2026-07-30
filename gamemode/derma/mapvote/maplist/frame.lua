--- @class DR_MapVoteFrameMapList : DR_MenuFrame
local DR_MapVoteFrameMapList = {
	["Title"] = "Map List",
	["Width"] = 480,
}

function DR_MapVoteFrameMapList:Init()
	self:RefreshSettings()

	-- GOLDEN RATIO FIBONACCI SPIRAL OMG
	self:SetTall(math.min(DR.ScreenHeight - 64,480 * 1.618 - 44))
end

derma.DefineControl("DR_MapVoteFrameMapList","",DR_MapVoteFrameMapList,"DR_MenuFrame")
