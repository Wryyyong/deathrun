local Iterator = ipairs({})

local IsValid = IsValid
local RunConsoleCommand = RunConsoleCommand

local GameGetMap = game.GetMap

local InputWasKeyPressed = input.WasKeyPressed

local NetReadBool = net.ReadBool
local NetReadFloat = net.ReadFloat
local NetReadTable = net.ReadTable

local StringToMinutesSeconds = string.ToMinutesSeconds

local TableCopyFromTo = table.CopyFromTo
local TableEmpty = table.Empty
local TableHasValue = table.HasValue

local TimerSimple = timer.Simple

local VguiCreate = vgui.Create

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
	return TableHasValue(Nominations,mapname)
end

function MapVote.OpenFullMapList()
	local frame = VguiCreate("DR_MapVoteMapListFrame")
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

	local curMap = GameGetMap()

	for _,map in Iterator,maps,0 do
		if map == curMap then continue end

		list:AddRow(map)
	end
end

-- actual voting menu place
function MapVote.OpenVotingPanel()
	local frame = VguiCreate("DR_MapVoteFrameVoting")
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

	for map,voteCount in next,VotingMapList do
		if winningVotes >= voteCount then continue end

		winningVotes = voteCount
		winner = map
	end

	TableEmpty(VotingMapsNoVotes)

	local num = 0

	for map,voteCount in next,VotingMapList do
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
		MapVote.VotingPanelDerma:SetTitle("Mapvote - " .. StringToMinutesSeconds(MapVote.TimeLeft > 0 and MapVote.TimeLeft or 0))

		if MapVote.TimeLeft <= 0 then
			TimerSimple(4,function()
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
		if not InputWasKeyPressed(KeyNums[idx]) then continue end

		RunConsoleCommand("mapvote_vote",VotingMapsNoVotes[idx])

		break
	end
end)

net.Receive("MapvoteUpdateMapList",function()
	TableCopyFromTo(NetReadTable(),VotingMapList)

	MapVote.RefreshVotingPanel()
end)

net.Receive("MapvoteSetActive",function()
	local active = NetReadBool()
	MapVote.Active = active

	local sourceTbl
	local newTime

	if active then
		sourceTbl = NetReadTable()
		newTime = NetReadFloat()
	else
		sourceTbl = {}
		newTime = -1
	end

	TableCopyFromTo(sourceTbl,VotingMapList)
	MapVote.TimeLeft = newTime

	if not active then return end

	MapVote.OpenVotingPanel()
	MapVote.RefreshVotingPanel()
end)

net.Receive("MapvoteSyncNominations",function()
	TableCopyFromTo(NetReadTable(),Nominations)

	MapVote.RepopulateMapList()
end)

net.Receive("MapvoteSendAllMaps",function()
	TableCopyFromTo(NetReadTable().maps,MapList)

	MapVote.OpenFullMapList()
end)
