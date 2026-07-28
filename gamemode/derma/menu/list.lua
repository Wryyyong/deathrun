--- @class DR_MenuList : DR_List
local DR_MenuList = {}

function DR_MenuList:Init()
	self:SetSize(self:GetParent():GetSize())
end

--- @param text string
function DR_MenuList:AddTop(text)
	local top = self:Add("DR_MenuTop")
	top:SetText(text)

	return top
end

--- @param text string
--- @param skipSpacer boolean?
function DR_MenuList:AddHeader(text,skipSpacer)
	if not skipSpacer then
		self:Add("DR_MenuSpacerLarge")
	end

	local header = self:Add("DR_MenuHeader")
	header:SetText(text)

	return header
end

--- @param text string
--- @param cvar ConVar
function DR_MenuList:AddBoolean(text,cvar)
	self:Add("DR_MenuSpacerSmall")

	local toggle = self:Add("DR_AuToggle")
	toggle:SetText(text)
	toggle:SetConVar(cvar:GetName())

	return toggle
end

--- @param text string
--- @param cvar ConVar
--- @param forceMax number?
function DR_MenuList:AddNumber(text,cvar,forceMax)
	self:Add("DR_MenuSpacerSmall")

	local number = self:Add("DR_MenuItemBase")
	number:SetText(text)

	local slider = self:Add("DR_MenuSliderNumber")
	slider:SetConVar(cvar:GetName())
	slider:SetMinMax(
		cvar:GetMin(),
		forceMax or cvar:GetMax()
	)
	slider:SetValue(cvar:GetFloat())

	return number,slider
end

--- @param text string
--- @param cvar ConVar
--- @param forceMax number?
function DR_MenuList:AddInteger(text,cvar,forceMax)
	self:Add("DR_MenuSpacerSmall")

	local integer = self:Add("DR_MenuItemBase")
	integer:SetText(text)

	local slider = self:Add("DR_MenuSliderInteger")
	slider:SetConVar(cvar:GetName())
	slider:SetMinMax(
		cvar:GetMin(),
		forceMax or cvar:GetMax()
	)
	slider:SetValue(cvar:GetInt())

	return integer,slider
end

function DR_MenuList:AddUpdateText()
	self:Add("DR_MenuSpacerLarge")

	local update = self:Add("DR_MenuImportant")
	update:SetText("Last Significant Update: " .. DR.TimeStampFormatted)

	return update
end

derma.DefineControl("DR_MenuList","",DR_MenuList,"DR_List")
