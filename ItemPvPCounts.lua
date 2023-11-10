local ItemPvPCountsDB_local
local events = {}
function events:ADDON_LOADED(...)
	if select(1, ...) == "ItemPvPCounts" then
		ItemPvPCountsDB_local = ItemPvPCountsDB
		if not ItemPvPCountsDB_local then -- addon loaded for first time
			ItemPvPCountsDB_local = {}
			print("ItemPvPCounts load default")
			ItemPvPCountsDB_local["point"] = "CENTER"
			ItemPvPCountsDB_local["relativePoint"] = "CENTER"
			ItemPvPCountsDB_local["xOffset"] = 0
			ItemPvPCountsDB_local["yOffset"] = 0
		end

		-- safe check all saved variables are there (in case older version was loaded)
		if not ItemPvPCountsDB_local["point"] then ItemPvPCountsDB_local["point"] = "CENTER" end
		if not ItemPvPCountsDB_local["relativePoint"] then ItemPvPCountsDB_local["relativePoint"] = "CENTER" end
		if not ItemPvPCountsDB_local["xOffset"] then ItemPvPCountsDB_local["xOffset"] = 0 end
		if not ItemPvPCountsDB_local["yOffset"] then ItemPvPCountsDB_local["yOffset"] = 0 end

		addon:UnregisterEvent("ADDON_LOADED")
		print("ItemPvPCounts Loaded")
	end
end

--- gets executed once all ui information is available (like honor etc)
function events:PLAYER_ENTERING_WORLD()
    addon:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

--- save variables to SavedVariables
function events:PLAYER_LOGOUT()
	ItemPvPCountsDB = ItemPvPCountsDB_local
end

local frame = CreateFrame("Frame", "MarksOfHonorFrame", UIParent)
frame:SetSize(128, 32) -- Adjust the size as needed
frame:SetPoint("CENTER", 0, 0) -- Adjust the position as needed


local function OnDragStart(self)
    if( IsAltKeyDown() ) then
        self.isMoving = true
        self:StartMoving()
    end
end

local function OnDragStop(self)
    if( self.isMoving ) then
        self.isMoving = nil
        self:StopMovingOrSizing()
    end
	local point, _, relativePoint, xOfs, yOfs = self:GetPoint()


end

	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", OnDragStart)
	frame:SetScript("OnDragStop", OnDragStop)
	
	
local textures = {}
local factionGroup = UnitFactionGroup("player");
local texturePaths = {
    "Interface\\Icons\\inv_misc_rune_07", -- Warsong
    "Interface\\Icons\\inv_jewelry_amulet_07", -- Arathi
    "Interface\\Icons\\spell_nature_eyeofthestorm", -- eots
    "Interface\\Icons\\inv_jewelry_necklace_21", -- AV
    "Interface\\PVPFrame\\PVP-Currency-" .. factionGroup, -- Honor points
    "Interface\\AddOns\\ItemPvPCounts\\PVP-ArenaPoints-Icon.blp" -- Arena Points
}

local counts = {} -- Store the counts here

local currencyIndices = {
    6,
    3,
    4,
    7,
    5,
    3,
    --4 = eots, 5 = honor, 3 = Arena P, 2 = Arathi, 1 = nothing, 6 = warsong, 7 = AV?
}

local currencyTexts = {
    "Warsong", -- Text for Warsong
    "Arathi", -- Text for Arathi
    "EotS", -- Text for Eye of the Storm
    "AV", -- Text for Alterac Valley
    "Honor", -- Text for Honor Points
    "Arena", -- Text for Arena Points
}

for i = 1, #currencyIndices do
    local index = currencyIndices[i]
    local name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon, itemID = GetCurrencyListInfo(index)

    if not isHeader then
        textures[i] = frame:CreateTexture(nil, "BACKGROUND")
        textures[i]:SetSize(32, 32) -- Adjust the size as needed
        textures[i]:SetPoint("LEFT", (i - 1) * 33, 0) -- Adjust the spacing between images as needed
        textures[i]:SetTexture(texturePaths[i]) -- Use the corresponding texture path

        counts[i] = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        counts[i]:SetPoint("BOTTOMRIGHT", textures[i], -3, 5)
        counts[i]:SetTextColor(1, 1, 1)
        counts[i]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE");

        -- Adjust the font size and position for Arena and Honor Points
        if currencyTexts[i] == "Arena" then
            counts[i]:SetPoint("BOTTOMRIGHT", textures[i], 9, -5) -- Adjust the position for Arena Points
            counts[i]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE"); -- Adjust the font size for Arena Points
        elseif currencyTexts[i] == "Honor" then
            counts[i]:SetPoint("BOTTOMRIGHT", textures[i], 9, -5) -- Adjust the position for Honor Points
            counts[i]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE"); -- Adjust the font size for Honor Points
        end
    end
end

local function UpdateCounts()
    for i = 1, #currencyIndices do
        local index = currencyIndices[i]
        local name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon, itemID = GetCurrencyListInfo(index)

        if not isHeader then
            if count == nil then
                counts[i]:SetText("0") -- Set text to "0" for zero counts
            else
                counts[i]:SetText(count) -- Set the actual count
            end
        end
    end
end

frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
frame:SetScript("OnEvent", UpdateCounts)

UpdateCounts() -- Initial update

frame:Show()
