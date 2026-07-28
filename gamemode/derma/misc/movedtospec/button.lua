--- @class DR_MovedToSpectatorButtonBase : DR_Button
--- @field Parent DR_MovedToSpectatorInner
local DR_MovedToSpectatorButtonBase = {
	["ButtonText"] = "",
	["WidthMod"] = -1,
	["PosX"] = 0,
}

function DR_MovedToSpectatorButtonBase:Init()
	local parent = self:GetParent()
	self.Parent = parent

	local width,height = parent:GetSize()

	local widthMod = (width - 12) * .5 -- 3 * 4
	self.WidthMod = widthMod
	local offsetY = height - 36 -- 32 - 4

	self:SetSize(widthMod,32)
	self:SetY(offsetY)

	self:RefreshSettings()
end

function DR_MovedToSpectatorButtonBase:RefreshSettings()
	self:SetX(self.PosX)
	self:SetText(self.ButtonText)
end

function DR_MovedToSpectatorButtonBase:DoClick()
	self.Parent:GetParent():Close()
end

--- @class DR_MovedToSpectatorButtonContinue : DR_MovedToSpectatorButtonBase
local DR_MovedToSpectatorButtonContinue = {
	["ButtonText"] = "No, I'm okay with this.",
	["PosX"] = 4,
}

function DR_MovedToSpectatorButtonContinue:Init()
	self:RefreshSettings()
end

--- @class DR_MovedToSpectatorButtonBack : DR_MovedToSpectatorButtonBase
local DR_MovedToSpectatorButtonBack = {
	["ButtonText"] = "Yes, please move me back.",
}

function DR_MovedToSpectatorButtonBack:Init()
	self.PosX = 8 + (self.Parent:GetWide() - 3 * 4) * .5

	self:RefreshSettings()
end

function DR_MovedToSpectatorButtonBack:DoClick()
	self.BaseClass.DoClick(self)

	LocalPlayer():ConCommand("deathrun_spectate_only 0")
end

derma.DefineControl("DR_MovedToSpectatorButtonBase","",DR_MovedToSpectatorButtonBase,"DR_Button")
derma.DefineControl("DR_MovedToSpectatorButtonContinue","",DR_MovedToSpectatorButtonContinue,"DR_MovedToSpectatorButtonBase")
derma.DefineControl("DR_MovedToSpectatorButtonBack","",DR_MovedToSpectatorButtonBack,"DR_MovedToSpectatorButtonBase")
