local MAJOR, MINOR = "SettingsCreater-1.0", 6
local SettingsCreater, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not SettingsCreater then return end -- No Upgrade needed.

--Round number
local function round(num, idp)
	local mult = 10 ^ (idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function InitializeDropDown(self)
    local options, opTable, db = unpack(self.Menu)
	local info, otherDB
    local frame = options[opTable.Name]
    if type(opTable.Menu) == "function" then
        opTable.MenuList, otherDB = opTable.Menu()
    else
        opTable.MenuList = opTable.Menu
    end
    if not opTable.MenuList then return end
    db = otherDB or db[opTable.Name]
	for i, menu in pairs(opTable.MenuList) do
		info = {
			text = menu;
			func = function()
                if opTable.Func then
                    opTable.Func(menu)
                end
                db = menu
                UIDropDownMenu_SetSelectedID(frame, i)
			end;
		}
        UIDropDownMenu_AddButton(info)
        if menu == db then
		    UIDropDownMenu_SetSelectedID(frame, i)
        end
	end
	UIDropDownMenu_SetWidth(frame, opTable.menuWidth or 150)
end

--[[ DB = Name of the db you want to setup
CheckBox = Global name of the checkbox if it has one and first numbered table entry is the boolean
Text = Global name of where the text and first numbered table entry is the default text 
Frame = Frame or button etc you want hidden/shown at start based on condition ]]
function SettingsCreater:SetupDB(dbName, defaultList)
    _G[dbName] = _G[dbName] or {}
    local db = _G[dbName]
    for table, v in pairs(defaultList) do
        if not db[table] and db[table] ~= false then
            if type(v) == "table" then
                db[table] = v[1]
            else
                db[table] = v
            end
        end
        if type(v) == "table" then
            if v.CheckBox and _G[v.CheckBox] then
                _G[v.CheckBox]:SetChecked(db[table])
            end
            if v.Text and _G[v.Text] then
                _G[v.Text]:SetText(db[table])
            end
            if v.ShowFrame and _G[v.Frame] then
                if db[table] then _G[v.Frame]:Show() else _G[v.Frame]:Hide() end
            end
            if v.HideFrame and _G[v.HideFrame] then
                if db[table] then _G[v.HideFrame]:Hide() else _G[v.HideFrame]:Show() end
            end
        end
    end
    return db
end

local function CreateCheckButton(options, db, frame, addonName, setPoint, opTable)
    options[opTable.Name] = CreateFrame("CheckButton", addonName.."Options"..opTable.Name.."CheckButton", frame, "UICheckButtonTemplate")
    options[opTable.Name]:SetPoint(unpack(setPoint))
    options[opTable.Name].Lable = options[opTable.Name]:CreateFontString(nil , "BORDER", "GameFontNormal")
    options[opTable.Name].Lable:SetJustifyH("LEFT")
    options[opTable.Name].Lable:SetPoint("LEFT", 30, 0)
    options[opTable.Name].Lable:SetText(opTable.Lable)
    options[opTable.Name]:SetScript("OnClick", opTable.OnClick)
        options[opTable.Name]:SetScript("OnEnter", function()
        if opTable.Tooltip and type(opTable.Tooltip) == "string" then opTable.Tooltip() end
        if opTable.OnEnter then opTable.OnEnter() end
        end)
    options[opTable.Name]:SetScript("OnLeave", opTable.OnLeave or GameTooltip:Hide())
    options[opTable.Name]:SetScript("OnShow", function() if opTable.OnShow then opTable.OnShow(options[opTable.Name]) end end)
    options[opTable.Name]:SetChecked(db[opTable.Name] or false)
    return options[opTable.Name]
end

local function CreateButton(options, db, frame, addonName, setPoint, opTable)
    options[opTable.Name] = CreateFrame("Button", addonName.."Options"..opTable.Name.."Button", frame, "OptionsButtonTemplate")
    options[opTable.Name]:SetSize(unpack(opTable.Size))
    options[opTable.Name]:SetPoint(unpack(setPoint))
    options[opTable.Name]:SetText(opTable.Lable)
    options[opTable.Name]:SetScript("OnClick", opTable.OnClick)
        options[opTable.Name]:SetScript("OnEnter", function()
        if opTable.Tooltip and type(opTable.Tooltip) == "string" then opTable.Tooltip() end
        if opTable.OnEnter then opTable.OnEnter() end
        end)
    options[opTable.Name]:SetScript("OnLeave", opTable.OnLeave or GameTooltip:Hide())
    return options[opTable.Name]
end

local dropDownList = {}

local function CreateDropDownMenu(options, db, frame, addonName, setPoint, opTable)
    options[opTable.Name] = CreateFrame("Button", addonName.."Options"..opTable.Name.."Menu", frame, "UIDropDownMenuTemplate")
    options[opTable.Name]:SetPoint(unpack(setPoint))
    options[opTable.Name].Lable = options[opTable.Name]:CreateFontString(nil , "BORDER", "GameFontNormal")
    options[opTable.Name].Lable:SetJustifyH("LEFT")
    options[opTable.Name].Lable:SetPoint("LEFT", options[opTable.Name], 190, 0)
    options[opTable.Name].Lable:SetText(opTable.Lable)
    options[opTable.Name]:SetScript("OnClick", opTable.OnClick)
    options[opTable.Name]:SetScript("OnEnter", function()
        if opTable.Tooltip and type(opTable.Tooltip) == "string" then opTable.Tooltip() end
        if opTable.OnEnter then opTable.OnEnter() end
        end)
    options[opTable.Name]:SetScript("OnLeave", opTable.OnLeave or GameTooltip:Hide())
    options[opTable.Name].Menu = { options, opTable, db }
    options[opTable.Name]:SetScript("OnShow", function() UIDropDownMenu_Initialize(options[opTable.Name], InitializeDropDown) end )
    options[opTable.Name].updateMenu = function() UIDropDownMenu_Initialize(options[opTable.Name], InitializeDropDown) end
    dropDownList[addonName] = dropDownList[addonName] or {}
    if opTable.Menu then
        tinsert(dropDownList[addonName], options[opTable.Name])
    end
    return options[opTable.Name]
end

function SettingsCreater:UpdateDropDownMenus(addonName)
    if not addonName then return end
    for _, frame in pairs(dropDownList[addonName]) do
        if frame then
            UIDropDownMenu_Initialize(frame, InitializeDropDown)
        end
    end
end

local function CreateSlider(options, db, frame, addonName, setPoint, opTable)
    options[opTable.Name] = CreateFrame("Slider", addonName.."Options"..opTable.Name.."Slider", frame, "OptionsSliderTemplate")
    options[opTable.Name]:SetPoint(unpack(setPoint))
    options[opTable.Name]:SetSize(unpack(opTable.Size))
    options[opTable.Name]:SetMinMaxValues(opTable.MinMax[1], opTable.MinMax[2])
    _G[options[opTable.Name]:GetName().."Text"]:SetText(opTable.Lable)
    _G[options[opTable.Name]:GetName().."Low"]:SetText(opTable.MinMax[1])
    _G[options[opTable.Name]:GetName().."High"]:SetText(opTable.MinMax[2])
    options[opTable.Name]:SetScript("OnValueChanged", function(slider)
        opTable.OnValueChanged(slider)
        options[opTable.Name].editBox:SetText(round(options[opTable.Name]:GetValue(),2))
    end)
    options[opTable.Name]:SetScript("OnShow", opTable.OnShow)
    options[opTable.Name]:SetValueStep(opTable.Step)
    options[opTable.Name].editBox = CreateFrame("EditBox", addonName.."Options"..opTable.Name.."SliderInputBox", options[opTable.Name], "InputBoxTemplate2")
    options[opTable.Name].editBox:SetSize(50, 25)
    options[opTable.Name].editBox:SetJustifyH("CENTER")
    options[opTable.Name].editBox:SetPoint("TOP", options[opTable.Name], "BOTTOM", 0, 0)
    options[opTable.Name].editBox:SetScript("OnEnterPressed", function()
        options[opTable.Name]:SetValue(round(options[opTable.Name].editBox:GetText(),2))
    end)
    return options[opTable.Name]
end

local function CreateInputBox(options, db, frame, addonName, setPoint, opTable)
    options[opTable.Name] = CreateFrame("EditBox", addonName.."Options"..opTable.Name.."InputBox", frame, "InputBoxTemplate2")
    options[opTable.Name]:SetPoint(unpack(setPoint))
    options[opTable.Name]:SetSize(unpack(opTable.Size))
    options[opTable.Name].Lable = options[opTable.Name]:CreateFontString(nil , "BORDER", "GameFontNormal")
    options[opTable.Name].Lable:SetJustifyH("LEFT")
    options[opTable.Name].Lable:SetPoint("BOTTOMLEFT", options[opTable.Name], "TOPLEFT", 0, 0)
    options[opTable.Name].Lable:SetText(opTable.Lable)
        options[opTable.Name]:SetScript("OnEnter", function()
        if opTable.Tooltip and type(opTable.Tooltip) == "string" then opTable.Tooltip() end
        if opTable.OnEnter then opTable.OnEnter() end
        end)
    options[opTable.Name]:SetScript("OnLeave", opTable.OnLeave or GameTooltip:Hide())
    options[opTable.Name]:SetScript("OnTextChanged", opTable.OnTextChanged)
    options[opTable.Name]:SetScript("OnEnterPressed", opTable.OnEnterPressed)
    return options[opTable.Name]
end

local function CreateTab(options, tabNum, data, tab)
    if tabNum == 1 then return end
	options.frame[tab.Name] = CreateFrame("FRAME", data.AddonName.."OptionsFrame"..tabNum, UIParent, nil)
		local fstring = options.frame[tab.Name]:CreateFontString(options.frame, "OVERLAY", "GameFontNormal")
		fstring:SetText(tab.TitleText)
		fstring:SetPoint("TOPLEFT", 30, -15)
		options.frame[tab.Name].name = tab.Name
		options.frame[tab.Name].parent = data.AddonName
		InterfaceOptions_AddCategory(options.frame[tab.Name])
        return options.frame[tab.Name]
end

function SettingsCreater:CreateOptionsPages(data, db)
    if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	local options = { frame = {} }
		options.frame.panel = CreateFrame("FRAME", data.AddonName.."OptionsFrame", UIParent, nil)
    	local fstring = options.frame.panel:CreateFontString(options.frame, "OVERLAY", "GameFontNormal")
		fstring:SetText(data.TitleText)
		fstring:SetPoint("TOPLEFT", 15, -15)
		options.frame.panel.name = data.AddonName
		InterfaceOptions_AddCategory(options.frame.panel)
        local frame = options.frame.panel
        for tabNum, tab in ipairs(data) do
            frame = CreateTab(options, tabNum, data, tab) or frame
            local lastFrame
            for coloum, side in pairs(tab) do
                local point = -10
                if type(side) == "table" then
                    local setPoint
                    for _, option in pairs(side) do
                        if option.Type == "CheckButton" then
                            if option.Position then
                                setPoint = (option.Position == "Left") and {"RIGHT", lastFrame, "LEFT", -2, 0} or (option.Position == "Right") and {"LEFT", lastFrame, "RIGHT", 2, 0}
                            else
                                point = point -30
                                setPoint = (coloum == "Left") and {"TOPLEFT", 30, point} or (coloum == "Right") and {"TOPLEFT", 370, point}
                            end
                            lastFrame = CreateCheckButton(options, db, frame, data.AddonName, setPoint, option)
                        elseif option.Type == "Button" then
                            if option.Position then
                                setPoint = (option.Position == "Left") and {"RIGHT", lastFrame, "LEFT", -2, 0} or (option.Position == "Right") and {"LEFT", lastFrame, "RIGHT", 2, 0}
                            else
                                point = point -35
                                setPoint = (coloum == "Left") and {"TOPLEFT", 30, point} or (coloum == "Right") and {"TOPLEFT", 375, point}
                            end
                            lastFrame = CreateButton(options, db, frame, data.AddonName, setPoint, option )
                        elseif option.Type == "Menu" then
                            if option.Position then
                                setPoint = (option.Position == "Left") and {"RIGHT", lastFrame, "LEFT", -2, 0} or (option.Position == "Right") and {"LEFT", lastFrame, "RIGHT", 2, 0}
                            else
                                point = point -35
                                setPoint = (coloum == "Left") and {"TOPLEFT", 20, point} or (coloum == "Right") and {"TOPLEFT", 357, point}
                            end
                            lastFrame = CreateDropDownMenu(options, db, frame, data.AddonName, setPoint, option)
                        elseif option.Type == "Slider" then
                            if option.Position then
                                setPoint = (option.Position == "Left") and {"RIGHT", lastFrame, "LEFT", -2, 0} or (option.Position == "Right") and {"LEFT", lastFrame, "RIGHT", 2, 0}
                            else
                                point = point -50
                                setPoint = (coloum == "Left") and {"TOPLEFT", 35, point} or (coloum == "Right") and {"TOPLEFT", 375, point}
                                lastFrame = CreateSlider(options, db, frame, data.AddonName, setPoint, option )
                            end
                        elseif option.Type == "EditBox" then
                            if option.Position then
                                setPoint = (option.Position == "Left") and {"RIGHT", lastFrame, "LEFT", -2, 0} or (option.Position == "Right") and {"LEFT", lastFrame, "RIGHT", 2, 0}
                            else
                                point = point -35
                                setPoint = (coloum == "Left") and {"TOPLEFT", 30, point} or (coloum == "Right") and {"TOPLEFT", 375, point}
                            end
                            lastFrame = CreateInputBox(options, db, frame, data.AddonName, setPoint, option )
                        end
                    end
                end
            end
        end
    return options
end

-- ---------------------------------------------------------------------
-- Embed handling

local mixins = {
	"SetupDB",
	"CreateOptionsPages",
    "UpdateDropDownMenus",
}

SettingsCreater.embeds = SettingsCreater.embeds or {}

function SettingsCreater:Embed(target)
    self.embeds[target] = true
	for _, v in pairs(mixins) do
		target[v] = self[v]
	end
	return target
end

-- Update embeds
for addon, _ in pairs(SettingsCreater.embeds) do
	SettingsCreater:Embed(addon)
end