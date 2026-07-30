local ColorAlizarin = DR.Colors.Alizarin

local IconMute = Material("icon16/sound_mute.png")

--- @class DR_ScoreboardPlayerAvatar : AvatarImage
--- @field Player Player
local DR_ScoreboardPlayerAvatar = {}

function DR_ScoreboardPlayerAvatar:Init()
	local height = self:GetParent():GetTall()

	self:SetSize(height,height)
end

function DR_ScoreboardPlayerAvatar:PaintOver(width,height)
	local ply = self.Player
	if not IsValid(ply) then return end

	local widthHalf = width * .5
	local heightHalf = height * .5

	if not ply:Alive() then
		surface.SetDrawColor(255,255,255,100)
		surface.DrawRect(
			0,
			0,
			width,
			height
		)

		draw.SimpleText(
			"✖",
			"Deathrun_Derma_Medium",
			widthHalf,
			heightHalf - 1,
			ColorAlizarin,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
	end

	if table.HasValue(LocalPlayer().MuteList or {},ply:SteamID()) then
		surface.SetMaterial(IconMute)

		surface.SetDrawColor(255,255,255,100)
		surface.DrawRect(
			0,
			0,
			width,
			height
		)

		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(
			heightHalf - 8,
			widthHalf - 8,
			16,
			16
		)
	end
end

derma.DefineControl("DR_ScoreboardPlayerAvatar","",DR_ScoreboardPlayerAvatar,"AvatarImage")
