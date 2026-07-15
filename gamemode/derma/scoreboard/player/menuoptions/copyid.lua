local PlyMeta = FindMetaTable("Player")

--- @class DR_ScoreboardPlayerMenuOptionCopyId : DR_ScoreboardPlayerMenuOptionBase
local DR_ScoreboardPlayerMenuOptionCopyId = {
	["IconPath"] = "icon16/page_copy.png",
	["Caption"] = "Copy SteamID to clipboard",
	["SteamIDFunc"] = PlyMeta.SteamID,
	["MessageAppend"] = "",
}

function DR_ScoreboardPlayerMenuOptionCopyId:Init()
	self:RefreshSettings()
end

function DR_ScoreboardPlayerMenuOptionCopyId:ValidClick()
	local player = self.Player

	SetClipboardText(self.SteamIDFunc(player))

	DR.ChatMessage(player:Nick() .. "'s SteamID" .. self.MessageAppend .. " was copied to the clipboard!")
end

--- @class DR_ScoreboardPlayerMenuOptionCopyId64 : DR_ScoreboardPlayerMenuOptionCopyId
local DR_ScoreboardPlayerMenuOptionCopyId64 = {
	["Caption"] = "Copy SteamID64 to clipboard",
	["SteamIDFunc"] = PlyMeta.SteamID64,
	["MessageAppend"] = "64",
}

function DR_ScoreboardPlayerMenuOptionCopyId64:Init()
	self:RefreshSettings()
end

derma.DefineControl("DR_ScoreboardPlayerMenuOptionCopyId","",DR_ScoreboardPlayerMenuOptionCopyId,"DR_ScoreboardPlayerMenuOptionBase")

derma.DefineControl("DR_ScoreboardPlayerMenuOptionCopyId64","",DR_ScoreboardPlayerMenuOptionCopyId64,"DR_ScoreboardPlayerMenuOptionCopyId")
