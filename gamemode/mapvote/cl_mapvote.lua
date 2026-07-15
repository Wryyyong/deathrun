local MapVote = DR.MapVote

MapVote.Active = MapVote.Active or false

--- @type string[]
local MapList = MapVote.MapList or {}
MapVote.MapList = MapList

--- @type table<string,integer>
local VotingMapList = MapVote.VotingMapList or {}
MapVote.VotingMapList = VotingMapList

--- @type string[]
local VotingMapsNoVotes = MapVote.VotingMapsNoVotes or {}
MapVote.VotingMapsNoVotes = VotingMapsNoVotes

local Nominations = MapVote.Nominations or {}
MapVote.Nominations = Nominations

function MapVote.IsMapNominated(mapname)
	return table.HasValue(Nominations,mapname)
end

function MapVote.OpenFullMapList()
	local frame = vgui.Create("DR_MapVoteMapListFrame")
	local inner = frame:Add("DR_MapVoteInner")
	local scroll = inner:Add("DR_MapVoteScrollPanel")
	local list = scroll:Add("DR_MapVoteListMapList")
	list.Maps = MapVote.MapList

	MapVote.AllMapsListList = list

	MapVote.RepopulateMapList()
end

function MapVote.RepopulateMapList()
	if not IsValid(MapVote.AllMapsListList) then return end

	local list = MapVote.AllMapsListList
	local maps = list.Maps

	list:Clear()

	list:AddLabel("Maps","Deathrun_Derma_Medium")
	list:AddLabel("Click on a map to see its options!","Deathrun_Derma_ExtraSmall")

	local inner = list:Add("DR_Inner")
	inner:SetSize(list:GetWide(),8)

	local curMap = game.GetMap()

	for _,map in ipairs(maps) do
		if map == curMap then continue end

		list:AddRow(map)
	end
end

-- actual voting menu place
function MapVote.OpenVotingPanel()
	local frame = vgui.Create("DR_MapVoteFrameVoting")
	local inner = frame:Add("DR_MenuInner")
	local list = inner:Add("DR_MapVoteListVoting")

	MapVote.VotingPanelDerma = frame
	MapVote.VotingPanelDermaList = list

	MapVote.RefreshVotingPanel()
end

function MapVote.RefreshVotingPanel()
	if not IsValid(MapVote.VotingPanelDermaList) then return end

	local list = MapVote.VotingPanelDermaList
	list:Clear()

	-- get the winning map
	local winner
	local winningVotes = 0

	for map,voteCount in pairs(VotingMapList) do
		if winningVotes >= voteCount then continue end

		winningVotes = voteCount
		winner = map
	end

	table.Empty(VotingMapsNoVotes)

	local num = 0

	for map,voteCount in pairs(VotingMapList) do
		num = num + 1

		VotingMapsNoVotes[#VotingMapsNoVotes + 1] = map

		list:AddRow(
			map,
			num,
			voteCount,
			map == winner
		)
	end
end

timer.Create("MapvoteCountdownTimer",.2,0,function()
	if not MapVote.Active then return end

	MapVote.TimeLeft = MapVote.TimeLeft - .2

	if IsValid(MapVote.VotingPanelDerma) then
		MapVote.VotingPanelDerma:SetTitle("Mapvote - " .. string.ToMinutesSeconds(MapVote.TimeLeft > 0 and MapVote.TimeLeft or 0))

		if MapVote.TimeLeft <= 0 then
			timer.Simple(4,function()
				if not IsValid(MapVote.VotingPanelDerma) then return end

				MapVote.VotingPanelDerma:Close()
			end)
		end
	end

	if MapVote.TimeLeft < 0 then
		MapVote.TimeLeft = 0
	end
end)

local KeyNums = {
	KEY_1,
	KEY_2,
	KEY_3,
	KEY_4,
	KEY_5,
	KEY_6,
	KEY_7,
	KEY_8,
	KEY_9,
	KEY_0,
}

hook.Add("SetupMove","MapvoteReceiveKeys",function()
	if not MapVote.Active then return end

	for idx = 1,#KeyNums do
		if not input.WasKeyPressed(KeyNums[idx]) then continue end

		RunConsoleCommand("mapvote_vote",VotingMapsNoVotes[idx])

		break
	end
end)

net.Receive("MapvoteUpdateMapList",function()
	table.CopyFromTo(net.ReadTable(),VotingMapList)

	MapVote.RefreshVotingPanel()
end)

net.Receive("MapvoteSetActive",function()
	local active = net.ReadBool()
	MapVote.Active = active

	local sourceTbl
	local newTime

	if active then
		sourceTbl = net.ReadTable()
		newTime = net.ReadFloat()
	else
		sourceTbl = {}
		newTime = -1
	end

	table.CopyFromTo(sourceTbl,VotingMapList)
	MapVote.TimeLeft = newTime

	if not active then return end

	MapVote.OpenVotingPanel()
	MapVote.RefreshVotingPanel()
end)

net.Receive("MapvoteSyncNominations",function()
	table.CopyFromTo(net.ReadTable(),Nominations)

	MapVote.RepopulateMapList()
end)

net.Receive("MapvoteSendAllMaps",function()
	table.CopyFromTo(net.ReadTable().maps,MapList)

	MapVote.OpenFullMapList()
end)
