-- Addon Saved Variables
local ItemPvPCountsDB_local

local frame = CreateFrame("Frame", "MarksOfHonorFrame", UIParent)
frame:SetSize(128, 32)
frame:SetPoint("CENTER", 0, 0)

-- Table to store currency information
local trackedCurrencies = {
    ["Warsong"] = 20558, -- Marque d'honneur du goulet des Chanteguerres
    ["Arathi"] = 20559, -- Marque d'honneur du bassin Arathi
    ["AV"] = 20560,     -- Marque d'honneur de la vallée d'Alterac
    ["EotS"] = 29024,   -- Marque d'honneur de l'Oeil du cyclone
    ["Honor"] = 43308,  -- Points d'honneur
    ["Arena"] = 43307,  -- Points d'arène
}

-- Custom display order
local displayOrder = { "Warsong", "Arathi", "AV", "EotS", "Honor", "Arena" }

local texturePaths = {
    ["Warsong"] = "Interface\\Icons\\inv_misc_rune_07",
    ["Arathi"] = "Interface\\Icons\\inv_jewelry_amulet_07",
    ["AV"] = "Interface\\Icons\\inv_jewelry_necklace_21",
    ["EotS"] = "Interface\\Icons\\spell_nature_eyeofthestorm",
    ["Honor"] = "Interface\\PVPFrame\\PVP-Currency-" .. UnitFactionGroup("player"),
    ["Arena"] = "Interface\\AddOns\\ItemPvPCounts\\PVP-ArenaPoints-Icon.blp"
}

local currencyIndices = {}
local textures = {}
local counts = {}

-- Find currency indices dynamically
local function FindCurrencyIndices()
    table.wipe(currencyIndices) -- Clear the table before refreshing
    local numCurrencies = GetCurrencyListSize()
    for i = 1, numCurrencies do
        local name, _, _, _, _, _, _, _, currencyID = GetCurrencyListInfo(i)
        for key, id in pairs(trackedCurrencies) do
            if currencyID == id then
                currencyIndices[key] = i
            end
        end
    end
end

-- Update counts for the currencies
local function UpdateCounts()
    for key, index in pairs(currencyIndices) do
        if index then
            local _, _, _, _, _, count = GetCurrencyListInfo(index)
            if count then
                counts[key]:SetText(count)
            else
                counts[key]:SetText("0")
            end
        else
            counts[key]:SetText("0")
        end
    end
end

-- Initialize textures and text for the currencies in custom order
local function InitializeUI()
    for i, key in ipairs(displayOrder) do
        local texturePath = texturePaths[key]

        textures[key] = frame:CreateTexture(nil, "BACKGROUND")
        textures[key]:SetSize(32, 32)
        textures[key]:SetPoint("LEFT", (i - 1) * 33, 0)
        textures[key]:SetTexture(texturePath)

        counts[key] = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        counts[key]:SetPoint("BOTTOMRIGHT", textures[key], -3, 5)
        counts[key]:SetTextColor(1, 1, 1)
        counts[key]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        counts[key]:SetText("0") -- Set initial text to 0

        -- Adjust font size and position for Arena and Honor points
        if key == "Arena" then
            counts[key]:SetPoint("BOTTOMRIGHT", textures[key], 9, -5)
            counts[key]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        elseif key == "Honor" then
            counts[key]:SetPoint("BOTTOMRIGHT", textures[key], 9, -5)
            counts[key]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        end
    end
end

-- Drag functionality with Alt key
local function OnDragStart(self)
    if IsAltKeyDown() then
        self.isMoving = true
        self:StartMoving()
    end
end

local function OnDragStop(self)
    if self.isMoving then
        self.isMoving = nil
        self:StopMovingOrSizing()

        -- Save the position
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        ItemPvPCountsDB_local.point = point
        ItemPvPCountsDB_local.relativePoint = relativePoint
        ItemPvPCountsDB_local.xOffset = xOfs
        ItemPvPCountsDB_local.yOffset = yOfs
    end
end

-- Frame settings for dragging
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", OnDragStart)
frame:SetScript("OnDragStop", OnDragStop)

-- Addon Events
local events = {}
function events:ADDON_LOADED(...)
    if select(1, ...) == "ItemPvPCounts" then
        ItemPvPCountsDB_local = ItemPvPCountsDB
        if not ItemPvPCountsDB_local then
            ItemPvPCountsDB_local = {
                point = "CENTER",
                relativePoint = "CENTER",
                xOffset = 0,
                yOffset = 0
            }
            print("ItemPvPCounts loaded with default settings.")
        end

        -- Apply saved position
        frame:ClearAllPoints()
        frame:SetPoint(
            ItemPvPCountsDB_local.point,
            UIParent,
            ItemPvPCountsDB_local.relativePoint,
            ItemPvPCountsDB_local.xOffset,
            ItemPvPCountsDB_local.yOffset
        )
    end
end

function events:PLAYER_ENTERING_WORLD()
    C_Timer.After(1, function()
        FindCurrencyIndices()
        UpdateCounts()
    end)
end

function events:CURRENCY_DISPLAY_UPDATE()
    FindCurrencyIndices()
    UpdateCounts()
end

function events:PLAYER_LOGOUT()
    ItemPvPCountsDB = ItemPvPCountsDB_local
end

-- Event registration
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
frame:SetScript("OnEvent", function(self, event, ...)
    if events[event] then
        events[event](self, ...)
    end
end)

-- Initialize UI
InitializeUI()
FindCurrencyIndices()
UpdateCounts()
