--- @class DR_ZoneEditorButtonTeleport : DR_ZoneEditorButtonBase
local DR_ZoneEditorButtonTeleport = {
	["ButtonText"] = "Go to zone centre",
}

function DR_ZoneEditorButtonTeleport:Init()
	self:RefreshSettings()
end

function DR_ZoneEditorButtonTeleport:DoClick()
	local command = "zone_goto \"" .. self.ZoneEdit:GetValue() .. "\""

	LocalPlayer():ConCommand(command)
end

derma.DefineControl("DR_ZoneEditorButtonTeleport","",DR_ZoneEditorButtonTeleport,"DR_ZoneEditorButtonBase")
