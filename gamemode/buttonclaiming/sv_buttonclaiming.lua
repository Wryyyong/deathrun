local DR = DR

local ButtonClaims = DR.ButtonClaims
local ButtonEnts = ButtonClaims.ButtonEnts
local ClaimRadius = ButtonClaims.ClaimRadius

util.AddNetworkString("DeathrunButtonEntsUpdateFull")
util.AddNetworkString("DeathrunButtonEntsUpdateSimple")
util.AddNetworkString("DeathrunButtonEntsClientReady")

hook.Add("InitPostEntity","SetupButtonEntData",function()
	local maxId = -1

	for _,ent in ipairs(ents.FindByClass("func_button")) do
		local mapId = ent:MapCreationID()
		maxId = math.max(mapId,maxId)

		local pos = ent:GetPos()
		pos:Add(ent:OBBCenter())

		ButtonEnts[mapId] = {
			["Claimed"] = false,
			["ClaimingPlayer"] = NULL,
			["Position"] = pos,
		}
	end

	ButtonClaims.EntBits = DR.CalcMaxBits(maxId)
end)

--- @param mapId integer
--- @param data ButtonEntData
local function SingleUpdate(mapId,data)
	net.Start("DeathrunButtonEntsUpdateSimple")
		net.WriteUInt(mapId,ButtonClaims.EntBits)

		local claimed = data.Claimed
		net.WriteBool(claimed)

		if claimed then
			net.WritePlayer(data.ClaimingPlayer)
		end
	net.SendPVS(data.Position)
end

net.Receive("DeathrunButtonEntsClientReady",function(_,ply)
	local entBits = ButtonClaims.EntBits

	net.Start("DeathrunButtonEntsUpdateFull")
		net.WriteUInt(entBits,16)

		for mapId,data in pairs(ButtonEnts) do
			net.WriteBool(true)

			net.WriteUInt(mapId,entBits)

			local claimed = data.Claimed
			net.WriteBool(claimed)

			if claimed then
				net.WritePlayer(data.ClaimingPlayer)
			end

			local pos = data.Position
			net.WriteDouble(pos[1])
			net.WriteDouble(pos[2])
			net.WriteDouble(pos[3])
		end

		net.WriteBool(false)
	net.Send(ply)
end)

timer.Create("CheckButtonClaims",1 / 3,0,function()
	--- @type Player[]
	local plyList = {}

	for _,ply in ipairs(team.GetPlayers(TEAM_DEATH)) do
		if not ply:Alive() then continue end

		plyList[#plyList + 1] = ply
	end

	if #plyList <= 0 then return end

	-- compile all the button entities into the table buttons
	--- @param mapId integer
	--- @param data ButtonEntData
	for mapId,data in pairs(ButtonEnts) do
		local claimed = data.Claimed
		local claimer = data.ClaimingPlayer
		local pos = data.Position

		local closestDist = math.huge
		local closestPlayer

		for _,ply in ipairs(plyList) do
			local dist = pos:DistToSqr(ply:EyePos())
			if dist >= closestDist then continue end

			closestDist = dist
			closestPlayer = ply
		end

		local currentClaimPlyDist = math.huge

		if IsValid(claimer) then
			currentClaimPlyDist = pos:DistToSqr(claimer:EyePos())
		end

		-- nobody within claiming distance
		if claimed and currentClaimPlyDist > ClaimRadius then
			data.Claimed = false
			data.ClaimingPlayer = NULL

			SingleUpdate(mapId,data)
		-- someone within claiming distance, and the button is unclaimed
		elseif not claimed and closestDist < ClaimRadius then
			data.Claimed = true
			data.ClaimingPlayer = closestPlayer

			SingleUpdate(mapId,data)
		end
	end
end)

hook.Add("PlayerUse","DeathrunButtonClaimPlayerUse",function(ply,ent)
	local plyTeam = ply:Team()

	if
		not ply:Alive()
	or	plyTeam == TEAM_SPECTATOR
	or	ply:GetObserverMode() ~= OBS_MODE_NONE
	then
		return false
	end

	local mapId = ent:MapCreationID()
	local data = ButtonEnts[mapId]

	-- to stop secrets breaking
	-- if that shit doesnt exist then sure, just do it, don't let your dreams be dreams
	-- if they own it, or if it is unclaimed (e.g. they run and press it the moment before it updates on the server, it won't disable and it wont cause them to lose the runner.)
	if
		plyTeam == TEAM_RUNNER
	or	not data
	or	not data.Claimed
	or	data.ClaimingPlayer == ply
	then
		if
			ent:GetInternalVariable("m_toggle_state") == 1 -- TS_AT_TOP
		and	not ent:GetInternalVariable("m_bLocked")
		and	ply:KeyPressed(IN_USE)
		then
			hook.Run("DeathrunButtonActivated",ply,ent)
		end

		ent.User = ply

		return
	end

	return false
end)
