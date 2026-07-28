--- @class DR_CustomScrollPanel : DPanel
--- @field pnlCanvas DR_CustomPanelCanvas
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

function DR_CustomScrollPanel:Init()
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
