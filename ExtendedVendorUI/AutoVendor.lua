local EV = LibStub("AceAddon-3.0"):GetAddon("ExtendedVendorUI")
local CYAN =  "|cff00ffff"
local LIMEGREEN = "|cFF32CD32"
local checked
local checkedList = {}
EV.autoVendorListNames = { whiteList = "Globle WhiteList", blackList = "BlackList", charWhiteList = GetUnitName("player").."s WhiteList"}

function EV:AutoVendorConfigOpen()
    self:AutoVendorFrameCreate()
    self.autoVendorFrame:Show()
    self:ListScrollFrameUpdate()
end

local frameLoaded
function EV:AutoVendorFrameCreate()
        if frameLoaded then return end
        self.selectedList = "whiteList"

        self.autoVendorFrame = CreateFrame("FRAME", "ExtendedVendorUIAutoVendorFrame", UIParent,"UIPanelDialogTemplate")
        self.autoVendorFrame:SetSize(400,500)
        self.autoVendorFrame:SetPoint("CENTER",0,0)
        self.autoVendorFrame:EnableMouse(true)
        self.autoVendorFrame:SetMovable(true)
        self.autoVendorFrame:SetToplevel(true)
        self.autoVendorFrame:RegisterForDrag("LeftButton")
        self.autoVendorFrame:SetScript("OnDragStart", function() self.autoVendorFrame:StartMoving() end)
        self.autoVendorFrame:SetScript("OnDragStop", function() self.autoVendorFrame:StopMovingOrSizing() end)
        self.autoVendorFrame:SetScript("OnShow", function() end)
        self.autoVendorFrame:SetScript("OnHide", function()
            checked = nil
            wipe(checkedList)
        end)
        self.autoVendorFrame.TitleText = self.autoVendorFrame:CreateFontString()
        self.autoVendorFrame.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 12)
        self.autoVendorFrame.TitleText:SetFontObject(GameFontNormal)
        self.autoVendorFrame.TitleText:SetText("Auto Vendor Setup")
        self.autoVendorFrame.TitleText:SetPoint("TOP", 0, -9)
        self.autoVendorFrame.TitleText:SetShadowOffset(1,-1)
        self.autoVendorFrame:Hide()
        --Add the Frame to the special frames tables to enable closing wih the ESC key
	    tinsert(UISpecialFrames, "ExtendedVendorUIAutoVendorFrame")

        --List selection dropdown
        self.autoVendorFrame.listSelection = CreateFrame("Button", "ExtendedVendorUiListSelection", self.autoVendorFrame, "ExtendedVendorUIDropMenuTemplate")
        self.autoVendorFrame.listSelection:SetWidth(197)
        self.autoVendorFrame.listSelection:SetPoint("TOPLEFT", self.autoVendorFrame, 20, -45)
        self.autoVendorFrame.listSelection:SetScript("OnClick", function(button)
            if self.dewdrop:IsOpen() then
                self.dewdrop:Close()
            else
                self:OpenAutoVendorListMenu(button)
            end
        end)
        self.autoVendorFrame.listSelection:SetScript("OnShow", function()
            self.autoVendorFrame.listSelection:SetText(self.autoVendorListNames[self.selectedList])
            checked = nil
            wipe(checkedList)
            self:ListScrollFrameUpdate()
        end)

        --Search Edit Box
        self.autoVendorFrame.searchbox = CreateFrame("EditBox", "ExtendedVendorUiListFrameSearch", self.autoVendorFrame, "SearchBoxTemplate")
        self.autoVendorFrame.searchbox:SetSize(190,30)
        self.autoVendorFrame.searchbox:SetPoint("TOPLEFT", self.autoVendorFrame.listSelection, "BOTTOMLEFT", 7, 0)
        self.autoVendorFrame.searchbox:SetScript("OnEnterPressed", function(editBox)
            if self.autoVendorFrame.searchbox:GetText() ~= "" then
                checked = nil
                wipe(checkedList)
                self:ListScrollFrameUpdate()
            end
        end)
        self.autoVendorFrame.searchbox:SetScript("OnTextChanged", function(editBox)
            checked = nil
            wipe(checkedList)
            if editBox:HasFocus() then
                SearchBoxTemplate_OnTextChanged(editBox)
            end
            self:ListScrollFrameUpdate()
        end)
        self.autoVendorFrame.searchbox.clearButton:HookScript("OnClick", function()
            checked = nil
            wipe(checkedList)
            self:ListScrollFrameUpdate()
        end)




