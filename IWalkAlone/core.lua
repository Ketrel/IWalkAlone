--================================
--== Basic Addon Setup
--================================
    IWA = { -- main variable
        ['conf']            = {},
        ['eventFrame']      = CreateFrame("FRAME","IWA_EventFrame"),
        ['spacerFrame']     = CreateFrame("FRAME","IWA_SpacerFrame"),
        ['events']          = {},
        ['CPF_UV']          = CompactPartyFrame_UpdateVisibility,
        ['CRFM_US']         = CompactRaidFrameManager_UpdateShown,
    }
    local db = {}

----------------------------------

--================================
--= IWalkAlone Functions
--================================
    local function IWA_sync()
        IWalkAlone = IWA.conf
    end

    function IWA_hideManager()
        CompactRaidFrameManager:SetAlpha(0)
        CompactRaidFrameManagerToggleButton:Hide()
    end

    function IWA_showManager()
        CompactRaidFrameManager:SetAlpha(1)
        CompactRaidFrameManagerToggleButton:Show()
    end

    local function IWA_toggleManager(msg, editBox, hc)
        if CompactRaidFrameManager:GetAlpha() < 1 then
            IWA.conf.showManager = true
            IWA_showManager()
            IWA_sync()
        else
            IWA.conf.showManager = false
            IWA_hideManager()
            IWA_sync()
        end
    end

    local function IWA_CRFM_UpdateOptionsFlowContainer()
        return true
    end
    
    local function IWA_CPF_OnLoad()
        IWA_CPF_Title()
    end

    local function IWA_CPF_Title()
        if IsInGroup() == false then 
            CompactPartyFrame.title:SetText(SOLO)
        elseif IsInGroup() and not IsInRaid() then
            CompactPartyFrame.title:SetText(PARTY)
        end
    end

    function CompactRaidFrameManager_UpdateShown()
        local showManager = true or EditModeManagerFrame:AreRaidFramesForcedShown() or EditModeManagerFrame:ArePartyFramesForcedShown();
        CompactRaidFrameManager:SetShown(showManager);

        CompactRaidFrameManager_UpdateOptionsFlowContainer();
        CompactRaidFrameManager_UpdateContainerVisibility();
    end

    function CompactPartyFrame_UpdateVisibility()
        if not CompactPartyFrame then
            return;
        end

        local isInArena = IsActiveBattlefieldArena();
        local groupFramesShown = (true and (isInArena or not IsInRaid())) or EditModeManagerFrame:ArePartyFramesForcedShown();
        local showCompactPartyFrame = groupFramesShown and EditModeManagerFrame:UseRaidStylePartyFrames();
        CompactPartyFrame:SetShown(showCompactPartyFrame);
        PartyFrame:UpdatePaddingAndLayout();
    end

    local function IWA_init()
        if IWalkAlone then
            IWA.conf = IWalkAlone
        else
            IWA.conf = {
                ["showManager"] = true,
            }
            IWA_sync()
        end

        if IWA.conf.showManager == false and IsInGroup() == false then
            IWA_hideManager()
        end

        IWA.spacerFrame:SetHeight(10)

        --================================
        --= Hooks, Secure and Otherwise
        --================================
        --hooksecurefunc("CompactRaidFrameManager_UpdateShown", IWA_CRFM_UpdateShown)
        --hooksecurefunc("CompactRaidFrameManager_UpdateOptionsFlowContainer", IWA_CRFM_UpdateOptionsFlowContainer)
        --hooksecurefunc("CompactRaidFrameManager_UpdateContainerVisibility", IWA_CRFM_UpdateContainerVisibility)
        --hooksecurefunc("CompactRaidFrameManager_UpdateContainerLockVisibility", IWA_CRFM_UpdateContainerLockVisibility)
        --hooksecurefunc("CompactPartyFrame_OnLoad",IWA_CPF_OnLoad)

        ----------------------------------

        IWA_CPF_Title()

        CompactRaidFrameContainer:SetIgnoreParentAlpha(1)
        IWA.eventFrame:UnregisterEvent("ADDON_LOADED")
    end

----------------------------------

--================================
--= Setup Events
--================================
    local events = {}

    function events:GROUP_JOINED()
        IWA_showManager()
        IWA_CPF_Title()
    end

    function events:GROUP_LEFT()
        if not IWA.conf.showManager then
            IWA_hideManager()
        end
        IWA_CPF_Title()
    end

    function events:ADDON_LOADED(...)
        event, arg1 = ...
        if arg1 == "IWalkAlone" then
            IWA_init()
        end
    end

    local function eventHandler(self,event,...)
        events[event](self,event,...)
    end

    IWA.eventFrame:RegisterEvent("GROUP_JOINED")
    IWA.eventFrame:RegisterEvent("GROUP_LEFT")
    IWA.eventFrame:RegisterEvent("ADDON_LOADED")

    IWA.eventFrame:SetScript("OnEvent",eventHandler)

----------------------------------

--================================
--= Slash Commands
--================================
    SlashCmdList["TOGGLEMANAGER"] = IWA_toggleManager
    SLASH_TOGGLEMANAGER1, SLASH_TOGGLEMANAGER2, SLASH_TOGGGLEMANAGER3 = '/iwa', '/toggleraidman', '/raidman'
