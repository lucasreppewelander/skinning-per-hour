SkinningPerHour = { }

-- skinning items
_items = {172097, 172092, 172089, 172094, 172096}
BAGS = {0, 1, 2, 3, 4}
-- GetContainerItemID(bag, slot) -- loop trough container and find the items above

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

function SkinningPerHour:Initialize()
    local background = "Interface\\TutorialFrame\\TutorialFrameBackground"

    local f = CreateFrame("Frame",nil,UIParent)
    f:SetFrameStrata("BACKGROUND")
    f:SetWidth(400) -- Set these to whatever height/width is needed 
    f:SetHeight(#_items * 23) -- for your Texture

    local t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture(background)
    t:SetAllPoints(f)
    f.texture = t

    f:SetPoint("TOPLEFT",10,-10)
    return f
end

function SkinningPerHour:CheckItemsInBags(f)
    items = {}

    for i=0, 4 do
        bagSlots = GetContainerNumSlots(i)
        slotsCheckLeft = bagSlots
        slotIndex = 0

        while ( slotsCheckLeft > 0 ) do
            itemID = GetContainerItemID(i, slotIndex)

            if has_value(_items, itemID) then
                table.insert(items, itemID)

                -- need to not append these to items if the already exists
                -- but i do need to count them to get total amount of each item
                -- that i currently have in my bags
                if has_not_value(items, itemID) then
                    
                end
            end

            slotIndex = slotIndex+1
            slotsCheckLeft = slotsCheckLeft-1
        end
    end

    return items
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

function SkinningPerHour:PresentBagItems(i, itemID)
    local itemName = C_Item.GetItemNameByID(tostring(itemID))
    local quality = C_Item.GetItemQualityByID(tostring(itemID))
    local range = i * 20
    local negative = -range
    
    local t = f:CreateFontString(f, "OVERLAY", "GameTooltipText")
    t:SetPoint("TOPLEFT", 20, negative)
    t:SetTextColor(SkinningPerHour:GetColorByName(quality))

    -- 163 53 238

    t:SetText(itemName)
end

function SkinningPerHour:Run()
    f = SkinningPerHour:Initialize()

    items = SkinningPerHour:CheckItemsInBags(f)

    for index, value in pairs(items) do
        SkinningPerHour:PresentBagItems(index, value)
    end    

    f:Show()
end

SkinningPerHour:Run()