--------------------------------------------------------------------------
-- Automatically select the item with the highest sell value from Quest Rewards
--------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["others"].questreward ~= true then return end

local questreward = CreateFrame("frame")

local function SelectQuestReward(index)
	local btn = getglobal("QuestInfoItem"..index);
	if (btn.type == "choice") then
		QuestInfoItemHighlight:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0);
		QuestInfoItemHighlight:Show();
		QuestInfoFrame.itemChoice = btn:GetID();
	end
end

local function SelectQuestRewardItem()
	-- default first button when no item has a sell value.
	local choice, price = 1, 0 
	local num = GetNumQuestChoices()

	if num <= 0 then
		return	-- no choices, quick exit
	end
	
	for index = 1, num do
		local link = GetQuestItemLink("choice", index);
		if (link) then
			local vsp = select(11, GetItemInfo(link))
			if vsp and vsp > price then
				price = vsp
				choice = index
			end
		end
	end

	SelectQuestReward(choice)
end

questreward:RegisterEvent("QUEST_COMPLETE")
questreward:SetScript("OnEvent", SelectQuestRewardItem)