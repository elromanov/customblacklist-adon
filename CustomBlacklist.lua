local frame = CreateFrame("Frame")
local addon_loaded = false

local addon_version = "1.0.1"

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_WHISPER")

if not customBlacklistSavedData then
    customBlacklistSavedData = {}
end

-- Function to display a message like a raid warning (but only to the user)
local function showLocalRaidWarning(message)
    RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo["RAID_WARNING"])
end

local function addBlacklistEntry(name)
    if not customBlacklistSavedData["blacklistedPlayers"][name] then
        customBlacklistSavedData["blacklistedPlayers"][name] = true

        print(name.." added to blacklist")
    else
        print(name.." is already in the blacklist")
    end
end

local function blacklistToString()
    local blacklistString = ""

    for playerName in pairs(customBlacklistSavedData["blacklistedPlayers"]) do
        blacklistString = blacklistString .. playerName .. ","
    end

    -- Remove trailing comma
    blacklistString = blacklistString:sub(1, -2)
    return blacklistString
end

local function removePlayerFromBlacklist(name)
    if customBlacklistSavedData["blacklistedPlayers"][name] then
        customBlacklistSavedData["blacklistedPlayers"][name] = nil
        print(name.." removed from blacklist")
    else
        print(name.." is not in the blacklist")
    end
end

local function importBlacklist(list)

    for playerName in string.gmatch(list, '([^,]+)') do
        if not customBlacklistSavedData["blacklistedPlayers"][playerName] then
            customBlacklistSavedData["blacklistedPlayers"][playerName] = true
            print(playerName .. " added to blacklist")
        else
            print(playerName .. " is already in the blacklist")
        end
    end

end

