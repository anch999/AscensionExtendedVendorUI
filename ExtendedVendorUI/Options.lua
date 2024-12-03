local EV = LibStub("AceAddon-3.0"):GetAddon("ExtendedVendorUI")

function EV:OptionsToggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	else
		InterfaceOptionsFrame_OpenToCategory("ExtendedVendorUI")
	end
end

--Creates the options frame and all its assets
function EV:CreateOptionsUI()
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
		},
		},
	}

self.options = self:CreateOptionsPages(Options, ExtendedVendorUIDB)

end