local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not Skada or not C["skin"].skada == true then return end

local Skada = Skada
local barSpacing = E.Scale(1, 1)
local borderWidth = E.Scale(2, 2)
local floor	= math.floor
local windows = {}

-- Used to strip unecessary options from the in-game config
local function StripOptions(options)
	options.baroptions.args.bartexture = options.windowoptions.args.height
	options.baroptions.args.bartexture.order = 12
	options.baroptions.args.bartexture.max = 1
	options.baroptions.args.barspacing = nil
	options.titleoptions.args.texture = nil
	options.titleoptions.args.bordertexture = nil
	options.titleoptions.args.thickness = nil
	options.titleoptions.args.margin = nil
	options.titleoptions.args.color = nil
	options.windowoptions = nil
	options.baroptions.args.barfont = nil
	options.titleoptions.args.font = nil
end

local barmod = Skada.displays["bar"]
barmod.AddDisplayOptions_ = barmod.AddDisplayOptions
barmod.AddDisplayOptions = function(self, win, options)
	self:AddDisplayOptions_(win, options)
	StripOptions(options)
end

for k, options in pairs(Skada.options.args.windows.args) do
	if options.type == "group" then
		StripOptions(options.args)
	end
end

-- Size height correctly
barmod.AdjustBackgroundHeight = function(self,win)
	local numbars = 0
	if win.bargroup:GetBars() ~= nil then
		if win.db.background.height == 0 then
			for name, bar in pairs(win.bargroup:GetBars()) do if bar:IsShown() then numbars = numbars + 1 end end
		else
			numbars = win.db.barmax
		end
		if win.db.enabletitle then numbars = numbars + 1 end
		if numbars < 1 then numbars = 1 end
		local height = (numbars * (win.db.barheight + barSpacing)) + barSpacing + borderWidth
		if win.bargroup.bgframe:GetHeight() ~= height then
			win.bargroup.bgframe:SetHeight(height)
		end
	end
end

-- Override settings from in-game GUI
local titleBG = {
	bgFile = C["media"].normTex,
	tile = false,
	tileSize = 0
}

barmod.ApplySettings_ = barmod.ApplySettings
barmod.ApplySettings = function(self, win)
	win.db.enablebackground = true
	win.db.background.borderthickness = borderWidth
	barmod:ApplySettings_(win)

	if win.db.enabletitle then
		win.bargroup.button:SetBackdrop(titleBG)
	end
	
	win.bargroup:SetTexture(C["media"].normTex)
	win.bargroup:SetSpacing(barSpacing)
	win.bargroup:SetFont(C["datatext"].font, C["datatext"].fontsize)
	win.bargroup:SetFrameLevel(5)
	
	local titlefont = CreateFont("TitleFont"..win.db.name)
	titlefont:SetFont(C["media"].font, C["datatext"].fontsize)

	local color = win.db.title.color
	win.bargroup.button:SetBackdropColor(unpack(C["media"].bordercolor))
	if win.bargroup.bgframe then
		win.bargroup.bgframe:SetTemplate("Transparent")
		if win.db.reversegrowth then
			win.bargroup.bgframe:SetPoint("BOTTOM", win.bargroup.button, "BOTTOM", 0, -1 * (win.db.enabletitle and 2 or 1))
		else
			win.bargroup.bgframe:SetPoint("TOP", win.bargroup.button, "TOP", 0, 1 * (win.db.enabletitle and 2 or 1))
		end
	end
	
	if C["skin"].embedright == "Skada" then
		win.bargroup.button:SetFrameStrata("HIGH")
		win.bargroup.button:SetFrameLevel(5)	
		win.bargroup.bgframe:SetFrameStrata("HIGH")
		win.bargroup:SetFrameStrata("HIGH")
	end
	
	self:AdjustBackgroundHeight(win)
	win.bargroup:SetMaxBars(win.db.barmax)
	win.bargroup:SortBars()
end

function EmbedWindow(window, width, height, point, relativeFrame, relativePoint, ofsx, ofsy)
	window.db.barwidth = width
	window.db.barheight = height / (floor(height / (C["datatext"].fontsize + 2)))
	window.db.barmax = (floor(height / window.db.barheight) - (window.db.enabletitle and 1 or 0))
	window.db.background.height = 1
	window.db.spark = false
	window.db.barslocked = true
	window.bargroup:ClearAllPoints()
	window.bargroup:SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy)
	
	barmod.ApplySettings(barmod, window)
end

function EmbedSkada()
	local xSpacing = ((borderWidth * 2) + barSpacing)
	local ySpacing = ((borderWidth + barSpacing) * 2)
	if #windows == 1 then
		EmbedWindow(windows[1], C["chat"].chatwidth - xSpacing, C["chat"].chatheight - ySpacing, "TOPRIGHT", ChatRBackground2, "TOPRIGHT", -borderWidth, -borderWidth)
	elseif #windows == 2 then
		EmbedWindow(windows[1], ((C["chat"].chatwidth) / 2) - xSpacing, C["chat"].chatheight - ySpacing, "TOPRIGHT", ChatRBackground2, "TOPRIGHT", -borderWidth, -borderWidth)
		EmbedWindow(windows[2], ((C["chat"].chatwidth) / 2) - xSpacing, C["chat"].chatheight - ySpacing, "TOPLEFT", ChatRBackground2, "TOPLEFT", borderWidth, -borderWidth)
	elseif #windows > 2 then
		EmbedWindow(windows[1], ((C["chat"].chatwidth) / 2) - xSpacing, C["chat"].chatheight - ySpacing, "TOPRIGHT", ChatRBackground2, "TOPRIGHT", -borderWidth, -borderWidth)
		EmbedWindow(windows[2], ((C["chat"].chatwidth) / 2) - xSpacing, ((C["chat"].chatheight - ySpacing) / 2) - borderWidth, "TOPLEFT", ChatRBackground2, "TOPLEFT", borderWidth, -borderWidth)
		EmbedWindow(windows[3], ((C["chat"].chatwidth) / 2) - xSpacing, ((C["chat"].chatheight - ySpacing) / 2) - borderWidth + barSpacing, "TOPLEFT", windows[2].bargroup.bgframe, "BOTTOMLEFT", borderWidth, -borderWidth)
	end
end

function UpdateWindowsTable()
	wipe(windows)
	-- Update pre-existing displays
	for _, window in ipairs(Skada:GetWindows()) do
		window:UpdateDisplay()
		tinsert(windows, window)
	end
	EmbedSkada()
end

Skada.CreateWindow_ = Skada.CreateWindow
function Skada:CreateWindow(name, db)
	Skada:CreateWindow_(name, db)
	UpdateWindowsTable()
end

Skada.DeleteWindow_ = Skada.DeleteWindow
function Skada:DeleteWindow(name)
	Skada:DeleteWindow_(name)
	UpdateWindowsTable()
end

if C["skin"].embedright == "Skada" then
	local Skada_Skin = CreateFrame("Frame")
	Skada_Skin:RegisterEvent("PLAYER_ENTERING_WORLD")
	Skada_Skin:SetScript("OnEvent", function(self)
		self:UnregisterAllEvents()
		self = nil
		
		UpdateWindowsTable()
	end)	
end