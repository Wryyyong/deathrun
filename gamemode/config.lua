DR.Colors = {
	["GhostTeam"] = Color(255,204,0),
	["DeathTeam"] = Color(242,108,79),
	["RunnerTeam"] = Color(58,137,201),
	["Clouds"] = Color(233,242,249),
	["Silver"] = Color(189,195,199),
	["Concrete"] = Color(149,165,166),
	["Alizarin"] = Color(231,76,60),
	["Peter"] = Color(52,152,219),
	["Turq"] = Color(26,188,156),
	["TurqDark"] = Color(211,84,0),
	["DarkBlue"] = Color(27,50,95),
	["LightBlue"] = Color(156,196,228),
	["Sunflower"] = Color(241,196,15),
	["Orange"] = Color(243,156,18),
	["Grey"] = Color(48,48,48),
	["LightGrey"] = Color(144,144,144),
	["DarkGrey"] = Color(16,16,16),

	["Derma"] = {
		["Bad"] = Color(231,76,60),
		["BadDark"] = Color(192,57,43),
		["Good"] = Color(46,204,113),
		["GoodDark"] = Color(39,174,96),
		["NeutralHigh"] = Color(236,240,241),
		["NeutralMed"] = Color(189,195,199),
		["NeutralLow"] = Color(149,165,166),
		["NeutralDark"] = Color(127,140,141),
	},
}

-- access levels
-- 1 = user, 2 = moderator, 3 = admin
-- 2 will inherit from 1, 3 will inherit from 2
-- to access a command, player must have access level >= permission level
-- ranks are case sensitive, Admin /= admin
DR.Ranks = {
	["user"] = 1,
	["regular"] = 1,
	["moderator"] = 2,
	["mod"] = 2,
	["admin"] = 3,
	["superadmin"] = 3,
	["owner"] = 3,
}

DR.PlayerAccess = {}

-- permission levels
DR.Permissions = {
	["deathrun_respawn"] = 3,
	["deathrun_cleanup"] = 3,
	["deathrun_open_zone_editor"] = 3,
	["deathrun_unstuck"] = 1, -- edit this to change unstuck permissions
	["deathrun_punish"] = 2,
	["zone_create"] = 3,
	["zone_remove"] = 3,
	["zone_setpos"] = 3,
	["zone_setcolor"] = 3,
	["zone_settype"] = 3,
	["deathrun_force_spectate"] = 2,

	-- mapvote
	["mapvote_list_maps"] = 1,
	["mapvote_begin_mapvote"] = 3,
	["mapvote_vote"] = 1,
	["mapvote_nominate_map"] = 1,
	["mapvote_update_mapvote"] = 3, -- debug tool
	["mapvote_rtv"] = 1,
}
