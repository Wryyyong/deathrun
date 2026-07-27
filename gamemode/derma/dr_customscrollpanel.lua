--- @class DR_CustomScrollPanel : DPanel
--- @field VBar DR_CustomVScrollBar
local DR_CustomScrollPanel = {
	["AddItem"] = DScrollPanel.AddItem,
	["Clear"] = DScrollPanel.Clear,
	["GetVBar"] = DScrollPanel.GetVBar,
	["InnerWidth"] = DScrollPanel.InnerWidth,
	["OnChildAdded"] = DScrollPanel.OnChildAdded,
	["OnMouseWheeled"] = DScrollPanel.OnMouseWheeled,
	["OnVScroll"] = DScrollPanel.OnVScroll,
	["PerformLayout"] = DScrollPanel.PerformLayout,
	["PerformLayoutInternal"] = DScrollPanel.PerformLayoutInternal,
	["Rebuild"] = DScrollPanel.Rebuild,
	["ScrollToChild"] = DScrollPanel.ScrollToChild,
	["SizeToContents"] = DScrollPanel.SizeToContents,

	["GetCanvas"] = DScrollPanel.GetCanvas,
	["SetCanvas"] = DScrollPanel.SetCanvas,

	["GetPadding"] = DScrollPanel.GetPadding,
	["SetPadding"] = DScrollPanel.SetPadding,
}

AccessorFunc(DR_CustomScrollPanel,"Padding","Padding")
AccessorFunc(DR_CustomScrollPanel,"pnlCanvas","Canvas")

function DR_CustomScrollPanel:Init()
	local width,height = self:GetParent():GetSize()

	self:SetSize(
		width - 16,
		height - 16
	)
	self:SetPos(8,8)

	self:SetPadding(0)
	self:SetMouseInputEnabled(true)

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled(false)
	self:SetPaintBorderEnabled(false)
	self:SetPaintBackground(false)

	self.pnlCanvas = self:Add("DR_CustomPanelCanvas")
	self.VBar = self:Add("DR_CustomVScrollBar")
end

derma.DefineControl("DR_CustomScrollPanel","",DR_CustomScrollPanel,"DPanel")
