local SurfacePlaySound = surface.PlaySound

local CvPlayRoundCues = DR.ConVars.PlayRoundCues

sound.Add({
	["name"] = "Deathrun.RoundStart",
	["sound"] = "ui/achievement_earned.wav",
	["channel"] = CHAN_AUTO,
	["level"] = SNDLVL_NORM,
})

function ROUNDSTATE:EnterRealm()
	if not CvPlayRoundCues:GetBool() then return end

	SurfacePlaySound("Deathrun.RoundStart")
end
