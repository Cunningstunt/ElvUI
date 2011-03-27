--------------------------------------------------------------------
-- DIRECTION ARROW TO TARGET (PARTY / RAIDMEMBER)
--------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["unitframes"].enable then return end

if (not C["unitframes"].targetgps or C["unitframes"].targetgps ~= true) 
	and (not C["unitframes"].focusgps or C["unitframes"].focusgps ~= true) then return end

local function OnUnitFramesLoad(self, event, addon)
	if not (addon == "ElvUI_RaidDPS" or addon == "ElvUI_RaidHeal") then return end

	self:UnregisterEvent("ADDON_LOADED")

	-- LibMapData-1.0 for zone sizes
	local mapfiles = LibStub("LibMapData-1.0")
	local s2 = math.sqrt(2)
	local getMapPosition = GetPlayerMapPosition
	local inParty = UnitInParty
	local inRaid = UnitInRaid
	local atan2 = math.atan2
	local sin = math.sin
	local cos = math.cos
	local mapfile

	local function GetBearing(unit)
	  local tx, ty = getMapPosition(unit)
	  if tx == 0 and ty == 0 then
	    return 999
	  end
	  local px, py = getMapPosition("player")
	  return -GetPlayerFacing() - atan2(tx - px, py - ty), px, py, tx, ty
	end

	local function CalculateCorner(r)
		return 0.5 + cos(r) / s2, 0.5 + sin(r) / s2;
	end

	local function RotateTexture(texture, angle)
		local LRx, LRy = CalculateCorner(angle + 0.785398163);
		local LLx, LLy = CalculateCorner(angle + 2.35619449);
		local ULx, ULy = CalculateCorner(angle + 3.92699082);
		local URx, URy = CalculateCorner(angle - 0.785398163);
		
		texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
	end
	
	local function SetupGpsFrame(type, parent, unit, point, relative, xoffset, yoffset)
		type:SetTemplate("Default")
		type:SetParent(parent)
		type:EnableMouse(false)
		type:SetFrameStrata("MEDIUM")
		type:SetFrameLevel(3)
	  type:SetWidth(E.Scale(44))
	  type:SetHeight(E.Scale(14))
	  type:SetAlpha(.9)
		type:SetPoint(point, parent, relative, xoffset, yoffset)
	  type:Show()
	  
	  type.unit = unit
	  type.parent = parent
	  
	  type.texture = type:CreateTexture("OVERLAY")
	  type.texture:SetTexture(C["media"].arrow)
	  type.texture:SetBlendMode("BLEND")
	  type.texture:SetAlpha(.9)
	  type.texture:SetWidth(E.Scale(12))
	  type.texture:SetHeight(E.Scale(12))
	  type.texture:SetPoint("LEFT", type, "LEFT", E.mult, 0)

		type.text = type:CreateFontString(nil, "OVERLAY")
		type.text:SetFont(C.media.font, 10, "THINOUTLINE")
		type.text:SetShadowOffset(E.mult, -E.mult)
		type.text:SetPoint("RIGHT", type, "RIGHT", 0 , 0)
	end
			
	local function UpdateGps(type)
		local angle, px, py, tx, ty = GetBearing(type.unit)
		if angle == 999 then
			if type.parent:IsVisible() and (inParty(type.unit) or inRaid(type.unit)) then
				-- we have a unit type that is in raid / party, but no bearing show ??? to indicate we are lost :)
    		type.text:SetText("???")
				type.texture:Hide()
				type:Show()
			else
				-- no focus or target
				type:Hide()
			end
			return 
		end
	  RotateTexture(type.texture, angle)
    type.texture:Show()
	
		local distance = mapfiles:Distance(mapfile, 0, px, py, tx, ty)
    type.text:SetFormattedText("%d", distance)
		type:Show()
	end
	
	local int = .1
	function Update(self, t)
		int = int - t
		if int > 0 then return end
		
		if self.targetgps then UpdateGps(self.targetgps) end
		if self.focusgps then UpdateGps(self.focusgps) end
		int = .1
	end
	
	mapfiles:RegisterCallback("MapChanged", function (event, map, floor, w, h)
		mapfile = map
	end)
	
	local updateframe = CreateFrame("Frame")
	if (addon == "ElvUI_RaidDPS") then
		updateframe.parenttarget = ElvDPS_target
		updateframe.parentfocus = ElvDPS_focus
	else
		updateframe.parenttarget = ElvHeal_target
		updateframe.parentfocus = ElvHeal_focus
	end
					
	if C["unitframes"].targetgps then
		updateframe.targetgps = CreateFrame("Frame", nil, updateframe)
		SetupGpsFrame(updateframe.targetgps, updateframe.parenttarget, "target", "BOTTOMRIGHT", "BOTTOMRIGHT", C["unitframes"].charportrait and E.Scale(-47) or E.Scale(-2), E.Scale(12))
	end
	
	if C["unitframes"].focusgps then
		updateframe.focusgps = CreateFrame("Frame", nil, updateframe)
		SetupGpsFrame(updateframe.focusgps, updateframe.parentfocus, "focus", "LEFT", "RIGHT", E.Scale(2), E.Scale(0))
	end
	
	updateframe:SetScript("OnUpdate", Update)
end	

--We need to load gps frames after our UnitFrames load..
local directionLoader = CreateFrame("Frame")
directionLoader:RegisterEvent("ADDON_LOADED")
directionLoader:SetScript("OnEvent", OnUnitFramesLoad)
