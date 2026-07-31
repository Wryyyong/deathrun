--- @class DR_ZoneEditorButtonBase : DR_Button
--- @field Parent DR_ZoneEditorList
--- @field ZoneEdit DR_ZoneEditComboBox
local DR_ZoneEditorButtonBase = {
	["ButtonText"] = "",
}

function DR_ZoneEditorButtonBase:Init()
	local parent = self:GetParent()
	self.Parent = parent

	self:SetSize(
		parent:GetWide(),
		18
	)
	self:SetFont("Deathrun_Derma_ExtraSmall")

	self:RefreshSettings()
end

function DR_ZoneEditorButtonBase:RefreshSettings()
	self:SetText(self.ButtonText)
end

function DR_ZoneEditorButtonBase:DoClick()
	local zoneEdit = self.ZoneEdit
	local newIdx = zoneEdit:GetSelectedID() - 1

	if newIdx <= 0 then
		newIdx = 1
	end

	zoneEdit:ChooseOptionID(newIdx)
end

derma.DefineControl("DR_ZoneEditorButtonBase","",DR_ZoneEditorButtonBase,"DR_Button")
