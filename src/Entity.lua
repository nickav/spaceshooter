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
function Entity.extend(cls)
    cls.speed = cc.p(0,0)
    cls.alive = true
    -- copy methods to class
    for k,v in pairs(Entity) do cls[k] = v end
    return cls
end

function Entity:update(dt)
    if not self.alive then return end

    -- move based on speed
    local x = self:getPositionX() + self.speed.x*dt
    local y = self:getPositionY() + self.speed.y*dt
    self:setPosition(x, y)
end

function Entity:kill()
    self.alive = false
    self:setVisible(false)
end

-- math.sqrt and math.atan2 are somewhat expensive functions
function Entity:moveTo(position, speed)
    local dx = position.x - self:getPositionX()
    local dy = position.y - self:getPositionY()
    local distance = math.sqrt(dx*dx + dy*dy)
    self.speed.x = speed * dx / distance
    self.speed.y = speed * dy / distance
    self:setRotation(math.deg(math.atan2(-dy, dx)))
end

return Entity