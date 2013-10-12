local DOTMonitor = getglobal("DOTMonitor") or {}

local Player 	= DOTMonitor.library.Player:New()
local HUD		= DOTMonitor.library.HUD:New(nil)

local userPref = nil

DOTMonitor.user = {player = Player}
DOTMonitor.interface = HUD


for aPos=1, 10 do
	CreateFrame("Frame", ("DOTM_HUD_ICON_"..aPos), UIParent)
end



local DOTMonitorEventCenter_StartResponding = function()
	-- initialization	
	DOTMonitorEventCenter:RegisterEvent("PLAYER_TARGET_CHANGED")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_REGEN_DISABLED")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_REGEN_ENABLED")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_TALENT_UPDATE")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_LEVEL_UP")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_LOGOUT")
	
	DOTMonitor.logMessage("initialized!")
end




-- @ Responder Functions Implementation
-- ================================================================================
local DOTMonitorReaction_playerChangedTarget 	= function()
	--if HUD:Permuting() then return false end
	local aTarget 	= UnitName("target") or "\[No Target\]"
	local status	= DOTMonitor.inspector.playerTargetingLivingEnemy() and "ALIVE" or "N/A"
	
	DOTMonitor.logMessage("Target Changed: "..aTarget.." ("..status..")")
end

local DOTMonitorReaction_playerStartedFighting 	= function()
	if HUD:Permuting() then return false end
	Player:InBattle(true)
	HUD:SetEnabled(true)
end
local DOTMonitorReaction_playerStoppedFighting 	= function()
	if HUD:Permuting() then return false end
	Player:InBattle(false)
	HUD:SetEnabled(false)
end

local DOTMonitorReaction_playerAbilitiesPossiblyChanged = function()
	Player:Synchronize()
	HUD:SetEnabled(false)
end

local DOTMonitorReaction_playerEnteringWorld 	= function()
	Player:Delegate(HUD)
	DOTMonitorReaction_playerAbilitiesPossiblyChanged()
	HUD:FormalPosition();
	DOTMonitorEventCenter_StartResponding()
end

local DOTMonitorReaction_playerExiting = function()
	--local DOTMonitorPreferences = _G["DOTMonitorPreference"];
	userPref = HUD:GetPreferences()
	
	DOTMonitorPreferences = userPref
end

local DOTMonitorReaction_restorePreferences = function()
	userPref = _G["DOTMonitorPreferences"];
	HUD:SetPreferences(userPref)
	Player:Synchronize()
end
-- ================================================================================




-- @ Responder Mapping Implementation
-- ================================================================================
local DOTMonitorEventResponder = { -- Main Response Handeler
	["PLAYER_TARGET_CHANGED"]	= DOTMonitorReaction_playerChangedTarget,
	
	["PLAYER_REGEN_DISABLED"] 	= DOTMonitorReaction_playerStartedFighting,
	["PLAYER_REGEN_ENABLED"] 	= DOTMonitorReaction_playerStoppedFighting,
	
	["PLAYER_TALENT_UPDATE"] 	= DOTMonitorReaction_playerAbilitiesPossiblyChanged,
	["PLAYER_LEVEL_UP"] 		= DOTMonitorReaction_playerAbilitiesPossiblyChanged,
	
	["PLAYER_ENTERING_WORLD"] 	= DOTMonitorReaction_playerEnteringWorld,
	["PLAYER_LOGOUT"]			= DOTMonitorReaction_playerExiting,
	
	["ADDON_LOADED"]			= DOTMonitorReaction_restorePreferences
}


-- @ Event Center Preparation Implementation
-- ================================================================================
DOTMonitorEventCenter = CreateFrame("Frame");
DOTMonitorEventCenter:SetAlpha(0);

DOTMonitorEventCenter:SetScript("OnEvent", (function(self, event, ...)
	if DOTMonitorEventResponder[event] then
		DOTMonitorEventResponder[event](...)
	end
end))

DOTMonitorEventCenter:RegisterEvent("PLAYER_ENTERING_WORLD")