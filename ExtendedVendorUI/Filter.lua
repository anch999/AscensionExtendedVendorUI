local EV = LibStub("AceAddon-3.0"):GetAddon("ExtendedVendorUI")

local FilterList = {
    {"Hide Filtered", "HideFiltered"},
    {"Unlearned Recipes Only", "HideLearnedRecipes"},
    {"Filter Known Skill Cars/Vanity Items", "HideVanity"},
    {
        Name = "Recipe Filtering",
        {
        Name = "Recipe Filters",
        {"Hide Already Known", "HideKnown"},
        {"Hide Already Purchased", "HidePurchased"}
        }
    },
    {
        Name = "Stats",
		{
        Name ="Primary Stats",
        {"Strength", "ITEM_MOD_STRENGTH_SHORT"},
        {"Agility", "ITEM_MOD_AGILITY_SHORT"},
        {"Intellect", "ITEM_MOD_INTELLECT_SHORT"},
        {"Spirit", "ITEM_MOD_SPIRIT_SHORT"},
        },
        {
        Name = "Secondary Stats",
        {"Attack Power", "ITEM_MOD_ATTACK_POWER_SHORT"},
        {"Spell Power", "ITEM_MOD_SPELL_POWER_SHORT"},
        {"Crit", "ITEM_MOD_CRIT_RATING_SHORT"},
        {"Hit", "ITEM_MOD_HIT_RATING_SHORT"},
        {"Haste", "ITEM_MOD_HASTE_RATING_SHORT"},
        {"Armor Pen", "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT"},
        {"Spell Pen", "ITEM_MOD_SPELL_PENETRATION_SHORT"},
        },
        {
        Name = "Defensive Stats",
        {"Defense", "ITEM_MOD_DEFENSE_SKILL_RATING_SHORT"},
        {"Dodge", "ITEM_MOD_DODGE_RATING_SHORT"},
        {"Parry", "ITEM_MOD_PARRY_RATING_SHORT"},
        {"Block", "ITEM_MOD_BLOCK_RATING_SHORT"},
        {"Block Value", "ITEM_MOD_BLOCK_VALUE_SHORT"},
        {"Resilience", "ITEM_MOD_RESILIENCE_RATING"}
        }
    },
    {
        Name = "Armor",
        {
        Name = "Armor Type",
        {"Cloth", "Cloth"},
        {"Leather", "Leather"},
        {"Mail", "Mail"},
        {"Plate", "Plate"},
        }
    },
    {
        Name = "Slots",
        {
        Name = "Armor Slot",
        {"Head", "INVTYPE_HEAD"},
        {"Shoulder", "INVTYPE_SHOULDER"},
        {"Cloak", "INVTYPE_CLOAK"},
        {"Chest", "INVTYPE_CHEST"},
        {"Waist", "INVTYPE_WAIST"},
        {"Legs", "INVTYPE_LEGS"},
        {"Feet", "INVTYPE_FEET"},
        {"Wrist", "INVTYPE_WRIST"},
        {"Hand", "INVTYPE_HAND"},
        },
        {
        Name = "Accessories",
        {"Neck", "INVTYPE_NECK"},
        {"Finger", "INVTYPE_FINGER"},
        {"Trinket", "INVTYPE_TRINKET"},
        },
        {
        Name = "Weapons",
        {"One Handed Weapon", "INVTYPE_WEAPON"},
        {"Two Handed Weapon", "INVTYPE_2HWEAPON"},
        {"Mainhand", "INVTYPE_WEAPONMAINHAND"},
        {"Offhand", "INVTYPE_WEAPONOFFHAND"},
        {"Holdable", "INVTYPE_HOLDABLE"},
        {"Ranged", "INVTYPE_RANGED"},
        {"Thrown", "INVTYPE_THROWN"},
        {"Rangedright", "INVTYPE_RANGEDRIGHT"},
        {"Relic", "INVTYPE_RELIC"},
        {"Shield", "INVTYPE_SHIELD"},
        }
    },
    {
        Name = "Quality",
        {
        Name = "Qualitys",
        {"Common", 1},
        {"Uncommon", 2},
        {"Rare", 3},
        {"Epic", 4},
        {"Vanity", 6},
        {"Heirloom", 7},
        }
    },
    {
        Name = "Difficulty",
        {
        Name = "Difficulties",
            {"Normal", "Normal"},
            {"Heroic Raid", "Heroic Raid"},
            {"Mythic Raid", "Mythic Raid"},
            {"Ascended Raid", "Ascended Raid"},
        }
    }
}


