--- @class DR_ZoneNameEntry : DTextEntry
local DR_ZoneNameEntry = {}

function DR_ZoneNameEntry:Init()
	self:SetSize(
		self:GetParent():GetWide() * .5 - 2,
		18
	)
	self:SetText("New Zone")
end

function DR_ZoneNameEntry:OnTextChanged()
	local createButton = self.CreateButton
	if not createButton then return end

	createButton:SetText("Create Zone \"" .. self:GetText() .. "\"")
end

derma.DefineControl("DR_ZoneNameEntry","",DR_ZoneNameEntry,"DTextEntry")
