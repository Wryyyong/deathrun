--- @class DR_CustomScrollBarGrip : DScrollBarGrip
local DR_CustomScrollBarGrip = {}

function DR_CustomScrollBarGrip:Paint(width,height)
	surface.SetDrawColor(0,0,0,200)
	surface.DrawRect(
		0,
		0,
		width,
		height
	)
end

derma.DefineControl("DR_CustomScrollBarGrip","",DR_CustomScrollBarGrip,"DScrollBarGrip")
