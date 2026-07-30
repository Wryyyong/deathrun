--- @type table<string,integer>
local MapList = MV.MapList or {}
MV.MapList = MapList

-- store each player's vote - {Player, Map}
--- @type table<Player,string>
local Players = MV.Players or {}
MV.Players = Players

--- @type table<Player,integer>
local PlayerNominations = MV.PlayerNominations or {}
MV.PlayerNominations = PlayerNominations

--- @type table<integer,integer>
local Nominations = MV.Nominations or {}
MV.Nominations = Nominations

--- @type string[]
local VotingMapsNoVotes = MV.VotingMapsNoVotes or {}
VotingMapsNoVotes = VotingMapsNoVotes

MV.Active = MV.Active or false
MV.TimeLeft = MV.TimeLeft or MV.VotingTime
MV.LoadTime = MV.LoadTime or CurTime()

util.AddNetworkString("MapvoteUpdateMapList")
util.AddNetworkString("MapvoteSendAllMaps")
util.AddNetworkString("MapvoteSetActive")
util.AddNetworkString("MapvoteSyncNominations")

if not file.Exists("deathrun/MapStatistics.json","DATA") then
	file.Write("deathrun/MapStatistics.json","[]")
end

local MapStats = MV.MapStats or util.JSONToTable(file.Read("deathrun/MapStatistics.json","DATA")) or {}
MV.MapStats = MapStats

local function SaveStats()
	file.Write("deathrun/MapStatistics.json",util.TableToJSON(MapStats))
end

-- increment stats by 1 each time a round is played on the map
hook.Add("DeathrunBeginPrep","RecordMapStats",function()
	local map = game.GetMap()
	local stats = MapStats[map]
	local plyNum = #DR.GetAllPlaying()

	MapStats[map] =
		stats
	and	stats + plyNum
	or	plyNum

	SaveStats()
end)

-- commands
concommand.Add("mapvote_list_maps",function(ply,cmd)
	if not DR.CanAccessCommand(ply,cmd) then return end

	net.Start("MapvoteSendAllMaps")
		net.WriteTable({
			["maps"] = MV.GetGoodMaps(),
			["action"] = "openlist",
		})
	net.Send(ply)
end)

function MV.SyncMapList()
	net.Start("MapvoteUpdateMapList")
		net.WriteTable(MapList)
	net.Broadcast()
end

