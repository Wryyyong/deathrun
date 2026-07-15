local ColorTurq = DR.Colors.Turq

--- @class DR_MapVoteListBase : DR_List
--- @generic ButtonClass : DButton
--- @field ButtonClass `ButtonClass`
local DR_MapVoteListBase = {
	["ButtonClass"] = "DButton",
}

function DR_MapVoteListBase:Init()
	self:SetSize(
		self.Parent:GetWide(),
		1500
	)
end

--- @return DR_MapVoteRowBase
function DR_MapVoteListBase:AddRow()
end

--- @param caption string
--- @param font string
function DR_MapVoteListBase:AddLabel(caption,font)
	local label = self:Add("DR_MapVoteItemBase")
	label:SetFont(font)
	label:SetText(caption)
	label:SetColor(ColorTurq)
	label:SizeToContents()
	label:SetWide(self:GetWide())

	return label
end

--- @param row DR_MapVoteRowBase
function DR_MapVoteListBase:FinishRow(row)
	local columnCount = row.ColumnCount
	local labelColor = row.LabelColor

	local width,height = row:GetSize()
	width = width + 8
	height = height * .5

	for idx,columnText in ipairs(row.Columns) do
		local offsetHeight = idx - 1
		local align = .5

		if idx == 1 then
			align = 0
		elseif idx == columnCount then
			align = 4
		end

		local label = row:Add("DLabel")
		label:SetText(columnText)
		label:SetTextColor(labelColor)
		label:SetFont("Deathrun_Derma_ExtraSmall")
		label:SizeToContents()

		local widthLabel,heightLabel = label:GetSize()

		label:SetPos(
			columnCount > 1
		and	4 + (offsetHeight * (width / (columnCount - 1)) - widthLabel * align)
		or	width * .5 - widthLabel * .5
			,
			height - heightLabel * .5 - 1
		)
	end

	row:Add(self.ButtonClass)

	return row
end

derma.DefineControl("DR_MapVoteListBase","",DR_MapVoteListBase,"DR_List")
