local DOTMonitor = getglobal("DOTMonitor") or {}

local DOTMonitorEventCenter = CreateFrame("Frame"); DOTMonitorEventCenter:SetAlpha(0);


-- @ Responder Functions Implementation
-- ================================================================================
local DOTMonitorReaction_playerChangedTarget 	= function()
	local targetName = "No Target"
	if DOTMonitor.inspector.playerTargetingLivingEnemy() then
		targetName = UnitName("target")
		
	end
	DOTMonitor.logMessage("Target changed: "..targetName)
end

local DOTMonitorReaction_playerStartedFighting 	= function()
	DOTMonitor.HUD:SetEnabled(true)
end

local DOTMonitorReaction_playerStoppedFighting 	= function()
	DOTMonitor.HUD:SetEnabled(false)
end

local DOTMonitorReaction_playerEnteringWorld 	= function()
	DOTMonitor.unit.player:Synchronize()
	
	if DOTMonitor.unit.player.ready then
		DOTMonitor.HUD:Update()
		DOTMonitor.printMessage("\[DOTMonitor: Ready\]", )
	else
		DOTMonitor.printMessage("requires a specialization!\]")
	end
end

local DOTMonitorReaction_playerAbilitiesPossiblyChanged = function()
	DOTMonitor.unit.player:Synchronize()
	DOTMonitor.HUD:Update()
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