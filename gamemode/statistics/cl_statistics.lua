local DR = DR

local Colors = DR.Colors
local ConVars = DR.ConVars
local Stats = DR.Stats

local ColorClouds = Colors.Clouds
local ColorGrey = Colors.Grey
local ColorTurq = Colors.Turq

local CvRenderYourStats = ConVars.RenderYourStats

local PlayerStatsCache = Stats.PlayerStatsCache or {}
Stats.PlayerStatsCache = PlayerStatsCache

--- @type Vector
local MapRecordsDrawPos = Stats.MapRecordsDrawPos or Vector()
Stats.MapRecordsDrawPos = MapRecordsDrawPos

--- @alias DeathrunMapRecord_Client {
--- 	Name: string,
--- 	Seconds: string,
--- }

--- @type DeathrunMapRecord_Client[]
local MapRecordsCache = Stats.MapRecordsCache or {
	{},
	{},
	{},
}
Stats.MapRecordsCache = MapRecordsCache

Stats.PersonalBestCache = Stats.PersonalBestCache or "--:--:--"

net.Receive("DeathrunSendMapRecords",function()
	MapRecordsDrawPos:SetUnpacked(
		net.ReadDouble(),
		net.ReadDouble(),
		net.ReadDouble()
	)

	local idx = 0

	while net.ReadBool() do
		idx = idx + 1
		local rank = MapRecordsCache[idx]

		rank.Name = net.ReadString()
		rank.Seconds = string.ToMinutesSecondsMilliseconds(net.ReadFloat())
	end
end)

net.Receive("DeathrunSendMapPersonalBest",function()
	Stats.PersonalBestCache = string.ToMinutesSecondsMilliseconds(net.ReadFloat())
end)

net.Receive("DeathrunSendStats",function()
	local data = net.ReadTable()
	PlayerStatsCache[data.SteamID64] = data

	local msg = [[Stats for ]] .. data.Name .. [[:
Kills: ]] .. data.Kills .. [[

Deaths: ]] .. data.Deaths .. [[

Runner Wins: ]] .. data.WinsRunner .. [[

Death Wins: ]] .. data.WinsDeath .. [[
]]

	DR.ChatMessage(msg)
end)

-- display stats on a player's face
local Stats3D = {
	["Position"] = Vector(),
	["Angle"] = Angle(),
	["Data"] = {},
	["Born"] = -1,
}

net.Receive("DeathrunDisplayStats",function()
	local localPly = LocalPlayer()

	if
		not (
			IsValid(localPly)
		and	CvRenderYourStats:GetBool()
		)
	then return end

	local eyePos = localPly:EyePos()
	local eyeAng = localPly:EyeAngles()
	local eyeAngForward = eyeAng:Forward()

	eyeAng:RotateAroundAxis(eyeAng:Right(),90)
	eyeAng:RotateAroundAxis(eyeAngForward,90)

	eyeAngForward:Mul(36)

	eyePos:Add(eyeAngForward)

	Stats3D.Position = eyePos
	Stats3D.Angle = eyeAng
	Stats3D.Data = util.JSONToTable(net.ReadString()) or {}
	Stats3D.Born = CurTime() + .45
end)

local PopUp_Stats_Width = 1000
local PopUp_Stats_Height = 380

local PopUp_Stats_PosX = -PopUp_Stats_Width * .5
local PopUp_Stats_PosY = -PopUp_Stats_Height * .5

local PopUp_Stats_Lifetime = 10

local PopUp_Stats_Labels = {
	"Your Kills",
	"Your Deaths",
	"Your Runner Wins",
	"Your Death Wins",
	"Most Wins",
}
local PopUp_Stats_LabelCount = #PopUp_Stats_Labels

