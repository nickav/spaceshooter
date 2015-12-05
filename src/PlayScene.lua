local GameInput = require("GameInput")

local PlayScene = class("PlayScene", function()
    return cc.Scene:create()
end)

function PlayScene.create()
    local scene = PlayScene.new()
    scene:addChild(scene:createLayer())
    return scene
end

function PlayScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.center = cc.p(self.visibleSize.width/2, -self.visibleSize.height/2)
    self.schedulerID = nil
end

function PlayScene:createLayer()
    local layer = cc.Layer:create()
    GameInput.create(layer)
    
    math.randomseed(os.clock())
    
    -- create draw node
    local draw = cc.DrawNode:create()
    layer:addChild(draw)
    --draw:drawSolidRect(cc.p(220,220),cc.p(100,100),cc.c4f(1.0,0,0,1.0))
    draw:drawSolidCircle(self.center,self.visibleSize.width/2,0,100,1,1,cc.c4f(1.0,0,0,1.0))
    draw:drawSolidRect(cc.p(self.visibleSize.width/2-50,100),cc.p(self.visibleSize.width/2+50,200),cc.c4f(0,1.0,0,1))

    layer:setAnchorPoint(0.5, 0)
    local rot = 0
    -- update every frame
    -- {
        local time = 0
        local function update(dt)
            time = time + dt
            layer:setRotation(layer:getRotation() + 1)
            
            if (GameInput.pressingLeft()) then
                --print "GO LEFT"
            end
        end
        self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false)
    
        local function onNodeEvent(event)
            if event == "exit" then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
            end
        end
        layer:registerScriptHandler(onNodeEvent)
    -- }

    return layer
end

return PlayScene