------------------ScrollFrameTooltips---------------------------
	local function ItemTemplate_OnEnter(self)
		if not self.link then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -13, -50)
		GameTooltip:SetHyperlink(self.link)
		GameTooltip:Show()
	end

	local function ItemTemplate_OnLeave()
		GameTooltip:Hide()
	end

	--ScrollFrame

	local ROW_HEIGHT = 20   -- How tall is each row?
	local MAX_ROWS = 15      -- How many rows can be shown at once?

	self.autoVendorFrame.listScrollFrame = CreateFrame("Frame", "", self.autoVendorFrame)
    local listFrame = self.autoVendorFrame.listScrollFrame
		listFrame:EnableMouse(true)
		listFrame:SetSize(360, ROW_HEIGHT * MAX_ROWS + 20)
		listFrame:SetPoint("BOTTOM", 0, 60)
		listFrame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 },
		})
		listFrame.lable = listFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
		listFrame.lable:SetJustifyH("LEFT")
		listFrame.lable:SetPoint("TOPLEFT", listFrame, 2, 15)
		listFrame.lable:SetText("Click to select or Hold Alt to multiselect")

	function EV:ListScrollFrameUpdate(isChecked)
        local search =  string.trim(self.autoVendorFrame.searchbox:GetText())
        local itemList = {}
        for itemID, _ in pairs(self[self.selectedList]) do
            local itemInfo = {self:GetItemInfo(itemID)}
            local name, link, icon = select(4,GetItemQualityColor(itemInfo[3]))..itemInfo[1], itemInfo[2], itemInfo[10]
            --search items
            if (string.len(search) > 0) and (string.find(string.lower(name), string.lower(search), 1, true)) then
                itemList[name] = {name, link, icon, itemID}
            elseif (string.len(search) < 1) then
                itemList[name] = {name, link, icon, itemID}
            end
        end
        local sortedList = {}
        for _, itemInfo in self:PairsByKeys(itemList) do
            tinsert(sortedList, itemInfo)
        end
		local maxValue = #sortedList
		FauxScrollFrame_Update(listFrame.scrollBar, maxValue, MAX_ROWS, ROW_HEIGHT)
		local offset = FauxScrollFrame_GetOffset(listFrame.scrollBar)
		for i = 1, MAX_ROWS do
			local value = i + offset
			listFrame.rows[i]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
			listFrame.rows[i]:Hide()
			if value <= maxValue then
				local row = listFrame.rows[i]
                local name, link, icon, itemID = unpack(sortedList[value])
				row.Icon:SetTexture(icon)
				row.Text:SetText(name)
                    if checkedList[itemID] or (isChecked and isChecked == itemID) then
                        row:SetChecked(true)
                    else
                        row:SetChecked(false)
                    end
				row:SetScript("OnClick", function()
                    if IsAltKeyDown() then
                        if checked then checkedList[checked] = true end
                        checkedList[itemID] = not checkedList[itemID]
                        checked = nil
                    else
                        wipe(checkedList)
                        checked = itemID
                    end
				    self:ListScrollFrameUpdate(checked)
                end)
				row.link = link
				row:Show()
			end
		end
	end

	listFrame.scrollBar = CreateFrame("ScrollFrame", "ExtendedVendorUiListFrameScrollBar", listFrame, "FauxScrollFrameTemplate")
	listFrame.scrollBar:SetPoint("TOPLEFT", 0, -8)
	listFrame.scrollBar:SetPoint("BOTTOMRIGHT", -30, 8)
	listFrame.scrollBar:SetScript("OnVerticalScroll", function(scroll, offset)
		scroll.offset = math.floor(offset / ROW_HEIGHT + 0.5)
		self:ListScrollFrameUpdate()
	end)

	local rows = setmetatable({}, { __index = function(t, i)
		local row = CreateFrame("CheckButton", "$parentRow"..i, listFrame )
		row:SetSize(190, ROW_HEIGHT)
		row:SetNormalFontObject(GameFontHighlightLeft)
        row:SetCheckedTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
		row.Text = row:CreateFontString("$parentRow"..i.."Text","OVERLAY","GameFontNormal")
		row.Text:SetSize(190, ROW_HEIGHT)
		row.Text:SetPoint("LEFT", row, 20, 0)
		row.Text:SetJustifyH("LEFT")
		row.Icon = row:CreateTexture(nil, "OVERLAY")
		row.Icon:SetSize(15,15)
		row.Icon:SetPoint("LEFT", row)
		row:SetScript("OnShow", function(button)
			if GameTooltip:GetOwner() == button:GetName() then
				ItemTemplate_OnEnter(button)
			end
		end)
		row:SetScript("OnEnter", function(button)
			ItemTemplate_OnEnter(button)
		end)
		row:SetScript("OnLeave", ItemTemplate_OnLeave)
		if i == 1 then
			row:SetPoint("TOPLEFT", listFrame, 8, -8)
		else
			row:SetPoint("TOPLEFT", listFrame.rows[i-1], "BOTTOMLEFT")
		end
		rawset(t, i, row)
		return row
	end })

	listFrame.rows = rows

    self.autoVendorFrame.deleteButton = CreateFrame("Button", "ExtendedVendorUiAutoVendorDeleteButton", self.autoVendorFrame.listScrollFrame, "StandardButtonTemplate")
    self.autoVendorFrame.deleteButton:SetPoint("TOPLEFT", self.autoVendorFrame.listScrollFrame,"BOTTOMLEFT", 0, -10)
    self.autoVendorFrame.deleteButton:SetSize(150,25)
    self.autoVendorFrame.deleteButton:SetScript("OnClick",  function() self:DeleteVendorListItem() end)
    self.autoVendorFrame.deleteButton:SetText("Delete Selected")

	------------------------------ Profile Settings Panel ------------------------------
	self.autoVendorFrame.addButton = CreateFrame("Button", "ExtendedVendorUiAutoVendorAddButton", self.autoVendorFrame.listScrollFrame, "ItemButtonTemplate")
	self.autoVendorFrame.addButton:SetPoint("TOPRIGHT", self.autoVendorFrame.listScrollFrame, "BOTTOMRIGHT", 0, -3)
	self.autoVendorFrame.addButton.Lable = self.autoVendorFrame.addButton:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.autoVendorFrame.addButton.Lable:SetJustifyH("LEFT")
	self.autoVendorFrame.addButton.Lable:SetPoint("RIGHT", self.autoVendorFrame.addButton, "LEFT", -5, 0)
	self.autoVendorFrame.addButton.Lable:SetText("Add item")
	self.autoVendorFrame.addButton:SetScript("OnClick", function()
		self:AddVendorListItem(self.selectedList)
	end)
	self.autoVendorFrame.addButton:SetScript("OnEnter", function(button)
		GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT", 0, 20)
		GameTooltip:AddLine("Drag and drop or set keybinding in keybinding interface to a item to add it to list")
		GameTooltip:Show()
	end)
	self.autoVendorFrame.addButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    frameLoaded = true
