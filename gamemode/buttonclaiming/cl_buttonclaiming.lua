local next = next

local IsValid = IsValid
local Lerp = Lerp
local LocalPlayer = LocalPlayer
local Vector = Vector

local DrawSimpleText = draw.SimpleText

local NetReadBool = net.ReadBool
local NetReadDouble = net.ReadDouble
local NetReadPlayer = net.ReadPlayer
local NetReadUInt = net.ReadUInt
local NetSendToServer = net.SendToServer
local NetStart = net.Start

local DR = DR

local ButtonClaimSystem = DR.ButtonClaimSystem
local ButtonEnts = ButtonClaimSystem.ButtonEnts
local ClaimRadius = ButtonClaimSystem.ClaimRadius

local FadeOutRadius = ClaimRadius * 3

local ClaimColors = {
	[true] = Color(255,100,100),
	[false] = Color(100,255,100),
}

hook.Add("InitPostEntity","DeathrunButtonEntsClientReady",function()
	NetStart("DeathrunButtonEntsClientReady")
	NetSendToServer()
end)

net.Receive("DeathrunButtonEntsUpdateFull",function(len)
	local entBits = NetReadUInt(16)
	ButtonClaimSystem.EntBits = entBits

	while NetReadBool() do
		local mapId = NetReadUInt(entBits)

		local claimed = NetReadBool()

		ButtonEnts[mapId] = {
			["Claimed"] = claimed,
			["ClaimingPlayer"] =
				claimed
			and	NetReadPlayer()
			or	NULL
			,
			["Position"] = Vector(NetReadDouble(),NetReadDouble(),NetReadDouble()),
		}
	end
end)

net.Receive("DeathrunButtonEntsUpdateSimple",function(len)
	local data = ButtonEnts[NetReadUInt(ButtonClaimSystem.EntBits)]

	local claimed = NetReadBool()
	data.Claimed = claimed

	data.ClaimingPlayer =
		claimed
	and	NetReadPlayer()
	or	NULL
end)

hook.Add("HUDPaint","DeathrunButtonClaimHUD",function()
	local localPly = LocalPlayer()

	if localPly:Team() == DR_TEAM_RUNNER then return end

	local eyePos = localPly:EyePos()

	--- @param data ButtonEntData
	for _,data in next,ButtonEnts do
		local pos = data.Position
		local dist = eyePos:DistToSqr(pos)

		if dist >= FadeOutRadius then continue end

		local alpha = 255

		if dist >= ClaimRadius then
			alpha = Lerp(DR.InverseLerp(dist,ClaimRadius,FadeOutRadius),255,0)
		end

		if alpha <= 0 then continue end

		local claimed = data.Claimed
		local claimer = data.ClaimingPlayer

		local claimText = "Unclaimed"

		if claimed and IsValid(claimer) then
			claimText = "Claimed by " .. claimer:Nick()
		end

		local toScreen = pos:ToScreen()
		local color = ClaimColors[claimed]
		color--[[@cast -?]].a = alpha

		DrawSimpleText(
			claimText,
			"Deathrun_Derma_ExtraSmall",
			toScreen.x,
			toScreen.y,
			color,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
	end
end)
