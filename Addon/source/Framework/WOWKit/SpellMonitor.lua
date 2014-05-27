--[[
	SpellMonitor 0.1V
	Simple spell monitoring class for the World of Warcraft environment.
--]]

local Icon 			= _G["MPXUIKit_Icon"]
local Spell			= _G["MPXWOWKit_Spell"]
local TextureSprite = _G["MPXUIKit_TextureSprite"]

local SpellMonitor = {} -- Local Namespace

function SpellMonitor:TrackSpell(spell)
	self.spell = spell
	self.icon:SetSpell(spell)
	return spell and tostring(spell) or "Nothing Appropriate"
end

function SpellMonitor:SetTarget(unit)
	self.target = unit
end

function SpellMonitor:SetAlpha(alpha)
	alpha = alpha or 1
	self.alpha = alpha
	self.icon:SetAlpha(alpha < 0 and 0 or alpha > 1 and 1 or alpha)
end

function SpellMonitor:Draggable(mouseButton)
	mouseButton = (mouseButton == nil 	and "LeftButton")
			   or (mouseButton ~= false and mouseButton)

	self:Monitor(not mouseButton)
	self:Enable(mouseButton)
	self.icon:Draggable(mouseButton)
end

function SpellMonitor:Enable(enable)
	if enable
	then self.icon:Show()
	else self.icon:Hide()
	end
end

function SpellMonitor:Monitor(monitor)
	self.monitoring = (monitor == nil) or (monitor ~= false)
	if not self.monitoring then
		self:Reset()
	end
end

function SpellMonitor:Reset()
	self:SetSize()
	self:SetAlpha()
end

function SpellMonitor:Update()
	if UnitExists(self.target) and not UnitIsDead(self.target) then
		local duration, expiration, caster = self.spell:TimeOnUnit(self.target)

		-- DOT Monitor
		if caster == "player" then
			local timeRemaining 	= (expiration - GetTime())
			local timeFraction 		= (duration ~= 0) and (timeRemaining / duration) or 0
			local sizeMagnitude 	= self.size.width - (timeFraction * self.size.width)
			local alphaMagnitude 	= 1 - timeFraction

			self.icon:SetHeight(sizeMagnitude)
			self.icon:SetWidth(sizeMagnitude)
			self.icon:SetAlpha(alphaMagnitude)
		else
			self.icon:SetHeight(self.size.width)
			self.icon:SetWidth(self.size.width)
			self.icon:SetAlpha(1)
		end

		-- CD Monitor
		local cdStart, cdDuration, cdEnabled = self.spell:GetCooldown()
		if cdStart > 0 and cdDuration > 0 then
			self.icon.sprite:SetPercentage(100-((cdStart + cdDuration - GetTime()) / cdDuration) * 100)
		--elseif duration == 0 then
		else
			self.icon.sprite:SetPercentage(100)
		end
	else
		self.icon:SetHeight(0)
		self.icon:SetWidth(0)
		self.icon:SetAlpha(0)
	end
end

function SpellMonitor:SetSize(width, height)
	self.size.width 	= width		or self.size.width
	self.size.height 	= height	or self.size.height

	self.icon:SetWidth(self.size.width)
	self.icon:SetHeight(self.size.height)
end

function SpellMonitor:IconMake(GlobalID, delegate)
 	local icon = Icon:New(GlobalID)

 	icon:Hide()
 	icon:Round(true)
 	icon:SetWidth(44)
 	icon:SetHeight(44)
	icon:SetDelegate(delegate)
	icon:ThrottleUpdateByTime(0.100)

	icon:SetBorder("Interface\\AddOns\\DOTMonitor\\Graphics\\IconBorder")
	icon:SetHighlight("Interface\\AddOns\\DOTMonitor\\Graphics\\IconOverlayDrag")

	icon.sprite = TextureSprite:New(icon)
   	icon.sprite:SetAllPoints()
   	icon.sprite:SetAlpha(0.60)

   	icon.sprite:SetSpriteSheetConfig("Interface\\AddOns\\DOTMonitor\\Graphics\\CircleLoadMask", 512, 256)
   	icon.sprite:SetSpriteImageConfig(20, 64, 64)

	return icon
end

local SpellMonitorDefault = {
	spell 		= nil,
	target 		= "target",
	monitoring 	= true,
	size = {
		width = 44,
		height = 44
	},
	TrackSpell 	= SpellMonitor.TrackSpell,
	SetTarget	= SpellMonitor.SetTarget,
	SetAlpha	= SpellMonitor.SetAlpha,
	Draggable	= SpellMonitor.Draggable,
	Enable		= SpellMonitor.Enable,
	Monitor		= SpellMonitor.Monitor,
	Reset		= SpellMonitor.Reset,
	Update		= SpellMonitor.Update,
	SetSize		= SpellMonitor.SetSize
}

function SpellMonitor:New(ID, spell)
	local spellMonitor = {}
	setmetatable(spellMonitor, {__index = SpellMonitorDefault})

	spellMonitor.ID = ID
	spellMonitor.icon = self:IconMake(ID, spellMonitor)

	spellMonitor.icon:OnUpdate((function(self, elapsed)
		if self.monitoring then self:Update() end
	end)) -- Register for updates

	if spell then
		spellMonitor:TrackSpell(spell)
	end

	return spellMonitor
end

MPXWOWKit_SpellMonitor = SpellMonitor -- Global Registration