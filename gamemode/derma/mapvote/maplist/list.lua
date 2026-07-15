local DR = DR

local Colors = DR.Colors
local MapVote = DR.MapVote

local ColorGrey = Colors.Grey
local ColorTurq = Colors.Turq

--- @class DR_MapVoteListMapList : DR_MapVoteListBase
local DR_MapVoteListMapList = {
	["ButtonClass"] = "DR_MapVoteButtonMapList",
}

--- @param map string
function DR_MapVoteListMapList:AddRow(map)
	local row = self:Add("DR_MapVoteRowBase")
	row.MapName = map

	local isNominated = MapVote.IsMapNominated(map)

	row.LabelColor =
		isNominated
	and	ColorTurq
	or	ColorGrey

	local columns = row.Columns
	columns[1] = map or "Error"
	columns[2] =
		isNominated
	and	"[NOMINATED]"
	or	""

	return self:FinishRow(row)
end

derma.DefineControl("DR_MapVoteListMapList","",DR_MapVoteListMapList,"DR_MapVoteListBase")