end


function EV:DeleteVendorListItem()
    if checked and self[self.selectedList] then
        self[self.selectedList][checked] = nil
    elseif checkedList then
        for _, itemID in pairs(checkedList) do
            self[self.selectedList][itemID] = nil
        end
    end
    checked = nil
    wipe(checkedList)
    self:ListScrollFrameUpdate()
end

function EV:AddVendorListItem(list)
    local link
    local infoType, itemID = GetCursorInfo()
    if infoType ~= "item" then
        link = select(2, GameTooltip:GetItem())
        itemID = GetItemInfoFromHyperlink(link)
    end
    local itemInfo = {self:GetItemInfo(itemID)}
    local price = itemInfo[11]
    link = link or itemInfo[2]
    if itemID and ((price or 0) > 0) then
        if self[list][itemID] then
            DEFAULT_CHAT_FRAME:AddMessage(link..CYAN.." is already on "..self.autoVendorListNames[list])
        else
            self[list][itemID] = true
            DEFAULT_CHAT_FRAME:AddMessage(link..CYAN.." has been added "..self.autoVendorListNames[list])
        end
        if self.autoVendorFrame and self.autoVendorFrame:IsVisible() then
            self:ListScrollFrameUpdate()
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage(link..CYAN.." cant be added as it either is not an item or has no sell price")
    end
    ClearCursor()
end

