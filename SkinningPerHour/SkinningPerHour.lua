SkinningPerHour = { }

-- skinning items
_items = {172097, 172092, 172089, 172094, 172096}
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

local function has_not_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return false
        end
    end

    return true
end

function SkinningPerHour:CheckItemsInBags(f)
    for i=0, 4 do
        bagSlots = GetContainerNumSlots(i)
        slotsCheckLeft = bagSlots
        slotIndex = 1

        while ( slotsCheckLeft > 0 ) do
            itemID = GetContainerItemID(i, slotIndex)

            if has_value(_items, itemID) then
                texture, itemCount = GetContainerItemInfo(i, slotIndex)

                if quantity[itemID] then
                    quantity[itemID] = quantity[itemID] + itemCount
                else
                    quantity[itemID] = itemCount;
                end

                if has_not_value(items, itemID) then
                    table.insert(items, itemID)
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
    
    f.fontStrings[itemID] = f:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    f.fontStrings[itemID]:SetPoint("TOPLEFT", 20, negative)
    f.fontStrings[itemID]:SetTextColor(SkinningPerHour:GetColorByName(quality))

    -- 163 53 238

    f.fontStrings[itemID]:SetText(itemName .. " (" .. quantity .. ")")
end

--[[
function SkinningPerHour:RegisterEvent(self, event)
    if event == "PLAYER_ENTERING_WORLD" then

    else if event == "ITEM_PUSH" then
        
    end
end
]]

function event__LOOT_READY(f)
    local numItems = GetNumLootItems()
    for slotID = 1, numItems do
        local _, nme, qty = GetLootSlotInfo(slotID)
        if (qty or 0) > 0 then
            local _, link = GetItemInfo(nme)
            local lootItemId = tonumber(string.match(link, "%d+"))

            if has_value(_items, lootItemId) then
                if quantity[lootItemId] then
                    quantity[lootItemId] = quantity[lootItemId] + qty
                else
                    quantity[lootItemId] = qty;
                end

                if has_not_value(items, lootItemId) then
                    table.insert(items, lootItemId)
                end

                f.fontStrings[lootItemId]:SetText(nme .. " (" .. quantity[lootItemId] .. ")")
            end
        end
    end
end

function SkinningPerHour:Run()
    local background = "Interface\\TutorialFrame\\TutorialFrameBackground"

    f = CreateFrame("Frame",nil,UIParent)
    f:SetFrameStrata("BACKGROUND")
    f:SetWidth(400) -- Set these to whatever height/width is needed 
    f:SetHeight(#_items * 23) -- for your Texture

    local t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture(background)
    t:SetAllPoints(f)
    f.texture = t

    f:SetPoint("TOPLEFT",10,-10)
    f.fontStrings = {}

    items, quantity = SkinningPerHour:CheckItemsInBags(f)

    for index, value in pairs(items) do
        SkinningPerHour:PresentBagItems(index, value, quantity[value])
    end

    f:RegisterEvent("LOOT_OPENED")
    f:SetScript("OnEvent", function(self, event, ...)
        if event == "LOOT_OPENED" then
            event__LOOT_READY(f)
        end
    end);

    f:Show()
end

SkinningPerHour:Run()