--- @class DR_ZoneEditorList : DR_MenuList
local DR_ZoneEditorList = {}

function DR_ZoneEditorList:Init()
	local width,height = self:GetParent():GetSize()

	self:SetSize(
		width - 6,
		height
	)

	self:SetSpaceX(4)
	self:SetSpaceY(8)
end

--- @param caption string
function DR_ZoneEditorList:AddLabel(caption)
	local label = self:Add("DR_MenuItemBase")
	label:SetText(caption)

	return label
end

--- @param caption string
--- @param defaultText string?
function DR_ZoneEditorList:AddTextEntry(caption,defaultText)
	local split = self:GetWide() * .5 - 2

	local label = self:AddLabel(caption)
	label:SetWide(split)

	local textEntry = self:Add("DTextEntry")
	textEntry:SetSize(
		split,
		18
	)
	textEntry:SetText(defaultText)

	return textEntry
end

function DR_ZoneEditorList:AddZoneNameEntry()
	local split = self:GetWide() * .5 - 2

	local label = self:AddLabel("Zone Name:")
	label:SetWide(split)

	return self:Add("DR_ZoneNameEntry")
end

--- @param caption string
--- @param choiceTbl table
--- @param defaultChoice string?
function DR_ZoneEditorList:AddComboBox(caption,choiceTbl,defaultChoice)
	local split = self:GetWide() * .5 - 2

	local label = self:Add("DR_MenuItemBase")
	label:SetText(caption)
	label:SetWide(split)

	local comboBox = self:Add("DComboBox")
	comboBox:SetSize(
		split,
		18
	)

	for _,val in next,choiceTbl do
		comboBox:AddChoice(val)
	end

	if defaultChoice then
		comboBox:SetValue(defaultChoice)
	end

	return comboBox
end

function DR_ZoneEditorList:AddZoneEditComboBox()
	return self:Add("DR_ZoneEditComboBox")
end

--- @param num 1 | 2
function DR_ZoneEditorList:AddPosWangSet(num)
	local split = self:GetWide() * .5 - 2

	local label = self:AddLabel("Pos" .. num .. ":")
	label:SetWide(split)

	local posX = self:Add("DR_ZoneEditorPosWangX")
	local posY = self:Add("DR_ZoneEditorPosWangY")
	local posZ = self:Add("DR_ZoneEditorPosWangZ")

	local buttonWangs = self:Add("DR_ZoneEditorButtonSetPosWang" .. num)
	local buttonEyeTrace = self:Add("DR_ZoneEditorButtonSetPosEyeTrace" .. num)

	buttonWangs.PosWangX = posX
	buttonWangs.PosWangY = posY
	buttonWangs.PosWangZ = posZ

	return buttonWangs,buttonEyeTrace
end

derma.DefineControl("DR_ZoneEditorList","",DR_ZoneEditorList,"DR_MenuList")
