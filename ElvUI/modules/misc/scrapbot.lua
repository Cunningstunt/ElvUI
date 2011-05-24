--------------------------------------------------------------------------
-- Auto-remove items from bags when full, based on type / value / usability.
--------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["others"].enablescrapbot ~= true then return end

local QI = LibStub('LibQuestItem-1.0')
local UNFIT = LibStub('Unfit-1.0')

local scrapbot = CreateFrame("frame")
local tooltip = CreateFrame('GameTooltip', 'ScrapBotTooltip', nil, 'GameTooltipTemplate')
local timerframe = CreateFrame('Frame')
local nexttime = 0

local WEAPON, ARMOR, _, CONSUMABLES = GetAuctionItemClasses()
local FISHING_ROD = select(17 , GetAuctionItemSubClasses(1))

local CLASS_NAME = LOCALIZED_CLASS_NAMES_MALE[select(2, UnitClass('player'))]
local CAN_TRADE = BIND_TRADE_TIME_REMAINING:format('.*')
local MATCH_CLASS = ITEM_CLASSES_ALLOWED:format('')

local ACTUAL_SLOTS = {
	ROBE = 'CHEST',
	CLOAK = 'BACK',
	RANGEDRIGHT = 'RANGED',
	THROWN = 'RANGED',
	WEAPONMAINHAND = 'MAINHAND',
	WEAPONOFFHAND = 'OFFHAND',
	HOLDABLE = 'OFFHAND',
	SHIELD = 'OFFHAND',
}

local junk = {}
local notjunk = notjunk or {}

function E.IterateJunk()
	local bagNumSlots, bag, slot = GetContainerNumSlots(BACKPACK_CONTAINER), BACKPACK_CONTAINER, 0
	local match, id
	
	return function()
		match = nil
		
		while not match do
			if slot < bagNumSlots then
				slot = slot + 1
			elseif bag < NUM_BAG_FRAMES then
				bag = bag + 1
				bagNumSlots = GetContainerNumSlots(bag)
				slot = 1
			else
				bag, slot = nil
				break
			end
			
			id = GetContainerItemID(bag, slot)
			match = E.IsJunk(id)
		end
		
		return bag, slot, id
	end
end

function E.CheckFilters(id)
	local _, link, quality, level, _, class, subClass, _, slot, _, value = GetItemInfo(id)
	local isPoor = quality == ITEM_QUALITY_POOR and value > 0
	
	if C["others"].scrapconsumables and class == CONSUMABLES then
		 return value > 0 and quality < 3 and level ~= 0 and (UnitLevel('player') - level) > 10
	elseif class == ARMOR or class == WEAPON then
		if isPoor then
			return level > 10 or UnitLevel('player') > 20
		else
			local isEnchanter = E.IsEnchanter()
			local numLines, limit = E.IsSoulbound(link)
			if numLines then
				return not isEnchanter and (UNFIT:IsClassUnusable(subClass, slot) or E.IsOtherClass(numLines, limit)) or E.IsLowEquip(id, subClass, slot, level, quality)
			end
		end
	end
	
	return isPoor
end

function E.IsJunk(id)
	if id then
		return junk[id] or (not notjunk[id] and E.CheckFilters(id))
	end
end

function E.IsEnchanter()
	local prof1, prof2 = GetProfessions()
	return not prof1 or not prof2 or select(7, GetProfessionInfo(prof1)) == 333 or select(7, GetProfessionInfo(prof2)) == 333
end

function E.IsSoulbound(link)
	tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
	tooltip:SetHyperlink(link)

	local numLines = tooltip:NumLines()
	local lastLine = _G['ScrapBotTooltipTextLeft'..numLines]:GetText()
	
	if not lastLine:match(CAN_TRADE) then
		for i = 2,4 do
			if _G['ScrapBotTooltipTextLeft'..i]:GetText() == ITEM_BIND_ON_PICKUP then
				return numLines, i
			end
		end
	end
end

function E.IsOtherClass(numLines, limit)
	for i = numLines, limit, -1 do
		local text = _G['ScrapBotTooltipTextLeft'..i]:GetText()
		if text:match(MATCH_CLASS) then
			return not text:match(CLASS_NAME)
		end
	end
end

function E.IsLowEquip(id, subClass, slot, ...)
	if slot ~= '' and subClass ~= FISHING_ROD then
		slot = slot:match('INVTYPE_(.+)')

		if slot ~= 'TRINKET' and slot ~= 'TABARD' and slot ~= 'BODY' then
			return E.HasBetterEquip(id, slot, ...)
		end
	end
end

function E.HasBetterEquip(id, slot, level, quality)
	if Scrap_LowEquip then
		local slot1, slot2 = ACTUAL_SLOTS[slot] or slot
		local value = level * quality ^.35
		local double
		
		if slot1 == 'WEAPON' or slot1 == '2HWEAPON' then
			if slot1 == '2HWEAPON' then
				double = true
			end
			
			slot1, slot2 = 'MAINHAND', 'OFFHAND'
		elseif slot1 == 'FINGER' then
			slot1, slot2 = 'FINGER1', 'FINGER2'
		end
		
		return E.IsBetterEquip(slot1, value) and (not slot2 or E.IsBetterEquip(slot2, value, double))
	end
end

function E.IsBetterEquip(slot, value, empty)
	local equipedItem = GetInventoryItemID('player', _G['INVSLOT_'..slot])
	if equipedItem then
		local _,_, equipQuality, equipLevel = GetItemInfo(equipedItem)
		return equipLevel * equipQuality^.35 - value > 15
	elseif empty then
		return true
	end
end

local function CleanTrash()
	local time = GetTime()
	
	if nexttime < time then
		if MainMenuBarBackpackButton.freeSlots == 0 then
			local bestValue, bestBag, bestSlot = 1/0
		
			for bag, slot, id in E.IterateJunk() do
				local bagType = select(2, GetContainerNumFreeSlots(bag))
				if not bagType then
					return
				end
				
				if bagType == 0 then
					local maxStack = select(8, GetItemInfo(id))
					local stack = select(2, GetContainerItemInfo(bag, slot))
					if not stack or not maxStack then
						return
					end
					
					local value = select(11, GetItemInfo(id)) * (stack + maxStack) * .5 -- Lets bet 50% on not full stacks
					if value < bestValue then
						bestBag, bestSlot = bag, slot
						bestValue = value
					end
				end
			end
			
			if bestBag and bestSlot then
				local itemId = GetContainerItemID(bestBag, bestSlot)
				local name = GetItemInfo(itemId)
				
				PickupContainerItem(bestBag, bestSlot)
				DeleteCursorItem()

				print(string.format("Scrapbot removed %s for a value of %d.", name, bestValue))
				
				nexttime = time + select(3, GetNetStats())
				timerframe:SetScript('OnUpdate', nil)
			end
		end
	else
		timerframe:SetScript('OnUpdate', CleanTrash)
	end
end

hooksecurefunc('MainMenuBarBackpackButton_UpdateFreeSlots', CleanTrash)