function MV.GetGoodMaps()
	-- get a list of maps
	local mapList = file.Find("maps/*.bsp","GAME","nameasc")

	-- cleanup the names
	for idx,map in ipairs(mapList) do
		mapList[idx] = map:StripExtension():lower()
	end

	-- remove files that don't have the right prefix
	local goodMaps = {}

	for _,filter in ipairs(MV.Filter) do
		local length = #filter

		for _,map in ipairs(mapList) do
			if
				map:sub(1,length) ~= filter
			or	table.HasValue(goodMaps,map)
			then continue end

			goodMaps[#goodMaps + 1] = map
		end
	end

	return goodMaps
end

function MV.UpdateMapVote()
	net.Start("MapvoteUpdateMapList")
		net.WriteTable(MapList)
	net.Broadcast()
end

local function SendMapVoteStatus()
	local active = MV.Active

	net.Start("MapvoteSetActive")
		net.WriteBool(active)

		if active then
			net.WriteTable(MapList)
			net.WriteFloat(MV.VotingTime)
		end
	net.Broadcast()
end

-- initiates the mapvote, and syncs the maps once
function MV.BeginMapVote()
	local mapList = MV.GetGoodMaps()

	-- populate the maplist
	table.Empty(MapList)

	-- add nominations
	for idx = 1,MV.MaxMaps do
		local nomination = Nominations[idx]
		if not nomination then continue end

		MapList[nomination] = 0
	end

	local loopCount = 0
	local numMaps = table.Count(MapList)

	while loopCount < 200 and numMaps < MV.MaxMaps and #mapList > 0 do
		local randNum = math.random(#mapList)
		local map = mapList[randNum]

		MapList[map] = 0

		table.remove(mapList,randNum)
		numMaps = table.Count(MapList)

		loopCount = loopCount + 1
	end

	numMaps = table.Count(MapList)

	MV.Active = true
	MV.TimeLeft = MV.VotingTime

	SendMapVoteStatus()
end

function MV.StopMapVote()
	MV.Active = false
	MV.TimeLeft = -1

	SendMapVoteStatus()
end

function MV.FinishMapVote()
	MV.Active = false

	-- find winning map
	-- change to it
	local winner
	local winningVotes = 0

	for map,voteCount in pairs(MapList) do
		if winningVotes >= voteCount then continue end

		winningVotes = voteCount
		winner = map
	end

	table.Empty(VotingMapsNoVotes)

	for mapId in pairs(MapList) do
		VotingMapsNoVotes[#VotingMapsNoVotes + 1] = mapId
	end

	if not winner then
		winner = VotingMapsNoVotes[math.random(#VotingMapsNoVotes)]
	end

	DR.ChatBroadcast("The next map will be " .. tostring(winner) .. ". Map will change in 5 seconds.")

	timer.Simple(5,function()
		DR.ChatBroadcast("Changing to the next map...")

		RunConsoleCommand("changelevel",winner)
	end)
end

timer.Create("MapvoteCountdownTimer",.2,0,function()
	if not MV.Active then return end

	local timeLeft = MV.TimeLeft - .2
	MV.TimeLeft = timeLeft

	if timeLeft > 0 then return end

	MV.FinishMapVote()
end)

concommand.Add("mapvote_begin_mapvote",function(ply,cmd)
	if
		not DR.CanAccessCommand(ply,cmd)
	or	hook.Run("DeathrunStartMapvote",ROUND.GetRoundsPlayed())
	then return end

	MV.BeginMapVote()
end)

concommand.Add("mapvote_vote",function(ply,cmd,args)
	if
		not (
			MV.Active
		and	IsValid(ply)
		and	DR.CanAccessCommand(ply,cmd)
		)
	then return end

	local targetMap = args[1]

	if targetMap then
		Players[ply] = targetMap

		for map in pairs(MapList) do
			MapList[map] = 0
		end

		for _,map in pairs(Players) do
			MapList[map] = MapList[map] + 1
		end

		MV.UpdateMapVote()
	else
		ply:DeathrunChatPrint("Please specify a map.")
	end
end)

concommand.Add("mapvote_nominate_map",function(ply,cmd,args)
	local nomNum = args[1]

	if
		not (
			nomNum
		and	DR.CanAccessCommand(ply,cmd)
		)
	then return end

	local curTime = CurTime()

	if not ply.LastNom or ply.LastNom + 1 < curTime then
		if not table.HasValue(MV.GetGoodMaps(),nomNum) then
			ply:DeathrunChatPrint("You can't nominate a map that isn't in the nominate list.")

			return
		end

		if nomNum == game.GetMap() then
			ply:DeathrunChatPrint("You can't nominate the map you are currently playing.")

			return
		end

		PlayerNominations[ply] = nomNum

		for _,plyNom in pairs(PlayerNominations) do
			if table.HasValue(Nominations,plyNom) then continue end

			Nominations[#Nominations + 1] = plyNom
		end

		ply.LastNom = CurTime()

		DR.ChatBroadcast(ply:Nick() .. " has nominated " .. nomNum .. " for the mapvote!")

		net.Start("MapvoteSyncNominations")
			net.WriteTable(Nominations)
		net.Broadcast()
	else
		ply:DeathrunChatPrint("Please wait before nominating again.")
	end
end)

concommand.Add("mapvote_update_mapvote",function(ply,cmd)
	if not DR.CanAccessCommand(ply,cmd) then return end

	MV.UpdateMapVote()
end)

-- RTV Features
local RTVRatio = DR.ConVars.MapVoteRTVRatio

function MV.CheckRTV(suppress)
	if MV.Active then return end

	if
		not suppress
	and MV.LoadTime + 60 > CurTime()
	then
		DR.ChatBroadcast("It is too early to call an RTV.")

		return
	end

	local voteCount = 0
	local plyList = player.GetAll()
	local plyCount = #plyList

	for _,ply in ipairs(plyList) do
		local wantsRtv = ply.WantsRTV or false
		ply.WantsRTV = wantsRtv

		if not wantsRtv then continue end

		voteCount = voteCount + 1
	end

	if voteCount / plyCount > RTVRatio:GetFloat() then
		if not hook.Run("DeathrunStartMapvote",ROUND.GetRoundsPlayed()) then MV.BeginMapVote() end

		DR.ChatBroadcast("RTV limit reached. Initiating mapvote.")
	elseif not suppress then
		DR.ChatBroadcast((math.ceil(RTVRatio:GetFloat() * plyCount) - voteCount + 1) .. " more votes needed in order to change the map. Type !rtv to vote.")
	end
end

concommand.Add("mapvote_rtv",function(ply,cmd)
	if not DR.CanAccessCommand(ply,cmd) then return end

	local oldWantsRtv = ply.WantsRTV
	ply.WantsRTV = true

	MV.CheckRTV(oldWantsRtv)
end)

hook.Add("PlayerSay","CheckRTVChat",function(ply,text)
	local args = text:Split(" ")
	if #args ~= 1 then return end

	local command = args[1]

	if command == "rtv" then
		ply:ConCommand("mapvote_rtv")
	elseif
		command == "nominate"
	or	command == "maps"
	then
		ply:ConCommand("mapvote_list_maps")
	end
end)

DR.AddChatCommand("rtv",function(ply)
	ply:ConCommand("mapvote_rtv")
end)

DR.AddChatCommand("nominate",function(ply)
	ply:ConCommand("mapvote_list_maps")
end)

DR.AddChatCommandAlias("nominate","maps")
