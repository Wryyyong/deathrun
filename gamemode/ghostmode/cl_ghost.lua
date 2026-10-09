local ipairs = ipairs({})
local pairs = next

local DrawColorModify = DrawColorModify
local FrameTime = FrameTime
local Lerp = Lerp

local ChatAddText = chat.AddText

local DrawSimpleText = draw.SimpleText

local HookAdd = hook.Add
local HookRemove = hook.Remove

local NetReadBool = net.ReadBool

local SurfaceDrawRect = surface.DrawRect
local SurfaceSetDrawColor = surface.SetDrawColor

local TableRemove = table.remove

local TimerCreate = timer.Create
local TimerRemove = timer.Remove

local Notifications = DR.GhostMode.Notifications

local CvAutoGhostMode = DR.ConVars.AutoGhostMode

local ColorMod = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1.2,
	["$pp_colour_colour"] = 0.6,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0,
}

local ChatColor = Color(255,200,0)

local function HandleCustomGhostScreenEffects()
	DrawColorModify(ColorMod)
end

local NotifWidth = 144
local NotifWidthHalf = NotifWidth * .5

local NotifColorCache = Color(75,75,75)

local NotifsToRemove = {}

local function HandleNotifications()
	if #Notifications <= 0 then return end

	local height = DR.ScreenHeight
	local heightMinus64 = height - 64

	local frameTime = FrameTime()
	local frameTimeDoubled = frameTime * 2

	local x = DR.ScreenWidth * .5
	local xMinusWidthHalf = x - NotifWidthHalf

	for idx,notif in ipairs,Notifications,0 do
		if notif.Time < 0 then
			NotifsToRemove[idx] = true

			continue
		end

		local time = notif.Time - frameTime
		local heightMod = Lerp(
			frameTimeDoubled,
			notif.PosY or height,
			heightMinus64 - (idx + 1) * 32
		)

		local alphaMul = time / 3

		NotifColorCache.a = 255 * alphaMul

		SurfaceSetDrawColor(255,255,255,150 * alphaMul)
		SurfaceDrawRect(
			xMinusWidthHalf,
			heightMod,
			NotifWidth,
			24
		)
		DrawSimpleText(
			notif.Text,
			"Default",
			x,
			heightMod + 4,
			NotifColorCache,
			TEXT_ALIGN_CENTER
		)

		notif.PosY = heightMod
		notif.Time = time
	end

	for idx in pairs,NotifsToRemove do
		TableRemove(Notifications,idx)
		NotifsToRemove[idx] = nil
	end
end

local function AutoGhostModeFunc()
	RunConsoleCommand("say","!ghost")
end

net.Receive("GhostModeSendNotif",function()
	if CvAutoGhostMode:GetBool() then
		TimerCreate("AutoGhostModeTimer",3,1,AutoGhostModeFunc)

		return
	end

	ChatAddText(
		ChatColor,
		[[Type !ghost in chat to continue practicing your movement in peace while waiting for the next round.]]
	)
end)

net.Receive("GhostModeSendStart",function()
	TimerRemove("AutoGhostModeTimer")

	HookAdd("RenderScreenspaceEffects","HandleCustomGhostScreenEffects",HandleCustomGhostScreenEffects)
	HookAdd("HUDPaint","HandleNotifications",HandleNotifications)

	ChatAddText(
		ChatColor,
[[You have entered Ghost Mode.
Left-Click to save your current location.
Right-Click to return to your saved location.
Type !ghost again to exit Ghost Mode.
]]
	)
end)

net.Receive("GhostModeSendEnd",function()
	TimerRemove("AutoGhostModeTimer")

	HookRemove("RenderScreenspaceEffects","HandleCustomGhostScreenEffects")
	HookRemove("HUDPaint","HandleNotifications")

	if not NetReadBool() then return end

	ChatAddText(
		ChatColor,
[[You are no longer in Ghost Mode.]]
	)
end)
