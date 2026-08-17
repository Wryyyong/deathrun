local Iterator = ipairs({})

local next = next
local istable = istable
local print = print
local setmetatable = setmetatable
local tonumber = tonumber
local tostring = tostring

local CurTime = CurTime
local Vector = Vector

local EngineTickInterval = engine.TickInterval

local FileCreateDir = file.CreateDir
local FileExists = file.Exists
local FileIsDir = file.IsDir
local FileRead = file.Read
local FileWrite = file.Write

local GameGetMap = game.GetMap

local HookRun = hook.Run

local MathRound = math.Round

local NetBroadcast = net.Broadcast
local NetSend = net.Send
local NetStart = net.Start
local NetWriteBool = net.WriteBool
local NetWriteColor = net.WriteColor
local NetWriteDouble = net.WriteDouble
local NetWriteString = net.WriteString

local PlayerIterator = player.Iterator

local StringToMinutesSecondsMilliseconds = string.ToMinutesSecondsMilliseconds

local TableCopyFromTo = table.CopyFromTo

local TeamGetPlayers = team.GetPlayers

local UtilJSONToTable = util.JSONToTable
local UtilTableToJSON = util.TableToJSON

local DR = DR

local RoundSystem = DR.RoundSystem
local ZoneSystem = DR.ZoneSystem

local MapZones = ZoneSystem.MapZones
local ZonesExtraData = ZoneSystem.ZonesExtraData

ZoneSystem.StartTime = ZoneSystem.StartTime or -1

local ZoneDataDir = "deathrun/zones"
local ZoneDataFilepath = ZoneDataDir .. "/" .. GameGetMap() .. ".json"

--- @type Zone
local Zone_Default = {
	["type"] = "start",
	["color"] = color_white,
	["pos1"] = vector_origin,
	["pos2"] = vector_origin,
	["dir"] = vector_origin,
}
local Zone_Meta = {
	["__index"] = Zone_Default,
}

util.AddNetworkString("DeathrunSendZones")

--- @param ply Player?
function ZoneSystem.SendZones(ply)
	NetStart("DeathrunSendZones")
		for name,zone in next,MapZones do
			NetWriteBool(true)

			NetWriteString(name)
			NetWriteString(zone.type)
			NetWriteColor(zone.color,true)

			local pos1 = zone.pos1
			NetWriteDouble(pos1[1])
			NetWriteDouble(pos1[2])
			NetWriteDouble(pos1[3])

			local pos2 = zone.pos2
			NetWriteDouble(pos2[1])
			NetWriteDouble(pos2[2])
			NetWriteDouble(pos2[3])

			local dir = zone.dir
			NetWriteDouble(dir[1])
			NetWriteDouble(dir[2])
			NetWriteDouble(dir[3])
		end

		NetWriteBool(false)

	if ply then
		NetSend(ply)
	else
		NetBroadcast()
	end
end

hook.Add("DeathrunClientInitialized","DeathrunSendZonesToNewClient",function(ply)
	ply.InZones = {}

	ZoneSystem.SendZones(ply)
end)

local function UpdateZones()
	ZoneSystem.Save()
	ZoneSystem.SendZones()

	ZoneSystem.CreateZonesExtraData()

	HookRun("DeathrunZonesUpdated")
end

function ZoneSystem.Save()
	FileWrite(
		ZoneDataFilepath,
		UtilTableToJSON(MapZones,true)
	)

	print("Zones were saved.")
end

function ZoneSystem.Load()
	if not FileIsDir(ZoneDataDir,"DATA") then
		FileCreateDir(ZoneDataDir)
	end

	local data

	if FileExists(ZoneDataFilepath,"DATA") then
		data = UtilJSONToTable(FileRead(ZoneDataFilepath,"DATA"))
	else
		data = {}
	end

	TableCopyFromTo(data,MapZones)

	for name,zone in next,MapZones do
		local color = zone.color

		zone.color = Color(
			color.r,
			color.g,
			color.b,
			color.a
		)

		setmetatable(zone,Zone_Meta)
	end

	UpdateZones()

	print("Zones were loaded.")
end

ZoneSystem.Load()

