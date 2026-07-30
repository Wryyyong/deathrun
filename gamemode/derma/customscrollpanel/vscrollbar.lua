local SurfaceSetDrawColor = CLIENT and surface.SetDrawColor
local SurfaceDrawRect = CLIENT and surface.DrawRect

--- @class DR_CustomVScrollBar : Panel
--- @field btnUp DR_CustomVScrollBarButtonUp
--- @field btnDown DR_CustomVScrollBarButtonDown
--- @field btnGrip DR_CustomScrollBarGrip
local DR_CustomVScrollBar = {
	["Offset"] = 0,
	["Scroll"] = 0,
	["CanvasSize"] = 1,
	["BarSize"] = 1,

	["AddScroll"] = DVScrollBar.AddScroll,
	["AnimateTo"] = DVScrollBar.AnimateTo,
	["BarScale"] = DVScrollBar.BarScale,
	["GetOffset"] = DVScrollBar.GetOffset,
	["GetScroll"] = DVScrollBar.GetScroll,
	["Grip"] = DVScrollBar.Grip,
	["OnCursorMoved"] = DVScrollBar.OnCursorMoved,
	["OnMousePressed"] = DVScrollBar.OnMousePressed,
	["OnMouseReleased"] = DVScrollBar.OnMouseReleased,
	["OnMouseWheeled"] = DVScrollBar.OnMouseWheeled,
	["PerformLayout"] = DVScrollBar.PerformLayout,
	["SetEnabled"] = DVScrollBar.SetEnabled,
	["SetScroll"] = DVScrollBar.SetScroll,
	["SetUp"] = DVScrollBar.SetUp,
	["Think"] = DVScrollBar.Think,

	["GetHideButtons"] = DVScrollBar.GetHideButtons,
	["SetHideButtons"] = DVScrollBar.SetHideButtons,
}

AccessorFunc(DR_CustomVScrollBar,"m_HideButtons","HideButtons")

function DR_CustomVScrollBar:Init()
	self:SetSize(15,15)
	self:SetHideButtons(true)
	self:Dock(RIGHT)

	self.btnUp = self:Add("DR_CustomVScrollBarButtonUp")
	self.btnDown = self:Add("DR_CustomVScrollBarButtonDown")
	self.btnGrip = self:Add("DR_CustomScrollBarGrip")
end

function DR_CustomVScrollBar:Paint(width,height)
	SurfaceSetDrawColor(0,0,0,100)
	SurfaceDrawRect(
		0,
		0,
		width,
		height
	)
end

derma.DefineControl("DR_CustomVScrollBar","",DR_CustomVScrollBar,"Panel")
