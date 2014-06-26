-- =======================================================================================
--	SpellMonitor V0.2
--	Simple spell monitoring class for the World of Warcraft environment.
-- =======================================================================================

local Icon 			= _G["MPXUIKit_Icon"]
local Spell			= _G["MPXWOWKit_Spell"]
local TextureSprite = _G["MPXUIKit_TextureSprite"]

local SpellMonitor = {} -- Local Namespace


function SpellMonitor:Update(enabled)
	self.updating = enabled == nil or enabled ~= false
end

function SpellMonitor:Show()
	self.icon:Show()
end

function SpellMonitor:Hide()
	self.icon:Hide()
end

function SpellMonitor:SetWidth(width)
	self.size.width 	= width 	or self.size.width
	self.icon:SetWidth(self.size.width)
end

function SpellMonitor:SetHeight(height)
	self.size.height 	= height 	or self.size.height
	self.icon:SetHeight(self.size.height)

end

function SpellMonitor:SetSize(width, height)
	self:SetWidth(width)
	self:SetHeight(height)
end

function SpellMonitor:Scale(scale)
	self.icon:SetWidth(self.size.width * (scale or 1))
	self.icon:SetHeight(self.size.height * (scale or 1))
end

function SpellMonitor:SetAlpha(alpha)
	self.alpha = alpha and (alpha < 0 and 0 or alpha > 1 and 1 or alpha) or 1
	self.icon:SetAlpha(self.alpha)
end

function SpellMonitor:SetTarget(unit)
	self.target = unit
end

function SpellMonitor:TrackSpell(spell)
	self.spell = spell
	self.icon:SetSpell(spell)
	return spell and tostring(spell) or "Nothing Appropriate"
end

function SpellMonitor:Draggable(mouseButton)
	mouseButton = (mouseButton == nil 	and "LeftButton")
			   or (mouseButton ~= false and mouseButton)

	self[(mouseButton and "Show" or "Hide")](self) -- Make sure it's being displayed if draggable
	self:Update(not mouseButton) -- Stop updating if draggable

	self.icon:SetBorder("Interface\\AddOns\\DOTMonitor\\Graphics\\IconBorder")
	self.icon:Draggable(mouseButton)
	self.icon.sprite:SetAlpha((not mouseButton) and 0.60 or 0)

	-- Reset
	self:Reset()
end

function SpellMonitor:Reset()
	self:SetSize() -- Resets size
	self.icon.digitalMeter:SetAlpha(self.updating and 1 or 0)
	self.icon.digitalCooldown:SetAlpha(self.updating and 1 or 0)
	self.icon:SetAlpha(1)
end

function SpellMonitor:DigitalMeter(enabled)
	local digitalMeter = self.icon.digitalMeter
	digitalMeter[(((enabled == nil) or (enabled ~= false)) and "Show" or "Hide")](digitalMeter)
end

function SpellMonitor:DigitalCooldown(enabled)
	local digitalCooldown = self.icon.digitalCooldown
	digitalCooldown[(((enabled == nil) or (enabled ~= false)) and "Show" or "Hide")](digitalCooldown)
end

function SpellMonitor:SetShowCondition(condition)
	if type(condition) == "function" then
		self.ShowCondition = condition
	end
end

function SpellMonitor:ShowCondition()
	return (not UnitIsDead(self.target))
			and (UnitIsEnemy("player", self.target)
			 or  UnitCanAttack("player", self.target))
end

function SpellMonitor:UpdateIcon(elapsed)
	if not self.spell then return false end
	local effectDuration, effectExpiration, effectCaster 	= self.spell:TimeOnUnit(self.target)
	local cooldownStart, cooldownDuration, cooldownEnabled 	= self.spell:GetCooldown()

	-- Percentage Indicator
	if effectCaster == "player" then
		local duration = (effectExpiration - GetTime())
		self.icon.digitalMeter:SetFormattedText((duration < 3 and "%1.1f" or "%2d"), duration)
	else
		self.icon.digitalMeter:SetText("^")
	end


	-- Cooldown Indicators
	if cooldownStart > 0 and cooldownDuration > 0 then
		local cooldown = (cooldownStart + cooldownDuration - GetTime())
		self.icon.sprite:SetPercentage(100-(cooldown / cooldownDuration) * 100)
		self.icon.digitalCooldown:SetFormattedText((cooldown < 3 and "%1.1f" or "%2d"), cooldown)
	else
		self.icon.sprite:SetPercentage(100)
		self.icon.digitalCooldown:SetText("")
	end

	for i, aCallback in ipairs(self.callback) do
		aCallback:Update(self, effectDuration, effectExpiration, effectCaster, cooldownStart, cooldownDuration, cooldownEnabled)
	end
end

