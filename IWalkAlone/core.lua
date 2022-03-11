--================================
--== Basic Addon Setup
--================================
    IWA = { -- main variable
        ['conf']            = {},
        ['eventFrame']      = CreateFrame("FRAME","IWA_EventFrame"),
        ['events']          = {},
        ['getDAF']          = GetDisplayedAllyFrames,
    }
    local db = {}

----------------------------------

--================================
-- IWalkAlone Functions
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

    local function IWA_init()
        if IWalkAlone then
            IWA.conf = IWalkAlone
        else
            IWA.conf = {
                ["showManager"] = true,
            }
            IWA_sync()
        end

        if IWA.conf.showManager == false and IWA.getDAF() == nil then
            IWA_hideManager()
        end

        function GetDisplayedAllyFrames()
          local daf = IWA.getDAF()
          if daf == 'party' or not daf then
            return 'raid'
          else
            return daf
          end
        end

        CompactRaidFrameContainer:SetIgnoreParentAlpha(1)

        --These two may cause taint, I need to investigate this
        CompactRaidFrameManager.RealHide = CompactRaidFrameManager.Hide
        CompactRaidFrameManager.Hide = function() end

        IWA.eventFrame:UnregisterEvent("ADDON_LOADED")
    end

----------------------------------

--================================
--= Setup Events
--================================
    local events = {}

    function events:GROUP_JOINED()
        IWA_showManager()
    end

    function events:GROUP_LEFT()
        if not IWA.conf.showManager then
            IWA_hideManager()
        end
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
-- Hooks, Secure and Otherwise
--================================

--local function postHookCompactRaidFrameContainer_OnEvent(self,event,...)
--    if not UnitAffectingCombat("player") then
--        if ( event == "UNIT_PET" ) then
--            if ( self.displayPets ) then
--                local unit = ...;
--                if unit == "player" or strsub(unit, 1, 4) == "raid" or strsub(unit, 1, 5) == "party" then
--                    return
--                else
--                    print('Marqs Code Ran')
--                    CompactRaidFrameContainer_TryUpdate(self);
--                end
--            end
--        end
--    end
--end
--hooksecurefunc("CompactRaidFrameContainer_OnEvent",postHookCompactRaidFrameContainer_OnEvent)

--local CRFCOE = CompactRaidFrameContainer_OnEvent
--function CompactRaidFrameContainer_OnEvent(self, event, ...)
--    CRFCOE(self, event, ...)
--    if ( event == "UNIT_PET" ) then
--        if ( self.displayPets ) then
--            local unit = ...;
--            if ( unit == "player" or strsub(unit, 1, 4) == "raid" or strsub(unit, 1, 5) == "party" ) or UnitAffectingCombat("player") then
--                return
--            else
--                CompactRaidFrameContainer_TryUpdate(self);
--            end
--        end
--    end
--end

--CompactRaidFrameContainer:Show()
--CompactRaidFrameManager:Show()


--CompactRaidFrameContainer.RealHide = CompactRaidFrameContainer.Hide
--CompactRaidFrameContainer.Hide = function() end

----------------------------------

--================================
-- Slash Commands
--================================
    SlashCmdList["TOGGLEMANAGER"] = IWA_toggleManager
    SLASH_TOGGLEMANAGER1, SLASH_TOGGLEMANAGER2, SLASH_TOGGGLEMANAGER3 = '/iwa', '/toggleraidman', '/raidman'
