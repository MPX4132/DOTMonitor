--[[
	SpellMonitor 0.1V
	Simple spell monitoring class for the World of Warcraft environment.
--]]

local Icon 		= _G["MPXUIKit_Icon"]
local Spell		= _G["MPXWOWKit_Spell"]

local SpellMonitor = {} -- Local Namespace

function SpellMonitor:TrackSpell(spell)
	self.spell = spell
	self.icon:SetSpell(spell)
end

function SpellMonitor:SetTarget(unit)
	self.target = unit
end

function SpellMonitor:SetAlpha(alpha)
	alpha = alpha or 1
	self.alpha = alpha
	self.icon:SetAlpha(alpha < 0 and 0 or alpha > 1 and 1 or alpha)
end

function SpellMonitor:Enable(enable)
	if enable
	then self.icon:Show()
	else self.icon:Hide()
	end
end

function SpellMonitor:Monitor(monitor)
	self.monitoring = monitor
	if not monitor then
		self:Reset()
	end
end

function SpellMonitor:Reset()
	self:SetSize()
	self:SetAlpha()
end

function SpellMonitor:Update()
	if not UnitExists(self.target) or UnitIsDead(self.target) then return end
	local duration, expiration, caster = self.spell:TimeOnUnit(self.target)

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
end

function SpellMonitor:SetSize(width, height)
	self.size.width 	= width		or self.size.width
	self.size.height 	= height	or self.size.height

	self.icon:SetWidth(self.size.width)
	self.icon:SetHeight(self.size.height)
end

function SpellMonitor:IconMake(delegate)
 	local icon = Icon:New(nil)

 	icon:Hide()
 	icon:Round(true)
 	icon:SetWidth(32)
 	icon:SetHeight(32)
	icon:SetDelegate(delegate)
	icon:ThrottleUpdateByTime(0.100)

	icon:SetBorder("Interface\\AddOns\\DOTMonitor\\Graphics\\IconBorder")
	icon:SetHighlight("Interface\\AddOns\\DOTMonitor\\Graphics\\IconOverlayDrag")

	return icon
end

local SpellMonitorDefault = {
	spell 		= nil,
	target 		= "target",
	monitoring 	= true,
	size = {
		width = 32,
		height = 32
	},
	TrackSpell 	= SpellMonitor.TrackSpell,
	SetTarget	= SpellMonitor.SetTarget,
	SetAlpha	= SpellMonitor.SetAlpha,
	Enable		= SpellMonitor.Enable,
	Monitor		= SpellMonitor.Monitor,
	Reset		= SpellMonitor.Reset,
	Update		= SpellMonitor.Update,
	SetSize		= SpellMonitor.SetSize
}

function SpellMonitor:New(spell)
	local spellMonitor = {}
	setmetatable(spellMonitor, {__index = SpellMonitorDefault})

	spellMonitor.icon = self:IconMake(spellMonitor)

	spellMonitor.icon:OnUpdate((function(self, elapsed)
		if self.monitoring then self:Update() end
	end)) -- Register for updates

	if spell then
		spellMonitor:TrackSpell(spell)
	end

	return spellMonitor
end

MPXWOWKit_SpellMonitor = SpellMonitor -- Global Registration