--- @param name string
--- @param pos1 Vector
--- @param pos2 Vector
--- @param dir Vector
--- @param color Color
--- @param force boolean
function ZoneSystem.Create(name,pos1,pos2,dir,color,type,force)
	local targetZone = MapZones[name]

	-- empty table
	if
		not istable(targetZone)
	or	next(targetZone) == nil
	or	force
	then
		MapZones[name] = setmetatable({
			["type"] = type,
			["color"] = color,
			["pos1"] = pos1,
			["pos2"] = pos2,
			["dir"] = dir,
		},Zone_Meta)

		return true
	end

	return false
end

local ScanRate
local SkipCounter = -1

-- makes it a bit less taxing, at the cost of reducing the resolution of records
local TickRate = MathRound(1 / EngineTickInterval())

if TickRate >= 100 then
	ScanRate = 3
elseif TickRate >= 66 then
	ScanRate = 2
else
	ScanRate = 1
end

-- cycle through zones and check for players
hook.Add("Tick","ZoneTick",function()
	SkipCounter = (SkipCounter + 1) % ScanRate
	if SkipCounter ~= 0 then return end

	for _,ent in PlayerIterator() do
		if not ent.Initialized then continue end

		local eyePos = ent:EyePos()
		local inZones = ent.InZones

		for name,zone in next,MapZones do
			if not zone.type then continue end

			local exData = ZonesExtraData[name]
			local posMin = exData.minBorder
			local posMax = exData.maxBorder

			local isWithinZone = eyePos:WithinAABox(posMin,posMax)
			local hasChanged

			if
				inZones[name]
			and	not isWithinZone
			then
				-- if we remember them being inside, but they arent anymore, then they left.
				inZones[name] = false
				hasChanged = true
			elseif
				not inZones[name]
			and	isWithinZone
			then
				-- if we don't remember them being inside, but they are inside, then they mustve just entered the zone.
				inZones[name] = true
				hasChanged = true
			end

			if
				not (
					hasChanged
				and	inZones[name]
				)
			then continue end

			HookRun("DeathrunPlayerEnteredZone",ent,name,zone)
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

	if ZoneSystem.Create(name,Vector(),Vector(),Vector(),color_white:Copy(),type,ply.LastZoneDenied == name) then
		ply.LastZoneDenied = nil

		msg = "Created zone \"" .. name .. "\" of type \"" .. type .. "\"."

		UpdateZones()
	else
		ply.LastZoneDenied = name

		msg = "There already exists a zone named \"" .. name .. "\". Please delete it first!\nIf you wish to overwrite it run this command again."
	end

	DR.SafeChatPrint(ply,msg)
end)

concommand.Add("zone_remove",function(ply,cmd,args)
	local name = args[1]

	if not DR.CanAccessCommand(ply,cmd) then
		DR.SafeChatPrint(ply,"Insufficient permissions.")

		return
	elseif not name then
		DR.SafeChatPrint(ply,"Invalid command arguments.")

		return
	end

	MapZones[name] = nil

	UpdateZones()

	DR.SafeChatPrint(ply,"Deleted zone \"" .. name .. "\"")
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

			msg = name .. ".pos" .. pos .. " set to " .. tostring(hitPos) .. "."

			UpdateZones()
		else
			msg = "Bad \"pos\" argument, please use either \"1\" or \"2\"."
		end
	else
		msg = "Zone does not exist."
	end

	DR.SafeChatPrint(ply,msg)
end)

