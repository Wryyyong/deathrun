--- @class DR_ZoneEditorColorMixer : DColorMixer
local DR_ZoneEditorColorMixer = {}

function DR_ZoneEditorColorMixer:Init()
	self:SetSize(
		self:GetParent():GetWide(),
		196
	)

	self:SetPalette(true)
	self:SetAlphaBar(true)
	self:SetWangs(true)
	self:SetColor(color_white)
end

derma.DefineControl("DR_ZoneEditorColorMixer","",DR_ZoneEditorColorMixer,"DColorMixer")
