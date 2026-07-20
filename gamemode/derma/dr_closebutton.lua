local DermaColors = DR.DermaColors

--- @class DR_CloseButton : DR_Button
--- @field Parent DR_Window
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
		DermaColors.Bad
	)
end

derma.DefineControl("DR_CloseButton","",DR_CloseButton,"DR_Button")
