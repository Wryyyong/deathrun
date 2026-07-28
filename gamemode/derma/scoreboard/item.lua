local ColorClouds = DR.Colors.Clouds
local ColorGrey = DR.Colors.Grey

local CvSmallScoreboard = DR.ConVars.SmallScoreboard

--- @class DR_ScoreboardItemBase : DPanel
--- @field Parent DR_ScoreboardList
local DR_ScoreboardItemBase = {
	["Paint"] = DR.EmptyFunction,
}

function DR_ScoreboardItemBase:Init()
	local parent = self:GetParent()
	self.Parent = parent

	self:SetWide(parent:GetWide())

	self.BgColor = color_white
	self.TextColor = color_black

	-- static across all instances
	DR_ScoreboardItemBase.SmallMode = CvSmallScoreboard:GetBool()
end

--- @class DR_ScoreboardItemSmallBase : DR_ScoreboardItemBase
local DR_ScoreboardItemSmallBase = {}

function DR_ScoreboardItemSmallBase:Init()
	self:SetTall(self.SmallMode and 24 or 32)

	self.BgColor = ColorClouds or ColorGrey
end

function DR_ScoreboardItemSmallBase:Paint(width,height)
	surface.SetDrawColor(self.BgColor)
	surface.DrawRect(
		0,
		0,
		width,
		height
	)
end

--[[
--- @class DR_ScoreboardHeader : DR_ScoreboardItemSmallBase
local DR_ScoreboardHeader = {
	["Text"] = "",
}

function DR_ScoreboardHeader:Init()
	self.Columns = {}
end
--]]

derma.DefineControl("DR_ScoreboardItemBase","",DR_ScoreboardItemBase,"DPanel")

derma.DefineControl("DR_ScoreboardItemSmallBase","",DR_ScoreboardItemSmallBase,"DR_ScoreboardItemBase")

--derma.DefineControl("DR_ScoreboardHeader","",DR_ScoreboardHeader,"DR_ScoreboardItemSmallBase")
