local DR = DR

local MapZones = ZONE.MapZones

ZONE.StartTime = ZONE.StartTime or -1

local ZoneDataDir = "deathrun/zones"
local ZoneDataFilepath = ZoneDataDir .. "/" .. game.GetMap() .. ".json"

util.AddNetworkString("DeathrunSendZones")

-- check if vector is within cuboid
local function VectorInCuboid(pos,min,max)
	-- get the min and max of the two corners
	local newMin,newMax = DR.VectorMinMax(min,max)

	local posX = pos[1]
	local posY = pos[2]
	local posZ = pos[3]

	return
		posX > newMin[1]
	and	posX < newMax[1]

	and	posY > newMin[2]
	and	posY < newMax[2]

	and	posZ > newMin[3]
	and	posZ < newMax[3]
end

local function CuboidOverlap(min1,max1,min2,max2)
	local pos1Min,pos1Max = DR.VectorMinMax(min1,max1)
	local pos2Min,pos2Max = DR.VectorMinMax(min2,max2)

	local pos1Min_X = pos1Min[1]
	local pos1Min_Y = pos1Min[2]
	local pos1Min_Z = pos1Min[3]

	local pos2Min_X = pos2Min[1]
	local pos2Min_Y = pos2Min[2]
	local pos2Min_Z = pos2Min[3]

	return
		(
			pos1Min_X <= pos2Min_X and pos2Min_X <= pos1Max[1]
		or	pos2Min_X <= pos1Min_X and pos1Min_X <= pos2Max[1]
		)
	and	(
			pos1Min_Y <= pos2Min_Y and pos2Min_Y <= pos1Max[2]
		or	pos2Min_Y <= pos1Min_Y and pos1Min_Y <= pos2Max[2]
		)
	and	(
			pos1Min_Z <= pos2Min_Z and pos2Min_Z <= pos1Max[3]
		or	pos2Min_Z <= pos1Min_Z and pos1Min_Z <= pos2Max[3]
		)
end

local OffsetIThink = Vector(0,0,50)

local function PlayerInCuboid(ply,min,max) -- check if vector is within cuboid
	local plyMin = ply:OBBMins()
	local plyMax = ply:OBBMaxs()
	local plyPos = ply:GetPos()

	plyMin:Add(plyPos)
	plyMax:Add(plyPos)

	plyPos:Add(OffsetIThink)

	return
		VectorInCuboid(plyPos,min,max)
	or	CuboidOverlap(plyMin,plyMax,min,max)
end

--- @param ply Player?
function ZONE.SendZones(ply)
	net.Start("DeathrunSendZones")
		net.WriteTable(MapZones)

	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

hook.Add("PlayerInitialSpawn","DeathrunSetupPlayerZones",function(ply)
	ply.InZones = {}

	ZONE.SendZones(ply)

	print("Sent zones to player " .. ply:Nick())
end)

function ZONE.Save()
	file.Write(
		ZoneDataFilepath,
		util.TableToJSON(MapZones,true)
	)

	print("Zones were saved.")
end

function ZONE.Load()
	if not file.Exists(ZoneDataDir,"DATA") then
		file.CreateDir(ZoneDataDir)
	end

	local data

	if file.Exists(ZoneDataFilepath,"DATA") then
		data = util.JSONToTable(file.Read(ZoneDataFilepath,"DATA"))
	else
		data = {}
	end

	table.CopyFromTo(data,MapZones)

	print("Zones were loaded.")
end

ZONE.Load()

--- @param name string
--- @param pos1 Vector
--- @param pos2 Vector
--- @param color Color
--- @param force boolean
function ZONE.Create(name,pos1,pos2,color,type,force)
	local targetZone = MapZones[name]

	-- empty table
	if
		not istable(targetZone)
	or	next(targetZone) == nil
	or	force
	then
		MapZones[name] = {
			["pos1"] = pos1,
			["pos2"] = pos2,
			["color"] = color,
			["type"] = type,
		}

		ZONE.Save()

		return true
	end

	return false
end

local ScanRate
local SkipCounter = -1

-- makes it a bit less taxing, at the cost of reducing the resolution of records
local TickRate = math.Round(1 / engine.TickInterval())

if TickRate >= 100 then
	ScanRate = 3
elseif TickRate >= 66 then
	ScanRate = 2
else
	ScanRate = 1
end

local ZoneBorder = Vector(20,20,20)

