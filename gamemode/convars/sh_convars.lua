local DR = DR

local ConVars = DR.ConVars or {}
DR.ConVars = ConVars

local DefaultFlags =
	FCVAR_NONE -- cleaner diffs for version control
+	FCVAR_ARCHIVE
+	FCVAR_NOTIFY
+	FCVAR_REPLICATED
+	FCVAR_SERVER_CAN_EXECUTE

ConVars.RoundDuration = CreateConVar(
	"deathrun_round_duration",
	300,
	DefaultFlags,
	"How many seconds each round should last, not including preptime.",
	0
)

ConVars.PrepDuration = CreateConVar(
	"deathrun_preptime_duration",
	5,
	DefaultFlags,
	"How many seconds preptime should go for.",
	0
)

ConVars.FinishDuration = CreateConVar(
	"deathrun_finishtime_duration",
	10,
	DefaultFlags,
	"How many seconds to wait before starting a new round.",
	0
)

ConVars.DeathRatio = CreateConVar(
	"deathrun_death_ratio",
	.15,
	DefaultFlags,
	"What fraction of players are Deaths.",
	0,
	1
)

ConVars.RoundLimit = CreateConVar(
	"deathrun_round_limit",
	6,
	DefaultFlags,
	"How many rounds to play before changing the map.",
	0
)

ConVars.DeathAvoidPunishment = CreateConVar(
	"deathrun_death_avoid_punishment",
	1,
	DefaultFlags,
	"How many round should a player sit out after they attempt to death avoid?",
	0
)

ConVars.DeathMax = CreateConVar(
	"deathrun_max_deaths",
	64,
	DefaultFlags,
	"Maximum amount of players on the Death team at any given time.",
	0
)

ConVars.AutoslayDelay = CreateConVar(
	"deathrun_autoslay_delay",
	90,
	DefaultFlags,
	"How long to wait after a start of a round before slaying all the AFKs.",
	0
)

ConVars.FinishBalloons = CreateConVar(
	"deathrun_finish_balloons",
	12,
	DefaultFlags,
	"How many balloons to spawn when the player finishes the map?",
	0
)

ConVars.InfiniteAmmo = CreateConVar(
	"deathrun_infinite_ammo",
	1,
	DefaultFlags,
	"Should ammo automatically replenish.",

	0,
	1
)

ConVars.UnstuckCooldown = CreateConVar(
	"deathrun_unstuck_cooldown",
	30,
	DefaultFlags,
	"Set the cooldown timer for when a player uses !stuck or takes damage, forcing them to wait that time until their next !stuck command.",
	0
)

ConVars.HelpURL = CreateConVar(
	"deathrun_help_url",
	"https://github.com/Arizard/deathrun/blob/master/help.md",
	DefaultFlags,
	"The URL to open when the player types !help."
)

-- AutoJump
local AutoJump = ConVars.AutoJump or {}
ConVars.AutoJump = AutoJump

AutoJump.Allow = CreateConVar(
	"deathrun_allow_autojump",
	1,
	DefaultFlags,
	"Allows players to use autojump.",
	0,
	1
)

AutoJump.VelocityCap = CreateConVar(
	"deathrun_autojump_velocity_cap",
	0,
	DefaultFlags,
	"The amount to limit players speed to when they use autojump. For game balance. 0 = unlimited",
	0
)

-- MotD
local MotD = ConVars.MotD or {}
ConVars.MotD = MotD

MotD.Enabled = CreateConVar(
	"deathrun_motd_enabled",
	1,
	DefaultFlags,
	"Enable the MOTD to display on all players when they join?",
	0,
	1
)

MotD.Title = CreateConVar(
	"deathrun_motd_title",
	"Deathrun Information",
	DefaultFlags,
	"The title of the MOTD (i.e. Deathrun Information, !info)"
)

MotD.URL = CreateConVar(
	"deathrun_motd_url",
	"http://arizard.github.io/deathruninfo.html",
	DefaultFlags,
	"Sets the MOTD url (i.e. Deathrun Information, !info)"
)

-- PointShop
local PointShop = ConVars.PointShop or {}
ConVars.PointShop = PointShop

PointShop.FinishReward = CreateConVar(
	"deathrun_pointshop_finish_reward",
	10,
	DefaultFlags,
	"How many points to award the player when he finishes the map.",
	0
)

PointShop.KillReward = CreateConVar(
	"deathrun_pointshop_kill_reward",
	5,
	DefaultFlags,
	"How many points to award the player when they kill another player.",
	0
)

PointShop.WinReward = CreateConVar(
	"deathrun_pointshop_win_reward",
	3,
	DefaultFlags,
	"How many points to award the player when their team wins.",
	0
)

PointShop.RewardMessage = CreateConVar(
	"deathrun_pointshop_notify",
	1,
	DefaultFlags,
	"Enable chat messages or notifications when rewards are received - does not work for PS2",
	0,
	1
)
