local frame = CreateFrame("Frame", "PvPCurrencyFrame", UIParent)
frame:SetSize(128, 32) -- Adjust the size as needed
frame:SetPoint("CENTER", 0, 0) -- Adjust the position as needed

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
    end
end

frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", OnDragStart)
frame:SetScript("OnDragStop", OnDragStop)

local textures = {}
local counts = {} -- Store the counts here
local factionGroup = UnitFactionGroup("player");
local currencyIndices = {
    {name = "Honor", func = GetHonorCurrency, icon = "Interface\\PVPFrame\\PVP-Currency-" .. factionGroup}, -- Honor points
    {name = "Arena", func = GetArenaCurrency, icon = "Interface\\AddOns\\ItemPvPCounts\\PVP-ArenaPoints-Icon.blp"}, -- Arena Points
}

for i = 1, #currencyIndices do
    textures[i] = frame:CreateTexture(nil, "BACKGROUND")
    textures[i]:SetSize(32, 32) -- Adjust the size as needed
    textures[i]:SetPoint("LEFT", (i - 1) * 35, 0) -- Adjust the spacing between images as needed
    textures[i]:SetTexture(currencyIndices[i].icon) -- Set the corresponding icon texture

    counts[i] = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    counts[i]:SetPoint("BOTTOMRIGHT", textures[i], 3, -5)
    counts[i]:SetTextColor(1, 1, 1)
    counts[i]:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
end

local function UpdateCounts()
    for i = 1, #currencyIndices do
        local currencyInfo = currencyIndices[i]
        local count = currencyInfo.func()

        counts[i]:SetText(count or 0) -- Set the actual count or default to 0
    end
end

frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
frame:RegisterEvent("PLAYER_LOGIN") -- Listen for PLAYER_LOGIN event

-- Additional events for Honor and Arena Points
frame:RegisterEvent("HONOR_CURRENCY_UPDATE")
frame:RegisterEvent("ARENA_POINTS_UPDATE")
frame:RegisterEvent("PLAYER_MONEY")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "CURRENCY_DISPLAY_UPDATE" or event == "PLAYER_LOGIN" or event == "HONOR_CURRENCY_UPDATE" or event == "ARENA_POINTS_UPDATE" or event == "PLAYER_MONEY" then
        UpdateCounts() -- Update counts on currency update, player login, honor currency update, or player money change
    end
end)

frame:Show()
