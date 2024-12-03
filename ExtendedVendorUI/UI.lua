local EV = LibStub("AceAddon-3.0"):GetAddon("ExtendedVendorUI")
local CYAN =  "|cff00ffff"
local LIMEGREEN = "|cFF32CD32"
--------------- Creates the main misc menu standalone button ---------------
local itemPerSubPage = 10
local itemsPerPage = 20
local numberPages = 1
local slotFilterIndex = 0
local statFilterIndex = 0
local fac = UnitFactionGroup("player")


local frameLoaded
function EV:CreateUI()
        if frameLoaded then return end
        -------------------Main Frame-------------------
        self.uiFrame = CreateFrame("FRAME", "ExtendedVendorUi", UIParent, "PortraitFrameTemplate")
        self.uiFrame:SetPoint("CENTER",0,0)
        self.uiFrame:SetSize(690,465)
        self.uiFrame:EnableMouse(true)
        self.uiFrame:SetMovable(true)
        self.uiFrame:SetFrameStrata("HIGH")
        self.uiFrame:RegisterForDrag("LeftButton")
        self.uiFrame:EnableKeyboard(true)
        self.uiFrame:SetToplevel(true)
        self.uiFrame:Hide()
        self.uiFrame:SetScript("OnShow", function() self:UiOnShow() end)
        self.uiFrame:SetScript("OnMouseDown", function()
            self.dewdrop:Close()
        end)
        self.uiFrame:SetScript("OnHide", function() EV.dewdrop:Close() end)
        self.uiFrame:SetScript("OnDragStart", function()
            self.uiFrame:StartMoving()
        end)
        self.uiFrame:SetScript("OnDragStop", function()
            self.uiFrame:StopMovingOrSizing()
        end)
        self.uiFrame:EnableMouseWheel()
        self.uiFrame:SetScript("OnMouseWheel", function(...) self:OnMouseWheel(...) end )
        --Add the ExtendedVendorUI to the special frames tables to enable closing wih the ESC key
	    tinsert(UISpecialFrames, "ExtendedVendorUi")

        --Loot Background
        self.uiFrame.itemPanel = CreateFrame("Frame", "ExtendedVendorUiItemFrame", self.uiFrame, "InsetFrameTemplate2")
        self.uiFrame.itemPanel:SetSize((self.uiFrame:GetWidth()-20),375)
        self.uiFrame.itemPanel:SetPoint("CENTER", self.uiFrame, 0, -14)
        self.uiFrame.itemPanel:EnableMouse()
        self.uiFrame.itemPanel:EnableMouseWheel()


        self.uiFrame.repairFrame = CreateFrame("Frame", "ExtendedVendorUiRepairFrame", self.uiFrame, "InsetFrameTemplate2")
        self.uiFrame.repairFrame:SetSize(150, 55)
        self.uiFrame.repairFrame:SetPoint("BOTTOMLEFT", 18, 38)

        self.uiFrame.buyBackFrame = CreateFrame("Frame", "ExtendedVendorUiBuyBackFrame", self.uiFrame, "InsetFrameTemplate2")
        self.uiFrame.buyBackFrame:SetSize(165, self.uiFrame.repairFrame:GetHeight())
        self.uiFrame.buyBackFrame:SetPoint("LEFT", self.uiFrame.repairFrame, "RIGHT",  0, 0)



        for buttonNum = 1, itemsPerPage do
            if _G["MerchantItem" .. buttonNum] then
                _G["MerchantItem" .. buttonNum]:SetParent(self.uiFrame.itemPanel)
            else
                CreateFrame("Frame", "MerchantItem" .. buttonNum, self.uiFrame.itemPanel, "MerchantItemTemplate")
            end
        end
        MerchantNextPageButton:SetParent(self.uiFrame.itemPanel)
        MerchantNextPageButton:ClearAllPoints()
        MerchantNextPageButton:SetPoint("BOTTOMRIGHT", self.uiFrame.itemPanel, -50, 17)
        MerchantPageText:SetParent(self.uiFrame.itemPanel)
        MerchantPageText:ClearAllPoints()
        MerchantPageText:SetPoint("RIGHT", MerchantNextPageButton, "LEFT", -30, 0)
        MerchantPrevPageButton:SetParent(self.uiFrame.itemPanel)
        MerchantPrevPageButton:ClearAllPoints()
        MerchantPrevPageButton:SetPoint("RIGHT", MerchantPageText, "LEFT", -30, 0)

        self.uiFrame.currencyBar = CreateFrame("Frame", nil, self.uiFrame, "CurrencyBarClassicTemplate")
        self.uiFrame.currencyBar:SetSize((self.uiFrame:GetWidth()-24), 23)
        self.uiFrame.currencyBar:SetPoint("BOTTOM", self.uiFrame, 0, 7)
        MerchantMoneyFrame:SetParent(self.uiFrame)
        MerchantMoneyFrame:ClearAllPoints()
        MerchantMoneyFrame:SetPoint("RIGHT", self.uiFrame.currencyBar)

        MerchantRepairAllButton:SetParent(self.uiFrame.repairFrame)
        MerchantRepairItemButton:SetParent(self.uiFrame.repairFrame)
        MerchantGuildBankRepairButton:SetParent(self.uiFrame.repairFrame)
        MerchantBuyBackItem:SetParent(self.uiFrame.buyBackFrame)
        MerchantPageText:SetParent(self.uiFrame.repairFrame)
        MerchantRepairSettingsButton:SetParent(self.uiFrame.repairFrame)




        self.UpdateMerchantInfoOld = MerchantFrame_UpdateMerchantInfo
        MerchantFrame_UpdateMerchantInfo = EV.UpdateMerchantInfo
        self.UpdateBuybackInfoOld = MerchantFrame_UpdateBuybackInfo
        MerchantFrame_UpdateBuybackInfo = EV.UpdateBuybackInfo
        self.UpdateRepairButtonsOld = MerchantFrame_UpdateRepairButtons
        MerchantFrame_UpdateRepairButtons = EV.UpdateRepairButtons

        self.selectedTab = "merchantTab"
        self.uiFrame.tabList = {}
         -------------------Merchant Tab Button-------------------
        self.uiFrame.merchantTabButton = CreateFrame("CheckButton", "ExtendedVendorUiMerchantTabButton", self.uiFrame, "ExtendedVendorUITabTemplate")
        self.uiFrame.merchantTabButton:SetPoint("BOTTOMLEFT", 5, -30)
        self.uiFrame.merchantTabButton:SetWidth(80)
        self.uiFrame.merchantTabButton.Text:SetText("Merchant")
        self.uiFrame.merchantTabButton.Text:SetPoint("CENTER")
        self.uiFrame.merchantTabButton:SetScript("OnClick", function()
            self.selectedTab = "merchantTab"
            PanelTemplates_SetTab(MerchantFrame, 1)
            self:SetFrameTab()
        end)
        tinsert(self.uiFrame.tabList, "merchantTab")

        -------------------Buyback Tab Button-------------------
        self.uiFrame.buybackTabButton = CreateFrame("CheckButton", "ExtendedVendorUiBuybackTabButton", self.uiFrame, "ExtendedVendorUITabTemplate")
        self.uiFrame.buybackTabButton:SetPoint("LEFT", self.uiFrame.merchantTabButton, "RIGHT", 0, 0)
        self.uiFrame.buybackTabButton:SetWidth(80)
        self.uiFrame.buybackTabButton.Text:SetText("Buyback")
        self.uiFrame.buybackTabButton.Text:SetPoint("CENTER")
        self.uiFrame.buybackTabButton:SetScript("OnClick", function(button)
            self.selectedTab = "buybackTab"
            PanelTemplates_SetTab(MerchantFrame, 2)
            self:SetFrameTab()
        end)
        tinsert(self.uiFrame.tabList, "buybackTab")


        self.uiFrame.filterButton = CreateFrame("Button", "ExtendedVendorUiFilterButton", self.uiFrame, "ExtendedVendorUIDropMenuTemplate")
        self.uiFrame.filterButton:SetPoint("TOPRIGHT", self.uiFrame, -13, -33)
        self.uiFrame.filterButton:SetScript("OnClick", function(self)
        end)

        --Search Edit Box
        self.uiFrame.searchbox = CreateFrame("EditBox", "ExtendedVendorUiSearchBox", self.uiFrame, "SearchBoxTemplate")
        self.uiFrame.searchbox:SetSize(190,30)
        self.uiFrame.searchbox:SetPoint("RIGHT", self.uiFrame.filterButton, "LEFT", -10, 1)
        self.uiFrame.searchbox:SetScript("OnEnterPressed", function(editBox)
            if self.uiFrame.searchbox:GetText() ~= "" then
                self:UpdateMerchantInfo()
            end
        end)
        self.uiFrame.searchbox:SetScript("OnTextChanged", function(editBox)
            self:UpdateMerchantInfo()
            if editBox:HasFocus() then
                SearchBoxTemplate_OnTextChanged(editBox)
            end
        end)
        self.uiFrame.searchbox.clearButton:HookScript("OnClick", function()
            self:UpdateMerchantInfo()
        end)

        function MerchantItemButton_OnModifiedClick(self, button)
            if ( ExtendedVendorUI.selectedTab == "merchantTab" ) then
                -- Is merchant frame
                if ( HandleModifiedItemClick(GetMerchantItemLink(self:GetID())) ) then
                    return;
                end
                    if IsAltKeyDown() then
                        local maxStack = GetMerchantItemMaxStack(self:GetID());
                        if ( self.extendedCost ) then
                            MerchantFrame_ConfirmExtendedItemCost(self);
                        elseif ( self.price and self.price >= MERCHANT_HIGH_PRICE_COST ) then
                            MerchantFrame_ConfirmHighCostItem(self);
                        else
                            BuyMerchantItem(self:GetID(),maxStack);
                        end
                    elseif ( IsModifiedClick("SPLITSTACK") ) then
                        local maxStack = GetMerchantItemMaxStack(self:GetID());
                        if ( self.price and (self.price > 0) ) then
                            local canAfford = floor(GetMoney() / self.price);
                            if ( canAfford < maxStack ) then
                                maxStack = canAfford;
                            end
                        end
                        OpenStackSplitFrame(1000, self, "BOTTOMLEFT", "TOPLEFT");
                        return
                end
            else
                HandleModifiedItemClick(GetBuybackItemLink(self:GetID()))
            end
        end

        frameLoaded = true
