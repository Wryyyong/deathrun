--- @class DR_CustomVScrollBarButtonBase : DButton
--- @field Parent DR_CustomVScrollBar
local DR_CustomVScrollBarButtonBase = {
	["ScrollInc"] = 0,
	["ScrollHook"] = "",
}

function DR_CustomVScrollBarButtonBase:Init()
	self.Parent = self:GetParent()

	self:SetText("")
end

function DR_CustomVScrollBarButtonBase:Paint(width,height)
	derma.SkinHook("Paint",self.ScrollHook,self,width,height)
end

function DR_CustomVScrollBarButtonBase:DoClock()
	self.Parent:AddScroll(self.ScrollInc)
end

--- @class DR_CustomVScrollBarButtonUp : DR_CustomVScrollBarButtonBase
local DR_CustomVScrollBarButtonUp = {
	["ScrollInc"] = -1,
	["ScrollHook"] = "ButtonUp",
}

--- @class DR_CustomVScrollBarButtonDown : DR_CustomVScrollBarButtonBase
local DR_CustomVScrollBarButtonDown = {
	["ScrollInc"] = 1,
	["ScrollHook"] = "ButtonDown",
}

derma.DefineControl("DR_CustomVScrollBarButtonBase","",DR_CustomVScrollBarButtonBase,"DButton")

derma.DefineControl("DR_CustomVScrollBarButtonUp","",DR_CustomVScrollBarButtonUp,"DR_CustomVScrollBarButtonBase")
derma.DefineControl("DR_CustomVScrollBarButtonDown","",DR_CustomVScrollBarButtonDown,"DR_CustomVScrollBarButtonBase")
