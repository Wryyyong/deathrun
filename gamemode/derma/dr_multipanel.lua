local Iterator = ipairs({})

local DermaColors = DR.DermaColors

--- @class DR_MultiPanel : Panel
--- @field Tabs table<integer,string>
--- @field Buttons table<string,DR_MultiPanelTabButton>
--- @field Panels table<string,DR_MultiPanelTabPanel>
--- @field Spacer DR_MultiPanelSpacer
--- @field NavLeft DR_NavButtonLeft
--- @field NavRight DR_NavButtonRight
local DR_MultiPanel = {
	["ActiveTab"] = 0,
	["ButtonOffset"] = 0,
	["VisibleArrows"] = true,
	["ColorUp"] = DermaColors.BadDark,
	["ColorHover"] = DermaColors.Bad,
	["Tabs"] = {},
	["Buttons"] = {},
	["Panels"] = {},
}

function DR_MultiPanel:Init()
	self.Tabs = setmetatable({},DR_MultiPanel.Tabs)
	self.Buttons = setmetatable({},DR_MultiPanel.Buttons)
	self.Panels = setmetatable({},DR_MultiPanel.Panels)

	self:SetSize(640,320)

	self.Spacer = self:Add("DR_MultiPanelSpacer")
	self.NavLeft = self:Add("DR_NavButtonLeft")
	self.NavRight = self:Add("DR_NavButtonRight")

	self:InvalidateLayout()
end

function DR_MultiPanel:ShowArrows(bool)
	self.NavLeft:SetVisible(bool)
	self.NavRight:SetVisible(bool)
end

function DR_MultiPanel:SetTab(idx)
	local tabs = self.Tabs
	local buttons = self.Buttons
	local panels = self.Panels

	for _,tab in Iterator,tabs,0 do
		buttons[tab]:SetSelected(false)
		panels[tab]:SetVisible(false)
	end

	local targetTab = tabs[idx]
	buttons[targetTab]:SetSelected(true)
	panels[targetTab]:SetVisible(true)
end

function DR_MultiPanel:SetTabDisabled(idx,bool)
	self.Buttons[self.Tabs[idx]]:SetDisabled(bool)
end

DR_MultiPanel.SetColors = DR_Button.SetColors

function DR_MultiPanel:AddTab(name)
	local tabs = self.Tabs
	local targetIndex = #tabs + 1

	tabs[targetIndex] = name
	self.ActiveTab = targetIndex

	local button = self:Add("DR_MultiPanelTabButton")
	self.Buttons[name] = button
	button:SetText(name)
	button.Index = targetIndex

	local panel = self:Add("DR_MultiPanelTabPanel")
	self.Panels[name] = panel

	self:SetTab(self.ActiveTab)
	self:InvalidateLayout()

	return panel
end

function DR_MultiPanel:PerformLayout()
	local tabs = self.Tabs
	local buttons = self.Buttons
	local panels = self.Panels

	local width,height = self:GetSize()
	local minOffset = -(#tabs * 92 - width) - 56 -- 24 * 2 - 8

	local newOffset =
		minOffset > 0
	and	8
	or	math.Clamp(self.ButtonOffset,minOffset,8)
	self.ButtonOffset = newOffset

	self.NavRight:SetPos(width - 24,0)
	self.Spacer:SetSize(width,4)

	for idx,tab in Iterator,tabs,0 do
		local button = buttons[tab]
		local offset = (idx - 1) * 92

		button:SetPos(24 + offset + newOffset,0)
		button.OriginalX = 8 + offset

		panels[tab]:SetSize(width,height - 28)
	end
end

derma.DefineControl("DR_MultiPanel","",DR_MultiPanel,"Panel")
