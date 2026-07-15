--- @class DR_SubButton : DButton
--- @field Parent DR_Button
local DR_SubButton = {}

function DR_SubButton:Init()
	local parent = self:GetParent() --- @cast parent DR_Button
	self.Parent = parent

	local doErrorText

	if not parent then
		doErrorText = "has no parent panel"
	elseif parent.Hover == nil then
		doErrorText = "has a parent panel lacking a 'Hover' property"
	end

	if not doErrorText then return end

	ErrorNoHaltWithStack("'",self:GetName(),"' instance ",doErrorText,"!")
	self:Remove()
end

DR_SubButton.Paint = DR.EmptyFunction

function DR_SubButton:OnCursorEntered()
	self.Parent.Hover = true
end

function DR_SubButton:OnCursorExited()
	self.Parent.Hover = false
end

function DR_SubButton:OnMousePressed(keyCode)
	self.Parent:OnMousePressed(keyCode)
end

function DR_SubButton:SetText(text)
	self.BaseClass--[[@cast -?]].SetText(self,text)
end

derma.DefineControl("DR_SubButton","",DR_SubButton,"DButton")
