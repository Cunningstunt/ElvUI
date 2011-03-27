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
	
	local function SetupGpsFrame(frame, parent, unit, point, relative, xoffset, yoffset)
		frame:SetTemplate("Default")
		frame:SetParent(parent)
		frame:EnableMouse(false)
		frame:SetFrameStrata("MEDIUM")
		frame:SetFrameLevel(3)
	  frame:SetWidth(E.Scale(44))
	  frame:SetHeight(E.Scale(14))
	  frame:SetAlpha(.9)
		frame:SetPoint(point, parent, relative, xoffset, yoffset)
	  frame:Show()
	  
	  frame.unit = unit
	  frame.parent = parent
	  
	  frame.texture = frame:CreateTexture("OVERLAY")
	  frame.texture:SetTexture(C["media"].arrow)
	  frame.texture:SetBlendMode("BLEND")
	  frame.texture:SetAlpha(.9)
	  frame.texture:SetWidth(E.Scale(12))
	  frame.texture:SetHeight(E.Scale(12))
	  frame.texture:SetPoint("LEFT", frame, "LEFT", E.mult, 0)

		frame.text = frame:CreateFontString(nil, "OVERLAY")
		frame.text:SetFont(C.media.font, 10, "THINOUTLINE")
		frame.text:SetShadowOffset(E.mult, -E.mult)
		frame.text:SetPoint("RIGHT", frame, "RIGHT", 0 , 0)
	end
			
	local function UpdateGps(frame)
		local angle, px, py, tx, ty = GetBearing(frame.unit)
		if angle == 999 then
			if frame.parent:IsVisible() and (inParty(frame.unit) or inRaid(frame.unit)) then
				-- we have a unit type that is in raid / party, but no bearing show ??? to indicate we are lost :)
    		frame.text:SetText("???")
				frame.texture:Hide()
				frame:Show()
			else
				-- no focus or target
				frame:Hide()
			end
			return 
		end
	  RotateTexture(frame.texture, angle)
    frame.texture:Show()
	
		local distance = mapfiles:Distance(mapfile, 0, px, py, tx, ty)
    frame.text:SetFormattedText("%d", distance)
		frame:Show()
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
