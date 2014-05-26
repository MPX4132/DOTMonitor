--
-- Icon V0.1
-- Simple frame icon for WOW
--

local Icon = {instance = 0}

function Icon:Round(round)
	self.isRound = round
	self:SetBackground()
	self:SetBorder()
	self:SetHighlight()
end

function Icon:Draggable(draggable, ...)
	local isDraggable = draggable ~= false
	self:SetMovable(isDraggable) -- For StartMoving() to work, otherwise error
	self:EnableMouse(isDraggable)
    self:RegisterForDrag(draggable, ...)
end

function Icon:SetPosition(x, y)
	self:SetPoint("CENTER", x, y)
end

function Icon:SetCenter(x, y)
	self:SetPoint("CENTER", WorldFrame, "CENTER", x, y)
end

function Icon:SetBackground(texturePath)
	self.texturePath = texturePath or self.texturePath
	if not self.texture then
		self.texture = self:CreateTexture(nil, "ARTWORK")
		self.texture:SetAllPoints(self)
	end

	if self.isRound then
		SetPortraitToTexture(self.texture, self.texturePath)
	else
		self.texture:SetTexture(self.texturePath)
	end
end

function Icon:SetBorder(texturePath)
	self.borderPath = texturePath or self.borderPath
	if not self.border then
		self.border	= self:CreateTexture(nil, "OVERLAY")
		self.border:SetAllPoints(self)
	end

	if not self.borderPath then return end

	-- WEIRD FREAKING QUIRK HERE WITH THAT FUNCTION!!!
	--if self.isRound then
	--	SetPortraitToTexture(self.border, self.borderPath)
	--else
		self.border:SetTexture(self.borderPath)
	--end
end

function Icon:SetHighlight(texturePath)
	self.highlightPath = texturePath or self.highlightPath
	if not self.highlight then
		self.highlight = self:CreateTexture(nil, "HIGHLIGHT")
		self.highlight:SetAllPoints(self)
	end

	if not self.highlightPath then return end

	-- WEIRD FREAKING QUIRK HERE WITH THAT FUNCTION!!!
	--if self.isRound then
	--	SetPortraitToTexture(self.highlight, self.highlightPath)
	--else
		self.highlight:SetTexture(self.highlightPath)
	--end
end

function Icon:SetSpell(spell)
	if not spell.icon then return false end
	self:SetBackground(spell.icon)
end

function Icon:IsAction(anAction)
	return type(anAction) == "function"
end

function Icon:OnClickDown(anAction)
	if not self:IsAction(anAction) then return false end
	self:SetScript("OnMouseDown", anAction)
end

function Icon:OnClickUp(anAction)
	if not self:IsAction(anAction) then return false end
	self:SetScript("OnMouseUp", anAction)
end

function Icon:OnHoverIn(anAction)
	if not self:IsAction(anAction) then return false end
	self:SetScript("OnEnter", anAction)
end

function Icon:OnHoverOut(anAction)
	if not self:IsAction(anAction) then return false end
	self:SetScript("OnLeave", anAction)
end

function Icon:OnDragStart(anAction)
	if not self:IsAction(anAction) then return false end
	self.callback["OnDragStart"] = anAction
end

function Icon:OnDragEnd(anAction)
	if not self:IsAction(anAction) then return false end
	self.callback["OnDragEnd"] = anAction
end

function Icon:OnUpdate(anAction)
	if not self:IsAction(anAction) then return false end
	self.callback["OnUpdate"] = anAction
end

function Icon:ThrottleUpdateByTime(time)
	self.updateThrottle = time
end

function Icon:SetDelegate(delegate)
	self.delegate = delegate
end

function Icon:New(ID, backgroundPath)
	self.instance = self.instance + 1
	local frameGlobalID = ID or string.format("MPXWOWKit_Icon_Instance_%d", Icon.instance)
	local icon = CreateFrame("Frame", frameGlobalID, UIParent)
	icon:SetMovable(true)

	icon:SetScript("OnUpdate", (function(self, elapsed)
		self.lastUpdate = self.lastUpdate and (self.lastUpdate + elapsed) or 0

		if self.lastUpdate >= self.updateThrottle then
			if self.callback["OnUpdate"] then
				self.callback["OnUpdate"](self.delegate, elapsed)
			end
			self.lastUpdate = 0
		end
	end))

	icon:SetScript("OnDragStart", (function(self, button)
		self:StartMoving()
		if self.callback["OnDragStart"] then
			self.callback["OnDragStart"](self, button)
		end
	end))


	icon:SetScript("OnDragStop", (function(self, button)
		self:StopMovingOrSizing()
		if self.callback["OnDragEnd"] then
   			self.callback["OnDragEnd"](self, button)
		end
	end))

	icon.delegate = nil
	icon.callback 		= {}
	icon.updateThrottle = 0.250
	icon.SetDelegate	= Icon.SetDelegate
	icon.Round 			= Icon.Round
	icon.Draggable		= Icon.Draggable
	icon.SetPosition	= Icon.SetPosition
	icon.SetCenter		= Icon.SetCenter
	icon.SetBackground	= Icon.SetBackground
	icon.SetBorder		= Icon.SetBorder
	icon.SetHighlight	= Icon.SetHighlight
	icon.SetSpell		= Icon.SetSpell
	icon.IsAction		= Icon.IsAction
	icon.OnClickDown	= Icon.OnClickDown
	icon.OnClickUp		= Icon.OnClickUp
	icon.OnHoverIn		= Icon.OnHoverIn
	icon.OnHoverOut		= Icon.OnHoverOut
	icon.OnDragStart	= Icon.OnDragStart
	icon.OnDragEnd		= Icon.OnDragEnd
	icon.OnUpdate		= Icon.OnUpdate
	icon.ThrottleUpdateByTime = Icon.ThrottleUpdateByTime

	icon.texturePath 	= "Interface\\ICONS\\Trade_Engineering"

	if backgroundPath then
		icon:SetBackground(backgroundPath)
	end

	if not icon:IsUserPlaced() then
		icon:SetWidth(32)
		icon:SetHeight(32)
		icon:SetPoint("Center", 0, 0)
	end

	return icon
end

MPXUIKit_Icon = Icon