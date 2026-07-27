--- @class DR_ZoneEditorButtonBase : DR_Button
--- @field Parent DR_MenuList_ZoneEditor
local DR_ZoneEditorButtonBase = {
	["Font"] = "Deathrun_Derma_ExtraSmall",
}

function DR_ZoneEditorButtonBase:Init()
	self:SetSize(self.Parent:GetWide(),18)
	self:SetOffsets()
end

derma.DefineControl("DR_ZoneEditorButtonBase","",DR_ZoneEditorButtonBase,"DR_Button")
