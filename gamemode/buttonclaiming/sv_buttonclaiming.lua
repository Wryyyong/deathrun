local Iterator = ipairs({})

local IsValid = IsValid

local EntsFindByClass = ents.FindByClass

local HookRun = hook.Run

local MathMax = math.max

local NetSend = net.Send
local NetSendPVS = net.SendPVS
local NetStart = net.Start
local NetWriteBool = net.WriteBool
local NetWriteDouble = net.WriteDouble
local NetWritePlayer = net.WritePlayer
local NetWriteUInt = net.WriteUInt

local TeamGetPlayers = team.GetPlayers

local TimerCreate = timer.Create

local DR = DR

local ButtonClaimSystem = DR.ButtonClaimSystem
local ButtonEnts = ButtonClaimSystem.ButtonEnts
local ClaimRadius = ButtonClaimSystem.ClaimRadius

util.AddNetworkString("DeathrunButtonEntsUpdateFull")
util.AddNetworkString("DeathrunButtonEntsUpdateSimple")
util.AddNetworkString("DeathrunButtonEntsClientReady")

hook.Add("InitPostEntity","SetupButtonEntData",function()
	local maxId = -1

	for _,ent in Iterator,EntsFindByClass("func_button"),0 do
		local mapId = ent:MapCreationID()
		maxId = MathMax(mapId,maxId)

		local pos = ent:GetPos()
		pos:Add(ent:OBBCenter())

		ButtonEnts[mapId] = {
			["Claimed"] = false,
			["ClaimingPlayer"] = NULL,
			["Position"] = pos,
		}
	end

	ButtonClaimSystem.EntBits = DR.CalcMaxBits(maxId)
end)

--- @param mapId integer
--- @param data ButtonEntData
local function SingleUpdate(mapId,data)
	NetStart("DeathrunButtonEntsUpdateSimple")
		NetWriteUInt(mapId,ButtonClaimSystem.EntBits)

		local claimed = data.Claimed
		NetWriteBool(claimed)

		if claimed then
			NetWritePlayer(data.ClaimingPlayer)
		end
	NetSendPVS(data.Position)
end

net.Receive("DeathrunButtonEntsClientReady",function(_,ply)
	local entBits = ButtonClaimSystem.EntBits

	NetStart("DeathrunButtonEntsUpdateFull")
		NetWriteUInt(entBits,16)

		for mapId,data in next,ButtonEnts do
			NetWriteBool(true)

			NetWriteUInt(mapId,entBits)

			local claimed = data.Claimed
			NetWriteBool(claimed)

			if claimed then
				NetWritePlayer(data.ClaimingPlayer)
			end

			local pos = data.Position
			NetWriteDouble(pos[1])
			NetWriteDouble(pos[2])
			NetWriteDouble(pos[3])
		end

		NetWriteBool(false)
	NetSend(ply)
end)

TimerCreate("CheckButtonClaims",1 / 3,0,function()
	--- @type Player[]
	local plyList = {}

	for _,ply in Iterator,TeamGetPlayers(DR_TEAM_DEATH),0 do
		if not ply:Alive() then continue end

		plyList[#plyList + 1] = ply
	end

	if #plyList <= 0 then return end

	-- compile all the button entities into the table buttons
	--- @param mapId integer
	--- @param data ButtonEntData
	for mapId,data in next,ButtonEnts do
		local claimed = data.Claimed
		local claimer = data.ClaimingPlayer
		local pos = data.Position

		local closestDist = math.huge
		local closestPlayer

		for _,ply in Iterator,plyList,0 do
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
	or	plyTeam == DR_TEAM_SPECTATOR
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
		plyTeam == DR_TEAM_RUNNER
	or	not data
	or	not data.Claimed
	or	data.ClaimingPlayer == ply
	then
		if
			ent:GetInternalVariable("m_toggle_state") == 1 -- TS_AT_TOP
		and	not ent:GetInternalVariable("m_bLocked")
		and	ply:KeyPressed(IN_USE)
		then
			HookRun("DeathrunButtonActivated",ply,ent)
		end

		ent.User = ply

		return
	end

	return false
end)