concommand.Add("zone_setposxyz",function(ply,cmd,args)
	local name = args[1]
	local pos = args[2]
	local x = args[3]
	local y = args[4]
	local z = args[5]

	if not DR.CanAccessCommand(ply,cmd) then
		DR.SafeChatPrint(ply,"Insufficient permissions.")

		return
	elseif
		not (
			name
		and pos
		and x
		and y
		and z
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
			local vec = zone["pos" .. pos]
			if not vec then return end

			vec:SetUnpacked(x,y,z)

			msg = name .. ".pos" .. pos .. " set to " .. tostring(vec) .. "."

			UpdateZones()
		else
			msg = "Bad \"pos\" argument, please use either \"1\" or \"2\"."
		end
	else
		msg = "Zone does not exist."
	end

	DR.SafeChatPrint(ply,msg)
end)

concommand.Add("zone_setdir",function(ply,cmd,args)
	local name = args[1]

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
		local ang = ply:EyeAngles()

		ang:SnapTo("pitch",90)
		ang:SnapTo("yaw",90)
		ang:SnapTo("roll",90)

		local dir = ang:Forward()
		dir:Mul(150)

		dir[1] = MathRound(dir[1])
		dir[2] = MathRound(dir[2])
		dir[3] = MathRound(dir[3])

		zone["dir"] = dir

		msg = name .. ".dir" .. " set to " .. tostring(dir) .. "."

		UpdateZones()
	else
		msg = "Zone does not exist."
	end

	DR.SafeChatPrint(ply,msg)
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

		msg = name .. ".color set to " .. colR .. " " .. colG .. " " .. colB .. " " .. colA .. "."

		UpdateZones()
	else
		msg = "Zone does not exist."
	end

	DR.SafeChatPrint(ply,msg)
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

		msg = name .. ".type set to " .. type .. "."

		UpdateZones()
	else
		msg = "Zone does not exist."
	end

	DR.SafeChatPrint(ply,msg)
end)

concommand.Add("zone_goto",function(ply,cmd,args)
	local name = args[1]
	local zone = MapZones[name]

	if not DR.CanAccessCommand(ply,cmd) then
		DR.SafeChatPrint(ply,"Insufficient permissions.")

		return
	elseif not zone then
		DR.SafeChatPrint(ply,"Invalid command arguments.")

		return
	end

	local newPos = zone.pos1 + zone.pos2
	newPos:Mul(.5)

	local eyePos = ply:EyePos()
	eyePos:Sub(ply:GetPos())
	newPos:Sub(eyePos)

	ply:SetPos(newPos)
	ply:SetLocalVelocity(vector_origin)

	DR.SafeChatPrint(ply,"Teleporetd to zone \"" .. name .. "\"")
end)

-- timing and rewards
local FinishOrder = {}

hook.Add("DeathrunBeginPrep","DeathrunResetFinishers",function()
	for _,ply in PlayerIterator() do
		ply.HasFinishedMap = false
	end

	for idx in Iterator,FinishOrder,0 do
		FinishOrder[idx] = nil
	end
end)

hook.Add("DeathrunBeginActive","DeathrunResetZoneTimer",function()
	ZoneSystem.StartTime = CurTime()
end)

hook.Add("DeathrunPlayerEnteredZone","DeathrunPlayerDenyZones",function(ply,_,zone)
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
	or	RoundSystem.GetCurrent() == DR_ROUND_WAITING
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

	local finishTime = CurTime() - ZoneSystem.StartTime

	DR.ChatBroadcast(ply:Nick() .. " has finished the map in " .. placeTxt .. " place with a time of " .. StringToMinutesSecondsMilliseconds(finishTime) .. "!")

	if place == 1 then
		-- deaths lose sprint when the first runner finishes
		for _,death in Iterator,TeamGetPlayers(DR_TEAM_DEATH),0 do
			death:SetRunSpeed(250)
		end
	end

	HookRun("DeathrunPlayerFinishMap",ply,name,zone,place,finishTime)
end)

DR.AddChatCommand("createzone",function(ply,args)
	ply:ConCommand("zone_create " .. (args[1] or "") .. " " .. (args[2] or ""))
end)

DR.AddChatCommand("removezone",function(ply,args)
	ply:ConCommand("zone_remove " .. (args[1] or ""))
end)

DR.AddChatCommand("setzonepos1",function(ply,args)
	ply:ConCommand("zone_setpos " .. (args[1] or "") .. " 1")
end)

DR.AddChatCommand("setzonepos2",function(ply,args)
	ply:ConCommand("zone_setpos " .. (args[1] or "") .. " 2")
end)

DR.AddChatCommand("setzonedir",function(ply,args)
	ply:ConCommand("zone_setdir " .. (args[1] or ""))
end)

DR.AddChatCommand("setzonecolor",function(ply,args)
	ply:ConCommand("zone_setcolor " .. (args[1] or "") .. " " .. (args[2] or "") .. " " .. (args[3] or "") .. " " .. (args[4] or "") .. " " .. (args[5] or ""))
end)

DR.AddChatCommand("setzonetype",function(ply,args)
	ply:ConCommand("zone_settype " .. (args[1] or "") .. " " .. (args[2] or ""))
end)
