--- @class DR_ScoreboardPlayerMenuOptionULXBase : DR_ScoreboardPlayerMenuOptionBase
local DR_ScoreboardPlayerMenuOptionULXBase = {
	["Command"] = "",
}

function DR_ScoreboardPlayerMenuOptionULXBase:RefreshSettings()
	DR_ScoreboardPlayerMenuOptionBase.RefreshSettings(self)

	local command = self.Command
	if #command == 0 then return end

	if not ULib.ucl.query(LocalPlayer(),"ulx " .. command,true) then
		self:Remove()

		return
	end
end

derma.DefineControl("DR_ScoreboardPlayerMenuOptionULXBase","",DR_ScoreboardPlayerMenuOptionULXBase,"DR_ScoreboardPlayerMenuOptionBase")
