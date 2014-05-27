--
-- TextureSprite V0.1
-- Simple sprite-capable texture "subclass" for WOW
--

local TextureSprite = {} -- Local Namespace

function TextureSprite:SetConfiguration(sheetConfig, imageConfig)
    self:SetSpriteSheetConfig(unpack(sheetConfig))
    self:SetSpriteImageConfig(unpack(imageConfig))
end

function TextureSprite:SetSpriteImageConfig(count, width, height)
    self.image = self.image or {}
    self.image.count   	= count    	or self.image.count
    self.image.width   	= width    	or self.image.width
    self.image.height 	= height	or self.image.height
end

function TextureSprite:SetSpriteSheetConfig(source, width, height)
    self.sheet = self.sheet or {}
    self.sheet.source  = source   or self.sheet.source
    self.sheet.multiple = type(self.sheet.source) == "table"
    self.sheet.width   = width    or self.sheet.width
    self.sheet.height  = height   or self.sheet.height
end

function TextureSprite:SetPercentage(percent)
    self:SetSprite(math.floor(percent / 100 * self.image.count))
end

function TextureSprite:SetSprite(imageIndex)
	local perRow 	= self.sheet.width / self.image.width

    local left  	= (imageIndex-1) % perRow * self.image.width
    local right 	= left + self.image.width
    local top   	= self.image.height * math.floor((imageIndex-1) / perRow)
    local bottom	= top + self.image.height

    local texturePath = self.sheet.multiple and self.sheet.source[math.floor(bottom/self.sheet.height)+1]
                                            or  self.sheet.source
    self:SetTexture(texturePath)

    local xUnit = self.sheet.width
    local yUnit = self.sheet.height

    self:SetTexCoord(left/xUnit, right/xUnit, top/yUnit, bottom/yUnit)
end

function TextureSprite:New(frame)
    local sprite = frame:CreateTexture(nil, "ARTWORK")

	sprite.SetConfiguration 	= TextureSprite.SetConfiguration
	sprite.SetSpriteImageConfig	= TextureSprite.SetSpriteImageConfig
	sprite.SetSpriteSheetConfig	= TextureSprite.SetSpriteSheetConfig
	sprite.SetPercentage		= TextureSprite.SetPercentage
	sprite.SetSprite			= TextureSprite.SetSprite

    return sprite
end

MPXUIKit_TextureSprite = TextureSprite -- Global Registration

