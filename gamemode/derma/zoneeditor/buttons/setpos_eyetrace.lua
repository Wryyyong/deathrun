--- @class DR_ZoneEditorButtonSetPosEyeTraceBase : DR_ZoneEditorButtonBase
local DR_ZoneEditorButtonSetPosEyeTraceBase = {
	["Pos"] = 0,
}

function DR_ZoneEditorButtonSetPosEyeTraceBase:Init()
	self:RefreshSettings()
end

function DR_ZoneEditorButtonSetPosEyeTraceBase:RefreshSettings()
	self:SetText("Set Pos" .. self.Pos .. " to EyeTrace")
end

function DR_ZoneEditorButtonSetPosEyeTraceBase:DoClick()
	local command = "zone_setpos \"" .. self.ZoneEdit:GetValue() .. "\" " .. self.Pos

	LocalPlayer():ConCommand(command)
end

--- @class DR_ZoneEditorButtonSetPosEyeTrace1 : DR_ZoneEditorButtonSetPosEyeTraceBase
local DR_ZoneEditorButtonSetPosEyeTrace1 = {
	["Pos"] = 1,
}

function DR_ZoneEditorButtonSetPosEyeTrace1:Init()
	self:RefreshSettings()
end

--- @class DR_ZoneEditorButtonSetPosEyeTrace2 : DR_ZoneEditorButtonSetPosEyeTraceBase
local DR_ZoneEditorButtonSetPosEyeTrace2 = {
	["Pos"] = 2,
}

function DR_ZoneEditorButtonSetPosEyeTrace2:Init()
	self:RefreshSettings()
end

derma.DefineControl("DR_ZoneEditorButtonSetPosEyeTraceBase","",DR_ZoneEditorButtonSetPosEyeTraceBase,"DR_ZoneEditorButtonBase")

derma.DefineControl("DR_ZoneEditorButtonSetPosEyeTrace1","",DR_ZoneEditorButtonSetPosEyeTrace1,"DR_ZoneEditorButtonSetPosEyeTraceBase")
derma.DefineControl("DR_ZoneEditorButtonSetPosEyeTrace2","",DR_ZoneEditorButtonSetPosEyeTrace2,"DR_ZoneEditorButtonSetPosEyeTraceBase")
