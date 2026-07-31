local MathHuge = math.huge

--- @class DR_ZoneEditorPosWangBase : DNumberWang
--- @field Parent DR_ZoneEditorList
local DR_ZoneEditorPosWangBase = {
	["OffsetX"] = -1,
}

function DR_ZoneEditorPosWangBase:Init()
	self.Parent = self:GetParent()

	self:SetWide(70)
	self:HideWang()
	self:SetMinMax(-MathHuge,MathHuge)
	self:SetDecimals(64)
	self:SetValue(0)

	self:RefreshSettings()
end

function DR_ZoneEditorPosWangBase:RefreshSettings()
	self:SetX(self.Parent:GetWide() + self.OffsetX)
end

--- @class DR_ZoneEditorPosWangX : DR_ZoneEditorPosWangBase
local DR_ZoneEditorPosWangX = {
	["OffsetX"] = 0,
}

function DR_ZoneEditorPosWangX:Init()
	self:RefreshSettings()
end

--- @class DR_ZoneEditorPosWangY : DR_ZoneEditorPosWangBase
local DR_ZoneEditorPosWangY = {
	["OffsetX"] = 36,
}

function DR_ZoneEditorPosWangY:Init()
	self:RefreshSettings()
end

--- @class DR_ZoneEditorPosWangZ : DR_ZoneEditorPosWangBase
local DR_ZoneEditorPosWangZ = {
	["OffsetX"] = 72,
}

function DR_ZoneEditorPosWangZ:Init()
	self:RefreshSettings()
end

derma.DefineControl("DR_ZoneEditorPosWangBase","",DR_ZoneEditorPosWangBase,"DNumberWang")

derma.DefineControl("DR_ZoneEditorPosWangX","",DR_ZoneEditorPosWangX,"DR_ZoneEditorPosWangBase")
derma.DefineControl("DR_ZoneEditorPosWangY","",DR_ZoneEditorPosWangY,"DR_ZoneEditorPosWangBase")
derma.DefineControl("DR_ZoneEditorPosWangZ","",DR_ZoneEditorPosWangZ,"DR_ZoneEditorPosWangBase")
