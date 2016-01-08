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

--[[
    Entity: the base game object class.
    Supports object pooling. Objects ready to be reused
    can be accessed with: parent:getChildByName("className")

    Psuedo-multiple inheritence thing...
    Just did this so auto completions for cc.Sprite still work.
--]]
local Entity = {}

Entity.default = "Alive"

-- Precondition: cls extends cc.Sprite
function Entity.extend(cls)
    cls.speed = cc.p(0,0)
    cls.alive = true
    cls.size = cls:getTextureRect()
    cls.lastRect = nil

    -- copy methods to class
    for k,v in pairs(Entity) do cls[k] = v end
    return cls
end

function Entity:update(dt)
    if not self.alive then return end
    
    self.lastRect = self:getRect()

    -- move based on speed
    local x = self:getPositionX() + self.speed.x*dt
    local y = self:getPositionY() + self.speed.y*dt
    self:setPosition(x, y)
end

function Entity:live()
    self.alive = true
    self.lastRect = nil
    self:setVisible(true)
    self:setName(Entity.default)
end

function Entity:kill()
    self.alive = false
    self:setVisible(false)
    self:setName(self.__cname)
end

-- cocos2dx function getBoundingBox returns an "Axis-Aligned Bounding Box" (AABB)
-- which does not account for the object's rotation. So, we use that as a lazy way
-- to see if two objects intersect
local function lazyCollidesWith(self, other)
    local rect1 = self:getBoundingBox()
    local rect2 = other:getBoundingBox()
    
    if self.lastRect then rect1 = cc.rectUnion(rect1, self.lastRect) end
    if other.lastRect then rect2 = cc.rectUnion(rect2, other.lastRect) end
    
    return cc.rectIntersectsRect(rect1, rect2)
end

-- rectangle intersection method that takes into account the game object's rotation
-- Rotated Rectangles Collision Detection, Oren Becker, 2001
local function rotatedCollidesWith(self, other)
    local r1 = self:getCollisionRect()
    local a1 = math.rad(self:getRotation())
    local r2 = other:getCollisionRect()
    local a2 = math.rad(other:getRotation())
    
    local ang = a1 - a2
    local cosa = math.cos(ang)
    local sina = math.sin(ang)
    
    -- move rr2 to make rr1 cannonic
    local C = cc.p(r2.x - r1.x, r2.y - r2.y)
    
    -- rotate rr2 clockwise by rr2->ang to make rr2 axis-aligned
    local ca = math.cos(a2)
    local sa = math.cos(a2)
    C.x = C.x*ca + C.y*sa
    C.y = -C.x*sa + C.y*ca
    
    -- calculate verticies of moved and axis-aligned rr2
    local BL = cc.p(C.x - r2.width, C.y - r2.height)
    local TR = cc.p(C.x + r2.width, C.y + r2.height)
    
    -- calculate verticies of rotated rr1
    local A = cc.p(-r1.height*sina + r1.width*cosa, r1.height*cosa + r1.width*sina)
    local B = cc.p(A.x - r1.width*cosa, A.y - r1.width*sina)
    
    local t = sina*cosa
    
    -- verify that A is vertical min/max, B is horizontal min/max
    if t < 0 then
        t = A.x
        A.x = B.x
        B.x = t
        t = A.y
        A.y = B.y
        B.y = t
    end
    
    -- verify that B is horizontal minimum (leftest-vertext)
    if sina < 0 then
        B.x = -B.x
        B.y = -B.y
   end
   
   -- if rr2(ma) isn't in the horizontal range of
   -- colliding with rr1(r), collision is impossible
   if B.x > TR.x or B.x > -BL.x then return false end
   
   local ext1 = 0
   local ext2 = 0
   
   -- if rr1(r) is axis-aligned, vertical min/max are easy to get
   if (t == 0) then
       ext1 = A.y
       ext2 = -ext1
   else
       local x = BL.x - A.x
       local a = TR.x - A.x
       ext1 = A.y
        -- if the first vertical min/max isn't in (BL.x, TR.x), then
        -- find the verical min/max on BL.x or on TR.x
        if a*x > 0 then
            local dx = A.x
            if (x < 0) then 
                dx = dx - B.x
                ext1 = ext1 - B.y
                x = a
            else
                dx = dx + B.x
                ext1 = ext1 + B.y
            end
            ext1 = ext1 * x
            ext1 = ext1 / dx
            ext1 = ext1 + A.y
        end
        
        x = BL.x + A.x
        a = TR.x + A.x
        ext2 = -A.y
        -- if the second vertical min/max isn't in (BL.x, TR.x), then
        -- find the local vertical min/max on BL.x or on TR.x
        if a*x > 0 then
            local dx = -A.x
            if x < 0 then
                dx = dx - B.x
                ext2 = ext2 - B.y
                x = a
            else
                dx = dx + B.x
                ext2 = ext2 + B.y
            end
            ext2 = ext2 * x
            ext2 = ext2 / dx
            ext2 = ext2 - A.y
        end
   end
   
   -- check whether rr2(ma) is in the vertical range of colliding with rr1(r)
   -- for the horizontal range of rr2
   return not((ext1 < BL.y and ext2 < BL.y) or (ext1 > TR.y and ext2 > TR.y))
end

-- TODO: merge current collision rect with previous to prevent tunneling
function Entity:getCollisionRect()
    local rect = self:getRect()
    -- sort of works, but doesn't merge rectangles according to rotation
    --if self.lastRect then rect = cc.rectUnion(rect, self.lastRect) end
    return rect
end

-- returns an unrotated rectangle
function Entity:getRect()
    local rect = {
        x = self:getPositionX() - 0.5 * self.size.width,
        y = self:getPositionY() - 0.5 * self.size.height,
        width = self.size.width,
        height = self.size.height
    }
    return rect
end

-- collision detection that takes into account a Node's position and rotation
function Entity:collidesWith(other)
    -- if two objects are nearby, then check more precisely whether or not they collide
    if self.alive and other.alive and lazyCollidesWith(self, other) then
        return rotatedCollidesWith(self, other)
    end
    return false
end

function Entity:moveTo(position, speed)
    local dx = position.x - self:getPositionX()
    local dy = position.y - self:getPositionY()
    local distance = math.sqrt(dx*dx + dy*dy)
    self.speed.x = speed * dx / distance
    self.speed.y = speed * dy / distance
end


return Entity