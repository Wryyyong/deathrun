local ColorBad = DR.Colors.Derma.Bad

--- @class DR_CloseButton : DR_Button
--- @field Parent DR_Frame
local DR_CloseButton = {}

function DR_CloseButton:DoClick()
	self.Parent:Close()
end

function DR_CloseButton.PaintOver(self,width,height)
	draw.RoundedBox(
		0,
		0,
		0,
		width,
		height,
		ColorBad
	)
end

derma.DefineControl("DR_CloseButton","",DR_CloseButton,"DR_Button")
