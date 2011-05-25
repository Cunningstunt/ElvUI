--------------------------------------------------------------------
-- GOLD
--------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["datatext"].gold or C["datatext"].gold == 0 then return end

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)
Stat:SetFrameStrata("BACKGROUND")
Stat:SetFrameLevel(3)

local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
E.PP(C["datatext"].gold, Text)

local defaultColor = { 1, 1, 1 }
local Profit	= 0
local Spent		= 0
local OldMoney	= 0

Stat:SetScript("OnEnter", function(self)
	if not InCombatLockdown() then
		local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(Text)
		GameTooltip:SetOwner(panel, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L.datatext_session)
		GameTooltip:AddDoubleLine(L.datatext_earned, E.FormatMoney(Profit, false), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(L.datatext_spent, E.FormatMoney(Spent, false), 1, 1, 1, 1, 1, 1)
		if Profit < Spent then
			GameTooltip:AddDoubleLine(L.datatext_deficit, E.FormatMoney(Profit-Spent, false), 1, 0, 0, 1, 1, 1)
		elseif (Profit-Spent)>0 then
			GameTooltip:AddDoubleLine(L.datatext_profit, E.FormatMoney(Profit-Spent, false), 0, 1, 0, 1, 1, 1)
		end				
		GameTooltip:AddLine' '								
	
		local totalGold = 0				
		GameTooltip:AddLine(L.datatext_character)			

		for k,_ in pairs(ElvuiData[E.myrealm]) do
			if ElvuiData[E.myrealm][k]["gold"] then 
				GameTooltip:AddDoubleLine(k, E.FormatMoney(ElvuiData[E.myrealm][k]["gold"], true), 1, 1, 1, 1, 1, 1)
				totalGold=totalGold+ElvuiData[E.myrealm][k]["gold"]
			end
		end 
		GameTooltip:AddLine' '
		GameTooltip:AddLine(L.datatext_server)
		GameTooltip:AddDoubleLine(L.datatext_totalgold, E.FormatMoney(totalGold, true), 1, 1, 1, 1, 1, 1)

		for i = 1, MAX_WATCHED_TOKENS do
			local name, count, extraCurrencyType, icon, itemID = GetBackpackCurrencyInfo(i)
			if name and i == 1 then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(CURRENCY)
			end
			if name and count then GameTooltip:AddDoubleLine(name, count, 1, 1, 1) end
		end
		GameTooltip:Show()
	end
end)

Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)

local function OnEvent(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		OldMoney = GetMoney()
	end
	
	local NewMoney	= GetMoney()
	local Change = NewMoney-OldMoney -- Positive if we gain money
	
	if OldMoney>NewMoney then		-- Lost Money
		Spent = Spent - Change
	else							-- Gained Moeny
		Profit = Profit + Change
	end
	
	Text:SetText(E.FormatMoney(NewMoney, false))
	-- Setup Money Tooltip
	self:SetAllPoints(Text)

	if (ElvuiData == nil) then ElvuiData = {}; end
	if (ElvuiData[E.myrealm] == nil) then ElvuiData[E.myrealm] = {} end
	if (ElvuiData[E.myrealm][E.myname] == nil) then ElvuiData[E.myrealm][E.myname] = {} end
	ElvuiData[E.myrealm][E.myname]["gold"] = GetMoney()
	ElvuiData.gold = nil -- old
		
	OldMoney = NewMoney
end

Stat:RegisterEvent("PLAYER_MONEY")
Stat:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
Stat:RegisterEvent("SEND_MAIL_COD_CHANGED")
Stat:RegisterEvent("PLAYER_TRADE_MONEY")
Stat:RegisterEvent("TRADE_MONEY_CHANGED")
Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:SetScript("OnMouseDown", function() ToggleCharacter("TokenFrame") end)
Stat:SetScript("OnEvent", OnEvent)

-- reset gold data
local function RESETGOLD()		
	for k,_ in pairs(ElvuiData[E.myrealm]) do
		ElvuiData[E.myrealm][k].gold = nil
	end 
	if (ElvuiData == nil) then ElvuiData = {}; end
	if (ElvuiData[E.myrealm] == nil) then ElvuiData[E.myrealm] = {} end
	if (ElvuiData[E.myrealm][E.myname] == nil) then ElvuiData[E.myrealm][E.myname] = {} end
	ElvuiData[E.myrealm][E.myname]["gold"] = GetMoney()		
end
SLASH_RESETGOLD1 = "/resetgold"
SlashCmdList["RESETGOLD"] = RESETGOLD