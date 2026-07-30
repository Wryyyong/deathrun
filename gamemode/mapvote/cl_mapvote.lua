MV.Active = MV.Active or false

--- @type string[]
local MapList = MV.MapList or {}
MV.MapList = MapList

--- @type table<string,integer>
local VotingMapList = MV.VotingMapList or {}
MV.VotingMapList = VotingMapList

--- @type string[]
local VotingMapsNoVotes = MV.VotingMapsNoVotes or {}
MV.VotingMapsNoVotes = VotingMapsNoVotes

local Nominations = MV.Nominations or {}
MV.Nominations = Nominations

function MV.IsMapNominated(mapname)
	return table.HasValue(Nominations,mapname)
end

function MV.OpenFullMapList()
	local frame = vgui.Create("DR_MapVoteMapListFrame")
	local inner = frame:Add("DR_MapVoteInner")
	local scroll = inner:Add("DR_MapVoteScrollPanel")
	local list = scroll:Add("DR_MapVoteListMapList")
	list.Maps = MV.MapList

	MV.AllMapsListList = list

	MV.RepopulateMapList()
end

function MV.RepopulateMapList()
	if not IsValid(MV.AllMapsListList) then return end

	local list = MV.AllMapsListList
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
function MV.OpenVotingPanel()
	local frame = vgui.Create("DR_MapVoteFrameVoting")
	local inner = frame:Add("DR_MenuInner")
	local list = inner:Add("DR_MapVoteListVoting")

	MV.VotingPanelDerma = frame
	MV.VotingPanelDermaList = list

	MV.RefreshVotingPanel()
end

function MV.RefreshVotingPanel()
	if not IsValid(MV.VotingPanelDermaList) then return end

	local list = MV.VotingPanelDermaList
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
	if not MV.Active then return end

	MV.TimeLeft = MV.TimeLeft - .2

	if IsValid(MV.VotingPanelDerma) then
		MV.VotingPanelDerma:SetTitle("Mapvote - " .. string.ToMinutesSeconds(MV.TimeLeft > 0 and MV.TimeLeft or 0))

		if MV.TimeLeft <= 0 then
			timer.Simple(4,function()
				if not IsValid(MV.VotingPanelDerma) then return end

				MV.VotingPanelDerma:Close()
			end)
		end
	end

	if MV.TimeLeft < 0 then
		MV.TimeLeft = 0
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
	if not MV.Active then return end

	for idx = 1,#KeyNums do
		if not input.WasKeyPressed(KeyNums[idx]) then continue end

		RunConsoleCommand("mapvote_vote",VotingMapsNoVotes[idx])

		break
	end
end)

net.Receive("MapvoteUpdateMapList",function()
	table.CopyFromTo(net.ReadTable(),VotingMapList)

	MV.RefreshVotingPanel()
end)

net.Receive("MapvoteSetActive",function()
	local active = net.ReadBool()
	MV.Active = active

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
	MV.TimeLeft = newTime

	if not active then return end

	MV.OpenVotingPanel()
	MV.RefreshVotingPanel()
end)

net.Receive("MapvoteSyncNominations",function()
	table.CopyFromTo(net.ReadTable(),Nominations)

	MV.RepopulateMapList()
end)

net.Receive("MapvoteSendAllMaps",function()
	table.CopyFromTo(net.ReadTable().maps,MapList)

	MV.OpenFullMapList()
end)
