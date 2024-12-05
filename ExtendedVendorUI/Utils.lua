local EV = LibStub("AceAddon-3.0"):GetAddon("ExtendedVendorUI")
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
local LIMEGREEN = "|cFF32CD32"
local ORANGE= "|cFFFFA500"
local AQUA  = "|cFF00FFFF"
local GREEN  = "|cff00ff00"

--========================================
-- Retrieve additional item info via the
-- item's tooltip
--========================================
local cTip = CreateFrame("GameTooltip","cTooltip",nil,"GameTooltipTemplate")
function EV:GetTooltipItemInfo(link, bag, slot)
    cTip:SetOwner(UIParent, "ANCHOR_NONE")

    -- set up return values
    local binds = {}

    -- generate item tooltip in hidden tooltip object
    if link then
        cTip:SetHyperlink(link)
    elseif bag and slot then
        cTip:SetBagItem(bag, slot)
    else
        return
    end

    for i = 1,cTip:NumLines() do
        local text = _G["cTooltipTextLeft"..i]:GetText()
        if text == "Realm Bound" then binds.isRealmbound = true end
        if text == ITEM_SOULBOUND then  binds.isSoulbound = true end
        if text == ITEM_BIND_ON_PICKUP then binds.isBoP = true end
        if text == ITEM_SPELL_KNOWN then binds.isKnown = true end
    end

    cTip:Hide()

    return binds
end

--for a adding a divider to dew drop menus 
function EV:AddDividerLine(maxLenght)
    local text = WHITE.."----------------------------------------------------------------------------------------------------"
    EV.dewdrop:AddLine(
        'text' , text:sub(1, maxLenght),
        'textHeight', self.db.txtSize,
        'textWidth', self.db.txtSize,
        'isTitle', true,
        "notCheckable", true
    )
    return true
end

function EV:GetTipAnchor(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
    local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
    return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
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

local itemEquipLocConversion = {
	"INVTYPE_HEAD","INVTYPE_NECK","INVTYPE_SHOULDER","INVTYPE_BODY","INVTYPE_CHEST",
	"INVTYPE_WAIST","INVTYPE_LEGS","INVTYPE_FEET","INVTYPE_WRIST",	"INVTYPE_HAND",
	"INVTYPE_FINGER","INVTYPE_TRINKET","INVTYPE_WEAPON","INVTYPE_SHIELD","INVTYPE_RANGED",
	"INVTYPE_CLOAK","INVTYPE_2HWEAPON","INVTYPE_BAG","INVTYPE_TABARD","INVTYPE_ROBE",
    "INVTYPE_WEAPONMAINHAND","INVTYPE_WEAPONOFFHAND","INVTYPE_HOLDABLE","INVTYPE_AMMO",
    "INVTYPE_THROWN","INVTYPE_RANGEDRIGHT","INVTYPE_QUIVER","INVTYPE_RELIC",
}
function EV:GetItemInfo(item)
	item = tonumber(item) and Item:CreateFromID(item) or Item:CreateFromLink(item)
    if not item.itemID then return end
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(item.itemID)
	if not item:GetInfo() then
		local itemInstant = GetItemInfoInstant(item.itemID)
		if itemInstant then
			itemName = itemInstant.name
			itemSubType = _G["ITEM_SUBCLASS_"..itemInstant.classID.."_"..itemInstant.subclassID]
			itemEquipLoc = itemEquipLocConversion[itemInstant.inventoryType]
			itemTexture = itemInstant.icon
			itemQuality = itemInstant.quality
			itemLink = item:GetLink()
		end
	end
	return itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice
end