-- Global Player Class
MPX_Class = _G["MPX_Class"] or {};
local MPX = MPX_Class;

-- Allocation & Local Reference
MPX.Player = {};
local Player = MPX.Player;

-- =======================================================================================
-- Enables or disables the player object's updater by passing arg1,
-- If no arg1, the object enables the updater.
-- =======================================================================================
--	Enable([enable]) -> nil
--		< bol	- true enables the updater, false does the opposite
function Player:Enable(...)
	if (type(select(1, ...)) == "boolean") then
		if (select(1, ...)) then
			self.eventCenter:Show();
		else
			self.eventCenter:Hide();
		end
	else
		self:Show();
	end
end

-- =======================================================================================
-- Returns a boolean denoting if the subject is a real player, otherwise false.
-- =======================================================================================
-- 	IsPlayer() -> bol
-- 		> bol	- true if the subject is a player, (not an NPC)
function Player:IsPlayer()
	return UnitIsPlayer(self.subject);
end

-- =======================================================================================
-- Returns the level of the specified subject.
-- =======================================================================================
--	Level([level]) -> int
--		< int	- Overrides the level value in the player object
--		> int	- Returns the level of the player
function Player:Level(...)
	self.resource.level = (select(1,...)) or self.resource.level;
	return self.resource.level;
end

-- =======================================================================================
-- Returns the player's class as given by a sync call
-- =======================================================================================
-- 	Class() -> str
-- 		> str	- Denotes the player's class
function Player:Class()
	return self.class.name;
end

-- =======================================================================================
-- Denotes if the player's high level enough to support a specialization
-- =======================================================================================
--	SupportsSpec() -> bol
--		> bol	- true if the player supports a specialization
function Player:SupportsSpec()
	return self:Level() >= 10;
end

-- =======================================================================================
-- Determines if the player has an active, working spec.
-- =======================================================================================
-- 	HasSpec() -> bol
--		> bol	- true if the player has a spec, false otherwise
--
-- >>> WARNING: READ BELOW <<<
function Player:HasSpec()
	-- Line below will not work since the player must be inspected to get the spec, and server might throttle
	-- Figure this one out in the future
	-- local specID = (self.subject == "player" and GetSpecialization()) or GetInspectSpecialization("target");
	return self:SupportsSpec() and GetSpecialization() or false;
end

-- =======================================================================================
-- Give's the players spec
-- =======================================================================================
-- 	Spec([spec]) -> str
--		< str	- Denotes a player's spec; when given, the previous spec is overwritten
-- 		> str 	- Denotes the player's current spec
function Player:Spec(...)
	self.class.spec = (select(1,...)) or self.class.spec or false;
	return self.class.spec;
end

-- =======================================================================================
-- Supplies the subject's information in the following order: isPlyer, level, class, sepc
-- =======================================================================================
--	GetInfo() -> str, int, str, str
--		> str 	- Denotes if the subject's a real player, false otherwise
--		> int	- Denotes the player's level
--		> str	- Denotes the player's class
--		> str	- Denotes the player's spec, if possible, otherwise false
function Player:GetInfo()
	return self:IsPlayer(), self:Level(), self:Class(), self:Spec();
end

-- Status Methods
-- =======================================================================================
-- Determine's the player's health percentage
-- =======================================================================================
-- 	Health() -> int
--		> int	- Denotes the player's health percent
function Player:Health()
	return UnitHealth(self.subject) / UnitHealthMax(self.subject);
end

-- =======================================================================================
-- Denotes the subjects's current combat status
-- =======================================================================================
--	InCombat() -> bol
--		> bol	- True if the player is in combat, false otherwise
function Player:InCombat()
	return UnitAffectingCombat(self.subject);
end

-- =======================================================================================
-- Denotes the subject's power percentage (this is either mana, rage, fury, demonic fury...)
-- =======================================================================================
--	Power() -> int
--		> int 	- Denotes the power percentage the player has available
function Player:Power()
	return UnitPower(self.subject) / UnitPowerMax(self.subject);
