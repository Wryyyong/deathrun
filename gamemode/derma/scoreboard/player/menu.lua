--- @class DR_ScoreboardPlayerMenu : DMenu
--- @field Parent DR_ScoreboardPlayerPanel
local DR_ScoreboardPlayerMenu = {}

function DR_ScoreboardPlayerMenu:Init()
	local parent = self:GetParent()
	self.Parent = parent

	local player = parent.Player
	self.Player = player

	if not player:IsBot() then
		self:AddOption("DR_ScoreboardPlayerMenuOptionCopyId")
		self:AddOption("DR_ScoreboardPlayerMenuOptionCopyId64")

		self:AddOption("DR_ScoreboardPlayerMenuOptionOpenProfile")

		self:AddOption("DR_ScoreboardPlayerMenuOptionMute")

		self:AddSpacer()
	end

	if DR.CanAccessCommand(LocalPlayer(),"deathrun_force_spectate") then
		self:AddOption("DR_ScoreboardPlayerMenuOptionForceSpectator")

		self:AddSpacer()
	end

	if ulx then
		self:AddOption("DR_ScoreboardPlayerMenuOptionULXGag")
		self:AddOption("DR_ScoreboardPlayerMenuOptionULXUngag")

		self:AddOption("DR_ScoreboardPlayerMenuOptionULXMute")
		self:AddOption("DR_ScoreboardPlayerMenuOptionULXUnmute")

		self:AddOption("DR_ScoreboardPlayerMenuOptionULXSlay")

		self:AddOption("DR_ScoreboardPlayerMenuOptionULXKick")

		self:AddOption("DR_ScoreboardPlayerMenuOptionULXBan30m")
		self:AddOption("DR_ScoreboardPlayerMenuOptionULXBan2h")
		self:AddOption("DR_ScoreboardPlayerMenuOptionULXBan1d")
		self:AddOption("DR_ScoreboardPlayerMenuOptionULXBan1w")
		self:AddOption("DR_ScoreboardPlayerMenuOptionULXBanPerm")

		self:AddSpacer()
	end

	self:Open()
end

--- @generic PanelClass : DR_ScoreboardPlayerMenuOptionBase
--- @param className `PanelClass`
--- @return (instance) PanelClass
function DR_ScoreboardPlayerMenu:AddOption(className)
	local option = vgui.Create(className)
	option:SetMenu(self)
	option.Player = self.Player

	self:AddPanel(option)

	return option
end

derma.DefineControl("DR_ScoreboardPlayerMenu","",DR_ScoreboardPlayerMenu,"DMenu")