-- cycle through zones and check for players
hook.Add("Tick","ZoneTick",function()
	SkipCounter = (SkipCounter + 1) % ScanRate
	if SkipCounter ~= 0 then return end

	for name,zone in pairs(MapZones) do
		if not zone.type then continue end

		local pos1 = zone.pos1
		local pos2 = zone.pos2

		local posMin,posMax = DR.VectorMinMax(pos1,pos2)
		posMin:Sub(ZoneBorder)
		posMax:Add(ZoneBorder)

		for _,ent in ipairs(ents.FindInBox(posMin,posMax)) do
			if not ent:IsPlayer() then continue end

			local inZones = ent.InZones
			local inCuboid = PlayerInCuboid(ent,pos1,pos2)
			local hasChanged

			if
				inZones[name]
			and	not inCuboid
			then
				-- if we remember them being inside, but they arent anymore, then they left.
				inZones[name] = false
				hasChanged = true
			elseif
				not inZones[name]
			and	inCuboid
			then
				-- if we don't remember them being inside, but they are inside, then they mustve just entered the zone.
				inZones[name] = true
				hasChanged = true
			end

			if not hasChanged then continue end

			hook.Run("DeathrunPlayerEnteredZone",ent,name,zone)
		end
	end
end)

-- add some concommands for creating zones
concommand.Add("zone_create",function(ply,cmd,args)
	-- e.g. zone_create endmap end
	local name = args[1]
	local type = args[2]

	if not DR.CanAccessCommand(ply,cmd) then
		DR.SafeChatPrint(ply,"Insufficient permissions.")

		return
	elseif
		not (
			name
		and type
		)
	then
		DR.SafeChatPrint(ply,"Invalid command arguments.")

		return
	end

	local msg

	if ZONE.Create(name,Vector(),Vector(),color_white,type,ply.LastZoneDenied == name) then
		ZONE.Save()
		ZONE.SendZones()

		ply.LastZoneDenied = nil

		msg = "Created zone \"" .. name .. "\" of type \"" .. type .. "\"."

		hook.Run("DeathrunZonesUpdated")
	else
		ply.LastZoneDenied = name

		msg = "There already exists a zone named \"" .. name .. "\". Please delete it first!\nIf you wish to overwrite it run this command again."
	end

	DR.SafeChatPrint(ply,msg)
end)

DR.AddChatCommand("createzone",function(ply,args)
	ply:ConCommand("zone_create " .. (args[1] or "") .. " " .. (args[2] or ""))
end)

concommand.Add("zone_remove",function(ply,cmd,args)
	-- e.g. zone_create endmap end
	local name = args[1]

	if not DR.CanAccessCommand(ply,cmd) then
		DR.SafeChatPrint(ply,"Insufficient permissions.")

		return
	elseif not name then
		DR.SafeChatPrint(ply,"Invalid command arguments.")

		return
	end

	MapZones[name] = nil

	ZONE.Save()
	ZONE.SendZones()

	hook.Run("DeathrunZonesUpdated")

	DR.SafeChatPrint(ply,"Deleted zone \"" .. name .. "\"")
end)

DR.AddChatCommand("removezone",function(ply,args)
	ply:ConCommand("zone_remove " .. (args[1] or ""))
end)

concommand.Add("zone_setpos",function(ply,cmd,args)
	local name = args[1]
	local pos = args[2]

	if not DR.CanAccessCommand(ply,cmd) then
		DR.SafeChatPrint(ply,"Insufficient permissions.")

		return
	elseif
		not (
			name
		and pos
		)
	then
		DR.SafeChatPrint(ply,"Invalid command arguments.")

		return
	end

	local zone = MapZones[name]
	local msg

	if zone then
		if
			pos == "1"
		or	pos == "2"
		then
			local hitPos = ply:GetEyeTrace().HitPos
			zone["pos" .. pos] = hitPos

			ZONE.Save()
			ZONE.SendZones()

			msg = name .. ".pos" .. pos .. " set to " .. tostring(hitPos) .. "."

			hook.Run("DeathrunZonesUpdated")
		else
			msg = "Bad \"pos\" argument, please use either \"1\" or \"2\"."
		end
	else
		msg = "Zone does not exist."
	end

	DR.SafeChatPrint(ply,msg)
end)

DR.AddChatCommand("setzonepos1",function(ply,args)
	ply:ConCommand("zone_setpos " .. (args[1] or "") .. "1")
end)

DR.AddChatCommand("setzonepos2",function(ply,args)
	ply:ConCommand("zone_setpos " .. (args[1] or "") .. "2")
end)

