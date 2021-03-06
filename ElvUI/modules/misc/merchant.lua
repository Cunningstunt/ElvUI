----------------------------------------------------------------------------------
-- Merchant
----------------------------------------------------------------------------------
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

local vendorInfoString = "|cffffff00%s|r %s"

local function AutoSellScrap()
	local cost = 0
	for bag, slot, id in E.IterateJunk() do
		local bagType = select(2, GetContainerNumFreeSlots(bag))
		if not bagType then
			return
		end
	
		if bagType == 0 then
			local maxStack, _, _, payed = select(8, GetItemInfo(id))
			local stack = select(2, GetContainerItemInfo(bag, slot))
			if not stack or not maxStack then
				return
			end
			
			UseContainerItem(bag, slot)
			PickupMerchantItem()
			
			cost = cost + (stack * payed)
		end
	end
	
	if cost > 0 then 
		DEFAULT_CHAT_FRAME:AddMessage(format(vendorInfoString, L.merchant_trashsell, E.FormatMoney(cost, false)))
	end
end

local function AutoSellGrayItems()
	local cost = 0
	for bag = 0, NUM_BAG_FRAMES do
		for slot = 1 ,GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
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
		DEFAULT_CHAT_FRAME:AddMessage(format(vendorInfoString, L.merchant_trashsell, E.FormatMoney(cost, false)))
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
	
	DEFAULT_CHAT_FRAME:AddMessage(format(vendorInfoString, L.merchant_repaircost, E.FormatMoney(cost, false)))
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function()
	if C["others"].enablescrapbot and C["others"].sellscrap then 
		AutoSellScrap()
	elseif C["others"].sellgrays then 
		AutoSellGrayItems() 
	end
	if not IsShiftKeyDown() then RepairAllPlayerItems() end
end)
f:RegisterEvent("MERCHANT_SHOW")

-- buy max number value with alt
local savedMerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
function MerchantItemButton_OnModifiedClick(self, ...)
	if ( IsAltKeyDown() ) then
		local itemLink = GetMerchantItemLink(self:GetID())
		if not itemLink then return end
		local maxStack = select(8, GetItemInfo(itemLink))
		if ( maxStack and maxStack > 1 ) then
			BuyMerchantItem(self:GetID(), GetMerchantItemMaxStack(self:GetID()))
		end
	end
	savedMerchantItemButton_OnModifiedClick(self, ...)
end