function SpellMonitor:AddDelegateForUpdate(delegate)
	if (delegate == nil) or (type(delegate.Update) ~= "function") then return false end
	table.insert(self.callback, delegate)
end

function SpellMonitor:RemoveDelegateForUpdate(delegate)
	for i, aDelegate in ipairs(self.callback) do
		if aDelegate == delegate then
			table.remove(self.callback, i)
			break
		end
	end
end

function SpellMonitor:ClearDelegatesForUpdate()
	wipe(self.callback)
end

function SpellMonitor:IconMake(globalID, delegate)
 	local icon = Icon:New(globalID)

 	icon:Hide()
 	icon:Round(true)
 	icon:SetWidth(44)
 	icon:SetHeight(44)
	icon:SetDelegate(delegate)
	icon:ThrottleUpdateByTime(0.050)

	icon:SetBorder("Interface\\AddOns\\DOTMonitor\\Graphics\\IconBorder")
	icon:SetHighlight("Interface\\AddOns\\DOTMonitor\\Graphics\\IconOverlayDrag")

	-- Cooldown Sprite
	icon.sprite = TextureSprite:New(icon)
   	icon.sprite:SetAllPoints()
   	icon.sprite:SetAlpha(0.75)

   	icon.sprite:SetSpriteSheetConfig("Interface\\AddOns\\DOTMonitor\\Graphics\\CircleLoadMask", 512, 256)
   	icon.sprite:SetSpriteImageConfig(20, 64, 64)

   	-- Digital Cooldown
	icon.digitalCooldown = icon:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	icon.digitalCooldown:SetFont("Interface\\AddOns\\DOTMonitor\\Fonts\\Century_Gothic.ttf", 14, nil)--"OUTLINE")
	icon.digitalCooldown:SetTextColor(1, 1, 1, 1)
	icon.digitalCooldown:SetShadowOffset(0, -1)
	icon.digitalCooldown:SetPoint("CENTER", 0, 0)
	icon.digitalCooldown:Hide()

	-- Digital Meter
	icon.digitalMeter = icon:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	icon.digitalMeter:SetFont("Interface\\AddOns\\DOTMonitor\\Fonts\\Century_Gothic.ttf", 16, nil)-- "OUTLINE")
	icon.digitalMeter:SetTextColor(1, 1, 1, 1)
	icon.digitalMeter:SetShadowOffset(0, -1)
	icon.digitalMeter:SetPoint("TOP", icon, "BOTTOM", 0, 0);
	icon.digitalMeter:Hide()

	return icon
end

local SpellMonitorDefault = {
	size = {
		width = 44,
		height = 44
	},

	updating 		= true,
	spell 			= nil,
	target 			= "target",

	Update 			= SpellMonitor.Update,
	Show			= SpellMonitor.Show,
	Hide			= SpellMonitor.Hide,
	SetWidth			= SpellMonitor.SetWidth,
	SetHeight			= SpellMonitor.SetHeight,
	SetSize				= SpellMonitor.SetSize,
	Scale				= SpellMonitor.Scale,
	SetAlpha			= SpellMonitor.SetAlpha,
	SetTarget 			= SpellMonitor.SetTarget,
	TrackSpell			= SpellMonitor.TrackSpell,
	Draggable			= SpellMonitor.Draggable,
	Reset				= SpellMonitor.Reset,
	DigitalMeter		= SpellMonitor.DigitalMeter,
	DigitalCooldown		= SpellMonitor.DigitalCooldown,
	SetShowCondition	= SpellMonitor.SetShowCondition,
	ShowCondition		= SpellMonitor.ShowCondition,
	UpdateIcon			= SpellMonitor.UpdateIcon,
	AddDelegateForUpdate 	= SpellMonitor.AddDelegateForUpdate,
	RemoveDelegateForUpdate = SpellMonitor.RemoveDelegateForUpdate,
	ClearDelegatesForUpdate = SpellMonitor.ClearDelegatesForUpdate,

}

function SpellMonitor:New(ID, spell)
	local spellMonitor = {}
	setmetatable(spellMonitor, {__index = SpellMonitorDefault})

	spellMonitor.ID = ID
	spellMonitor.icon = self:IconMake(ID, spellMonitor)

	spellMonitor.callback = {} -- Callback Queue

	spellMonitor.icon:OnUpdate((function(self, elapsed)
		if not self.updating then return end
		if UnitExists(self.target) and self:ShowCondition() then
			self:UpdateIcon(elapsed)
		else
			self.icon:SetHeight(0)
			self.icon:SetWidth(0)
			self.icon:SetAlpha(0)
		end
	end)) -- Register for updates

	if spell then
		spellMonitor:TrackSpell(spell)
	end

	return spellMonitor
end

MPXWOWKit_SpellMonitor = SpellMonitor -- Global Registration