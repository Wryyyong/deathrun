--- @class DR_MapVoteInner : DR_Inner
local DR_MapVoteInner = {
	["Paint"] = DR.EmptyFunction,
}

function DR_MapVoteInner:Init()
	local width,height = self.Parent:GetSize()

	self:SetPos(4,32)
	self:SetSize(
		width - 4,
		height - 44
	)
end

derma.DefineControl("DR_MapVoteInner","",DR_MapVoteInner,"DR_Inner")
