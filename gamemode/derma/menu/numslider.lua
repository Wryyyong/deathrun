local ConVarMeta = FindMetaTable("ConVar")

--- @class DR_MenuSliderNumber : DNumSlider
--- @field Parent DR_MenuList
local DR_MenuSliderNumber = {
	["Decimals"] = 2,

	["ConVarGet"] = ConVarMeta.GetFloat,
	["ConVarSet"] = ConVarMeta.SetFloat,
}

function DR_MenuSliderNumber:Init()
	local parent = self:GetParent()
	self.Parent = parent

	self.Label:SetVisible(false)
	self:SetWide(parent:GetWide())
	self:SetDark(true)

	self:RefreshSettings()
end

function DR_MenuSliderNumber:RefreshSettings()
	self:SetDecimals(self.Decimals)
end

function DR_MenuSliderNumber:OnValueChanged(newVal)
	local cvar = self.ConVar
	if not cvar then return end

	self.ConVarSet(cvar,math.Round(newVal,self.Decimals))
end

--- @class DR_MenuSliderInteger : DR_MenuSliderNumber
local DR_MenuSliderInteger = {
	["Decimals"] = 0,

	["ConVarGet"] = ConVarMeta.GetInt,
	["ConVarSet"] = ConVarMeta.SetInt,
}

function DR_MenuSliderInteger:Init()
	self:RefreshSettings()
end

derma.DefineControl("DR_MenuSliderNumber","",DR_MenuSliderNumber,"DNumSlider")

derma.DefineControl("DR_MenuSliderInteger","",DR_MenuSliderInteger,"DR_MenuSliderNumber")
