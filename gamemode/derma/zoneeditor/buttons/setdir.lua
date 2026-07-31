--- @class DR_ZoneEditorButtonSetDir : DR_ZoneEditorButtonBase
local DR_ZoneEditorButtonSetDir = {
	["ButtonText"] = "Set Dir to current cardinal direction",
}

function DR_ZoneEditorButtonSetDir:Init()
	self:RefreshSettings()
end

function DR_ZoneEditorButtonSetDir:DoClick()
	local command = "zone_setdir \"" .. self.ZoneEdit:GetValue() .. "\""

	LocalPlayer():ConCommand(command)
end

derma.DefineControl("DR_ZoneEditorButtonSetDir","",DR_ZoneEditorButtonSetDir,"DR_ZoneEditorButtonBase")