end

function EV:UpdateButtonPositions()
    self = ExtendedVendorUI
    local vertSpacing, horizSpacing

    if self.selectedTab == "buybackTab" then
        vertSpacing = -30
        horizSpacing = 50
    else
        vertSpacing = -16
        horizSpacing = 12
    end
    for i = 1, itemsPerPage do
        local button = _G["MerchantItem" .. i]
        if self.selectedTab == "buybackTab" then
            if (i > BUYBACK_ITEMS_PER_PAGE) then
                button:Hide()
            else
                if (i == 1) then
                    button:SetPoint("TOPLEFT", ExtendedVendorUiItemFrame, "TOPLEFT", 60, -45)
                else
                    if ((i % 3) == 1) then
                        button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 3)], "BOTTOMLEFT", 0, vertSpacing)
                    else
                        button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 1)], "TOPRIGHT", horizSpacing, 0)
                    end
                end
            end
        else
            button:Show()
            if ((i % itemPerSubPage) == 1) then
                if (i == 1) then
                    button:SetPoint("TOPLEFT", ExtendedVendorUiItemFrame, "TOPLEFT", 15, -15)
                else
                    button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - (itemPerSubPage - 1))], "TOPRIGHT", 12, 0)
                end
            else
                if ((i % 2) == 1) then
                    button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 2)], "BOTTOMLEFT", 0, vertSpacing)
                else
                    button:SetPoint("TOPLEFT", _G["MerchantItem" .. (i - 1)], "TOPRIGHT", horizSpacing, 0)
                end
            end
        end
    end

