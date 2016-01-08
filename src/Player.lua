local Player = class("Player", function()
    return cc.Sprite:create("player.png")
end)

function Player:ctor(layer, center, radius)
    self.layer = layer
    self.radius = radius
    self.center = center
    self.rotation = nil
    self.alive = true
    
    self:setAnchorPoint(0.5, 0.05)
    self:setLocalZOrder(1)
end

function Player:update(dt)
    -- make player on top of the world
    if self.rotation ~= self.layer:getRotation() then
        local angle = math.rad(self.layer:getRotation() + 90)
        local x = self.radius * math.cos(angle) + self.center.x
        local y = self.radius * math.sin(angle) + self.center.y
        self:setPosition(x, y)
        self.rotation = self.layer:getRotation()
        self:setRotation(-self.rotation)
    end
end


return Player