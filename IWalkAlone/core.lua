local showManager = true
local db = {}

--================================

local eventFrame = CreateFrame("FRAME","IWA_EventFrame")
local events = {}
eventFrame:RegisterEvent("GROUP_JOINED")
eventFrame:RegisterEvent("GROUP_LEFT")
eventFrame:RegisterEvent("ADDON_LOADED")

local function IWA_sync()
    IWA = db
end

local function eventHandler(self,event,...)
	events[event](self,event,...)
end
	
function events:GROUP_JOINED()
    IWA_showManager()
end

function events:GROUP_LEFT()
	if not db.showManager then
        IWA_hideManager()
	end
end

function events:ADDON_LOADED(...)
    event, arg1 = ...
    if arg1 == "IWalkAlone" then
        if IWA then
            db = IWA
        else
            db = {
                ["showManager"] = true,
            }
        IWA_sync()
        end
        if db.showManager == false and IWA_getDAF() == nil then
            IWA_hideManager()
        end
    end
    eventFrame:UnregisterEvent("ADDON_LOADED")
end

eventFrame:SetScript("OnEvent",eventHandler)

--=================================

IWA_getDAF = GetDisplayedAllyFrames
function GetDisplayedAllyFrames()
  local daf = IWA_getDAF()
  if daf == 'party' or not daf then
    return 'raid'
  else
    return daf
  end
end

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

--=================================

--CompactRaidFrameContainer:Show()
--CompactRaidFrameManager:Show()

CompactRaidFrameManager.RealHide = CompactRaidFrameManager.Hide
CompactRaidFrameManager.Hide = function() end

--CompactRaidFrameContainer.RealHide = CompactRaidFrameContainer.Hide
--CompactRaidFrameContainer.Hide = function() end

CompactRaidFrameContainer:SetIgnoreParentAlpha(1)

--=================================

function IWA_hideManager()
    CompactRaidFrameManager:SetAlpha(0)
    CompactRaidFrameManagerToggleButton:Hide()
end

function IWA_showManager()
    CompactRaidFrameManager:SetAlpha(1)
    CompactRaidFrameManagerToggleButton:Show()
end

local function toggleManager(msg, editBox, hc)
	if CompactRaidFrameManager:GetAlpha() < 1 then
		--showManager = 1
        db.showManager = true
        IWA_showManager()
        IWA_sync()
	else
		--showManager = 0
        db.showManager = false
        IWA_hideManager()
        IWA_sync()
	end
end

SlashCmdList["TOGGLEMANAGER"] = toggleManager
SLASH_TOGGLEMANAGER1, SLASH_TOGGLEMANAGER2, SLASH_TOGGGLEMANAGER3 = '/trman', '/toggleraidman', '/raidman'
