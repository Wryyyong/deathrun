local DermaColors = DR.DermaColors

--- @class DR_NavButtonBase : DR_Button
--- @field Parent DR_MultiPanel
local DR_NavButtonBase = {
	["Text"] = "",
	["ZPos"] = -32768,
}

function DR_NavButtonBase:Init()
	self:SetColors(DermaColors.GoodDark,DermaColors.Good)
	self:SetSize(24,24)
	self:SetText(self.Text)
	self:SetZPos(self.ZPos)
end

function DR_NavButtonBase.GetNewOffset()
	return FrameTime() * 200
end

function DR_NavButtonBase:Think()
	if not self:IsDown() then return end

	local parent = self.Parent
	parent.ButtonOffset = parent.ButtonOffset + self:GetNewOffset()
	parent:InvalidateLayout()
end

--- @class DR_NavButtonLeft : DR_NavButtonBase
local DR_NavButtonLeft = {
	["Text"] = "<",
	["ZPos"] = 99,
}

--- @class DR_NavButtonRight : DR_NavButtonBase
local DR_NavButtonRight = {
	["Text"] = ">",
	["ZPos"] = 98,
}

function DR_NavButtonRight:GetNewOffset()
	return -(self.BaseClass--[[@cast -?]].GetNewOffset())
end

derma.DefineControl("DR_NavButtonBase","",DR_NavButtonBase,"DR_Button")

derma.DefineControl("DR_NavButtonLeft","",DR_NavButtonLeft,"DR_NavButtonBase")
derma.DefineControl("DR_NavButtonRight","",DR_NavButtonRight,"DR_NavButtonBase")
