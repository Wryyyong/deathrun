--- @class DR_ScoreboardPlayerIcon : DPanel
--- @field Material IMaterial
local DR_ScoreboardPlayerIcon = {
	["Player"] = NULL,
}

function DR_ScoreboardPlayerIcon:Init()
	local height = self:GetParent():GetTall()

	self:SetSize(height,height)
	self:SetX(height)
end

function DR_ScoreboardPlayerIcon:Paint(width,height)
	local material = self.Material
	if not material then return end

	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(material)
	surface.DrawTexturedRect(
		width * .5 - 8,
		height * .5 - 8,
		16,
		16
	)
end

derma.DefineControl("DR_ScoreboardPlayerIcon","",DR_ScoreboardPlayerIcon,"DPanel")
