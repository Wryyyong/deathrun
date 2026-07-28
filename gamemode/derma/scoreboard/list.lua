local ColorGrey = DR.Colors.Grey

local CvSmallScoreboard = DR.ConVars.SmallScoreboard

--- @class DR_ScoreboardList : DR_List
local DR_ScoreboardList = {}

function DR_ScoreboardList:Init()
	self:SetSize(
		self:GetParent():GetWide(),
		1500
	)
end

function DR_ScoreboardList:AddTop()
	local top = self:Add("DR_ScoreboardTop")

	return top
end

--- @param text string?
--- @param color Color?
function DR_ScoreboardList:AddHeader(text,color)
	local header = self:Add("DR_ScoreboardItemSmallBase")

	local label = header:Add("DLabel")
	label:SetText(text or "")
	label:SetTextColor(color or ColorGrey)
	label:SetFont(header.SmallMode and "Deathrun_Derma_ExtraSmall" or "Deathrun_Derma_Small")
	label:SizeToContents()
	label:SetX((header:GetWide() - 8) * .5 - label:GetWide() * .5)
	label:CenterVertical()

	return header,label
end

local TeamHeaderTexts = {
	[DR_TEAM_RUNNER] = "on Runner Team",
	[DR_TEAM_DEATH] = "on Death Team",
	[DR_TEAM_GHOST] = "in Ghost Mode",
	[TEAM_SPECTATOR] = "spectating",
}

--- @param teamNum integer
function DR_ScoreboardList:AddTeamGroup(teamNum)
	local color = team.GetColor(teamNum)
	local teamPlys = team.GetPlayers(teamNum)
	local plyCount = #teamPlys

	if plyCount <= 0 then return end

	local header = self:AddHeader(plyCount .. " players " .. TeamHeaderTexts[teamNum],color)

	for _,ply in ipairs(teamPlys) do
		self:AddPlayer(ply,color)
	end

	return header
end

--- @alias ColumnFunction fun(ply: Player, specialData: table): string

--- @type ColumnFunction[]
local Columns = {
	-- Name
	function(ply)
		return ply:Nick()
	end,

	-- (blank)
	function()
		return "" -- empty space to even the spacings out
	end,

	-- Title
	function(_,specialData)
		return
			specialData.Tag
		or	""
	end,

	-- Rank
	function(ply,specialData)
		return
			specialData.Rank
		or	ply:GetUserGroup():upper()
	end,

	-- Ping
	function(ply)
		return tostring(ply:Ping())
	end,
}
local ColumnCount = #Columns
local ColumnCountMinusOne = ColumnCount - 1

local VhsStrings = {
	"vhs7",
	"vhs-7",
	"vhs7.tv",
}

local function IsSupporting(ply)
	local name = ply:Nick():lower()

	for _,str in ipairs(VhsStrings) do
		if not name:find(str) then continue end

		return true
	end

	return false
end

--- @param ply Player
--- @param teamColor Color
function DR_ScoreboardList:AddPlayer(ply,teamColor)
	local panel = self:Add("DR_ScoreboardPlayerPanel")
	panel.BgColor = teamColor
	panel.Player = ply

	local avatar = panel:Add("DR_ScoreboardPlayerAvatar")
	avatar:SetPlayer(ply)
	avatar.Player = ply
	panel.Avatar = avatar

	local data = panel:Add("DR_ScoreboardPlayerData")
	data.BgColor = teamColor
	data.Player = ply
	panel.Data = data

	local icon = panel:Add("DR_ScoreboardPlayerIcon")
	panel.Icon = icon

	local special = hook.Run("GetScoreboardSpecial",ply)
	local iconPath

	if ply:IsSuperAdmin() or ply:IsAdmin() then
		iconPath = "icon16/shield.png"
	elseif IsSupporting(ply) then
		iconPath = "icon16/heart.png"
	end

	iconPath = special.Icon or iconPath

	icon.Material =
		iconPath
	and	Material(iconPath)
	or	nil

	local labelOffset = (data:GetWide() - 8) / ColumnCountMinusOne
	local smallMode = data.SmallMode
	local customNameColor = special.Color or color_white

	for idx,func in ipairs(Columns) do
		local offsetHeight = idx - 1
		local align = .5

		if idx == 1 then
			align = 0
		elseif idx == ColumnCount then
			align = 1
		end

		local label = data:Add("DLabel")
		label:SetText(func(ply,special))
		label:SetTextColor(customNameColor)
		label:SetFont(smallMode and "Deathrun_Derma_ExtraSmall" or "Deathrun_Derma_Small")
		label:SetExpensiveShadow(1,color_black)
		label:SizeToContents()
		label:SetPos(offsetHeight * labelOffset - label:GetWide() * align,0)
		label:CenterVertical()
	end

	local button = panel:Add("DR_ScoreboardPlayerButton")
	panel.Button = button

	return panel
end

function DR_ScoreboardList:AddOptions()
	local options = self:Add("DR_ScoreboardItemSmallBase")

	local sizeToggle = options:Add("DR_AuToggle")
	sizeToggle:SetConVar(CvSmallScoreboard:GetName())
	sizeToggle:SetText("Small Scoreboard (will change size the next time you pull the scoreboard up)")
	sizeToggle:SetFont(options.SmallMode and "Deathrun_Derma_ExtraSmall" or "Deathrun_Derma_Small")
	sizeToggle:SizeToContents()
	sizeToggle:SetWide(options:GetWide())
	sizeToggle:CenterVertical()

	return options
end

derma.DefineControl("DR_ScoreboardList","",DR_ScoreboardList,"DR_List")