function EV:AutoVendorItems()
    if GetCursorInfo() then return end
	local junkToSell = MerchantFrame.isSelling
	-- gather all grey items
	if not junkToSell then
		junkToSell = {}
		MerchantFrame.isSelling = junkToSell
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				local itemID = GetContainerItemID(bag, slot)
				if itemID then
					local _, link, quality, _, _, invType, itemSubType, _, _, _, vendorSell = GetItemInfo(itemID)
                    local tootltipInfo = self:GetTooltipItemInfo(link)
					if not self.blackList[itemID] and (self.whiteList[itemID] or self.charWhiteList[itemID] or
                    (quality and quality == 0 and invType and invType ~= "Quest" and vendorSell and vendorSell > 0) or
                    (self.db.VendorCommonItems and quality and quality == 1 and invType and (invType == "Weapon" or invType == "Armor") and (itemSubType ~= "INVTYPE_TABARD" or itemSubType ~= "INVTYPE_SHIRT") and vendorSell and vendorSell > 0) or
                    (self.db.AlreadyKnownBop and tootltipInfo.isKnown and (tootltipInfo.isBoP or tootltipInfo.isSoulbound)) or
                    (self.db.AlreadyKnownBoe and tootltipInfo.isKnown and (not tootltipInfo.isBoP and not tootltipInfo.isSoulbound))) then
						local itemCount = select(2, GetContainerItemInfo(bag, slot)) or 1
						vendorSell = vendorSell * itemCount
						tinsert(junkToSell, {bag = bag, slot = slot, link = link, count = itemCount, vendorSell = vendorSell, itemID = itemID})
					end
				end
			end
		end

		if #junkToSell == 0 then
			MerchantFrame.hasSoldJunk = true
			MerchantFrame.isSelling = nil
			return
		end
	end

	local sold = 1

	while sold <= 12 and #junkToSell > 0 do
		local item = tremove(junkToSell)
		MerchantFrame.junkProfit = MerchantFrame.junkProfit + item.vendorSell
        local appearanceID = C_Appearance.GetItemAppearanceID(item.itemID)
        if appearanceID and not C_AppearanceCollection.IsAppearanceCollected(appearanceID) then
            C_AppearanceCollection.CollectItemAppearance(item.itemID)
        end
		PickupContainerItem(item.bag, item.slot)
		PickupMerchantItem()
		SendSystemMessage(format(MERCHANT_AUTO_SOLD_ITEM, item.link, item.count, GetMoneyString(item.vendorSell)))
		sold = sold + 1
	end

	if #junkToSell > 0 then
		return
	end
	if MerchantFrame.junkProfit > 0 then
		SendSystemMessage(format(MERCHANT_AUTO_SOLD_RECEIPT, GetMoneyString(MerchantFrame.junkProfit)))
		MerchantFrame.junkProfit = 0
	end
	MerchantFrame.hasSoldJunk = true
	MerchantFrame.isSelling = nil
end

function EV:OpenAutoVendorListMenu(button)
    GameTooltip:Hide()
    if self.dewdrop:Open(button) then self.dewdrop:Close() return end
    self.dewdrop:Open(button,
    'point', function(parent)
      local point1, _, point2 = self:GetTipAnchor(button)
      return point1, point2
    end,
    'children', function(level, value)
        self:UpdateAutoVendorListMenu(level, value)
    end)
    if not self.worldFrameHook[button:GetName()] then
        WorldFrame:HookScript("OnEnter", function()
        if self.dewdrop:IsOpen(button) then
            self.dewdrop:Close()
        end
    end)
    self.worldFrameHook[button:GetName()] = true
    end
end

function EV:UpdateAutoVendorListMenu(level, value)
    if level == 1 then
        for list, displayName in pairs(EV.autoVendorListNames) do
            self.dewdrop:AddLine(
                'textHeight', self.db.TxtSize,
                'textWidth', self.db.TxtSize,
                'notCheckable', true,
                'text', displayName,
                'closeWhenClicked', true,
                'func', function() self:SelectAutoVendorList(list) end
            )
        end
        self:CloseDewDrop(true, 35)
    end
end

function EV:SelectAutoVendorList(list)
    self.selectedList = list
    self.autoVendorFrame.listSelection:SetText(self.autoVendorListNames[self.selectedList])
    checked = nil
    wipe(checkedList)
    self:ListScrollFrameUpdate()
end