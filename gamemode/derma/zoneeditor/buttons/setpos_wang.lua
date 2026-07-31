--- @class DR_ZoneEditorButtonSetPosWangBase : DR_ZoneEditorButtonBase
--- @field PosWangX DR_ZoneEditorPosWangX
--- @field PosWangY DR_ZoneEditorPosWangY
--- @field PosWangZ DR_ZoneEditorPosWangZ
local DR_ZoneEditorButtonSetPosWangBase = {
	["Pos"] = 0,
}

function DR_ZoneEditorButtonSetPosWangBase:Init()
	self:RefreshSettings()
end

function DR_ZoneEditorButtonSetPosWangBase:RefreshSettings()
	self:SetText("Set Pos" .. self.Pos .. " by values")
end

function DR_ZoneEditorButtonSetPosWangBase:DoClick()
	local command =
		"zone_setposxyz \"" .. self.ZoneEdit:GetValue() .. "\" "
	..	self.Pos
	..	" " .. self.PosWangX:GetValue()
	..	" " .. self.PosWangY:GetValue()
	..	" " .. self.PosWangZ:GetValue()

	LocalPlayer():ConCommand(command)
end

--- @class DR_ZoneEditorButtonSetPosWang1 : DR_ZoneEditorButtonSetPosWangBase
local DR_ZoneEditorButtonSetPosWang1 = {
	["Pos"] = 1,
}

function DR_ZoneEditorButtonSetPosWang1:Init()
	self:RefreshSettings()
end

--- @class DR_ZoneEditorButtonSetPosWang2 : DR_ZoneEditorButtonSetPosWangBase
local DR_ZoneEditorButtonSetPosWang2 = {
	["Pos"] = 2,
}

function DR_ZoneEditorButtonSetPosWang2:Init()
	self:RefreshSettings()
end

derma.DefineControl("DR_ZoneEditorButtonSetPosWangBase","",DR_ZoneEditorButtonSetPosWangBase,"DR_ZoneEditorButtonBase")

derma.DefineControl("DR_ZoneEditorButtonSetPosWang1","",DR_ZoneEditorButtonSetPosWang1,"DR_ZoneEditorButtonSetPosWangBase")
derma.DefineControl("DR_ZoneEditorButtonSetPosWang2","",DR_ZoneEditorButtonSetPosWang2,"DR_ZoneEditorButtonSetPosWangBase")
