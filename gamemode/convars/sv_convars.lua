local ConVars = DR.ConVars

local DefaultFlags =
	FCVAR_NONE -- cleaner diffs for version control
+	FCVAR_ARCHIVE
+	FCVAR_NOTIFY
+	FCVAR_SERVER_CAN_EXECUTE

ConVars.DeathModel = CreateConVar(
	"deathrun_death_model",
	"models/player/monk.mdl",
	DefaultFlags,
	"The default model for the Deaths."
)

ConVars.DropWeaponsOnDeath = CreateConVar(
	"deathrun_drop_weapons_on_death",
	1,
	DefaultFlags,
	"Should players drop weapons on death?",
	0,
	1
)

ConVars.DeathSprint = CreateConVar(
	"deathrun_death_sprint",
	650,
	DefaultFlags,
	"Sprint speed for Death team.",
	0
)

ConVars.StartingWeapon = CreateConVar(
	"deathrun_starting_weapon",
	"weapon_crowbar",
	DefaultFlags,
	"Starting weapon for both teams."
)

ConVars.AllTalk = CreateConVar(
	"deathrun_alltalk",
	1,
	DefaultFlags,
	"Enable alltalk - 1 for enabled, 0 to stop living players from hearing dead players.",
	0,
	1
)

ConVars.IdleTimer = CreateConVar(
	"deathrun_idle_kick_time",
	60,
	DefaultFlags,
	"How many seconds each to wait before speccing idle players.",
	0
)

ConVars.DrownTimer = CreateConVar(
	"deathrun_drown_time",
	20,
	DefaultFlags,
	"How long can a player stay submerged before drowning?",
	0
)

ConVars.DisableDefaultDeathSpeed = CreateConVar(
	"deathrun_disable_default_deathspeed",
	0,
	DefaultFlags,
	"Removes the player_speedmod entities from maps to disable the default deathspeed.",
	0,
	1
)

ConVars.MapVoteRTVRatio = CreateConVar(
	"deathrun_mapvote_rtv_ratio",
	.5,
	DefaultFlags,
	"The ratio between votes and players in order to initiate a mapvote.",
	0,
	1
)
