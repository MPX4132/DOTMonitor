local DOTMonitor = getglobal("DOTMonitor") or {}
local Player = DOTMonitor.PlayerClass

DOTMonitorEventCenter = CreateFrame("Frame"); DOTMonitorEventCenter:SetAlpha(0);
local DOTMonitorEventCenter_StartResponding = function()
	-- initialization	
	DOTMonitorEventCenter:RegisterEvent("PLAYER_TARGET_CHANGED")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_REGEN_DISABLED")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_REGEN_ENABLED")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_TALENT_UPDATE")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_LEVEL_UP")
	
	DOTMonitor.logMessage("initialized!")
end




-- @ Responder Functions Implementation
-- ================================================================================
local DOTMonitorReaction_playerChangedTarget 	= function()
	local targetName = "[NONE]"
	if DOTMonitor.inspector.playerTargetingLivingEnemy() then
		targetName = UnitName("target")
		--DOTMonitor.unit.enemy:Synchronize()
	end
	DOTMonitor.logMessage("Target: "..targetName)
end


local DOTMonitorReaction_playerStartedFighting 	= function()
	DOTMonitor.HUD:SetEnabled(true)
	DOTMonitor.HUD:SetVisible(true)
end
local DOTMonitorReaction_playerStoppedFighting 	= function()
	DOTMonitor.HUD:SetVisible(false)
	DOTMonitor.HUD:SetEnabled(false)
end


local DOTMonitorReaction_playerAbilitiesPossiblyChanged = function()
	DOTMonitor.unit.player:Synchronize()
	DOTMonitor.HUD:Update()
	DOTMonitor.unit.player:ShowTrackingInfo()
end


local DOTMonitorReaction_playerEnteringWorld 	= function()
	DOTMonitor.unit = {	-- Start Players
		player 	= Player:New()-- ,enemy	= Player:New()
	}

	-- Get User Set
	DOTMonitor.unit.player:Synchronize()
	
	if DOTMonitor.unit.player.ready then
		local userHUDPreferences = getglobal("DOTMONITOR_HUD_SETTINGS")
		DOTMonitor.HUD:Initialize(DOTMonitor.unit.player, nil)
		DOTMonitor.unit.player:ShowTrackingInfo()
		
		DOTMonitorEventCenter_StartResponding()
		
		DOTMonitor.printMessage("Ready", "epic")
	else
		DOTMonitor.printMessage("requires a specialization!", "info")
	end
end




-- @ Responder Mapping Implementation
-- ================================================================================
local DOTMonitorEventResponder = { -- Main Response Handeler
	["PLAYER_TARGET_CHANGED"]	= DOTMonitorReaction_playerChangedTarget,
	
	["PLAYER_REGEN_DISABLED"] 	= DOTMonitorReaction_playerStartedFighting,
	["PLAYER_REGEN_ENABLED"] 	= DOTMonitorReaction_playerStoppedFighting,
	
	["PLAYER_TALENT_UPDATE"] 	= DOTMonitorReaction_playerAbilitiesPossiblyChanged,
	["PLAYER_LEVEL_UP"] 		= DOTMonitorReaction_playerAbilitiesPossiblyChanged,
	
	["PLAYER_ENTERING_WORLD"] 	= DOTMonitorReaction_playerEnteringWorld
}


-- @ Event Center Preparation Implementation
-- ================================================================================
DOTMonitorEventCenter:SetScript("OnEvent", (function(self, event, ...)
	if DOTMonitorEventResponder[event] then
		DOTMonitorEventResponder[event](...)
	else
		DOTMonitor.printMessage("ERROR!")
	end
end))

DOTMonitorEventCenter:RegisterEvent("PLAYER_ENTERING_WORLD")