end

local numButtons = 0
--========================================
-- Show merchant page
--========================================
function EV:UpdateMerchantInfo()
    self = ExtendedVendorUI
    self:UpdateMerchantInfoOld()
    self:UpdateButtonPositions()

    -- set title and portrait
    self.uiFrame.TitleText:SetText(UnitName("NPC"))
    SetPortraitTexture(self.uiFrame.portrait, "NPC")

    -- locals
    local totalMerchantItems = GetMerchantNumItems()
    local visibleMerchantItems = 0
    local indexes = {}
    local search = string.trim(ExtendedVendorUiSearchBox:GetText())
	local name, texture, price, quantity, numAvailable, isUsable, extendedCost, r, g, b, notOptimal
    local link, quality, itemType, itemSubType, itemId, itemEquipLoc
    local isFiltered = false
    local isBoP = false
    local isKnown = false
    local isCollectionItemKnow = false

    -- **************************************************
    --  Pre-check filtering if hiding filtered items
    -- **************************************************
    if (EXTVENDOR_DATA['config']['hide_filtered']) then
        visibleMerchantItems = 0
        for i = 1, totalMerchantItems, 1 do
		    name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(i)
            if (name) then
                isFiltered = false
                link = GetMerchantItemLink(i)
                quality = 1
                isKnown = false
                isBoP = false
                isCollectionItemKnow = false

                -- get info from item link
                if (link) then
                    isBoP, isKnown = ExtVendor_GetExtendedItemInfo(link)
                    itemId = GetItemInfoFromHyperlink(link)
                    isCollectionItemKnow = C_VanityCollection.IsCollectionItemOwned(itemId)
                    _, _, quality, _, _, itemType, itemSubType, _, itemEquipLoc, _, _ = self:GetItemInfo(link)
                end
                -- filter known recipes
                if (EXTVENDOR_DATA['config']['hide_known_recipes'] and isKnown) then
                    isFiltered = true
                end
                -- filter known skill cards
                if (EXTVENDOR_DATA['config']['hide_known_ascension_collection_items'] and isCollectionItemKnow) then
                    isFiltered = true
                end
                -- filter purchased recipes
                if (EXTVENDOR_DATA['config']['filter_purchased_recipes']) then
                    if (itemType == "ITEMTYPE_RECIPE") then
                        if (GetItemCount(itemId) > 0) then
                            isFiltered = true
                        end
                    end
                end
                -- check search filter
                if (string.len(search) > 0) then
                    if (not string.find(string.lower(name), string.lower(search), 1, true)) then
                        isFiltered = true
                    end
                end
                -- check quality filter
                if (EXTVENDOR_SELECTED_QUALITY > 0) then
                    if ((quality < EXTVENDOR_SELECTED_QUALITY) or ((quality > EXTVENDOR_SELECTED_QUALITY) and EXTVENDOR_SPECIFIC_QUALITY)) then
                        isFiltered = true
                    end
                end
                -- check armor filter
                if EXTVENDOR_DATA['config']['armor_filter'] and not EXTVENDOR_DATA['config']['armor_filter']["All"] and itemType == "Armor" then
                    for i, v in pairs(EXTVENDOR_DATA['config']['armor_filter']) do
                        if i == itemSubType and not v then
                            isFiltered = true
                        end
                    end   
                end
                -- check slot filter
                if (slotFilterIndex > 0) then
                    if (SLOT_FILTERS[slotFilterIndex]) then
                        local validSlot = false
                        for _, slot in pairs(SLOT_FILTERS[slotFilterIndex]) do
                            if (slot == itemEquipLoc) then
                                validSlot = true
                            end
                        end
                        if (not validSlot) then
                            isFiltered = true
                        end
                    end
                end
                
                -- check stat filter
                if (statFilterIndex > 0) then
                    if (STAT_FILTERS[statFilterIndex]) and link then
                        local ItemStats = {}
                        GetItemStats(link, ItemStats)
                        local validSlot = false
                        for _, slot in pairs(STAT_FILTERS[statFilterIndex]) do
                            if (ItemStats[slot]) then
                                validSlot = true
                            end
                        end
                        if (not validSlot) then
                            isFiltered = true
                        end
                    end
                end

                -- ***** add item to list if not filtered *****
                if (not isFiltered) then
                    table.insert(indexes, i)
                    visibleMerchantItems = visibleMerchantItems + 1
                end
            end
        end
    else
        -- no item hiding, add all items to list
        visibleMerchantItems = totalMerchantItems
        for i = 1, totalMerchantItems, 1 do
            table.insert(indexes, i)
        end
    end

    -- validate current page shown
    if (MerchantFrame.page > math.max(1, math.ceil(visibleMerchantItems / MERCHANT_ITEMS_PER_PAGE))) then
        MerchantFrame.page = math.max(1, math.ceil(visibleMerchantItems / MERCHANT_ITEMS_PER_PAGE))
    end

    -- Show correct page count based on number of items shown
	MerchantPageText:SetFormattedText(MERCHANT_PAGE_NUMBER, MerchantFrame.page, math.ceil(visibleMerchantItems / MERCHANT_ITEMS_PER_PAGE))

    -- **************************************************
    --  Display items on merchant page
    -- **************************************************
    local isAltCurrency = {}
    
    if numButtons then
        for i = 1, numButtons, 1 do
            _G["MerchantFrame_AltCurrency"..i]:Hide()
            _G["MerchantFrame_AltCurrency_Icon"..i]:Hide()
        end
    end

    for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
        local index = ((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i
		local itemButton = _G["MerchantItem" .. i .. "ItemButton"]
        itemButton.link = nil
		local merchantButton = _G["MerchantItem" .. i]
		local merchantMoney = _G["MerchantItem" .. i .. "MoneyFrame"]
		local merchantAltCurrency = _G["MerchantItem" .. i .. "AltCurrencyFrame"]

        if (index <= visibleMerchantItems) then
			name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(indexes[index])
            if (name ~= nil) then
			    _G["MerchantItem" .. i.."Name"]:SetText(name)
			    SetItemButtonCount(itemButton, quantity)
			    SetItemButtonStock(itemButton, numAvailable)
			    SetItemButtonTexture(itemButton, texture)
                local honorPoints, arenaPoints = GetMerchantItemCostInfo(i)
                -- update item's currency info
			    if ( extendedCost and (price <= 0) ) then
				    itemButton.price = nil
				    itemButton.extendedCost = true
				    itemButton.link = GetMerchantItemLink(indexes[index])
				    itemButton.texture = texture
				    MerchantFrame_UpdateAltCurrency(indexes[index], i)
				    merchantAltCurrency:ClearAllPoints()
				    merchantAltCurrency:SetPoint("BOTTOMLEFT", "MerchantItem" .. i.."NameFrame", "BOTTOMLEFT", 0, 31)
				    merchantMoney:Hide()
				    merchantAltCurrency:Show()
                    if honorPoints > 0 then
                        isAltCurrency.honor = {"honor", true, "honor"}
                    elseif arenaPoints > 0 then
                        isAltCurrency.arena = {"arena", true, "arena"}
                    elseif _G["MerchantItem" .. i .. "AltCurrencyFrameItem1"].itemLink then 
                        local _, id = strsplit(":", _G["MerchantItem" .. i .. "AltCurrencyFrameItem1"].itemLink)
                        isAltCurrency[id] = {id}
                    end
			    elseif ( extendedCost and (price > 0) ) then
				    itemButton.price = price
				    itemButton.extendedCost = true
				    itemButton.link = GetMerchantItemLink(indexes[index])
				    itemButton.texture = texture
				    MerchantFrame_UpdateAltCurrency(indexes[index], i)
				    MoneyFrame_Update(merchantMoney:GetName(), price)
				    merchantAltCurrency:ClearAllPoints()
				    merchantAltCurrency:SetPoint("LEFT", merchantMoney:GetName(), "RIGHT", -14, 0)
				    merchantAltCurrency:Show()
				    merchantMoney:Show()
                    if honorPoints > 0 then
                        isAltCurrency.honor = {"honor", true, "honor"}
                    elseif arenaPoints > 0 then
                        isAltCurrency.arena = {"arena", true, "arena"}
                    elseif _G["MerchantItem" .. i .. "AltCurrencyFrameItem1"].itemLink then  
                        local _, id = strsplit(":", _G["MerchantItem" .. i .. "AltCurrencyFrameItem1"].itemLink)
                        isAltCurrency[id] = {id}
                    end
			    else
				    itemButton.price = price
				    itemButton.extendedCost = nil
				    itemButton.link = GetMerchantItemLink(indexes[index])
				    itemButton.texture = texture
				    MoneyFrame_Update(merchantMoney:GetName(), price)
				    merchantAltCurrency:Hide()
				    merchantMoney:Show()
			    end

                isBoP = false
                isKnown = false
                isFiltered = false
                isCollectionItemKnow = false

                quality = 1
                if (itemButton.link) then
                    isBoP, isKnown = ExtVendor_GetExtendedItemInfo(itemButton.link)
                    itemId = GetItemInfoFromHyperlink(itemButton.link)
                    isCollectionItemKnow = C_VanityCollection.IsCollectionItemOwned(itemId)
                    _, _, quality, _, _, itemType, itemSubType, _, itemEquipLoc, _, _ = self:GetItemInfo(itemButton.link)
                end

                -- set color
                r, g, b = GetItemQualityColor(quality)
                _G["MerchantItem" .. i .. "Name"]:SetTextColor(r, g, b)

                -- check filtering
                if (not EXTVENDOR_DATA['config']['hide_filtered']) then
                    -- check search filter
                    if (string.len(search) > 0) then
                        if (not string.find(string.lower(name), string.lower(search), 1, true)) then
                            isFiltered = true
                        end
                    end
                    -- check quality filter
                    if (EXTVENDOR_SELECTED_QUALITY > 0) then
                        if ((quality < EXTVENDOR_SELECTED_QUALITY) or ((quality > EXTVENDOR_SELECTED_QUALITY) and EXTVENDOR_SPECIFIC_QUALITY)) then
                            isFiltered = true
                        end
                    end
                    -- filter known recipes
                    if (EXTVENDOR_DATA['config']['hide_known_recipes'] and isKnown) then
                        isFiltered = true
                    end
                    -- filter known skill cards
                    if (EXTVENDOR_DATA['config']['hide_known_ascension_collection_items'] and isCollectionItemKnow) then
                        isFiltered = true
                    end
                    -- filter purchased recipes
                    if (EXTVENDOR_DATA['config']['filter_purchased_recipes']) then
                        if (itemType == "ITEMTYPE_RECIPE") then
                            if (GetItemCount(itemId) > 0) then
                                isFiltered = true
                            end
                        end
                    end
                    -- check armor filter
                    if EXTVENDOR_DATA['config']['armor_filter'] and not EXTVENDOR_DATA['config']['armor_filter']["All"] and itemType == "Armor" then
                        for i, v in pairs(EXTVENDOR_DATA['config']['armor_filter']) do
                            if i == itemSubType and not v then
                                isFiltered = true
                            end
                        end   
                    end
                    -- check slot filter
                    if (slotFilterIndex > 0) then
                        if (SLOT_FILTERS[slotFilterIndex]) then
                            local validSlot = false
                            for _, slot in pairs(SLOT_FILTERS[slotFilterIndex]) do
                                if (slot == itemEquipLoc) then
                                    validSlot = true
                                end
                            end
                            if (not validSlot) then
                                isFiltered = true
                            end
                        end
                    end

                    -- check stat filter
                    if (statFilterIndex > 0) then
                        if (STAT_FILTERS[statFilterIndex]) and itemButton.link then
                            local ItemStats = {}
                            GetItemStats(itemButton.link, ItemStats)
                            local validSlot = false
                            for _, slot in pairs(STAT_FILTERS[statFilterIndex]) do
                                if (ItemStats[slot]) then
                                    validSlot = true
                                end
                            end
                            if (not validSlot) then
                                isFiltered = true
                            end
                        end
                    end
                end

                ExtVendor_SearchDimItem(_G["MerchantItem" .. i], isFiltered)

			    itemButton.hasItem = true
			    itemButton:SetID(indexes[index])
			    itemButton:Show()
                local colorMult = 1.0
                local detailColor = {}
                local slotColor = {}
                -- unavailable items (limited stock, bought out) are darkened
			    if ( numAvailable == 0 ) then
                    colorMult = 0.5
                end
			    if ( not isUsable ) then
                    slotColor = {r = 1.0, g = 0, b = 0}
                    detailColor = {r = 1.0, g = 0, b = 0}
			    else
                    if (notOptimal) then
                        slotColor = {r = 0.25, g = 0.25, b = 0.25}
                        detailColor = {r = 0.5, g = 0, b = 0}
                    else
                        slotColor = {r = 1.0, g = 1.0, b = 1.0}
                        detailColor = {r = 0.5, g = 0.5, b = 0.5}
                    end
			    end
			    SetItemButtonNameFrameVertexColor(merchantButton, detailColor.r * colorMult, detailColor.g * colorMult, detailColor.b * colorMult)
			    SetItemButtonSlotVertexColor(merchantButton, slotColor.r * colorMult, slotColor.g * colorMult, slotColor.b * colorMult)
			    SetItemButtonTextureVertexColor(itemButton, slotColor.r * colorMult, slotColor.g * colorMult, slotColor.b * colorMult)
			    SetItemButtonNormalTextureVertexColor(itemButton, slotColor.r * colorMult, slotColor.g * colorMult, slotColor.b * colorMult)
            end
        else
			itemButton.price = nil
			itemButton.hasItem = nil
			itemButton:Hide()
			SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0.5, 0.5)
			SetItemButtonSlotVertexColor(merchantButton,0.4, 0.4, 0.4)
			_G["MerchantItem" .. i.."Name"]:SetText("")
			_G["MerchantItem" .. i.."MoneyFrame"]:Hide()
			_G["MerchantItem" .. i.."AltCurrencyFrame"]:Hide()
            ExtVendor_SearchDimItem(_G["MerchantItem" .. i], false)
        end
    end

    if isAltCurrency then
        self:UpdateAltCurrency(isAltCurrency)
    end
	self:UpdateRepairButtons()

	-- Handle vendor buy back item
	local buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable = GetBuybackItemInfo(GetNumBuybackItems())
	if ( buybackName ) then
		MerchantBuyBackItemName:SetText(buybackName)
		SetItemButtonCount(MerchantBuyBackItemItemButton, buybackQuantity)
		SetItemButtonStock(MerchantBuyBackItemItemButton, buybackNumAvailable)
		SetItemButtonTexture(MerchantBuyBackItemItemButton, buybackTexture)
		MerchantBuyBackItemMoneyFrame:Show()
		MoneyFrame_Update("MerchantBuyBackItemMoneyFrame", buybackPrice)
		MerchantBuyBackItem:Show()
	else
		MerchantBuyBackItemName:SetText("")
		MerchantBuyBackItemMoneyFrame:Hide()
		SetItemButtonTexture(MerchantBuyBackItemItemButton, "")
		SetItemButtonCount(MerchantBuyBackItemItemButton, 0)
		-- Hide the tooltip upon sale
		if ( GameTooltip:IsOwned(MerchantBuyBackItemItemButton) ) then
			GameTooltip:Hide()
		end
	end

	-- Handle paging buttons
	if ( visibleMerchantItems > MERCHANT_ITEMS_PER_PAGE ) then
		if ( MerchantFrame.page == 1 ) then
			MerchantPrevPageButton:Disable()
		else
			MerchantPrevPageButton:Enable()
		end
		if ( MerchantFrame.page == ceil(visibleMerchantItems / MERCHANT_ITEMS_PER_PAGE) or visibleMerchantItems == 0) then
			MerchantNextPageButton:Disable()
		else
			MerchantNextPageButton:Enable()
		end
        numberPages = ceil(visibleMerchantItems / MERCHANT_ITEMS_PER_PAGE)
		MerchantPageText:Show()
		MerchantPrevPageButton:Show()
		MerchantNextPageButton:Show()
	else
        numberPages = 1
		MerchantPageText:Hide()
		MerchantPrevPageButton:Hide()
		MerchantNextPageButton:Hide()
	end

	-- Show all merchant related items
	MerchantBuyBackItem:Show()

	-- Hide buyback related items
    for i = 13, MERCHANT_ITEMS_PER_PAGE, 1 do
	    _G["MerchantItem" .. i]:Show()
    end

    local numHiddenItems = math.max(0, totalMerchantItems - visibleMerchantItems)
    local hstring = (numHiddenItems == 1) and "SINGLE_ITEM_HIDDEN" or "MULTI_ITEMS_HIDDEN"
    MerchantFrameHiddenText:SetText(string.format(hstring, numHiddenItems))

    -- update text color for buyback slot
    local link = GetBuybackItemLink(GetNumBuybackItems())
    if (link) then
        local _, _, quality = self:GetItemInfo(link)
        local r, g, b = GetItemQualityColor(quality)
        MerchantBuyBackItemName:SetTextColor(r, g, b)
    end

    if (ExtVendor_GetQuickVendorList()) then
        ExtVendor_SetJunkButtonState(true)
    else
        ExtVendor_SetJunkButtonState(false)
    end
end

--========================================
-- Show buyback page
--========================================
function EV:UpdateBuybackInfo()
    self = ExtendedVendorUI
    self:UpdateBuybackInfoOld()
    self:UpdateButtonPositions()
    self:UpdateRepairButtons()
    -- apply coloring
    local btn, link, quality, r, g, b
    for i = 1, BUYBACK_ITEMS_PER_PAGE do
        btn = _G["MerchantItem" .. i]
        if (btn) then
            link = GetBuybackItemLink(i)
            if (link) then
                _, _, quality = self:GetItemInfo(link)
                r, g, b = GetItemQualityColor(quality)
                _G["MerchantItem" .. i .. "Name"]:SetTextColor(r, g, b)
            end
            self:SearchDimItem(btn, false)
        end
    end
    
end

--========================================
-- Dims or shows an item frame
--========================================
function EV:SearchDimItem(itemFrame, isDimmed)

    if (not itemFrame) then return end

    local alpha

    if (isDimmed) then
        alpha = 0.2
    else
        alpha = 1
    end
    itemFrame:SetAlpha(alpha)

    local btn = _G[itemFrame:GetName() .. "ItemButton"]
    if (isDimmed) then
        btn:Disable()
    else
        btn:Enable()
    end

end

--========================================
-- Mouse wheel handler
--========================================
function EV:OnMouseWheel(self, delta)
    if (delta > 0) then
        if ((MerchantFrame.page > 1) and (MerchantPrevPageButton:IsEnabled()) and (MerchantPrevPageButton:IsVisible())) then
            MerchantPrevPageButton:Click()
        end
    else
        if ((MerchantFrame.page < numberPages) and (MerchantNextPageButton:IsEnabled()) and (MerchantNextPageButton:IsVisible())) then
            MerchantNextPageButton:Click()
        end
    end
end

function EV:UiOnShow()
    self.selectedTab = "merchantTab"
    self:SetFrameTab()
    self.uiFrame:Show()
end

function EV:SetFrameTab()
    for _, tab in pairs(self.uiFrame.tabList) do
        if tab ~= self.selectedTab then
            self.uiFrame[tab.."Button"]:SetChecked(false)
            self.uiFrame[tab.."Button"]:UpdateButton()
        end
    end
    self.uiFrame[self.selectedTab.."Button"]:SetChecked(true)
    self.uiFrame[self.selectedTab.."Button"]:UpdateButton()
    if self.selectedTab == "merchantTab" then
        self:UpdateMerchantInfo()
    elseif self.selectedTab == "buybackTab" then
        self:UpdateBuybackInfo()
    end
end



function EV:UpdateAltCurrency(currencyTable)
    local i = 1
    local sorted = {}
    for id, v in pairs(currencyTable) do
        if id == "honor" or id == "arena" then
            sorted[id] = v
        else
            sorted[self:GetItemInfo(v[1])] = v
        end
    end
    table.sort(sorted)
    for _,currency in self:PairsByKeys(sorted) do
        if currency[1] then
            local button = self:CreateAtlCurrencys(i)
            if currency[2] and currency[3] == "honor" then
                button.itemID = "Honor Points"
                button.icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..fac);
                button.Lable:SetText("Honor Points: |cffffffff"..GetHonorCurrency())
                button.icon:SetSize(16,16);
                EV:ScheduleTimer(updateCurrency, .2, "honor", button)
            elseif currency[2] and currency[3] == "arena" then
                button.itemID = "Arena Points"
                button.icon:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon");
                button.Lable:SetText("Arena Points: |cffffffff"..GetArenaCurrency())
                button.icon:SetSize(16,16);
                EV:ScheduleTimer(updateCurrency, .2, "arena", button)
            else
                button.itemID = currency[1]
                button.icon:SetTexture(GetItemIcon(currency[1]));
                button.Lable:SetText("|cffffffff"..GetItemCount(currency[1]))
                button.icon:SetSize(13,13);
            end
            self:SetTooltip(button)
            if i == 1 then
                button:ClearAllPoints()
                button:SetPoint("RIGHT","MerchantMoneyFrameGoldButton", (- MerchantMoneyFrameGoldButtonText:GetStringWidth()) - 20,-1);
            else
                local lastFrame = i - 1
                button:ClearAllPoints()
                button:SetPoint("RIGHT",_G["MerchantFrame_AltCurrency"..lastFrame], (- button.Lable:GetStringWidth()) - 20,0);
            end
            button:SetWidth(button.Lable:GetStringWidth() + 15)
            button:Show()
            button.icon:Show()
            i = i + 1
        end
    end
