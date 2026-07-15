--- @class DR_List : DIconLayout
--- @field Parent DR_CustomPanelCanvas
local DR_List = {}

function DR_List:Init()
	self.Parent = self:GetParent()

	self:SetPos(0,0)
	self:SetSpaceX(0)
	self:SetSpaceY(4)
end

derma.DefineControl("DR_List","",DR_List,"DIconLayout")