concommand.Add("zone_setcolor",function(ply,cmd,args)
	-- RGBA e.g. zone_setcolor endmap 255 0 0 255
	local name = args[1]
	local colR = tonumber(args[2]) or 255
	local colG = tonumber(args[3]) or 255
	local colB = tonumber(args[4]) or 255
	local colA = tonumber(args[5]) or 255

	if not DR.CanAccessCommand(ply,cmd) then
		DR.SafeChatPrint(ply,"Insufficient permissions.")

		return
	elseif not name then
		DR.SafeChatPrint(ply,"Invalid command arguments.")

		return
	end

	local zone = MapZones[name]
	local msg

	if zone then
		local color = zone.color
		color.r = colR
		color.g = colG
		color.b = colB
		color.a = colA

		ZONE.Save()
		ZONE.SendZones()

		msg = name .. ".color set to " .. colR .. " " .. colG .. " " .. colB .. " " .. colA .. "."

		hook.Run("DeathrunZonesUpdated")
	else
		msg = "Zone does not exist."
	end

	DR.SafeChatPrint(ply,msg)
end)

DR.AddChatCommand("setzonecolor",function(ply,args)
	ply:ConCommand("zone_setcolor " .. (args[1] or "") .. " " .. (args[2] or "") .. " " .. (args[3] or "") .. " " .. (args[4] or "") .. " " .. (args[5] or ""))
end)

concommand.Add("zone_settype",function(ply,cmd,args)
	-- e.g. zone_settype endmap end
	local name = args[1]
	local type = args[2]

	if not DR.CanAccessCommand(ply,cmd) then
		DR.SafeChatPrint(ply,"Insufficient permissions.")

		return
	elseif
		not (
			name
		and type
		)
	then
		DR.SafeChatPrint(ply,"Invalid command arguments.")

		return
	end

	local zone = MapZones[name]
	local msg

	if zone then
		zone.type = type

		ZONE.Save()
		ZONE.SendZones()

		msg = name .. ".type set to " .. type .. "."

		hook.Run("DeathrunZonesUpdated")
	else
		msg = "Zone does not exist."
	end

	DR.SafeChatPrint(ply,msg)
end)

DR.AddChatCommand("setzonetype",function(ply,args)
	ply:ConCommand("zone_settype " .. (args[1] or "") .. " " .. (args[2] or ""))
end)

-- timing and rewards
local FinishOrder = {}

hook.Add("DeathrunBeginPrep","DeathrunResetFinishers",function()
	for _,ply in player.Iterator() do
		ply.HasFinishedMap = false
	end

	for idx in ipairs(FinishOrder) do
		FinishOrder[idx] = nil
	end
end)

hook.Add("DeathrunBeginActive","DeathrunResetZoneTimer",function()
	ZONE.StartTime = CurTime()
end)

hook.Add("DeathrunPlayerInsideZone","DeathrunPlayerDenyZones",function(ply,_,zone)
	local type = zone.type
	local plyTeam = ply:Team()

	if
		not (
			ply:Alive()
		and	ply:GetObserverMode() == OBS_MODE_NONE
		and	(
				type == "deny"
			or	type == "deny_team_runner" and plyTeam == DR_TEAM_RUNNER
			or	type == "deny_team_death" and plyTeam == DR_TEAM_DEATH
			)
		)
	then return end

	ply:Kill()
end)

hook.Add("DeathrunPlayerEnteredZone","DeathrunPlayerFinishMap",function(ply,name,zone)
	if
		zone.type ~= "end"
	or	not ply:Alive()
	or	ply:GetSpectate()
	or	ply:Team() ~= DR_TEAM_RUNNER
	or	ply.HasFinishedMap
	or	ROUND.GetCurrent() == DR_ROUND_WAITING
	then return end

	ply.HasFinishedMap = true

	local place = #FinishOrder + 1
	FinishOrder[place] = ply

	local placeTxt
	local placeStr = tostring(place)
	local endCharNN = placeStr:sub(-1,-2)
	local endCharN = endCharNN:sub(-1,-1)

	if
		endCharNN == "11"
	or	endCharNN == "12"
	or	endCharNN == "13"
	then
		placeTxt = placeStr .. "th"
	elseif endCharN == "1" then
		placeTxt = placeStr .. "st"
	elseif endCharN == "2" then
		placeTxt = placeStr .. "nd"
	elseif endCharN == "3" then
		placeTxt = placeStr .. "rd"
	else
		placeTxt = placeStr .. "th"
	end

	local finishTime = CurTime() - ZONE.StartTime

	DR.ChatBroadcast(ply:Nick() .. " has finished the map in " .. placeTxt .. " place with a time of " .. string.ToMinutesSecondsMilliseconds(finishTime) .. "!")

	if place == 1 then
		-- deaths lose sprint when the first runner finishes
		for _,death in ipairs(team.GetPlayers(DR_TEAM_DEATH)) do
			death:SetRunSpeed(250)
		end
	end

	hook.Run("DeathrunPlayerFinishMap",ply,name,zone,place,finishTime)
end)
