local MapVote = DR.MapVote

MapVote.MaxMaps = 5 -- maximum number of maps on the mapvote when synced
MapVote.VotingTime = 20 -- how many seconds the player has to vote

MapVote.Filter = { -- map names need to start with these in order to be valid
	"deathrun_",
	"dr_",
}
