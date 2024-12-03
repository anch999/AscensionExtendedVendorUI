local EV = LibStub("AceAddon-3.0"):NewAddon("ExtendedVendorUI", "AceTimer-3.0", "AceEvent-3.0", "SettingsCreater-1.0")
ExtendedVendorUI = EV
EV.dewdrop = AceLibrary("Dewdrop-2.0")
EV.Version = 1

local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
EV.defaultIcon = "Interface\\Icons\\INV_Misc_Book_06"

--Set Savedvariables defaults
local DefaultSettings  = {
    TxtSize         = 12,
    WhiteList = {},
    BlackList = {},
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
    self:CreateOptionsUI()
end

--[[
EV:SlashCommand(msg):
msg - takes the argument for the /mysticextended command so that the appropriate action can be performed
If someone types /mysticextended, bring up the options box
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

    end
end

function EV:CopyItemListsFromOldAddon()
    if EXTVENDOR_DATA then
        if EXTVENDOR_DATA.quickvendor_blacklist then
            for _, itemID in pairs(EXTVENDOR_DATA.quickvendor_blacklist) do
                self.blackList[itemID] = true
            end
        end
        if EXTVENDOR_DATA.quickvendor_whitelist then
            for _, itemID in pairs(EXTVENDOR_DATA.quickvendor_whitelist) do
                self.whiteList[itemID] = true
            end
        end

    end
end

function EV:MERCHANT_SHOW()
    self:CreateUI()
    self:UiOnShow()
end

function EV:MERCHANT_CLOSED()
    ExtendedVendorUi:Hide()
end

function EV:MERCHANT_UPDATE()
    self:SetFrameTab()
    MerchantFrame_Update()
end