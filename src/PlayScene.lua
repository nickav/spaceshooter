local GameInput = require("GameInput")
local Timer = require("common/Timer")
local Player = require("Player")
local Enemy = require("Enemy")
local Bullet = require("Bullet")

local PlayScene = class("PlayScene", function()
    return cc.Scene:create()
end)

function PlayScene.create()
    local scene = PlayScene.new()
    scene:addChild(scene:createLayer())
    return scene
end

function PlayScene:ctor()
    self.size = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.center = cc.p(0.5 * self.size.width, 0.5 * self.size.height)
    self.schedulerID = nil
    local width = 0.5 * self.size.width + 100
    self.enemySpawnDist = math.sqrt(width * width + self.size.height * self.size.height)
    self.bullets = {}
end

function PlayScene:createLayer()
    local layer = cc.Layer:create()
    GameInput.create(layer)
    self.layer = layer
    
    math.randomseed(os.clock())
    
    -- create draw node
    local debug = cc.DrawNode:create()
    debug:setLocalZOrder(100)
    layer:addChild(debug)
    
    -- planet radius
    local radius = 127
    self.radius = radius

    -- move camera
    layer:setPosition(0, -self.center.y - radius/2)
    
    --[[
    local moveCenter = cc.MoveTo:create(1, cc.p(0,0))
    local zoomOut = cc.ScaleTo:create(0.5,0.5)
    local moveCenterAndZoomOut = cc.Spawn:create(moveCenter, zoomOut)
    layer:runAction(cc.EaseInOut:create(moveCenterAndZoomOut, 6))
    local moveBottom = cc.MoveTo:create(1, cc.p(0,-self.size.height/2))
    local zoomIn = cc.ScaleTo:create(1,1)
    local moveBottomAndZoomIn = cc.Spawn:create(moveBottom, zoomIn)
    layer:setScale(0.5)
    layer:runAction(cc.EaseInOut:create(moveBottomAndZoomIn, 6))
    --]]

    -- update every frame
    do
        -- create player
        local player = Player.new(layer, self.center, radius)
        layer:addChild(player)
    
        local rightSpeed = 0
        local leftSpeed = 0
        local accel = 4
        local minSpeed = 5
        local maxSpeed = 120
        local shootCooldown = Timer.create(0.3)
        
        local enemyTimer = Timer.create(2)
        self:createEnemy()

        -- game speed, 1 = normal speed
        local speed = 1
        Timer.speed = speed

        local time = 0
        local function update(dt)
            time = time + dt
            
            debug:clear()
            
            -- rotate the world
            if GameInput.pressingRight() then
                local rot = layer:getRotation() - rightSpeed*dt
                if rot >= 360 then rot = rot - 360 end
                layer:setRotation(rot)
                
                if rightSpeed < maxSpeed then
                    rightSpeed = rightSpeed + accel
                else
                    rightSpeed = maxSpeed
                end
                leftSpeed = minSpeed
            elseif GameInput.pressingLeft() then
                local rot = layer:getRotation() + leftSpeed*dt
                if rot < 0 then rot = rot + 360 end
                layer:setRotation(rot)
                
                if leftSpeed < maxSpeed then
                    leftSpeed = leftSpeed + accel
                else
                    leftSpeed = maxSpeed
                end
                rightSpeed = minSpeed
            else
                rightSpeed = minSpeed
                leftSpeed = minSpeed
            end
            
            -- shoot bullets
            if shootCooldown.finished then
                self:shoot(player)
                shootCooldown:reset()
            end

            -- update all children
            local children = layer:getChildren()
            for i=1, #children do
                if children[i].alive then
                    children[i]:update(dt * speed)
                
                    -- check if an enemy collides with a bullet
                    if children[i].__cname == "Enemy" then
                        local enemy = children[i]
                        for i=1,#self.bullets do
                            local bullet = self.bullets[i]
                            if bullet.alive and bullet:collidesWith(enemy) then
                                bullet:kill()
                                enemy:kill()
                                break
                            end
                        end
                    end
                end
            end
            
            -- create enemies
            if enemyTimer.finished then
                self:createEnemy()
                enemyTimer:reset(math.random(1, 4))
            end
        end
        self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false)
    
        local function onNodeEvent(event)
            if event == "exit" then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
            end
        end
        layer:registerScriptHandler(onNodeEvent)
    end

    return layer
end

function PlayScene:createEnemy()
    local angle = math.random()*2*math.pi
    local distance = self.enemySpawnDist
    
    local x = math.cos(angle) * distance + self.center.x
    local y = math.sin(angle) * distance + self.center.y
    
    -- try to reuse an old enemy or create one if none exists
    local enemy = self.layer:getChildByName("Enemy")
    if enemy == nil then
        enemy = Enemy.new(self.center, self.radius)
        self.layer:addChild(enemy)
    else
        enemy:live()
    end
    enemy:setPosition(x, y)
    enemy:setRotation(math.deg(-angle))
    enemy:moveTo(self.center, 50)
end

function PlayScene:createBullet()
    -- try to find an unused bullet or create one if none exists
    local bullet = self.layer:getChildByName("Bullet")
    if bullet == nil then
        bullet = Bullet.new(self.center, self.size.width)
        self.layer:addChild(bullet)
        table.insert(self.bullets, bullet)
    else
        bullet:live()
    end
    
    return bullet
end

function PlayScene:shoot(player)
    local x = player:getPositionX()
    local y = player:getPositionY()

    local bullet = self:createBullet()
    bullet:setPosition(x, y)
    bullet:moveTo(self.center, -1000)
    bullet:setRotation(player:getRotation())

    -- move bullets to turrent positions
    local angle = math.rad(self.layer:getRotation())
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    bullet:setPosition(x + 20*cos, y + 20*sin)
    bullet:update(20/1000)

    local bullet2 = self:createBullet()
    bullet2:setPosition(x, y)
    bullet2:moveTo(self.center, -1000)
    bullet2:setRotation(player:getRotation())
    bullet2:setPosition(x - 20*cos, y - 20*sin)
    bullet2:update(20/1000)
end

return PlayScene