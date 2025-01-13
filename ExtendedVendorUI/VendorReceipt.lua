local EV = LibStub("AceAddon-3.0"):GetAddon("ExtendedVendorUI")
local AQUA  = "|cFF00FFFF"
local WHITE = "|cffFFFFFF"

function EV:OpenReceiptUI()
    self:ReceiptFrameCreate()
    self.receiptFrame:Show()
    self:ReceiptFrameListScrollFrameUpdate()
end

local frameLoaded
function EV:ReceiptFrameCreate()
    if frameLoaded then return end

    self.receiptFrame = CreateFrame("FRAME", "ExtendedVendorUIReceiptFrame", UIParent,"UIPanelDialogTemplate")
    self.receiptFrame:SetSize(400,500)
    self.receiptFrame:SetPoint("CENTER",0,0)
    self.receiptFrame:EnableMouse(true)
    self.receiptFrame:SetMovable(true)
    self.receiptFrame:SetToplevel(true)
    self.receiptFrame:SetFrameStrata("HIGH")
    self.receiptFrame:RegisterForDrag("LeftButton")
    self.receiptFrame:SetScript("OnDragStart", function() self.receiptFrame:StartMoving() end)
    self.receiptFrame:SetScript("OnDragStop", function() self.receiptFrame:StopMovingOrSizing() end)
    self.receiptFrame:SetScript("OnShow", function() end)
    self.receiptFrame.TitleText = self.receiptFrame:CreateFontString()
    self.receiptFrame.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 12)
    self.receiptFrame.TitleText:SetFontObject(GameFontNormal)
    self.receiptFrame.TitleText:SetText("Receipt of vendored items")
    self.receiptFrame.TitleText:SetPoint("TOP", 0, -9)
    self.receiptFrame.TitleText:SetShadowOffset(1,-1)
    self.receiptFrame:Hide()
    --Add the Frame to the special frames tables to enable closing wih the ESC key
    tinsert(UISpecialFrames, "ExtendedVendorUIReceiptFrame")

    --Search Edit Box
    self.receiptFrame.searchbox = CreateFrame("EditBox", "ExtendedVendorUiReceiptListFrameSearch", self.receiptFrame, "SearchBoxTemplate")
    self.receiptFrame.searchbox:SetSize(190,30)
    self.receiptFrame.searchbox:SetPoint("TOPLEFT", self.receiptFrame, 25, -30)
    self.receiptFrame.searchbox:SetScript("OnTextChanged", function(editBox)
        if editBox:HasFocus() then
            SearchBoxTemplate_OnTextChanged(editBox)
        end
        self:ReceiptFrameListScrollFrameUpdate()
    end)
    self.receiptFrame.searchbox.clearButton:HookScript("OnClick", function()
        self:ReceiptFrameListScrollFrameUpdate()
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
    local MAX_ROWS = 18      -- How many rows can be shown at once?

    self.receiptFrame.listScrollFrame = CreateFrame("Frame", "", self.receiptFrame)
    local listFrame = self.receiptFrame.listScrollFrame
        listFrame:EnableMouse(true)
        listFrame:SetSize(360, ROW_HEIGHT * MAX_ROWS + 20)
        listFrame:SetPoint("BOTTOM", 0, 35)
        listFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        listFrame.name = listFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
		listFrame.name:SetJustifyH("LEFT")
		listFrame.name:SetPoint("TOPLEFT", listFrame, 15, 15)
		listFrame.name:SetText("Item")
        listFrame.name:SetWidth(180)
        listFrame.count = listFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
		listFrame.count:SetJustifyH("LEFT")
		listFrame.count:SetPoint("LEFT", listFrame.name, "RIGHT", 0, 0)
		listFrame.count:SetText("Number")
        listFrame.count:SetWidth(70)
        listFrame.price = listFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
		listFrame.price:SetJustifyH("LEFT")
		listFrame.price:SetPoint("LEFT", listFrame.count, "RIGHT", 0, 0)
		listFrame.price:SetText("Price")
        listFrame.price:SetWidth(70)
        listFrame.total = listFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
        listFrame.total:SetJustifyH("LEFT")
        listFrame.total:SetPoint("RIGHT", listFrame, "BOTTOMRIGHT", -45, -10)
        listFrame.total:SetText("")

    function EV:ReceiptFrameListScrollFrameUpdate()
        local search =  string.trim(self.receiptFrame.searchbox:GetText())
        local itemList = {}
        for _, item in ipairs(MerchantFrame.receipt) do
            local itemInfo = {self:GetItemInfo(item[1])}
            local name, link, icon = select(4,GetItemQualityColor(itemInfo[3]))..itemInfo[1], itemInfo[2], itemInfo[10]
            local count = itemList[name] and (itemList[name][5] + item[2]) or item[2]
            local price = itemList[name] and (itemList[name][6] + item[3]) or item[3]
            --search items
            if (string.len(search) > 0) and (string.find(string.lower(name), string.lower(search), 1, true)) then
                itemList[name] = {name, link, icon, item[1], count, price}
            elseif (string.len(search) < 1) then
                itemList[name] = {name, link, icon, item[1], count, price}
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
                local name, link, icon, itemID, count, price = unpack(sortedList[value])
                row.Icon:SetTexture(icon)
                row.Text:SetText(name)
                row.Count:SetText(count)
                row.Price:SetText(GetMoneyString(price))
                row.link = link
                row:Show()
            end
        end
        listFrame.total:SetText(AQUA.."Total - "..WHITE..MerchantFrame.receipt.total)
    end

    listFrame.scrollBar = CreateFrame("ScrollFrame", "ExtendedVendorUiReceiptListFrameScrollBar", listFrame, "FauxScrollFrameTemplate")
    listFrame.scrollBar:SetPoint("TOPLEFT", 0, -8)
    listFrame.scrollBar:SetPoint("BOTTOMRIGHT", -30, 8)
    listFrame.scrollBar:SetScript("OnVerticalScroll", function(scroll, offset)
        scroll.offset = math.floor(offset / ROW_HEIGHT + 0.5)
        self:ReceiptFrameListScrollFrameUpdate()
    end)

    local rows = setmetatable({}, { __index = function(t, i)
        local row = CreateFrame("Button", "$parentRow"..i, listFrame )
        row:SetSize(190, ROW_HEIGHT)
        row:SetNormalFontObject(GameFontHighlightLeft)
        row.Text = row:CreateFontString("$parentRow"..i.."Text","OVERLAY","GameFontNormal")
        row.Text:SetSize(180, ROW_HEIGHT)
        row.Text:SetPoint("LEFT", row, 20, 0)
        row.Text:SetJustifyH("LEFT")
        row.Count = row:CreateFontString("$parentRow"..i.."Text","OVERLAY","GameFontNormal")
        row.Count:SetSize(50, ROW_HEIGHT)
        row.Count:SetPoint("LEFT", row.Text, "RIGHT", 0, 0)
        row.Count:SetJustifyH("LEFT")
        row.Price = row:CreateFontString("$parentRow"..i.."Text","OVERLAY","GameFontNormal")
        row.Price:SetSize(50, ROW_HEIGHT)
        row.Price:SetPoint("LEFT", row.Count, "RIGHT", 0, 0)
        row.Price:SetJustifyH("LEFT")
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
    frameLoaded = true
end