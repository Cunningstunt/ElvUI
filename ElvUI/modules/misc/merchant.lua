----------------------------------------------------------------------------------
-- Merchant
----------------------------------------------------------------------------------
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

local format	= string.format
local join		= string.join
local abs 		= math.abs

local moneyCopperFormatString = join("", " |cffffffff%d|r", L.copperabbrev)
local moneySilverFormatString = join("", " |cffffffff%d|r", L.silverabbrev, moneyCopperFormatString)
local moneyGoldFormatString = join("", " |cffffffff%d|r", L.goldabbrev, moneySilverFormatString)
local vendorInfoString = "|cffffff00%s|r %s"


local function formatMoney(money)
	if not money then return end
	local gold, silver, copper = abs(money / 10000), abs(mod(money / 100, 100)), abs(mod(money, 100))
	if floor(gold) ~= 0 then
		return format(moneyGoldFormatString, gold, silver, copper)
	elseif floor(silver) ~= 0 then
		return format(moneySilverFormatString, silver, copper)
	else
		return format(moneyCopperFormatString, copper)
	end
end

local function AutoSellGrayItems()
	local link, payed
	local cost = 0
	for bag = 0, 4 do
		for slot = 1 ,GetContainerNumSlots(bag) do
			link = GetContainerItemLink(bag, slot)
			if link then
				local payed = select(11, GetItemInfo(link)) * select(2, GetContainerItemInfo(bag, slot))
				if select(3, GetItemInfo(link)) == 0 and payed > 0 then
					UseContainerItem(bag, slot)
					PickupMerchantItem()
					cost = cost + payed
				end
			end
		end
	end

	if cost > 0 then 
		DEFAULT_CHAT_FRAME:AddMessage(format(vendorInfoString, L.merchant_trashsell, formatMoney(cost)))
	end
end

local function RepairAllPlayerItems()
	-- auto repair is disabled
	if (not C["others"].autorepair or C["others"].autorepair ~= true) then return end
	-- merchant cannot repair
  if (not CanMerchantRepair()) then return end

	-- get our total repair bill
	local cost = GetRepairAllCost()
	local useGuildRep = 0
	
	-- nothing damaged
	if (cost <= 0) then return end

	if (C["others"].guildbankrepair and IsInGuild() and CanGuildBankRepair()) then
		local withdrawLimit = GetGuildBankWithdrawMoney()
		local guildBankMoney = GetGuildBankMoney()

		-- Guild leader (unlimited withdrawal privileges)
		if (withdrawLimit == -1) then
			withdrawLimit = guildBankMoney
		else
			withdrawLimit = min(withdrawLimit, guildBankMoney)
		end
		
		if (cost < withdrawLimit) then useGuildRep = 1 end
	end
	
	-- Can't afford to repair
	if (useGuildRep == 0 and (GetMoney() < cost)) then
	  DEFAULT_CHAT_FRAME:AddMessage(L.merchant_repairnomoney, 255, 0, 0)
	  return
	end
	
	RepairAllItems(useGuildRep)
	
	DEFAULT_CHAT_FRAME:AddMessage(format(vendorInfoString, L.merchant_repaircost, formatMoney(cost)))
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function()
	if C["others"].sellgrays then AutoSellGrayItems() end
	if not IsShiftKeyDown() then RepairAllPlayerItems() end
end)
f:RegisterEvent("MERCHANT_SHOW")

-- buy max number value with alt
local savedMerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
function MerchantItemButton_OnModifiedClick(self, ...)
	if ( IsAltKeyDown() ) then
		local maxStack = select(8, GetItemInfo(GetMerchantItemLink(self:GetID())))
		if ( maxStack and maxStack > 1 ) then
			BuyMerchantItem(self:GetID(), GetMerchantItemMaxStack(self:GetID()))
		end
	end
	savedMerchantItemButton_OnModifiedClick(self, ...)
end