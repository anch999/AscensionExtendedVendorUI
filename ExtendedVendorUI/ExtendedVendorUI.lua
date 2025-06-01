local EV = LibStub("AceAddon-3.0"):NewAddon("ExtendedVendorUI", "AceTimer-3.0", "AceEvent-3.0", "SettingsCreator-1.0")
ExtendedVendorUI = EV
EV.Dewdrop = AceLibrary("Dewdrop-2.0")
EV.Version = 1

local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
EV.defaultIcon = "Interface\\Icons\\INV_Misc_Book_06"
EV.worldFrameHook = {}
EV.skin = { buttons = {}, frames = {}, portraitFrames = {} }

--Set Savedvariables defaults
local DefaultSettings  = {
    txtSize = 14,
    WhiteList = {},
    BlackList = {},
    AutoVendor = false,
    SkinSelected = "Default",
    FilterList = {},
}

function EV:OnInitialize()
    --setup dbs
    self.db = self:SetupDB("ExtendedVendorUIDB", DefaultSettings)
    --Enable the use of /ExtendedVendorUI slash command
    SLASH_EXTENDEDVENDORUI1 = "/extendedvendorui"
    SLASH_EXTENDEDVENDORUI2 = "/ev"
    SlashCmdList["EXTENDEDVENDORUI"] = function(msg)
        ExtendedVendorUI:SlashCommand(msg)
    end
end

function EV:OnEnable()
    self.realm = GetRealmName()
    self.thisChar = GetUnitName("player")
    self.playerKey = self.thisChar.." - "..self.realm
    self:RegisterEvent("MERCHANT_UPDATE")
    self:RegisterEvent("MERCHANT_SHOW")
    self:RegisterEvent("MERCHANT_CLOSED")

    if not self.db[self.realm] then self.db[self.realm] = {} end
    if not self.db[self.realm][self.thisChar] then self.db[self.realm][self.thisChar] = {} end
    self.charDB = self.db[self.realm][self.thisChar]
    self.charDB.WhiteList = self.charDB.WhiteList or {}
    self.whiteList = self.db.WhiteList
    self.charWhiteList = self.charDB.WhiteList
    self.blackList = self.db.BlackList
    self:InitializeOptionsUI()
    self:InitializeUI()
    self:InitializeSkins()
    self:DisableElvUiMerchantSkin()

end

--[[
EV:SlashCommand(msg):
msg - takes the argument for the /extendedvendorui command so that the appropriate action can be performed
If someone types /extendedvendorui, bring up the options box
]]
function EV:SlashCommand(msg)
    local cmd, arg = string.split(" ", msg, 2)
	cmd = string.lower(cmd) or nil
	arg = arg or nil
    if cmd == "reset" then
        ExtendedVendorUIDB = nil
        self:OnInitialize()
        DEFAULT_CHAT_FRAME:AddMessage("Settings Reset")
    elseif cmd == "options" then
        self:OptionsToggle()
    elseif cmd == "copyoldaddon" then
        self:CopyItemListsFromOldAddon()
    else
        self:AutoVendorConfigOpen()
    end
end

function EV:CopyItemListsFromOldAddon()
    if EXTVENDOR_DATA then
        for listName, list in pairs(EXTVENDOR_DATA) do
            if listName == "quickvendor_blacklist" then
                for _, itemID in pairs(list) do
                    if itemID then self.blackList[itemID] = true end
                end
            elseif listName == "quickvendor_whitelist" then
                for _, itemID in pairs(list) do
                    if itemID then self.whiteList[itemID] = true end
                end
            else
                local realm, character = strsplit('.', listName, 2)
                if realm and character then
                    self.db[realm] = self.db[realm] or {}
                    self.db[realm][character] = self.db[realm][character] or {}
                    self.db[realm][character]["WhiteList"] = self.db[realm][character]["WhiteList"] or {}
                    for _, itemID in pairs(list.quickvendor_whitelist) do
                        if itemID then
                            self.db[realm][character]["WhiteList"][itemID] = true
                        end
                    end
                end
            end
        end
    end
end

function EV:MERCHANT_SHOW()
    self:UiOnShow()
end

function EV:MERCHANT_CLOSED()
    ExtendedVendorUi:Hide()
end

function EV:MERCHANT_UPDATE()
    self:SetFrameTab()
end

_G["BINDING_HEADER_EXTENDEDVENDORUI"] = "ExtendedVendorUI"
_G["BINDING_NAME_EXTENDEDVENDORUIBIND1"] = "Add to global white list"
_G["BINDING_NAME_EXTENDEDVENDORUIBIND2"] = "Add to character white list "
_G["BINDING_NAME_EXTENDEDVENDORUIBIND3"] = "Add to black list"
