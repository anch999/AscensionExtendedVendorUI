local Skin = LibStub("AceAddon-3.0"):GetAddon("ExtendedVendorUI")

local skins = {
    ["Default"] = {
        DefaultFrame = {
            bg = "Interface\\DialogFrame\\UI-DialogBox-Background",
            bgColor = {2,2,2,2},
            edge = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeColor = {1,1,1,1},
            tile = true,
        },
        Backdrop = {
            bg = "Interface\\FrameGeneral\\UI-Background-Marble",
            bgColor = {0,0,0,0},
            edge = "",
            edgeColor = {0,0,0,0},
            tile = true,
        },
        btTex = "Interface\\Buttons\\UI-Silver-Button-Up",
        insets = {1,1,1,1},
        showFrame = true,
        searchP = {0,-0.5},
        searchH = 24,
        edgeSize = 16,
        closebtn = {0,0},
        title = {0,0},
    },
    ["Dark Mode"] = {
        DefaultFrame = {
            bg = "Interface\\DialogFrame\\UI-DialogBox-Background",
            bgColor = {2,2,2,2},
            edge = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeColor = {0,0,0,5},
            tile = true,
        },
        Backdrop = {
            bg = "Interface\\DialogFrame\\UI-DialogBox-Background",
            bgColor = {2,2,2,2},
            edge = "",
            edgeColor = {0,0,0,0},
            tile = true,
        },
        btTex = {0,0,0,.6},
        insets = {1,1,1,1},
        showFrame = false,
        searchP = {2,0},
        searchH = 25,
        edgeSize = 8,
        closebtn = {-5,-5},
        title = {0,0},
        hideBackdrop = true,
    },
}

function Skin:InitializeSkins()

    function self:GetSkinList()
        local skinsList = {}
        for skin, _ in pairs(skins) do
            tinsert(skinsList, skin)
        end
        return skinsList
    end

    -- Setup default skin onload
    for _, frame in pairs(self.skin.portraitFrames) do
        self.CloseDefaults = {}
        local DF = self.CloseDefaults
        DF[1], DF[2], DF[3], DF[4], DF[5] = frame.CloseButton:GetPoint()

        self.TitleDefaults = {}
        local TDF = self.TitleDefaults
        TDF[1], TDF[2], TDF[3], TDF[4], TDF[5] = frame.TitleText:GetPoint()
    end

    --[[
    SetSkin()
    Changes the skin
    ]]
    function self:SetSkin(key)
        local skin = skins[key]
            for _, frame in pairs(self.skin.frames) do
                if skin.hideBackdrop then
                    frame.Bg:Hide()
                    frame:SetBackdrop({
                        bgFile = skin.Backdrop.bg, tile = skin.Backdrop.tile, tileSize = 16,
                        insets = { left = skin.insets[1], right = skin.insets[2], top = skin.insets[3], bottom = skin.insets[4] },
                    })
                    frame:SetBackdropColor(skin.Backdrop.bgColor[1], skin.Backdrop.bgColor[2], skin.Backdrop.bgColor[3], skin.Backdrop.bgColor[4])
                    frame:SetBackdropBorderColor(skin.Backdrop.edgeColor[1], skin.Backdrop.edgeColor[2], skin.Backdrop.edgeColor[3], skin.Backdrop.edgeColor[4])    
                else
                    frame.Bg:Show()
                end
            end

            for _, frame in pairs(self.skin.portraitFrames) do
                local DF = self.CloseDefaults
                frame.CloseButton:SetPoint(DF[1], DF[2], DF[3], DF[4]+skin.closebtn[1], DF[5]+skin.closebtn[2])

                local TDF = self.TitleDefaults
                frame.TitleText:SetPoint(TDF[1], TDF[2], TDF[3], TDF[4]+skin.title[1], TDF[5]+skin.title[2])

                if type(skin.btTex) == "table" then
                    local color = skin.btTex
                    frame.searchbox.Left:SetTexture(color[1],color[2],color[3],color[4])
                    frame.searchbox.Right:SetTexture(color[1],color[2],color[3],color[4])
                    frame.searchbox.Middle:SetTexture(color[1],color[2],color[3],color[4])
                else
                    frame.searchbox.Left:SetTexture("")
                    frame.searchbox.Right:SetTexture("")
                    frame.searchbox.Middle:SetTexture("")
                    frame.searchbox.Left:SetAtlas("common-search-border-left")
                    frame.searchbox.Right:SetAtlas("common-search-border-right")
                    frame.searchbox.Middle:SetAtlas("common-search-border-middle")
                end

                frame.searchbox.Left:SetHeight(skin.searchH)
                frame.searchbox.Right:SetHeight(skin.searchH)
                frame.searchbox.Middle:SetHeight(skin.searchH)

                local frameParts = {"RightEdge","LeftEdge","BottomEdge","TopEdge","BottomRightCorner","BottomLeftCorner","TopRightCorner","TopLeftCorner"}
                if skin.showFrame then
                    for _, frameParts in ipairs(frameParts) do
                        frame.NineSlice[frameParts]:Show()
                    end
                    frame.portrait:Show()
                    frame.Bg:Show()
                    frame.TitleBg:Show()
                    frame.TopTileStreaks:Show()
                    frame:SetBackdrop(nil)
                else
                    for _, frameParts in ipairs(frameParts) do
                        frame.NineSlice[frameParts]:Hide()
                    end
                    frame.portrait:Hide()
                    frame.Bg:Hide()
                    frame.TitleBg:Hide()
                    frame.TopTileStreaks:Hide()
                    frame:SetBackdrop({
                        bgFile = skin.DefaultFrame.bg, tile = skin.DefaultFrame.tile, tileSize = 16,
                        edgeFile = skin.DefaultFrame.edge, edgeSize = skin.edgeSize,
                        insets = { left = skin.insets[1], right = skin.insets[2], top = skin.insets[3], bottom = skin.insets[4] },
                    })
                    frame:SetBackdropColor(skin.DefaultFrame.bgColor[1], skin.DefaultFrame.bgColor[2], skin.DefaultFrame.bgColor[3], skin.DefaultFrame.bgColor[4])
                    frame:SetBackdropBorderColor(skin.DefaultFrame.edgeColor[1], skin.DefaultFrame.edgeColor[2], skin.DefaultFrame.edgeColor[3], skin.DefaultFrame.edgeColor[4])
                end
            end

            local function ReTextureButtons(button)
                local tex, tex2, tex3, tex4
                if type(skin.btTex) == "table" then
                    tex, tex2, tex3, tex4 = unpack(skin.btTex)
                else
                    tex = skin.btTex
                end
                button.TopLeft:SetTexture(tex, tex2, tex3, tex4)
                button.TopRight:SetTexture(tex, tex2, tex3, tex4)
                button.BottomLeft:SetTexture(tex, tex2, tex3, tex4)
                button.BottomRight:SetTexture(tex, tex2, tex3, tex4)
                button.TopMiddle:SetTexture(tex, tex2, tex3, tex4)
                button.MiddleLeft:SetTexture(tex, tex2, tex3, tex4)
                button.MiddleRight:SetTexture(tex, tex2, tex3, tex4)
                button.BottomMiddle:SetTexture(tex, tex2, tex3, tex4)
                button.MiddleMiddle:SetTexture(tex, tex2, tex3, tex4)
            end

            for _, button in pairs(self.skin.buttons) do
                ReTextureButtons(button)
            end
    end

    --Set visual style for the loot browser
	if self.db.SkinSelected then
		self:SetSkin(self.db.SkinSelected)
	end
end
