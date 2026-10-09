local ipairs = ipairs({})
local pairs = next

local IsValid = IsValid

local EntsFindByClass = ents.FindByClass

local HookRun = hook.Run

local MathHuge = math.huge
local MathMax = math.max

local NetSend = net.Send
local NetStart = net.Start
local NetWriteBool = net.WriteBool
local NetWritePlayer = net.WritePlayer
local NetWriteUInt = net.WriteUInt
local NetWriteVectorFull = net.WriteVectorFull

local TableEmpty = table.Empty

local TimerCreate = timer.Create

local DR = DR

local ButtonClaimSystem = DR.ButtonClaimSystem
local PlayerFilter_DeathsAlive = DR.PlayerFilters.DeathsAlive

local ButtonEnts = ButtonClaimSystem.ButtonEnts
local ClaimRadius = ButtonClaimSystem.ClaimRadius

local OutputList = {
	"OnPressed",
}

for idx,outputName in ipairs,OutputList,0 do
	OutputList[idx] = outputName .. " DeathrunButtonClaimingOutputHandler:RunPassedCode:hook.Run('DeathrunButtonClaiming_" .. outputName .. "'):0:-1"
end

util.AddNetworkString("DeathrunButtonEntsUpdateFull")
util.AddNetworkString("DeathrunButtonEntsUpdateSimple")

local function SetupOutputHandler()
	local outputHandler = ents.Create("lua_run") --- @cast outputHandler -NULL

	outputHandler:SetName("DeathrunButtonClaimingOutputHandler")
	outputHandler:Spawn()

	local maxId = -1

	TableEmpty(ButtonEnts)

	--- @param ent Entity
	for _,ent in ipairs,EntsFindByClass("func_button"),0 do
		local mapId = ent:MapCreationID()
		maxId = MathMax(mapId,maxId)

		local pos = ent:GetPos()
		pos:Add(ent:OBBCenter())

		ButtonEnts[mapId] = {
			["Active"] = true,
			["Claimed"] = false,
			["ClaimingPlayer"] = NULL,
			["Entity"] = ent,
			["Position"] = pos,
		}

		for _,output in ipairs,OutputList,0 do
			ent:Fire("AddOutput",output)
		end

		ent:RemoveFlags(512) -- 512: Damage Activates
	end

	ButtonClaimSystem.EntBits = DR.CalcMaxBits(maxId)
end

for _,hookName in ipairs,{"InitPostEntity","PostCleanupMap"},0 do
	hook.Add(hookName,"DeathrunButtonClaimingSetupOutputHandler",SetupOutputHandler)
end

--- @param mapId integer
--- @param data ButtonEntData
local function SingleUpdate(mapId,data)
	NetStart("DeathrunButtonEntsUpdateSimple")
		NetWriteUInt(mapId,ButtonClaimSystem.EntBits)

		local claimed = data.Claimed
		NetWriteBool(data.Active)
		NetWriteBool(claimed)

		if claimed then
			NetWritePlayer(data.ClaimingPlayer)
		end
	NetSend(PlayerFilter_DeathsAlive)
end

hook.Add("DeathrunClientInitialized","DeathrunSendButtonEntsToNewClient",function(ply)
	local entBits = ButtonClaimSystem.EntBits

	NetStart("DeathrunButtonEntsUpdateFull")
		NetWriteUInt(entBits,16)

		--- @param mapId integer
		--- @param data ButtonEntData
		for mapId,data in pairs,ButtonEnts do
			NetWriteBool(true)

			NetWriteUInt(mapId,entBits)

			local claimed = data.Claimed
			NetWriteBool(data.Active)
			NetWriteBool(claimed)

			if claimed then
				NetWritePlayer(data.ClaimingPlayer)
			end

			NetWriteVectorFull(data.Position)
		end

		NetWriteBool(false)
	NetSend(ply)
end)

TimerCreate("CheckButtonClaims",1 / 3,0,function()
	local plyList = PlayerFilter_DeathsAlive:GetPlayers()
	if #plyList <= 0 then return end

	local eyePosIndex = {}

	for _,ply in ipairs,plyList,0 do
		eyePosIndex[ply] = ply:EyePos()
	end

	-- compile all the button entities into the table buttons
	--- @param mapId integer
	--- @param data ButtonEntData
	for mapId,data in pairs,ButtonEnts do
		local claimed = data.Claimed
		local claimer = data.ClaimingPlayer
		local pos = data.Position

		local closestDist = MathHuge
		local closestPlayer

		for ply,eyePos in pairs,eyePosIndex do
			local dist = pos:DistToSqr(eyePos)
			if dist >= closestDist then continue end

			closestDist = dist
			closestPlayer = ply
		end

		local currentClaimPlyDist = MathHuge

		if IsValid(claimer) then
			currentClaimPlyDist = pos:DistToSqr(eyePosIndex[claimer])
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

local function IsButtonActive(ent)
	return
		ent:GetInternalVariable("m_toggle_state") == 1 -- TS_AT_TOP
	and	not ent:GetInternalVariable("m_bLocked")
end

hook.Add("DeathrunButtonClaiming_OnPressed","DeathrunButtonClaiming_LogicOnPressed",function()
	--- @type Entity?
	local button = CALLER
	if not button then return end

	local mapId = button:MapCreationID()
	local data = ButtonEnts[mapId]

	data.Active = false
	SingleUpdate(mapId,data)
end)

TimerCreate("DeathrunButtonClaimingCheckInactiveButtons",1,0,function()
	--- @param mapId integer
	--- @param data ButtonEntData
	for mapId,data in pairs,ButtonEnts do
		if data.Active then continue end
		if not IsButtonActive(data.Entity) then continue end

		data.Active = true

		SingleUpdate(mapId,data)
	end
end)

hook.Add("PlayerUse","DeathrunButtonClaimingPlayerUse",function(ply,ent)
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
			IsButtonActive(ent)
		and	ply:KeyPressed(IN_USE)
		then
			HookRun("DeathrunButtonActivated",ply,ent)
		end

		ent.User = ply

		return
	end

	return false
end)