local function initializeSettingsScreen()
    local optionsPanel = CreateFrame("Frame", "CustomBlacklistOptionsPanel", UIParent)
    optionsPanel.name = "CustomBlacklist"

    -- Register with the new settings API
    local custombl_settings_category = Settings.RegisterCanvasLayoutCategory(optionsPanel, "Custom Blacklist")
    custombl_settings_category.ID = "CustomBlacklistOptionsPanel";
    Settings.RegisterAddOnCategory(custombl_settings_category)

    local title = optionsPanel:CreateFontString("Custom Blacklist", nil, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("CustomBlacklist")

    local addonVersionAndAuthor = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    addonVersionAndAuthor:SetPoint("TOPLEFT", 11, -26)
    addonVersionAndAuthor:SetText("Version " .. addon_version .. " by Romanov")
    addonVersionAndAuthor:SetTextColor(1,1,1)

    local editBoxTitle = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    editBoxTitle:SetPoint("TOPLEFT", 11, -50)
    editBoxTitle:SetText("Export blacklist")

    local messageEditBox = CreateFrame("EditBox", "CustomBlacklistMessageEditBox", optionsPanel, "InputBoxTemplate")
    messageEditBox:SetMultiLine(false)
    messageEditBox:SetAutoFocus(false)
    messageEditBox:SetWidth(300)
    messageEditBox:SetHeight(50)
    messageEditBox:SetFontObject(ChatFontNormal)
    messageEditBox:EnableMouse(true)
    messageEditBox:SetPoint("TOPLEFT", 11, -50)
    messageEditBox:SetText(blacklistToString())

    messageEditBox:SetCursorPosition(0)

    local editBoxTitle = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    editBoxTitle:SetPoint("TOPLEFT", 11, -110)
    editBoxTitle:SetText("Import blacklist")

    local importEditBox = CreateFrame("EditBox", "CustomBlacklistMessageEditBox", optionsPanel, "InputBoxTemplate")
    importEditBox:SetMultiLine(false)
    importEditBox:SetAutoFocus(false)
    importEditBox:SetAutoFocus(false)
    importEditBox:SetWidth(300)
    importEditBox:SetHeight(50)
    importEditBox:SetFontObject(ChatFontNormal)
    importEditBox:EnableMouse(true)
    importEditBox:SetPoint("TOPLEFT", 11, -110)

    local importButton = CreateFrame("Button", "customMessageimportButton", optionsPanel, "UIPanelButtonTemplate")
    importButton:SetPoint("TOPLEFT", 5, -150)
    importButton:SetSize(125, 25)
    importButton:SetText("Import blacklist")

    importButton:SetScript("OnClick", function(self, button, down)
        importBlacklist(messageEditBox:GetText())
        importEditBox:SetText(blacklistToString())
    end)

    local removePlayerBlacklistTitle = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    removePlayerBlacklistTitle:SetPoint("TOPLEFT", 11, -190)
    removePlayerBlacklistTitle:SetText("Remove player from blacklist")

    local removePlayerEditBox = CreateFrame("EditBox", "CustomBlacklistMessageEditBox", optionsPanel, "InputBoxTemplate")
    removePlayerEditBox:SetMultiLine(false)
    removePlayerEditBox:SetAutoFocus(false)
    removePlayerEditBox:SetWidth(300)
    removePlayerEditBox:SetHeight(50)
    removePlayerEditBox:SetFontObject(ChatFontNormal)
    removePlayerEditBox:EnableMouse(true)
    removePlayerEditBox:SetPoint("TOPLEFT", 11, -190)

    local removePlayerButton = CreateFrame("Button", "customMessageimportButton", optionsPanel, "UIPanelButtonTemplate")
    removePlayerButton:SetPoint("TOPLEFT", 5, -230)
    removePlayerButton:SetSize(125, 25)
    removePlayerButton:SetText("Remove player")

    removePlayerButton:SetScript("OnClick", function(self, button, down)
        removePlayerFromBlacklist(removePlayerEditBox:GetText())
        removePlayerEditBox:SetText("")
        importEditBox:SetText(blacklistToString())
    end)

    local removePlayerWarning = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    removePlayerWarning:SetPoint("TOPLEFT", 11, -260)
    removePlayerWarning:SetText("Warning: Please add the player's realm name as well. Example: Player-Realm")

    local addPlayerBlacklistTitle = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    addPlayerBlacklistTitle:SetPoint("TOPLEFT", 11, -290)
    addPlayerBlacklistTitle:SetText("Add player to blacklist")

    local addPlayerEditBox = CreateFrame("EditBox", "CustomBlacklistMessageEditBox", optionsPanel, "InputBoxTemplate")
    addPlayerEditBox:SetMultiLine(false)
    addPlayerEditBox:SetAutoFocus(false)
    addPlayerEditBox:SetWidth(300)

    addPlayerEditBox:SetHeight(50)
    addPlayerEditBox:SetFontObject(ChatFontNormal)
    addPlayerEditBox:EnableMouse(true)
    addPlayerEditBox:SetPoint("TOPLEFT", 11, -290)

    local addPlayerButton = CreateFrame("Button", "customMessageimportButton", optionsPanel, "UIPanelButtonTemplate")
    addPlayerButton:SetPoint("TOPLEFT", 5, -330)
    addPlayerButton:SetSize(125, 25)
    addPlayerButton:SetText("Add player")

    addPlayerButton:SetScript("OnClick", function(self, button, down)
        addBlacklistEntry(addPlayerEditBox:GetText())
        addPlayerEditBox:SetText("")
        importEditBox:SetText(blacklistToString())
    end)

    local addPlayerWarning = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    addPlayerWarning:SetPoint("TOPLEFT", 11, -360)
    addPlayerWarning:SetText("Warning: Please add the player's realm name as well. Example: Player-Realm")
end

local function createAddonMaccro()
    CreateMacro("[CBL]", "INV_MISC_QUESTIONMARK", "/cb", nil);
    customBlacklistSavedData["maccroCreated"] = true
end

local function addTargetToBlacklist()
    local targetName, targetRealm = UnitName("target")
    
    if not targetName then
        print("No target selected.")
        return
    end
    
    if not targetRealm then
        targetRealm = GetRealmName()
    end
        
    addBlacklistEntry(targetName .. "-" .. targetRealm)
end

local function checkIfPlayerIsBlacklisted(name)
    if customBlacklistSavedData["blacklistedPlayers"][name] then
        showLocalRaidWarning(name.." is blacklisted!")
        PlaySound(SOUNDKIT.RAID_WARNING, "Master")
    end
end

local function listAllBlacklistedPlayers()
    print("Blacklisted players:")
    print("-------------------(START)-------------------")
    for k, v in pairs(customBlacklistSavedData["blacklistedPlayers"]) do
        print(k)
    end
    print("-------------------(END)-------------------")
end

frame:SetScript("OnEvent", function(self, event, arg1, arg2)

    if event == "ADDON_LOADED" and addon_loaded == false then
        self:UnregisterEvent("ADDON_LOADED")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFA45AEDCustomBlacklist addon loading...")

        if not customBlacklistSavedData then
            customBlacklistSavedData = {}
        end
         
        if not customBlacklistSavedData["blacklistedPlayers"] then
            customBlacklistSavedData["blacklistedPlayers"] = {}
        end

        if not customBlacklistSavedData["maccroCreated"] then
            createAddonMaccro()
        end

        initializeSettingsScreen()

        DEFAULT_CHAT_FRAME:AddMessage("|cFFA45AEDCustomBlacklist addon successfully loaded!")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFA45AED[Custom Blacklist] You can add a targeted user to the blacklist with |cff00ff00/cb |cFFA45AEDand |cff00ff00/customblacklist |cFFA45AEDcommands")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFA45AED[Custom Blacklist] You can can access Custom Blacklist settings by typing |cff00ff00/cb settings |cFFA45AEDor |cff00ff00/cb s")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFA45AED[Custom Blacklist] You can list all blacklisted players by typing |cff00ff00/cb list |cFFA45AEDor |cff00ff00/cb l")
        addon_loaded = true
    elseif event == "CHAT_MSG_WHISPER" then
        checkIfPlayerIsBlacklisted(arg2)
    end
end)
  
-- Register the slash commands
SLASH_CUSTOMBLACKLIST1, SLASH_CUSTOMBLACKLIST2 = '/cb', '/customblacklist'

-- Example usage
-- showLocalRaidWarning("This is a local raid warning!")

SlashCmdList["CUSTOMBLACKLIST"] = function(msg, editbox)
    if msg == "list" then
        listAllBlacklistedPlayers()
    elseif msg == "test" then
        showLocalRaidWarning("HE IS SCAMMER !!!")
    elseif msg == "settings" then
        InterfaceOptionsFrame_OpenToCategory("Custom Blacklist")
    elseif msg == "s" then
        Settings.OpenToCategory("CustomBlacklistOptionsPanel")
    elseif msg == "l" then
        listAllBlacklistedPlayers()
    else
        addTargetToBlacklist()
    end
end