end

function EV:SetTooltip(button)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -13, -50)
        if tonumber(button.itemID) then
        GameTooltip:SetHyperlink(select(2,EV:GetItemInfo(button.itemID)));
        else
            GameTooltip:AddLine(button.itemID)
        end
        GameTooltip:Show()
    end)
end

function EV:PairsByKeys(t, reverse)
    local function order(a, b)
        if reverse then
            return a > b
        else
            return a<b
        end
    end
    local a = {}
    for n in pairs(t) do
      table.insert(a, n)
    end
    table.sort(a, function(a,b) return order(a,b)  end)

    local i = 0
    local iter = function()
      i = i + 1
      if a[i] == nil then
        return nil
      else
        return a[i], t[a[i]]
      end
    end
    return iter
end

function EV:CreateAtlCurrencys(num)
    if _G["MerchantFrame_AltCurrency"..num] then return _G["MerchantFrame_AltCurrency"..num] end
    local altCurrencyFrame = "MerchantFrame_AltCurrency"..num
    local altCurrencyFrameIcon = "MerchantFrame_AltCurrency_Icon"..num
    local button = CreateFrame("Button", altCurrencyFrame, ExtendedVendorUi)
    button:SetSize(100,15)
    button.icon = button:CreateTexture(altCurrencyFrameIcon,"ARTWORK");
    button.icon:SetSize(13,13);
    button.icon:SetPoint("RIGHT", altCurrencyFrame,0,0);
	button.Lable = button:CreateFontString(nil, "BORDER", "GameFontNormal");
    button.Lable:SetPoint("RIGHT", altCurrencyFrameIcon, -15, 1);
	button.Lable:SetJustifyH("RIGHT");
    button:SetScript("OnLeave", function () GameTooltip:Hide() end)
    button:Hide()
    numButtons = numButtons + 1
    return _G[altCurrencyFrame]
