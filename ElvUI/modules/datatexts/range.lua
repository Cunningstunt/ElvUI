--------------------------------------------------------------------
-- RANGE DISPLAY DATATEXT ON TARGET
--------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
	
if not C["datatext"].range or C["datatext"].range == 0 then return end

-- LibMapData-1.0 for zone sizes
local rc = LibStub("LibRangeCheck-2.0")
local displayString = string.join("", RANGED, ": ", E.ValColor, "%d|r - ", E.ValColor, "%d|r")
local curMin, curMax

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)
Stat:SetFrameStrata("BACKGROUND")
Stat:SetFrameLevel(3)

local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
Text:SetShadowColor(0, 0, 0, 0.4)
E.PP(C["datatext"].range, Text)

local int = 1

local function Update(self, t)
	int = int - t
	if int > 0 then return end
	int = .25
	
	local min, max = rc:GetRange('target')
	if (min == curMin and max == curMax) then return end
	
	curMin = min
	curMax = max
	
	if min and max then
		Text:SetFormattedText(displayString, min, max)
	else
		Text:SetText("")
	end
end

Stat:SetScript("OnUpdate", Update)