end

-- =======================================================================================
-- Supplies the subject's status in the order: combat, health, power
-- =======================================================================================
--	Status() -> bol, int, int
--		> bol	- True if the subject is in combat, false otherwise
--		> int 	- Denotes the subject's health percent
--		> int 	- Denotes the subject's power percent
function Player:Status()
	return self:InCombat(), self:Health(), self:Power();
end

-- =======================================================================================
-- Sets or gets the subject of the Player object, sets if arg1 is provided, gets otherwise
-- =======================================================================================
--	Subject([unit]) -> str
--		< str	- Denoting a unit which the Player object will track for its lifetime.
--		> str	- Denotes the unit which the Player object is tracking
function Player:Subject(...)
	self.subject = (type(select(1, ...)) == "string") and (select(1, ...)) or self.subject;
	return self.subject;
end

-- =======================================================================================
-- Synchronizes the Player object to the latest stats, automatically called by the updater
-- =======================================================================================
--	Sync() -> nil
-- >>> WARNING: READ BELOW <<<
function Player:Sync()
	self:Level(UnitLevel(self.subject));
	self:Class(UnitClass(self.subject));

	-- Only for subject "player"
	if self:HasSpec() then
		local specID, specName, specDesc = GetSpecializationInfo(GetSpecialization());
		self.class.id = specID;
		self:Spec(specName);
	end
end

-- =======================================================================================
-- Sets or get the Player object's subject, sets if arg1 is provided, gets otherwise
-- =======================================================================================
--	Delegate([delegate]) -> str
-- 		< str	- Denotes a delegate object which the Player object will notify on updates
--		> str 	- Denotes the delegate object being used by the Player object
function Player:Delegate(...)
	local newDelegate = (select(1, ...));
	self.eventCenter.delegate = newDelegate or self.eventCenter.delegate;
	return self.eventCenter.delegate;
end

-- =======================================================================================
-- [CONSTRUCTOR] Constructs a new Player object
-- =======================================================================================
--	New(subject) -> Player
--		< str	- Denotes a unit which the Player object will track
--		> Player	- Denotes a Player object constructed by the New method
-- >>> WARNING: READ BELOW <<<
function Player:New(subject)
	local newPlayer = {
		["subject"] = subject,

		["Enable"]	= self.Enable,
		["IsPlayer"]= self.IsPlayer,
		["Level"] 	= self.Level,
		["Class"] 	= self.Class,
		["SupportsSpec"] = self.SupportsSpec,
		["HasSpec"]	= self.HasSpec,
		["Spec"] 	= self.Spec,
		["GetInfo"]	= self.GetInfo,
		["Health"]	= self.Health,
		["InCombat"]= self.InCombat,
		["Power"]	= self.Power,
		["Status"]	= self.Status,
		["Subject"]	= self.Subject,
		["Sync"]	= self.Sync,
	};

	newPlayer.resource 	= {};
	newPlayer.class 	= {};
	newPlayer.class.name = UnitClass(self.subject);

	newPlayer.eventCenter = CreateFrame("Frame", ("MPX_PLAYER_"..subject), UIParent);
	newPlayer.eventCenter:SetAlpha(0);
	newPlayer.eventCenter.owner = newPlayer;

	local notifier = (function(self, ...)
		if type(self.delegate) == "function" then
			self.delegate(self, ...);
		end
	end)

	local monitor = (function(self, ...)
		self.lastUpdate = self.lastUpdate and (self.lastUpdate + elapsed) or 0
		if not (self.lastUpdate >= .25) then return end
		if self.owner:Health() <= 25 then
			self.delegate(self, "LOW_HP");
		end
	end)

	-- Only for subject "player"
	if subject == "player" then
		newPlayer.eventCenter:SetScript("PLAYER_TALENT_UPDATE", notifier);
		newPlayer.eventCenter:SetScript("PLAYER_LEVEL_UP", notifier);

		newPlayer.eventCenter:SetScript("OnUpdate", notifier);
	end
end