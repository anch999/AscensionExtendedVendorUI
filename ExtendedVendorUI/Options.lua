local EV = LibStub("AceAddon-3.0"):GetAddon("ExtendedVendorUI")

function EV:OptionsToggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	else
		InterfaceOptionsFrame_OpenToCategory("ExtendedVendorUI")
	end
end

--Creates the options frame and all its assets
function EV:InitializeOptionsUI()
	local Options = {
		AddonName = "ExtendedVendorUI",
		TitleText = "ExtendedVendorUI Settings",
		{
		Name = "ExtendedVendorUI",
		Left = {
			{
				Type = "Menu",
				Name = "TxtSize",
				Lable = "Menu text size",
				Menu = {10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25}
			},
			{
				Type = "CheckButton",
				Name = "AutoVendor",
				Lable = "Auto vendor items",
				Tooltip = "Auto vendor items when the merchant frame is opened",
				OnClick = function() self.db.AutoVendor = not self.db.AutoVendor end,
			},
			{
				Type = "CheckButton",
				Name = "AlreadyKnownBop",
				Lable = "Already Known items (BoE)",
				Tooltip = "Auto vendor items that are bound on pick and knonw by the player",
				OnClick = function() self.db.AlreadyKnownBop = not self.db.AlreadyKnownBop end,
			},
			{
				Type = "CheckButton",
				Name = "AlreadyKnownBoe",
				Lable = "Already Known items (BoE)",
				Tooltip = "Auto vendor items that are bound on equip and knonw by the player",
				OnClick = function() self.db.AlreadyKnownBoe = not self.db.AlreadyKnownBoe end,
			},
			{
				Type = "CheckButton",
				Name = "VendorCommonItems",
				Lable = "Vendor Common quality (White) weapons and armor",
				Tooltip = "Auto vendor gray items",
				OnClick = function() self.db.VendorCommonItems = not self.db.VendorCommonItems end,
			}
		},
		Right = {
			{
				Type = "Slider",
				Name = "MerchantFrameScale",
				Lable = "Merchant Frame Scale",
				MinMax = {0.25, 1.5},
				Step = 0.01,
				Size = {240,16},
				OnShow = function() self.options.MerchantFrameScale:SetValue(self.db.MerchantFrameScale or 1) end,
				OnValueChanged = function()
					self.db.MerchantFrameScale = self.options.MerchantFrameScale:GetValue()
					self.uiFrame:SetScale(self.db.MerchantFrameScale)
				end
			}
		}
		},
	}

self.options = self:CreateOptionsPages(Options, ExtendedVendorUIDB)

if LibStub:GetLibrary("LibAboutPanel", true) then
	LibStub("LibAboutPanel").new("Extended Vendor UI Ascension", "ExtendedVendorUI")
end

end