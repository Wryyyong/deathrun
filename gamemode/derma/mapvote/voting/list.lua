local Colors = DR.Colors
local ColorClouds = Colors.Clouds
local ColorTurq = Colors.Turq

--- @class DR_MapVoteListVoting : DR_MapVoteListBase
local DR_MapVoteListVoting = {
	["ButtonClass"] = "DR_MapVoteButtonVoting",
}

--- @param map string
--- @param num integer
--- @param voteCount integer
--- @param isWinner boolean
function DR_MapVoteListVoting:AddRow(map,num,voteCount,isWinner)
	local row = self:Add("DR_MapVoteRowVoting")
	row.MapName = map

	row.CustomColor =
		isWinner
	and	ColorTurq
	or	ColorClouds

	row.LabelColor =
		isWinner
	and	ColorClouds
	or	ColorTurq

	local columns = row.Columns
	columns[1] = num .. ". "
	columns[2] = map
	columns[3] = voteCount

	return self:FinishRow(row)
end

derma.DefineControl("DR_MapVoteListVoting","",DR_MapVoteListVoting,"DR_MapVoteListBase")
