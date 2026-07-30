local SurfaceSetDrawColor = CLIENT and surface.SetDrawColor
local SurfaceDrawRect = CLIENT and surface.DrawRect

local Colors = DR.Colors

--- @class DR_MapVoteRowBase : DPanel
--- @field Parent DR_MapVoteListMapList
local DR_MapVoteRowBase = {
	["Columns"] = {},
	["ColumnCount"] = 2,
	["CustomColor"] = Colors.Clouds,
	["LabelColor"] = Colors.Grey,
}

function DR_MapVoteRowBase:Init()
	local parent = self:GetParent()
	self.Parent = parent

	self.Columns = {}

	self:SetSize(
		parent:GetParent():GetParent():GetWide() - 8,
		24
	)
end

function DR_MapVoteRowBase:Paint(width,height)
	SurfaceSetDrawColor(self.CustomColor)
	SurfaceDrawRect(
		0,
		0,
		width,
		height
	)
end

derma.DefineControl("DR_MapVoteRowBase","",DR_MapVoteRowBase,"DPanel")