end

function EV:UpdateRepairButtons()
    self = ExtendedVendorUI
    self:UpdateRepairButtonsOld()
    if self.selectedTab == "merchantTab" then
        self.uiFrame.repairFrame:Show()
        self.uiFrame.buyBackFrame:Show()
    else
        self.uiFrame.repairFrame:Hide()
        self.uiFrame.buyBackFrame:Hide()
    end
    MerchantRepairAllButton:ClearAllPoints()
    MerchantRepairAllButton:SetPoint("LEFT", self.uiFrame.repairFrame, 7, 0)
    MerchantRepairItemButton:ClearAllPoints()
    MerchantRepairItemButton:SetPoint("LEFT", MerchantRepairAllButton, "RIGHT", 5, 0)
    MerchantGuildBankRepairButton:ClearAllPoints()
    MerchantGuildBankRepairButton:SetPoint("LEFT", MerchantRepairItemButton, "RIGHT", 5, 0)
    MerchantRepairSettingsButton:ClearAllPoints()
    MerchantRepairSettingsButton:SetPoint("TOPRIGHT", self.uiFrame.repairFrame, -3, -3)
    MerchantBuyBackItem:ClearAllPoints()
    MerchantBuyBackItem:SetPoint("LEFT", self.uiFrame.repairFrame, "RIGHT", 9, -1.2)

end

--sets up the drop down menu for any menus
function EV:DewdropRegister(button)
    if self.dewdrop:IsOpen(button) then self.dewdrop:Close() return end
    self.dewdrop:Register(button,
        'point', function(parent)
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value)
            for name, char in pairs(self.containersDB) do
                self.dewdrop:AddLine(
                    'text', name,
                    'func', function()
                        self.selectedCharacter = name
                        self.uiFrame.characterSelect:SetText(self.selectedCharacter)
                        self:SetScrollFrame()
                    end,
                    'textHeight', self.db.txtSize,
                    'textWidth', self.db.txtSize,
                    'closeWhenClicked', true,
                    'notCheckable', true
                )
            end
            self:AddDividerLine(35)
            self.dewdrop:AddLine(
				'text', "|cFF00FFFFClose Menu",
                'textHeight', self.db.txtSize,
                'textWidth', self.db.txtSize,
				'closeWhenClicked', true,
				'notCheckable', true
			)
		end,
		'dontHook', true
	)
    self.dewdrop:Open(button)

    GameTooltip:Hide()
end
