local Entity = require("Entity")
local Enemy = class("Enemy", function()
    return Entity.extend(cc.Sprite:create("player.png"))
end)

function Enemy:ctor(position, center, radius)
    radius = radius + 0.5 * self:getTextureRect().height
    self.radiusSquared = radius * radius
    self.center = center
    self:setPosition(position)
    self:moveTo(center, 50)
end

function Enemy:update(dt)
    -- call super method
    Entity.update(self, dt)
    local dx = self:getPositionX() - self.center.x
    local dy = self:getPositionY() - self.center.y
    
    if (dx*dx + dy*dy <= self.radiusSquared) then
        self:kill()
    end
end

return Enemy