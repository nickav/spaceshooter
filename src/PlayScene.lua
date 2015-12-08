local GameInput = require("GameInput")
local Timer = require("Timer")
local Player = require("Player")
local Enemy = require("Enemy")

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
    
    math.randomseed(os.clock())
    
    -- create draw node
    local draw = cc.DrawNode:create()
    local radius = 127
    draw:drawSolidCircle(self.center, radius, 0, 18, 1, 1, cc.c4f(1.0,0,0,1.0))
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
        layer:addChild(player)
        
        local enemy = Enemy.new(cc.p(0,self.size.height), self.center, radius)
        layer:addChild(enemy)
    
        local godSpeed = 150
        local shootCooldown = Timer.create(0.5)

        local time = 0
        local function update(dt)
            time = time + dt
            
            -- rotate the world
            if GameInput.pressingRight() then
                local rot = layer:getRotation() + godSpeed*dt
                if rot >= 360 then rot = rot - 360 end
                layer:setRotation(rot)
            elseif GameInput.pressingLeft() then
                local rot = layer:getRotation() - godSpeed*dt
                if rot < 0 then rot = rot + 360 end
                layer:setRotation(rot)
            elseif shootCooldown.finished then
                -- shoot bullets
                shootCooldown:reset()
            end
            
            player:update(dt)
            enemy:update(dt)
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

return PlayScene
