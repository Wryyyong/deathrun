local DR = DR

local ButtonClaims = DR.ButtonClaims
local ButtonEnts = ButtonClaims.ButtonEnts
local ClaimRadius = ButtonClaims.ClaimRadius

local FadeOutRadius = ClaimRadius * 3

local ClaimColors = {
	[true] = Color(255,100,100),
	[false] = Color(100,255,100),
}

hook.Add("InitPostEntity","DeathrunButtonEntsClientReady",function()
	net.Start("DeathrunButtonEntsClientReady")
	net.SendToServer()
end)

net.Receive("DeathrunButtonEntsUpdateFull",function(len)
	local entBits = net.ReadUInt(16)
	ButtonClaims.EntBits = entBits

	while net.ReadBool() do
		local mapId = net.ReadUInt(entBits)

		local claimed = net.ReadBool()

		ButtonEnts[mapId] = {
			["Claimed"] = claimed,
			["ClaimingPlayer"] =
				claimed
			and	net.ReadPlayer()
			or	NULL
			,
			["Position"] = Vector(net.ReadDouble(),net.ReadDouble(),net.ReadDouble()),
		}
	end
end)

net.Receive("DeathrunButtonEntsUpdateSimple",function(len)
	local data = ButtonEnts[net.ReadUInt(ButtonClaims.EntBits)]

	local claimed = net.ReadBool()
	data.Claimed = claimed

	data.ClaimingPlayer =
		claimed
	and	net.ReadPlayer()
	or	NULL
end)

hook.Add("HUDPaint","DeathrunButtonClaimHUD",function()
	local localPly = LocalPlayer()

	if localPly:Team() == DR_TEAM_RUNNER then return end

	local eyePos = localPly:EyePos()

	--- @param data ButtonEntData
	for _,data in pairs(ButtonEnts) do
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

		draw.SimpleText(
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
