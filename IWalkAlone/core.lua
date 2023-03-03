--================================
--== Basic Addon Setup
--================================
    IWA = { -- main variable
        ['conf']            = {},
        ['eventFrame']      = CreateFrame("FRAME","IWA:EventFrame"),
        ['spacerFrame']     = CreateFrame("FRAME","IWA:SpacerFrame"),
        ['events']          = {},
        ['combatQueue']     = {},
    }
    local db = {}

----------------------------------

--================================
--= IWalkAlone Functions
--================================
    function IWA:sync()
        IWalkAlone = IWA.conf
    end

    function IWA:hideManager()
        CompactRaidFrameManager:SetAlpha(0)
        CompactRaidFrameManagerToggleButton:Hide()
    end

    function IWA:showManager()
        CompactRaidFrameManager:SetAlpha(1)
        CompactRaidFrameManagerToggleButton:Show()
    end

    function IWA:toggleManager(msg, editBox, hc)
        if CompactRaidFrameManager:GetAlpha() < 1 then
            IWA.conf.showManager = true
            IWA:showManager()
            IWA:sync()
        else
            IWA.conf.showManager = false
            IWA:hideManager()
            IWA:sync()
        end
    end

    function IWA:CRFM_UpdateOptionsFlowContainer()
        return true
    end
    
    function IWA:CPF_Title()
        if UnitAffectingCombat('player') then
            IWA.combatQueue[IWA.CPF_Title] = true
            IWA.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
            return;
        end
        if IsInGroup() == false then 
            CompactPartyFrame.title:SetText(SOLO)
        elseif IsInGroup() and not IsInRaid() then
            CompactPartyFrame.title:SetText(PARTY)
        end
        --if in raid, let it do it's own thing for groups
    end

    function IWA:CRFM_UpdateShown()
        if UnitAffectingCombat('player') then
            IWA.combatQueue[IWA.CRFM_UpdateShown] = true
            IWA.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
            return;
        end
        local showManager = true or EditModeManagerFrame:AreRaidFramesForcedShown() or EditModeManagerFrame:ArePartyFramesForcedShown();
        CompactRaidFrameManager:SetShown(showManager);

        CompactRaidFrameManager_UpdateOptionsFlowContainer();
        CompactRaidFrameManager_UpdateContainerVisibility();
    end

    function IWA:CPF_UpdateVisibility()
        if UnitAffectingCombat('player') then
            IWA.combatQueue[IWA.CPF_UpdateVisibility] = true
            IWA.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
            return;
        end
        if not CompactPartyFrame then
            return;
        end

        local isInArena = IsActiveBattlefieldArena();
        --local groupFramesShown = (true and (isInArena or not IsInRaid())) or EditModeManagerFrame:ArePartyFramesForcedShown();
        local groupFramesShown = GetCVarBool("raidOptionIsShown") and (true and (isInArena or not IsInRaid())) or EditModeManagerFrame:ArePartyFramesForcedShown();
        local showCompactPartyFrame = groupFramesShown and EditModeManagerFrame:UseRaidStylePartyFrames();
        CompactPartyFrame:SetShown(showCompactPartyFrame);
        PartyFrame:UpdatePaddingAndLayout();
    end

    function IWA:CRFM_UpdateOptionsFlowContainer()
        if UnitAffectingCombat('player') then
            IWA.combatQueue[IWA.CRFM_UpdateOptionsFlowContainer] = true
            IWA.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
            return;
        elseif IsInGroup() == true then
            return;
        end

        local container = CompactRaidFrameManager.displayFrame.optionsFlowContainer
        FlowContainer_AddObject(container, CompactRaidFrameManager.displayFrame.hiddenModeToggle)

        if GetCVarBool("raidOptionIsShown") then
            CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetText(HIDE)
        else
            CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetText(SHOW)
        end

        CompactRaidFrameManager.displayFrame.hiddenModeToggle:Show()
    end

    function IWA:Reload()
        IWA:CRFM_UpdateShown()
        IWA:CPF_UpdateVisibility()
        IWA:CRFM_UpdateOptionsFlowContainer()
        IWA:CPF_Title()
    end

    function IWA:CombatReload()
        IWA.eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        for func,act in pairs(IWA.combatQueue) do
            if act == true then
                IWA.combatQueue[func] = false
                func(IWA)
            end
        end
    end

    function IWA:init()
        if IWalkAlone then
            IWA.conf = IWalkAlone
        else
            IWA.conf = {
                ["showManager"] = true,
            }
            IWA:sync()
        end

        if IWA.conf.showManager == false and IsInGroup() == false then
            IWA:hideManager()
        end

        IWA.spacerFrame:SetHeight(10)

        --================================
        --= Hooks, Secure and Otherwise
        --================================
        hooksecurefunc("CompactRaidFrameManager_UpdateShown", IWA.CRFM_UpdateShown)
        hooksecurefunc("CompactPartyFrame_UpdateVisibility", IWA.CPF_UpdateVisibility)
        hooksecurefunc("CompactRaidFrameManager_UpdateOptionsFlowContainer", IWA.CRFM_UpdateOptionsFlowContainer)
        ----------------------------------

        IWA:CPF_Title()

        CompactRaidFrameContainer:SetIgnoreParentAlpha(1)
        IWA.eventFrame:UnregisterEvent("ADDON_LOADED")
    end

----------------------------------

--================================
--= Setup Events
--================================
    local events = {}

    function events:GROUP_JOINED()
        IWA:showManager()
        IWA:CPF_Title()
    end

    function events:GROUP_LEFT()
        if not IWA.conf.showManager then
            IWA:hideManager()
        end
        IWA:CPF_Title()
    end

    function events:ADDON_LOADED(...)
        event, arg1 = ...
        if arg1 == "IWalkAlone" then
            IWA:init()
        end
    end

    function events:PLAYER_REGEN_ENABLED()
        IWA:CombatReload()
    end

    function eventHandler(self,event,...)
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
    SlashCmdList["TOGGLEMANAGER"] = IWA.toggleManager
    SLASH_TOGGLEMANAGER1, SLASH_TOGGLEMANAGER2, SLASH_TOGGGLEMANAGER3 = '/iwa', '/toggleraidman', '/raidman'
    SlashCmdList["RELOADIWA"] = IWA.Reload
    SLASH_RELOADIWA1, SLASH_RELOADIWA2= "/reloadiwa", "/iwareload"
