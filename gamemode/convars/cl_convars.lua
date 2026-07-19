local ConVars = DR.ConVars

local DefaultFlags =
	FCVAR_NONE -- cleaner diffs for version control
+	FCVAR_ARCHIVE

ConVars.ShowZones = CreateConVar(
	"deathrun_zones_visibility",
	1,
	DefaultFlags,
	nil,
	0,
	1
)

ConVars.RoundCues = CreateConVar(
	"deathrun_round_cues",
	1,
	DefaultFlags,
	nil,
	0,
	1
)

ConVars.ShowInfo = CreateConVar(
	"deathrun_info_on_join",
	1,
	DefaultFlags,
	nil,
	0,
	1
)

ConVars.SmallScoreboard = CreateConVar(
	"deathrun_scoreboard_small",
	1,
	DefaultFlags,
	nil,
	0,
	1
)

ConVars.VisibleStats = CreateConVar(
	"deathrun_stats_visibility",
	1,
	DefaultFlags,
	nil,
	0,
	1
)

ConVars.SpectateOnly = CreateConVar(
	"deathrun_spectate_only",
	0,
	DefaultFlags,
	nil,
	0,
	1
)

-- AutoJump
local AutoJump = ConVars.AutoJump

AutoJump.Enabled = CreateConVar(
	"deathrun_autojump",
	1,
	DefaultFlags,
	nil,
	0,
	1
)

-- Announcements
local Announcements = ConVars.Announcements or {}
ConVars.Announcements = Announcements

Announcements.Enabled = CreateConVar(
	"deathrun_enable_announcements",
	1,
	DefaultFlags,
	nil,
	0,
	1
)

Announcements.Interval = CreateConVar(
	"deathrun_announcement_interval",
	300,
	DefaultFlags,
	nil,
	0,
	600
)

-- Crosshair
local Crosshair = ConVars.Crosshair or {}
ConVars.Crosshair = Crosshair

Crosshair.Size = CreateConVar(
	"deathrun_crosshair_size",
	8,
	DefaultFlags,
	nil,
	0,
	32
)

Crosshair.Thickness = CreateConVar(
	"deathrun_crosshair_thickness",
	2,
	DefaultFlags,
	nil,
	0,
	16
)

Crosshair.Gap = CreateConVar(
	"deathrun_crosshair_gap",
	8,
	DefaultFlags,
	nil,
	0,
	32
)

Crosshair.ColorR = CreateConVar(
	"deathrun_crosshair_red",
	255,
	DefaultFlags,
	nil,
	0,
	255
)

Crosshair.ColorG = CreateConVar(
	"deathrun_crosshair_green",
	255,
	DefaultFlags,
	nil,
	0,
	255
)

Crosshair.ColorB = CreateConVar(
	"deathrun_crosshair_blue",
	255,
	DefaultFlags,
	nil,
	0,
	255
)

Crosshair.ColorA = CreateConVar(
	"deathrun_crosshair_alpha",
	255,
	DefaultFlags,
	nil,
	0,
	255
)

-- Hud
local Hud = ConVars.Hud or {}
ConVars.Hud = Hud

Hud.Theme = CreateConVar(
	"deathrun_hud_theme",
	1,
	DefaultFlags,
	nil,
	1
)

Hud.Alpha = CreateConVar(
	"deathrun_hud_alpha",
	255,
	DefaultFlags,
	nil,
	0,
	255
)

Hud.PosMain = CreateConVar(
	"deathrun_hud_main_pos",
	7,
	DefaultFlags,
	nil,
	1,
	9
)

Hud.PosAmmo = CreateConVar(
	"deathrun_hud_ammo_pos",
	9,
	DefaultFlags,
	nil,
	1,
	9
)

Hud.TargetIdFadeTime = CreateConVar(
	"deathrun_targetid_fade_duration",
	1,
	DefaultFlags,
	nil,
	0,
	10
)

Hud.Vhs7Mode = CreateConVar(
	"deathrun_vhs7",
	0,
	FCVAR_NONE,
	nil,
	0,
	1
)

-- ThirdPerson
local ThirdPerson = ConVars.ThirdPerson or {}
ConVars.ThirdPerson = ThirdPerson

ThirdPerson.Enabled = CreateConVar(
	"deathrun_thirdperson_enabled",
	0,
	DefaultFlags,
	nil,
	0,
	1
)

ThirdPerson.OffsetX = CreateConVar(
	"deathrun_thirdperson_offset_x",
	0,
	DefaultFlags,
	nil,
	-40,
	40
)

ThirdPerson.OffsetY = CreateConVar(
	"deathrun_thirdperson_offset_y",
	0,
	DefaultFlags,
	nil,
	-40,
	40
)

ThirdPerson.OffsetZ = CreateConVar(
	"deathrun_thirdperson_offset_z",
	0,
	DefaultFlags,
	nil,
	-75,
	75
)

ThirdPerson.OffsetRoll = CreateConVar(
	"deathrun_thirdperson_offset_roll",
	0,
	DefaultFlags,
	nil,
	-75,
	75
)

ThirdPerson.OffsetPitch = CreateConVar(
	"deathrun_thirdperson_offset_pitch",
	0,
	DefaultFlags,
	nil,
	-75,
	75
)

ThirdPerson.OffsetYaw = CreateConVar(
	"deathrun_thirdperson_offset_yaw",
	0,
	DefaultFlags,
	nil,
	-75,
	75
)

ThirdPerson.Opacity = CreateConVar(
	"deathrun_thirdperson_opacity",
	255,
	DefaultFlags,
	nil,
	5,
	255
)

ThirdPerson.FadeDistance = CreateConVar(
	"deathrun_teammate_fade_distance",
	75,
	DefaultFlags,
	nil,
	0,
	512
)
