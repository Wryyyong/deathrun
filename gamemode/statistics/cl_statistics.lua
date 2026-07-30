local Iterator = ipairs({})

local CurTime = CurTime
local IsValid = IsValid
local LocalPlayer = LocalPlayer

local CamEnd3D2D = cam.End3D2D
local CamStart3D2D = cam.Start3D2D

local MathClamp = math.Clamp

local NetReadBool = net.ReadBool
local NetReadDouble = net.ReadDouble
local NetReadFloat = net.ReadFloat
local NetReadString = net.ReadString
local NetReadTable = net.ReadTable

local RenderClearStencil = render.ClearStencil
local RenderSetStencilCompareFunction = render.SetStencilCompareFunction
local RenderSetStencilEnable = render.SetStencilEnable
local RenderSetStencilFailOperation = render.SetStencilFailOperation
local RenderSetStencilPassOperation = render.SetStencilPassOperation
local RenderSetStencilReferenceValue = render.SetStencilReferenceValue
local RenderSetStencilZFailOperation = render.SetStencilZFailOperation

local StringToMinutesSecondsMilliseconds = string.ToMinutesSecondsMilliseconds

local SurfaceDrawRect = surface.DrawRect
local SurfaceSetDrawColor = surface.SetDrawColor

local UtilJSONToTable = util.JSONToTable

local DR = DR

local Colors = DR.Colors
local ConVars = DR.ConVars
local Stats = DR.Stats
local UI = DR.UI

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
	local idx = 0

	while NetReadBool() do
		idx = idx + 1
		local rank = MapRecordsCache[idx]

		rank.Name = NetReadString()
		rank.Seconds = StringToMinutesSecondsMilliseconds(NetReadFloat())
	end
end)

net.Receive("DeathrunSendEndZone",function()
	MapRecordsDrawPos:SetUnpacked(
		NetReadDouble(),
		NetReadDouble(),
		NetReadDouble()
	)
end)

net.Receive("DeathrunSendMapPersonalBest",function()
	Stats.PersonalBestCache = StringToMinutesSecondsMilliseconds(NetReadFloat())
end)

net.Receive("DeathrunSendStats",function()
	local data = NetReadTable()
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
	Stats3D.Data = UtilJSONToTable(NetReadString()) or {}
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

		CamStart3D2D(Stats3D.Position,Stats3D.Angle,.04)

		-- i dont know how this works?!?!?!?
		RenderClearStencil()
		RenderSetStencilEnable(true)
		RenderSetStencilFailOperation(STENCILOPERATION_KEEP)
		RenderSetStencilZFailOperation(STENCILOPERATION_REPLACE)
		RenderSetStencilPassOperation(STENCILOPERATION_REPLACE)
		RenderSetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		RenderSetStencilReferenceValue(1)

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

		SurfaceSetDrawColor(color_black)
		SurfaceDrawRect(
			PopUp_Stats_PosX,
			PopUp_Stats_PosY,
			PopUp_Stats_Width,
			PopUp_Stats_Height * DR.QuadLerp(
				MathClamp(
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

		RenderSetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		RenderSetStencilPassOperation(STENCILOPERATION_REPLACE)

		-- draw
		SurfaceSetDrawColor(ColorClouds)
		SurfaceDrawRect(
			PopUp_Stats_PosX,
			PopUp_Stats_PosY,
			PopUp_Stats_Width,
			PopUp_Stats_Height
		)

		SurfaceSetDrawColor(ColorTurq)
		SurfaceDrawRect(
			PopUp_Stats_PosX,
			PopUp_Stats_PosY,
			PopUp_Stats_Width,
			80
		)
		UI.ShadowTextSimple(
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

			UI.ShadowTextSimple(
				PopUp_Stats_Labels[idx],
				"Deathrun_3D2D_Small",
				posXPlus20,
				offsetY,
				ColorGrey,
				TEXT_ALIGN_LEFT,
				TEXT_ALIGN_TOP,
				0
			)
			UI.ShadowTextSimple(
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
		RenderSetStencilEnable(false)

		CamEnd3D2D()
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
	CamStart3D2D(MapRecordsDrawPos,eyeAng,.1)

	SurfaceSetDrawColor(ColorTurq)
	SurfaceDrawRect(
		-700,
		-300,
		PopUp_Records_Width,
		80
	)
	UI.ShadowTextSimple(
		"TOP 3 RECORDS",
		"Deathrun_3D2D_Large",
		0,
		-300,
		ColorClouds,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_TOP,
		2
	)

	for idx,data in Iterator,MapRecordsCache,0 do
		local offsetY = -150 + 100 * (idx - 1)

		UI.ShadowTextSimple(
			idx .. ". " .. (data.Name or "---"),
			"Deathrun_3D2D_Large",
			-700,
			offsetY,
			ColorClouds,
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_TOP,
			2
		)
		UI.ShadowTextSimple(
			data.Seconds or "--:--:--",
			"Deathrun_3D2D_Large",
			700,
			offsetY,
			ColorTurq,
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_TOP,
			2
		)

		SurfaceSetDrawColor(ColorTurq)
		SurfaceDrawRect(
			-700,
			offsetY + 80,
			PopUp_Records_Width,
			2
		)
	end

	local offsetY = -150 + 100 * 4

	UI.ShadowTextSimple(
		"Personal Best",
		"Deathrun_3D2D_Large",
		-700,
		offsetY,
		ColorClouds,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_TOP,
		2
	)
	UI.ShadowTextSimple(
		Stats.PersonalBestCache,
		"Deathrun_3D2D_Large",
		700,
		offsetY,
		ColorTurq,
		TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_TOP,
		2
	)

	SurfaceSetDrawColor(ColorTurq)
	SurfaceDrawRect(
		-700,
		offsetY + 80,
		PopUp_Records_Width,
		2
	)

	CamEnd3D2D()
end

hook.Add("PostDrawTranslucentRenderables","DeathrunStatsDisplay",function()
	DrawYourStats()
	DrawMapRecords()
end)
