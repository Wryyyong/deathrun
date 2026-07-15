--- @class DR_ZoneEditorButtonSetPosBase : DR_ZoneEditorButtonBase
local DR_ZoneEditorButtonSetPosBase = {
	["Pos"] = 0,
}

function DR_ZoneEditorButtonSetPosBase:Init()
	self:RefreshSettings()
end

function DR_ZoneEditorButtonSetPosBase:RefreshSettings()
	self:SetText("Set Pos" .. self.Pos .. " to EyeTrace")
end

function DR_ZoneEditorButtonSetPosBase:DoClick()
	local command = "zone_setpos \"" .. self.ZoneEdit:GetValue() .. "\" " .. self.Pos

	LocalPlayer():ConCommand(command)
end

--- @class DR_ZoneEditorButtonSetPos1 : DR_ZoneEditorButtonSetPosBase
local DR_ZoneEditorButtonSetPos1 = {
	["Pos"] = 1,
}

function DR_ZoneEditorButtonSetPos1:Init()
	self:RefreshSettings()
end

--- @class DR_ZoneEditorButtonSetPos2 : DR_ZoneEditorButtonSetPosBase
local DR_ZoneEditorButtonSetPos2 = {
	["Pos"] = 2,
}

function DR_ZoneEditorButtonSetPos2:Init()
	self:RefreshSettings()
end

derma.DefineControl("DR_ZoneEditorButtonSetPosBase","",DR_ZoneEditorButtonSetPosBase,"DR_ZoneEditorButtonBase")

derma.DefineControl("DR_ZoneEditorButtonSetPos1","",DR_ZoneEditorButtonSetPos1,"DR_ZoneEditorButtonSetPosBase")
derma.DefineControl("DR_ZoneEditorButtonSetPos2","",DR_ZoneEditorButtonSetPos2,"DR_ZoneEditorButtonSetPosBase")
