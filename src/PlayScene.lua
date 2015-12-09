local GameInput = require("GameInput")
local Timer = require("Timer")
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
    self.center = cc.p(self.size.width/2, self.size.height/2)
    self.schedulerID = nil
end

function PlayScene:createLayer()
    local layer = cc.Layer:create()
    GameInput.create(layer)
    self.layer = layer
    
    math.randomseed(os.clock())
    
    -- create draw node
    local draw = cc.DrawNode:create()
    local radius = 127
    self.radius = radius
    draw:drawSolidCircle(self.center, radius, 0, 16, 1, 1, cc.c4f(1.0,0,0,1.0))
    layer:addChild(draw)

    -- move camera
    layer:setPosition(0, -self.center.y - radius/2)
    --layer:setScale(0.5)
    
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
        player:setLocalZOrder(1)
        layer:addChild(player)
    
        local rightSpeed = 0
        local leftSpeed = 0
        local accel = 4
        local minSpeed = 5
        local maxSpeed = 150
        local shootCooldown = Timer.create(0.2)
        
        local enemyTimer = Timer.create(2)

        local time = 0
        local function update(dt)
            time = time + dt
            
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
            
            if shootCooldown.finished then
                -- shoot bullets
                self:shoot(player)
                shootCooldown:reset()
            end

            -- update all children
            local children = layer:getChildren()
            for i=1, #children do
                children[i]:update(dt)
            end
            
            -- create enemies
            if enemyTimer.finished then
                self:createEnemy()
                enemyTimer:reset(math.random(2, 4))
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
    local distance = self.size.height
    local x = math.cos(angle) * distance + self.center.x
    local y = math.sin(angle) * distance + self.center.y
    local enemy = Enemy.new(self.center, self.radius)
    enemy:setPosition(x, y)
    enemy:setRotation(math.deg(-angle))
    enemy:moveTo(self.center, 50)
    self.layer:addChild(enemy)
end

function PlayScene:shoot(player)
    local x = player:getPositionX()
    local y = player:getPositionY()

    local bullet = Bullet.new(self.center, self.size.width)
    bullet:setPosition(x, y)
    bullet:moveTo(self.center, -1000)
    bullet:setRotation(player:getRotation())
    local bullet2 = Bullet.new(self.center, self.size.width)
    bullet2:setPosition(x, y)
    bullet2:moveTo(self.center, -1000)
    bullet2:setRotation(player:getRotation())

    local angle = math.rad(self.layer:getRotation())
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    bullet2:setPosition(x - 20*cos, y - 20*sin)
    bullet:setPosition(x + 20*cos, y + 20*sin)
    self.layer:addChild(bullet)
    self.layer:addChild(bullet2)
end

return PlayScene
