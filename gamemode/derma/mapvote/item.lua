local Colors = DR.Colors

--- @class DR_MapVoteItemBase : DR_MenuItemBase
--- @field Parent DR_MapVoteListBase
local DR_MapVoteItemBase = {}

function DR_MapVoteItemBase:Init()
	self.TextColor = Colors.Turq

	self:RefreshSettings()
end

function DR_MapVoteItemBase:RefreshSettings()
end

derma.DefineControl("DR_MapVoteItemBase","",DR_MapVoteItemBase,"DR_MenuItemBase")