local function DrawYourStats()
	local duration = CurTime() - Stats3D.Born

	if duration < PopUp_Stats_Lifetime then
		PopUp_Stats_Height = 80 + 75 * PopUp_Stats_LabelCount

		cam.Start3D2D(Stats3D.Position,Stats3D.Angle,.04)

		-- i dont know how this works?!?!?!?
		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		render.SetStencilReferenceValue(1)

		local fromInv,toInv
		local fromQuad,toQuad
		if duration < PopUp_Stats_Lifetime - 1 then
			fromInv = 0
			toInv = 1

			fromQuad = 0
			toQuad = 1
		else
			fromInv = PopUp_Stats_Lifetime - 1
			toInv = PopUp_Stats_Lifetime

			fromQuad = 1
			toQuad = 0
		end

		surface.SetDrawColor(color_black)
		surface.DrawRect(
			PopUp_Stats_PosX,
			PopUp_Stats_PosY,
			PopUp_Stats_Width,
			PopUp_Stats_Height * DR.QuadLerp(
				math.Clamp(
					DR.InverseLerp(
						duration,
						fromInv,
						toInv
					),
					0,
					1
				),
				fromQuad,
				toQuad
			)
		)

		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)

		-- draw
		surface.SetDrawColor(ColorClouds)
		surface.DrawRect(
			PopUp_Stats_PosX,
			PopUp_Stats_PosY,
			PopUp_Stats_Width,
			PopUp_Stats_Height
		)

		surface.SetDrawColor(ColorTurq)
		surface.DrawRect(
			PopUp_Stats_PosX,
			PopUp_Stats_PosY,
			PopUp_Stats_Width,
			80
		)
		DR.ShadowTextSimple(
			"STATS",
			"Deathrun_3D2D_Large",
			0,
			PopUp_Stats_PosY,
			ColorClouds,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_TOP,
			2
		)

		local data = Stats3D.Data
		local posXPlus20 = PopUp_Stats_PosX + 20
		local posYPlus100 = PopUp_Stats_PosY + 100

		for idx = 1,PopUp_Stats_LabelCount do
			local offsetY = posYPlus100 + 70 * (idx - 1)

			DR.ShadowTextSimple(
				PopUp_Stats_Labels[idx],
				"Deathrun_3D2D_Small",
				posXPlus20,
				offsetY,
				ColorGrey,
				TEXT_ALIGN_LEFT,
				TEXT_ALIGN_TOP,
				0
			)
			DR.ShadowTextSimple(
				data[idx],
				"Deathrun_3D2D_Small",
				PopUp_Stats_PosX + PopUp_Stats_Width - 20,
				offsetY,
				ColorTurq,
				TEXT_ALIGN_RIGHT,
				TEXT_ALIGN_TOP,
				0
			)
		end

		-- close stencil
		render.SetStencilEnable(false)

		cam.End3D2D()
	end
end

local PopUp_Records_Width = 1400

local PopUp_Records_MaxDist = 1000 ^ 2

local function DrawMapRecords()
	local localPly = LocalPlayer()

	if MapRecordsDrawPos:DistToSqr(localPly:GetPos()) >= PopUp_Records_MaxDist then return end

	local eyeAng = localPly:EyeAngles()
	local eyeAngRight = eyeAng:Right()
	local eyeAngForward = eyeAng:Forward()

	eyeAng:RotateAroundAxis(eyeAngRight,90)
	eyeAng:RotateAroundAxis(eyeAngForward,90)
	eyeAng[3] = 90

	-- end
	cam.Start3D2D(MapRecordsDrawPos,eyeAng,.1)

	surface.SetDrawColor(ColorTurq)
	surface.DrawRect(
		-700,
		-300,
		PopUp_Records_Width,
		80
	)
	DR.ShadowTextSimple(
		"TOP 3 RECORDS",
		"Deathrun_3D2D_Large",
		0,
		-300,
		ColorClouds,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_TOP,
		2
	)

	for idx,data in ipairs(MapRecordsCache) do
		local offsetY = -150 + 100 * (idx - 1)

		DR.ShadowTextSimple(
			idx .. ". " .. (data.Name or "---"),
			"Deathrun_3D2D_Large",
			-700,
			offsetY,
			ColorClouds,
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_TOP,
			2
		)
		DR.ShadowTextSimple(
			data.Seconds or "--:--:--",
			"Deathrun_3D2D_Large",
			700,
			offsetY,
			ColorTurq,
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_TOP,
			2
		)

		surface.SetDrawColor(ColorTurq)
		surface.DrawRect(
			-700,
			offsetY + 80,
			PopUp_Records_Width,
			2
		)
	end

	local offsetY = -150 + 100 * 4

	DR.ShadowTextSimple(
		"Personal Best",
		"Deathrun_3D2D_Large",
		-700,
		offsetY,
		ColorClouds,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_TOP,
		2
	)
	DR.ShadowTextSimple(
		Stats.PersonalBestCache,
		"Deathrun_3D2D_Large",
		700,
		offsetY,
		ColorTurq,
		TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_TOP,
		2
	)

	surface.SetDrawColor(ColorTurq)
	surface.DrawRect(
		-700,
		offsetY + 80,
		PopUp_Records_Width,
		2
	)

	cam.End3D2D()
end

hook.Add("PostDrawTranslucentRenderables","DeathrunStatsDisplay",function()
	DrawYourStats()
	DrawMapRecords()
end)
