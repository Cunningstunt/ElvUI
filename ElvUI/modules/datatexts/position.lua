--Set Datatext Postitions
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

E.LeftDatatexts = {}
function E.PP(p, obj)
	obj:SetHeight(E.Scale(15))
	local left = ElvuiInfoLeft
	local leftHeight = left:GetHeight() - E.Scale(4)
	local right = ElvuiInfoRight
	local rightHeight = right:GetHeight() - E.Scale(4)
	local mapleft = ElvuiMinimapStatsLeft
	local mapright = ElvuiMinimapStatsRight
	local bottom = ElvuiInfoBottom
	local bottomHeight = bottom:GetHeight() - E.Scale(4)
	local t
	if obj:GetParent():GetName() == "TimeDataText" or obj:GetParent():GetName() == "DurabilityDataText" then t = true else t = false end
	
	if p == 1 then
		obj:SetHeight(leftHeight)
		obj:SetPoint("LEFT", left, "LEFT", E.Scale(5), 0)
		if t ~= true then obj:SetParent(left) else obj:GetParent():SetParent(left) end
		tinsert(E.LeftDatatexts, obj)
	elseif p == 2 then
		obj:SetHeight(leftHeight)
		obj:SetPoint("CENTER", left, "CENTER")
		if t ~= true then obj:SetParent(left) else obj:GetParent():SetParent(left) end
		tinsert(E.LeftDatatexts, obj)
	elseif p == 3 then
		obj:SetHeight(leftHeight)
		obj:SetPoint("RIGHT", left, "RIGHT", -E.Scale(5), 0)
		if t ~= true then obj:SetParent(left) else obj:GetParent():SetParent(left) end
		tinsert(E.LeftDatatexts, obj)
	elseif p == 4 then
		obj:SetHeight(rightHeight)
		obj:SetPoint("LEFT", right, "LEFT", E.Scale(5), 0)
		if t ~= true then obj:SetParent(right) else obj:GetParent():SetParent(right) end
	elseif p == 5 then
		obj:SetHeight(rightHeight)
		obj:SetPoint("CENTER", right, "CENTER")
		if t ~= true then obj:SetParent(right) else obj:GetParent():SetParent(right) end
	elseif p == 6 then
		obj:SetHeight(rightHeight)
		obj:SetPoint("RIGHT", right, "RIGHT", -E.Scale(5), 0)
		if t ~= true then obj:SetParent(right) else obj:GetParent():SetParent(right) end
	elseif p == 9 then
		obj:SetHeight(bottomHeight)
		obj:SetPoint("LEFT", bottom, "LEFT", E.Scale(5), 0)
		if t ~= true then obj:SetParent(bottom) else obj:GetParent():SetParent(bottom) end
	elseif p == 10 then
		obj:SetHeight(bottomHeight)
		obj:SetPoint("LEFT", bottom, "LEFT", E.Scale(120), 0)
		if t ~= true then obj:SetParent(bottom) else obj:GetParent():SetParent(bottom) end
	elseif p == 11 then
		obj:SetHeight(bottomHeight)
		obj:SetPoint("CENTER", bottom, "CENTER")
		if t ~= true then obj:SetParent(bottom) else obj:GetParent():SetParent(bottom) end
	elseif p == 12 then
		obj:SetHeight(bottomHeight)
		obj:SetPoint("RIGHT", bottom, "RIGHT", -E.Scale(120), 0)
		if t ~= true then obj:SetParent(bottom) else obj:GetParent():SetParent(bottom) end	
	elseif p == 13 then
		obj:SetHeight(bottomHeight)
		obj:SetPoint("RIGHT", bottom, "RIGHT", -E.Scale(5), 0)
		if t ~= true then obj:SetParent(bottom) else obj:GetParent():SetParent(bottom) end	
	end
	
	if ElvuiMinimap then
		if p == 7 then
			obj:SetHeight(mapleft:GetHeight())
			obj:SetPoint("CENTER", mapleft, 0, 0)
			if t ~= true then obj:SetParent(mapleft) else obj:GetParent():SetParent(mapleft) end
		elseif p == 8 then
			obj:SetHeight(mapright:GetHeight())
			obj:SetPoint("CENTER", mapright, 0, 0)
			if t ~= true then obj:SetParent(mapright) else obj:GetParent():SetParent(mapright) end
		end
	end
end

E.DataTextTooltipAnchor = function(self)
	local panel = self:GetParent()
	local anchor = "ANCHOR_TOP"
	local xoff = 0
	local yoff = E.Scale(4)
	
	if panel == ElvuiInfoLeft then
		anchor = "ANCHOR_TOPLEFT"
		xoff = E.Scale(-17)
	elseif panel == ElvuiInfoRight then
		anchor = "ANCHOR_TOPRIGHT"
		xoff = E.Scale(17)
	elseif panel == ElvuiMinimapStatsLeft or panel == ElvuiMinimapStatsRight then
		local position = select(3, MinimapMover:GetPoint())
		if position:match("LEFT") then
			anchor = "ANCHOR_BOTTOMRIGHT"
			yoff = E.Scale(-4)
			xoff = -ElvuiMinimapStatsRight:GetWidth()
			panel = ElvuiMinimapStatsLeft
		elseif position:match("RIGHT") then
			anchor = "ANCHOR_BOTTOMLEFT"
			yoff = E.Scale(-4)
			xoff = ElvuiMinimapStatsRight:GetWidth()
			panel = ElvuiMinimapStatsRight
		else
			anchor = "ANCHOR_BOTTOM"
			yoff = E.Scale(-4)
		end
	end
	
	return anchor, panel, xoff, yoff
end