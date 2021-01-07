SkinningPerHour = { }
SkinningPerHourGold = {}

-- skinning items
_items = {"172097", "172092", "172089", "172096", "172094", "172232"}
BAGS = {0, 1, 2, 3, 4}
items = {}
quantity = {}

local auctions = {}

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function SkinningPerHour:CheckItemsInBags(f)
    for i=0, 4 do
        bagSlots = GetContainerNumSlots(i)
        slotsCheckLeft = bagSlots
        slotIndex = 1

        while ( slotsCheckLeft > 0 ) do
            itemID = GetContainerItemID(i, slotIndex)

            if has_value(_items, tostring(itemID)) then
                texture, itemCount = GetContainerItemInfo(i, slotIndex)

                if quantity[tostring(itemID)] then
                    quantity[tostring(itemID)] = quantity[tostring(itemID)] + itemCount
                else
                    quantity[tostring(itemID)] = itemCount;
                end

                if not has_value(items, tostring(itemID)) then
                    table.insert(items, tostring(itemID))
                end
            end

            slotIndex = slotIndex+1
            slotsCheckLeft = slotsCheckLeft-1
        end
    end

    return items, quantity
end

function SkinningPerHour:GetColorByName(quality)
    if quality == 1 then
        return 1, 1, 1
    end

    if quality == 2 then
        return 0.12, 1, 00
    end

    if quality == 3 then
        return 0, 0.44, 0.87
    end

    if quality == 4 then
        return 0.64, 0.21, 0.93
    end
end

function SkinningPerHour:PresentBagItems(i, itemID, quantity)
    local itemName = C_Item.GetItemNameByID(tostring(itemID))
    local quality = C_Item.GetItemQualityByID(tostring(itemID))
    local range = tonumber(i) * 35

    local negative = -range

    f.fontStrings[tostring(itemID)] = f:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    -- f.fontStrings[tostring(itemID)]:SetPoint("CENTER", 20, negative)
    f.fontStrings[tostring(itemID)]:SetPoint("TOPLEFT", f, "TOPLEFT", 10, negative)
    f.fontStrings[tostring(itemID)]:SetTextColor(SkinningPerHour:GetColorByName(quality))

    -- current gold per item worth


    -- 163 53 238
    f.aquiredSinceStart[tostring(itemID)] = 0
    -- print(itemName, quality, tostring(itemID))
    local sessionQuantity = 0
    local ahValue = 0
    
    if f.aquiredSinceStart[itemID] then
        sessionQuantity = f.aquiredSinceStart[itemID]
    end

    if SkinningPerHourGold[itemID] then
     ahValue = SkinningPerHourGold[itemID]
    end

    if itemName then
        f.fontStrings[tostring(itemID)]:SetText(itemName .. " (" .. quantity .. ") (session: ".. sessionQuantity..")\nTotal value in the bags: " .. GetCoinTextureString(quantity * ahValue))
    end
end

