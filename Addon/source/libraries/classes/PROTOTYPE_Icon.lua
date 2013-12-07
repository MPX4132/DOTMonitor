local DOTMonitor = _G["DOTMonitor"] or {}

local matchesType = function(aType, obj)
	return (type(obj) == aType);
end

local argSize = function(n, ...)
	return (select('#', ...) == n);
end


local Icon = {};

function Icon:AnchorPoints(...)
	if argSize(3, ...) then
		self.anchors = {
			origin = arg[1],
			target = arg[2],
			relative = arg[3]
		}
	end
	return self.anchors.origin, self.anchors.target, self.anchors.relative;
end

function Icon:Position(...)
	if matchesType("table", arg[1]) then
		local origin, target, relative = self:AnchorPoints();
		point = arg[1];

		self:SetPoint(origin, target, relative, point.x, point.y);

		self.settings.position.point 		= point;
		self.settings.position.origin 		= origin;
		self.settings.position.target 		= target;
		self.settings.position.relative 	= relative;
	end
	return self.settings.position;
end

function Icon:Dimensions(...)
	if #arg == 2 then
		local baseDimensions = arg[2];

	end
	if matchesType("table", arg[1]) then
		self:SetWidth(dimensions.width);
		self:SetHeight(dimensions.height)
		self.status.dimensions = dimensions;
	elseif matchesType("string", arg[1]) and (arg[1] == "max") then
		if matchesType("table", arg[2]) then
			self.settings.dimensions = arg[2];
		end
		return self.settings.dimensions;
	end
	return self.status.dimensions;
end

function Icon:ScaleDimensions(percent)
	local dimensions 	= self:Dimensions("max");
	percent = (percent >= 0 and percent <= 1) and percent or 0;
	dimensions.width 	= dimensions.width * percent;
	dimensions.height 	= dimensions.height * percent;
	return dimensions;
end

--	SetAppearance(appearance)	-> void
--		< tbl: appearance		- table with the form {alpha, dimensions}
function Icon:SetAppearance(appearance)
	self:SetAlpha(appearance.alpha);
	self:SetDimensions(appearance.dimensions);
end

--	SetStyle(style)		-> void
--		< tbl: style	- table with the form {appearance, theme:{border, highlight, round | icon}}
function Icon:SetStyle(style)
	self:SetAppearance(style.appearance);

	if not self.texture then
		self.texture	= anIcon:CreateTexture(nil, "ARTWORK");
		self.texture:SetAllPoints(self);

		self.border		= anIcon:CreateTexture(nil, "OVERLAY");
		self.border:SetAllPoints(self);

		self.highlight	= anIcon:CreateTexture(nil, "HIGHLIGHT");
		self.highlight:SetAllPoints(self);
	end

	self.border:SetTexture(style.theme.border);
	self.highlight:SetTexture(style.theme.highlight);

	if style.texture.round then
		SetPortraitToTexture(self.texture, style.theme.round);
	else
		self.texture:SetTexture(style.theme.icon);
	end
end

function Icon:DefaultsWithTexture(texture)
	local defaultTheme = {
		border 		= "Interface\\AddOns\\DOTMonitor\\graphics\\icon_border_effect_over",
		highlight 	= "Interface\\AddOns\\DOTMonitor\\graphics\\icon_directional_arrows"
	};

	local defaultDimensions = {
		width 	= 44,
		height 	= 44
	};

	local defaultAppearance = {
		alpha = 1,
		dimensions = defaultDimensions
	};

	return {appearance = defaultAppearance, theme = defaultTheme};
end

function Icon:Enabled(on)
	self:SetHidden(on);
end

function Icon:EffectMagnitude(percent)
	percent = (percent >= 0 and percent <= 1) and percent or 0;
	self:SetAlpha(percent);
	self:Dimensions(self:ScaleDimensions(percent));
end