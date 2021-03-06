--------------------------------------------------------------------------
-- Auto-Change reputation bar when standing changes.
--------------------------------------------------------------------------
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

-- only available at max player level (the bar will Show XP otherwise)
if E.level ~= MAX_PLAYER_LEVEL or C["unitframes"].autorepchange ~= true then end

local find				= string.find
local gsub				= string.gsub
local incpat 			= gsub(gsub(FACTION_STANDING_INCREASED, "(%%s)", "(.+)"), "(%%d)", "(.+)")
local changedpat	= gsub(gsub(FACTION_STANDING_CHANGED, "(%%s)", "(.+)"), "(%%d)", "(.+)")
local decpat			= gsub(gsub(FACTION_STANDING_DECREASED, "(%%s)", "(.+)"), "(%%d)", "(.+)")

local autorepchange  = CreateFrame("frame")
autorepchange:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

function autorepchange:CHAT_MSG_COMBAT_FACTION_CHANGE(event, arg1)
	local _, _, faction, amount = find(arg1, incpat)
	if not faction then _, _, faction, amount = find(arg1, changedpat) or find(arg1, decpat) end
	if faction then
		if faction == GUILD_REPUTATION then
			faction = GetGuildInfo("player")
		end

		-- required for the GetNumFactions() function to return all factions in the game
		ExpandAllFactionHeaders()
	
		local active = GetWatchedFactionInfo()
		for factionIndex = 1, GetNumFactions() do
			local name = GetFactionInfo(factionIndex)
			if name == faction and name ~= active then
				-- check if watch has been disabled by user
				local inactive = IsFactionInactive(factionIndex)
				if inactive == nil then
					SetWatchedFactionIndex(factionIndex)
				end
				return
			end
		end
	end
end

autorepchange:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")