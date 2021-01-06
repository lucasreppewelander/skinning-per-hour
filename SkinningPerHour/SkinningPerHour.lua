SkinningPerHour = { }

-- skinning items
_items = {"172097", "172092", "172089", "172094", "172096"}
BAGS = {0, 1, 2, 3, 4}
items = {}
quantity = {}

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
    local range = i * 20
    local negative = -range
    
    f.fontStrings[tostring(itemID)] = f:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    f.fontStrings[tostring(itemID)]:SetPoint("TOPLEFT", 20, negative)
    f.fontStrings[tostring(itemID)]:SetTextColor(SkinningPerHour:GetColorByName(quality))

    -- 163 53 238
    f.aquiredSinceStart[tostring(itemID)] = 0
    print(itemName, quality, tostring(itemID))
    f.fontStrings[tostring(itemID)]:SetText(itemName .. " (" .. quantity .. ") (session: "..f.aquiredSinceStart[itemID]..")")
end

function event__LOOT_READY(f)
    local numItems = GetNumLootItems()
    for slotID = 1, numItems do
        local _, nme, qty = GetLootSlotInfo(slotID)
        if (qty or 0) > 0 then
            local _, link = GetItemInfo(nme)
            print("---------------")
            local _, lootItemId = strsplit(":", link)
            -- local lootItemId = tonumber(string.match(link, "%d+"))

            print("lootItemId: "..lootItemId)
            if has_value(_items, tostring(lootItemId)) then
                if quantity[tostring(lootItemId)] then
                    quantity[tostring(lootItemId)] = quantity[tostring(lootItemId)] + qty
                else
                    quantity[tostring(lootItemId)] = qty;
                end

                if not has_value(items, tostring(lootItemId)) then
                    table.insert(items, tostring(lootItemId))
                end

                print(nme, qty, tostring(lootItemId))
                f.aquiredSinceStart[tostring(lootItemId)] = f.aquiredSinceStart[tostring(lootItemId)] + qty
                f.fontStrings[tostring(lootItemId)]:SetText(nme .. " (" .. quantity[tostring(lootItemId)] .. ") (session: "..f.aquiredSinceStart[tostring(lootItemId)]..")")
                f:SetHeight(10 + #items * 25)
            end
        end
    end
end

function SkinningPerHour:Run()
    local background = "Interface\\TutorialFrame\\TutorialFrameBackground"

    f = CreateFrame("Frame",nil,UIParent)
    f:SetFrameStrata("HIGH")
    f:SetWidth(300) -- Set these to whatever height/width is needed 

    local t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture(background)
    t:SetAllPoints(f)
    f.texture = t

    f:SetPoint("TOPLEFT",10,-10)
    f.fontStrings = {}
    f.aquiredSinceStart = {}

    --[[
    items, quantity = SkinningPerHour:CheckItemsInBags(f)

    f:SetHeight(10 + #items * 25) -- for your Texture

    for index, value in pairs(items) do
        SkinningPerHour:PresentBagItems(index, value, quantity[value])
    end
    ]]--

    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("LOOT_OPENED")
    f:SetScript("OnEvent", function(self, event, ...)
        if event == "LOOT_OPENED" then
            event__LOOT_READY(f)
        end

        if event == "PLAYER_ENTERING_WORLD" then
            SkinningPerHour.startTime = time()

            items, quantity = SkinningPerHour:CheckItemsInBags(f)

            f:SetHeight(10 + #items * 25) -- for your Texture

            for index, value in pairs(items) do
                SkinningPerHour:PresentBagItems(index, value, quantity[value])
            end
        end
    end);

    f:Show()
end

SkinningPerHour:Run()