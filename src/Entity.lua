--[[
local Entity = class("Entity", function()
    return cc.Sprite:create()
end)

function Entity.create(sprite)
    local entity = Entity.new()
    entity:setTexture(sprite)
    return entity
end
--]]

-- psuedo-multiple inheritence thing
-- pretty much just did this so auto completions for cc.Sprite still works
local Entity = {}

Entity.default = "0"
Entity.tag = "1"

-- Precondition: cls extends cc.Sprite
function Entity.extend(cls)
    cls.speed = cc.p(0,0)
    cls.alive = true
    cls.size = cls:getTextureRect()
    cls.prevBoundingBox = nil

    -- copy methods to class
    for k,v in pairs(Entity) do cls[k] = v end
    return cls
end

function Entity:update(dt)
    if not self.alive then return end
    
    self.prevBoundingBox = self:getBoundingBox()

    -- move based on speed
    local x = self:getPositionX() + self.speed.x*dt
    local y = self:getPositionY() + self.speed.y*dt
    self:setPosition(x, y)
end

function Entity:live()
    self.alive = true
    self.prevBoundingBox = nil
    self:setVisible(true)
    self:setName(Entity.default)
end

function Entity:kill()
    self.alive = false
    self:setVisible(false)
    self:setName(Entity.tag)
end

-- cocos2dx function getBoundingBox returns an "Axis-Aligned Bounding Box" (AABB)
-- which does not account for the object's rotation. So, we use that as a lazy way
-- to see if two objects intersect
local function lazyCollidesWith(self, other)
    local rect1 = self:getBoundingBox()
    local rect2 = other:getBoundingBox()
    
    if self.prevBoundingBox then rect1 = cc.rectUnion(rect1, self.prevBoundingBox) end
    if other.prevBoundingBox then rect2 = cc.rectUnion(rect2, other.prevBoundingBox) end
    
    return cc.rectIntersectsRect(rect1, rect2)
end

-- rotate a single point:
-- x1 = cos(deg) * x - sin(deg) * y
-- y2 = sin(deg) * x + cos(deg) * y

-- rectangle intersection method that takes into account the game object's rotation
local function rotatedCollidesWith(self, other)
end

function Entity:getCollisionRect()
    local rect = {x = 0, y = 0, width = 0, height = 0}
    rect.x = self:getPositionX() - 0.5 * self.size.width
    rect.y = self:getPositionY() - 0.5 * self.size.height
    rect.width = self.size.width
    rect.height = self.size.height
    return rect
end

function Entity:collidesWith(other)
    return cc.rectIntersectsRect(self:getCollisionRect(), other:getCollisionRect())
end

-- parent must extend Node
--[[
function Entity.getFirstAvailable(parent)
    return parent:getChildByName(Entity.dead)
end
--]]

function Entity:moveTo(position, speed)
    local dx = position.x - self:getPositionX()
    local dy = position.y - self:getPositionY()
    local distance = math.sqrt(dx*dx + dy*dy)
    self.speed.x = speed * dx / distance
    self.speed.y = speed * dy / distance
end

return Entity