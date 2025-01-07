local EV = LibStub("AceAddon-3.0"):GetAddon("ExtendedVendorUI")

EV.worldFrameHook = {}
function EV:OpenSettingQuickMenu(button)
    GameTooltip:Hide()
    if self.Dewdrop:Open(button) then self.Dewdrop:Close() return end
    self.Dewdrop:Open(button,
    'point', function(parent)
      local point1, _, point2 = self:GetTipAnchor(button)
      return point1, point2
    end,
    'children', function(level, value)
        self:QuickSettingsMenu(level, value)
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

function EV:QuickSettingsMenu(level, value)
    if level == 1 then
        self.Dewdrop:AddLine(
            'textHeight', self.db.txtSize,
            'textWidth', self.db.txtSize,
            'text', "Quick Settings",
            'isTitle', true,
            'notCheckable', true
        )
        self.Dewdrop:AddLine(
            'textHeight', self.db.txtSize,
            'textWidth', self.db.txtSize,
            'text', "Run Auto Vendor",
            'tooltipTitle', "Runs the auto vendor function vendoring everything thats in your white lists and other selected types",
            'notCheckable', true,
            'closeWhenClicked', true,
            'func', function() self:AutoVendorItems() end
        )
        self.Dewdrop:AddLine(
            'textHeight', self.db.txtSize,
            'textWidth', self.db.txtSize,
            'notCheckable', true,
            'text', "Auto Vendor Config",
            'tooltipTitle', "opens the auto vendor list config window",
            'closeWhenClicked', true,
            'func', function() self:AutoVendorConfigOpen() end
        )
        self.Dewdrop:AddLine(
            'textHeight', self.db.txtSize,
            'textWidth', self.db.txtSize,
            'notCheckable', true,
            'text', "Options",
            'closeWhenClicked', true,
            'func', function() self:OptionsToggle() end
        )
        self.Dewdrop:AddLine(
            'textHeight', self.db.txtSize,
            'textWidth', self.db.txtSize,
            'text', "Toggle Auto Vendor",
            'tooltipTitle', "Toggles whether the auto vendor will run when the vendor is opened",
            'isRadio', true,
            'checked', self.db.AutoVendor,
            'func', function() self.db.AutoVendor = not self.db.AutoVendor end
        )
        self:CloseDewDrop(true, 35)
    end
end