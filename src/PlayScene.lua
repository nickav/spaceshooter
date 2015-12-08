local GameInput = require("GameInput")
local Timer = require("Timer")
local Player = require("Player")

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
    draw:drawSolidCircle(self.center, radius, 0, 20, 1, 1, cc.c4f(1.0,0,0,1.0))
    draw:drawSolidRect(cc.p(self.center.x-20,self.center.y - radius), cc.p(self.center.x+20,self.center.y + radius), cc.c4f(0,1.0,0,1))
    layer:addChild(draw)
    
    -- create player
    local player = Player.new(layer, self.center, radius)
    layer:addChild(player)

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
        local godSpeed = 150
        
        local time = 0
        local function update(dt)
            time = time + dt
            
            -- rotate the world
            if GameInput.pressingLeft() then
                layer:setRotation(layer:getRotation() - godSpeed*dt)
                if layer:getRotation() < 0 then
                    layer:setRotation(layer:getRotation() + 360)
                end
            elseif GameInput.pressingRight() then
                layer:setRotation(layer:getRotation() + godSpeed*dt)
                if layer:getRotation() >= 360 then
                    layer:setRotation(layer:getRotation() - 360)
                end
            end
            
            player:update(dt)
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
