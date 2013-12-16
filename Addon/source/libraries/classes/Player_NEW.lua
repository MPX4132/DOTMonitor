local Player = {};

function Player:Enabled(...)
	if type(select(1, ...)) == "boolean" then
		if (select(1, ...)) then
			self:Show();
		else
			self:Hide();
		end
	else
		self:Show();
	end
end

function Player:IsPlayer()
	return UnitIsPlayer(self.subject)
end

function Player:Level(...)
	self.resource.level = (select(1,...)) or self.resource.level;
	return self.resource.level;
end

function Player:Class()
	return self.class.name;
end

function Player:HasSpec(...)
	return self:Level() >= 10 and GetSpecialization() or false;
end

function Player:Spec(...)
	self.class.spec = (select(1,...)) or self.class.spec or false;
	return self.class.spec;
end

function Player:GetInfo()
	return self:IsPlayer(), self:Level(), self:Class(), self:Spec();
	--[[{
		["player"]	= self:IsPlayer(),
		["level"] 	= self:Level(),
		["class"] 	= self:Class(),
		["spec"]	= self:Spec(),
	};]]
end

-- Status Methods

function Player:Health()
	return UnitHealth(self.subject) / UnitHealthMax(self.subject);
end

function Player:InCombat()
	return UnitAffectingCombat(self.subject);
end

function Player:Power()
	return UnitPower(self.subject) / UnitPowerMax(self.subject);
end

function Player:Status()
	return self:InCombat(), self:Health(), self:Power();
	--[[{
		["health"] 	= self:Health(),
		["combat"] 	= self:InCombat(),
		["power"]	= self:Power(),
	};]]
end

function Player:Sync()
	self:Level(UnitLevel(self.subject));
	self:Class(UnitClass(self.subject));

	if self:HasSpec() then
		local specID, specName, specDesc = GetSpecializationInfo(GetSpecialization());
		self.class.id = specID;
		self:Spec(specName);
	end
end

function Player:Delegate(delegate)
	self.eventCenter.delegate = delegate;
end

function Player:New(subject)
	local newPlayer = {
		["subject"] = subject,

		["IsPlayer"]= self.IsPlayer,
		["Level"] 	= self.Level,
		["Class"] 	= self.Class,
		["HasSpec"]	= self.HasSpec,
		["Spec"] 	= self.Spec,
		["GetInfo"]	= self.GetInfo,
		["Sync"]	= self.Sync,
	};

	newPlayer.resource 	= {};
	newPlayer.class 	= {};
	newPlayer.class.name = UnitClass(self.subject);

	newPlayer.eventCenter = CreateFrame("Frame", ("DOTM_PLAYER_"..subject), UIParent);
	newPlayer.eventCenter:SetAlpha(0);

	newPlayer.eventCenter:SetScript("PLAYER_TALENT_UPDATE", (function(self, ...)
		if type(self.delegate) ~= "function" then return; end
	end));

end

--[[

local aFrame = CreateFrame("Frame", frameGlobalID, UIParent)
	aFrame:SetMovable(true)
	aFrame:SetFrameStrata(frameLayer)

	-- Register Frames For MOVEMENT! (HAPPY NOW, PEOPLE?!)
	aFrame:SetScript("OnMouseDown", (function(self, button)
		if button == "LeftButton" and not self.isMoving then
			self:StartMoving();
			self.isMoving = true;
		end
	end))

	aFrame:SetScript("OnMouseUp", (function(self, button)
		if button == "LeftButton" and self.isMoving then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
	end))

	aFrame:SetScript("OnHide", (function(self)
		if (self.isMoving) then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
	end))

	]]