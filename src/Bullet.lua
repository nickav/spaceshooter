local Entity = require("Entity")
local Bullet = class("Bullet", function()
    return Entity.extend(cc.Sprite:create("bullet.png"))
end)

Bullet.tag = "3"

function Bullet:ctor(center, killRadius)
    self.center = center
    self.radiusSquared = killRadius * killRadius
end

function Bullet:update(dt)
    -- call super method
    Entity.update(self, dt)
    local dx = self:getPositionX() - self.center.x
    local dy = self:getPositionY() - self.center.y

    if (dx*dx + dy*dy >= self.radiusSquared) then
        self:kill()
    end
end

function Bullet:kill()
    self.alive = false
    self:setVisible(false)
    self:setName(Bullet.tag)
end

return Bullet