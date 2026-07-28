--- @class DR_List : DIconLayout
local DR_List = {}

function DR_List:Init()
	self:SetPos(0,0)
	self:SetSpaceX(0)
	self:SetSpaceY(4)
end

derma.DefineControl("DR_List","",DR_List,"DIconLayout")
