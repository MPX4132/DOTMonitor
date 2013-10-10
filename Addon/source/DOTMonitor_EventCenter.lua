local DOTMonitor = getglobal("DOTMonitor") or {}

local Player 	= DOTMonitor.library.Player:New()
local HUD		= DOTMonitor.library.HUD:New(nil)

--Test vars:
DOTMonitor.unit = {
	player 	= Player,
	HUD		= HUD
}

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
	HUD:SetVisible(DOTMonitor.inspector.playerTargetingLivingEnemy())
	DOTMonitor.logMessage("Target Changed: "..(UnitName("target") or "\[x\]"))
end


local DOTMonitorReaction_playerStartedFighting 	= function()
	HUD:SetEnabled(true)
end
local DOTMonitorReaction_playerStoppedFighting 	= function()
	HUD:SetEnabled(false)
end


local DOTMonitorReaction_playerAbilitiesPossiblyChanged = function()
	Player:Synchronize()
	HUD:SetEnabled(false)
end


local DOTMonitorReaction_playerEnteringWorld 	= function()
	Player:Delegate(HUD)
	DOTMonitorReaction_playerAbilitiesPossiblyChanged()
	HUD:FormalPosition()
	DOTMonitorEventCenter_StartResponding()
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
	end
end))

DOTMonitorEventCenter:RegisterEvent("PLAYER_ENTERING_WORLD")