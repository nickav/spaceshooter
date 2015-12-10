local Entity = require("Entity")

local Enemy = class("Enemy", function()
    return Entity.extend(cc.Sprite:create("player.png"))
end)

Enemy.tag = "2"

function Enemy:ctor(center, radius)
    radius = radius + 0.5 * self.size.height
    self.radiusSquared = radius * radius
    self.center = center
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

function Enemy:kill()
    self.alive = false
    self:setVisible(false)
    self:setName(Enemy.tag)
end


return Enemy