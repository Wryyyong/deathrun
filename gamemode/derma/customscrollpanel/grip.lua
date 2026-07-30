local SurfaceSetDrawColor = surface.SetDrawColor
local SurfaceDrawRect = surface.DrawRect

--- @class DR_CustomScrollBarGrip : DScrollBarGrip
local DR_CustomScrollBarGrip = {}

function DR_CustomScrollBarGrip:Paint(width,height)
	SurfaceSetDrawColor(0,0,0,200)
	SurfaceDrawRect(
		0,
		0,
		width,
		height
	)
end

derma.DefineControl("DR_CustomScrollBarGrip","",DR_CustomScrollBarGrip,"DScrollBarGrip")
