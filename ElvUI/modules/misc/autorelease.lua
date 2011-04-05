--------------------------------------------------------------------------
-- Auto-Release when dead in Battleground.
--------------------------------------------------------------------------

local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["others"].pvpautorelease ~= true then return end

local autoreleasepvp = CreateFrame("frame")
autoreleasepvp:RegisterEvent("PLAYER_DEAD")
autoreleasepvp:SetScript("OnEvent", function(self, event)
	local inInstance, instanceType = IsInInstance()
	if (inInstance and (instanceType == "pvp")) then
		local soulstone = GetSpellInfo(20707)
		if ((E.myclass ~= "SHAMAN") and not (soulstone and UnitBuff("player", soulstone))) then
			RepopMe()
		end
	end
	
	-- auto resurrection for world PvP area...when active
	for index = 1, GetNumWorldPVPAreas() do
		local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(index)
		
		if (GetRealZoneText() == localizedName and isActive) then
			RepopMe()
		end
	end
end)