function EV:UpdateFilterMenu(level, value)
    if level == 1 then
        for _, filter in ipairs(FilterList) do
            if filter.Name then
                local checked = self:GetFilter(filter.Name)
                self.Dewdrop:AddLine(
                    'textHeight', self.db.txtSize,
                    'textWidth', self.db.txtSize,
                    'text', filter.Name,
                    'hasArrow', true,
                    'value', filter,
                    'isRadio', true,
                    'checked', checked,
                    'func', function() self:SetFilter(filter.Name) end
                )
            else
                local checked = self:GetFilter(filter[2])
                self.Dewdrop:AddLine(
                    'textHeight', self.db.txtSize,
                    'textWidth', self.db.txtSize,
                    'isRadio', true,
                    'text', filter[1],
                    'checked', checked,
                    'func', function() self:SetFilter(filter[2]) end
                )
            end
        end
        self:CloseDewDrop(true, 65)
    elseif level == 2 then
        for _, filterGroup in ipairs(value) do
            if filterGroup.Name then
                self.Dewdrop:AddLine(
                    'textHeight', self.db.txtSize,
                    'textWidth', self.db.txtSize,
                    'text', filterGroup.Name,
                    'isTitle', true,
                    'notCheckable', true
                )
            end
            for _, filter in ipairs(filterGroup) do
                local checked = self:GetFilter({filterGroup.Name, filter[2]})
                self.Dewdrop:AddLine(
                    'textHeight', self.db.txtSize,
                    'textWidth', self.db.txtSize,
                    'isRadio', true,
                    'text', filter[1],
                    'checked', checked,
                    'func', function() self:SetFilter({filterGroup.Name, filter[2]}) end
                )
            end
        end
        self:CloseDewDrop(true, 40)
    end
end

function EV:SetFilter(filter)
    self.db.FilterList = self.db.FilterList or {}
    if type(filter) == "table" then
        self.db.FilterList[filter[1]] = self.db.FilterList[filter[1]] or {}
        self.db.FilterList[filter[1]][filter[2]] = not self.db.FilterList[filter[1]][filter[2]]
    else
        self.db.FilterList[filter] = not self.db.FilterList[filter]
    end
    self.UpdateMerchantInfo()
end

function EV:GetFilter(filter)
    if type(filter) == "table" and self.db.FilterList[filter[1]] then
        return self.db.FilterList[filter[1]][filter[2]] or false
    else
        return self.db.FilterList[filter] or false
    end
end

function EV:IsFiltered(link, itemId, isKnown, isCollectionItemKnow, search, itemType, name, quality, itemSubType, itemEquipLoc, isHeroic, isMythic, isAscended)
    local isFiltered, validSlot
    local filters = self.db.FilterList

    -- check search filter
    if (string.len(search) > 0) then
        if (not string.find(string.lower(name), string.lower(search), 1, true)) then
            isFiltered = true
        end
    end

    if not filters then return isFiltered end

    -- filter known skill cards
    if filters.HideVanity and isCollectionItemKnow then
        isFiltered = true
    end

    -- filter known recipes
    if filters["Recipe Filtering"] and filters["Recipe Filters"] and filters["Recipe Filters"].HideKnown and isKnown then
        isFiltered = true
    end

    -- filter purchased recipes
    if filters["Recipe Filtering"] and filters["Recipe Filters"] and filters["Recipe Filters"].HidePurchased then
        if (itemType == "ITEMTYPE_RECIPE") then
            if (GetItemCount(itemId) > 0) then
                isFiltered = true
            end
        end
    end

    -- check quality filter
    if filters.Quality and filters.Qualitys and not filters.Qualitys[quality] then
        isFiltered = true
    end

    local difficulties = {
        ["Normal"] = (not isHeroic and not isMythic and not isAscended),
        ["Heroic Raid"] = isHeroic,
        ["Mythic Raid"] = isMythic,
        ["Ascended Raid"] = isAscended,
    }

    -- check difficuilty filter
    if filters.Difficulty and filters.Difficulties then
        for dif, show in pairs(filters.Difficulties) do
            if show and difficulties[dif] then
                validSlot = true
            end
        end
        if not validSlot then
            isFiltered = true
        end
    end

    -- check armor filter
    if filters.Armor and filters["Armor Type"] and not filters["Armor Type"][itemSubType] then
        isFiltered = true
    end

    -- check slot filter
    if filters.Slots then
        for _, group in ipairs(FilterList[7]) do
            if filters[group.Name] and filters[group.Name][itemEquipLoc] then
                validSlot = true
            end
        end
        if not validSlot then
            isFiltered = true
        end
    end

    -- check stat filter
    if filters.Stats then
        local itemStats = GetItemStats(link)
        for itemsStats,_ in pairs(itemStats) do
            for _, group in pairs(FilterList[5]) do
                if filters[group.Name] then
                    for _, stats in ipairs(group) do
                        if filters[group.Name][itemsStats] then
                            validSlot = true
                        end
                    end
                end
            end
        end
        if not validSlot then
            isFiltered = true
        end
    end

    return isFiltered
end

-- ["robe"] = "INVTYPE_ROBE", note add a swap for robes  {"Body", "INVTYPE_BODY"},
function EV:OpenFilterMenu(button)
    GameTooltip:Hide()
    if self.Dewdrop:Open(button) then self.Dewdrop:Close() return end
    self.Dewdrop:Open(button,
    'point', function(parent)
      local point1, _, point2 = self:GetTipAnchor(button)
      return point1, point2
    end,
    'children', function(level, value)
        self:UpdateFilterMenu(level, value)
    end)
    if not self.worldFrameHook[button:GetName()] then
        WorldFrame:HookScript("OnEnter", function()
        if self.Dewdrop:IsOpen(button) then
            self.Dewdrop:Close()
        end
    end)
    self.worldFrameHook[button:GetName()] = true
    end
end

function EV:CloseDewDrop(divider, maxLenght)
    if divider then
        self:AddDividerLine(maxLenght)
    end
    self.Dewdrop:AddLine(
        'text', "Close Menu",
        'textR', 0,
        'textG', 1,
        'textB', 1,
        'textHeight', 12,
        'textWidth', 12,
        'closeWhenClicked', true,
        'notCheckable', true
    )
end