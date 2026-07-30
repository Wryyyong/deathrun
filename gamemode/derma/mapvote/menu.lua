--- @class DR_MapVoteMenu : DMenu
local DR_MapVoteMenu = {}

--- @generic PanelClass : DR_MapVoteNominateOption
--- @param className `PanelClass`
--- @return (instance) PanelClass
function DR_MapVoteMenu:AddOption(className)
	local option = vgui.Create(className)
	option:SetMenu(self)

	self:AddPanel(option)

	return option
end

derma.DefineControl("DR_MapVoteMenu","",DR_MapVoteMenu,"DMenu")