function event__LOOT_READY(f)
    local numItems = GetNumLootItems()
    for slotID = 1, numItems do
        local _, nme, qty = GetLootSlotInfo(slotID)
        if (qty or 0) > 0 then
            local _, link = GetItemInfo(nme)
            if link then
                local _, lootItemId = strsplit(":", link)

                if has_value(_items, tostring(lootItemId)) then
                    if quantity[tostring(lootItemId)] then
                        quantity[tostring(lootItemId)] = quantity[tostring(lootItemId)] + qty
                    else
                        quantity[tostring(lootItemId)] = qty;
                    end

                    if not has_value(items, tostring(lootItemId)) then
                        table.insert(items, tostring(lootItemId))
                    end

                    f.aquiredSinceStart[tostring(lootItemId)] = f.aquiredSinceStart[tostring(lootItemId)] + qty
                    f.fontStrings[tostring(lootItemId)]:SetText(nme .. " (" .. quantity[tostring(lootItemId)] .. ") (session: "..f.aquiredSinceStart[tostring(lootItemId)]..")\nTotal value in the bags: " .. GetCoinTextureString(quantity[tostring(lootItemId)] * SkinningPerHourGold[tostring(lootItemId)]))
                    f:SetHeight(#items * 50)

                    local totalBagValue = 0
                    for index, value in pairs(items) do
                        local itemValue = SkinningPerHourGold[tostring(value)]
                        local itemQuantity = quantity[tostring(value)]
                        totalBagValue = totalBagValue + itemQuantity * itemValue
                    end

                    f.fontStrings["total"]:SetText("Total bag value: "..GetCoinTextureString(totalBagValue))
                end
            end
        end
    end
end

function SkinningPerHour:Run()
    local background = "Interface\\TutorialFrame\\TutorialFrameBackground"

    btn = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
    f = CreateFrame("Frame",nil,UIParent)
    f:SetFrameStrata("MEDIUM")
    f:SetWidth(400) -- Set these to whatever height/width is needed 

    local t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture(background)
    t:SetAllPoints(f)
    f.texture = t

    f:SetPoint("TOPLEFT",5,-5)
    f.fontStrings = {}
    f.aquiredSinceStart = {}

    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("LOOT_OPENED")
    f:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED")
    f:RegisterEvent("AUCTION_HOUSE_SHOW")
    f:RegisterEvent("AUCTION_HOUSE_CLOSED")

    f:SetScript("OnEvent", function(self, event, ...)
        if event == "LOOT_OPENED" then
            event__LOOT_READY(f)
        elseif event == "PLAYER_ENTERING_WORLD" then
            local isLogin, isReload = ...

            if isLogin or isReload then
                SkinningPerHour.startTime = time()

                items, quantity = SkinningPerHour:CheckItemsInBags(f)

                f:SetHeight(#items * 50) -- for your Texture

                for index, value in pairs(items) do
                    SkinningPerHour:PresentBagItems(index, value, quantity[value])
                end

                local totalBagValue = 0
                for index, value in pairs(items) do
                    local itemValue = 0
                    local itemQuantity = 0

                    if SkinningPerHourGold[tostring(value)] then
                        itemValue = SkinningPerHourGold[tostring(value)]
                    end

                    if quantity[tostring(value)] then
                        itemQuantity = quantity[tostring(value)]
                    end

                    totalBagValue = totalBagValue + itemQuantity * itemValue
                end

                f.fontStrings["total"] = f:CreateFontString(nil, "OVERLAY", "GameTooltipText")
                -- f.fontStrings[tostring(itemID)]:SetPoint("CENTER", 20, negative)
                f.fontStrings["total"]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 10)
                f.fontStrings["total"]:SetTextColor(1, 1, 1)
                f.fontStrings["total"]:SetText("Total bag value: "..GetCoinTextureString(totalBagValue))
            end
        elseif event == "AUCTION_HOUSE_SHOW" then
            btn = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
            btn:SetPoint("CENTER", -345, -39)
            btn:SetFrameStrata("HIGH")
            btn:SetSize(220, 25)
            btn:SetText("Welander leather scanning tool")

            btn:SetScript("OnClick", function(self, button)
                local itemKeysToSearchFor = {}

                for index, value in pairs(_items) do
                    local itemKey = C_AuctionHouse.MakeItemKey(tonumber(value))
                    table.insert(itemKeysToSearchFor, itemKey)
                end

                C_AuctionHouse.SearchForItemKeys(itemKeysToSearchFor, { sortOrder = Enum.AuctionHouseSortOrder.Buyout, reverseSort = false })
            end)
        elseif event == "AUCTION_HOUSE_CLOSED" then
            btn:Hide()
        elseif event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
            local result = C_AuctionHouse.GetBrowseResults()
            for i in pairs(result) do
                SkinningPerHourGold[tostring(result[i].itemKey.itemID)] = result[i].minPrice
            end
        end
    end);

    f:Show()
end

SkinningPerHour:Run()