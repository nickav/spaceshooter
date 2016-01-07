--[[
    GameInput - static class to handle user input.
--]]
local GameInput = {}

local target = cc.Application:getInstance():getTargetPlatform()
local _touch = nil
local _visibleSize = nil
local _key_right = false
local _key_left = false

-- attach input to layer
function GameInput.create(layer)
    _visibleSize = cc.Director:getInstance():getVisibleSize()
    -- touch handlers
    -- {
        local function onTouchBegan(touch, event)
            -- CCTOUCHBEGAN event must return true
            _touch = touch
            return true
        end
    
        local function onTouchMoved(touch, event)
            _touch = touch
        end
    
        local function onTouchEnded(touch, event)
            _touch = nil
        end
    
        local function onTouchCancelled(touch, event)
            _touch = nil
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED)
        layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, layer)
    -- }

    -- keyboard handlers
    -- {
        local function onKeyPressed(keyCode, event)
            -- for some reason Mac keyboard codes are different
            if (target == cc.PLATFORM_OS_MAC) then
                if (keyCode == 127 or keyCode == 27) then
                    _key_right = true
                end
                if (keyCode == 124 or keyCode == 26) then
                    _key_left = true
                end
                if (keyCode == 146 or keyCode == 28) then
                end
                if (keyCode == 142 or keyCode == 29) then
                end
            else
                if (keyCode == cc.KeyCode.KEY_D or keyCode == cc.KeyCode.KEY_RIGHT_ARROW) then
                    _key_right = true
                end
                if (keyCode == cc.KeyCode.KEY_A or keyCode == cc.KeyCode.KEY_LEFT_ARROW) then
                    _key_left = true
                end
                if (keyCode == cc.KeyCode.KEY_W or keyCode == cc.KeyCode.KEY_UP_ARROW) then
                end
                if (keyCode == cc.KeyCode.KEY_S or keyCode == cc.KeyCode.KEY_DOWN_ARROW) then
                end
            end
        end
        local function onKeyReleased(keyCode, event)
            if (target == cc.PLATFORM_OS_MAC) then
                if (keyCode == 127 or keyCode == 27) then
                    _key_right = false
                end
                if (keyCode == 124 or keyCode == 26) then
                    _key_left = false
                end
                if (keyCode == 146 or keyCode == 28) then
                end
                if (keyCode == 142 or keyCode == 29) then
                end
            else
                if (keyCode == cc.KeyCode.KEY_D or keyCode == cc.KeyCode.KEY_RIGHT_ARROW) then
                    _key_right = false
                end
                if (keyCode == cc.KeyCode.KEY_A or keyCode == cc.KeyCode.KEY_LEFT_ARROW) then
                    _key_left = false
                end
                if (keyCode == cc.KeyCode.KEY_W or keyCode == cc.KeyCode.KEY_UP_ARROW) then
                end
                if (keyCode == cc.KeyCode.KEY_S or keyCode == cc.KeyCode.KEY_DOWN_ARROW) then
                end
            end
        end
        local keyListener = cc.EventListenerKeyboard:create()
        keyListener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
        keyListener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
        layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(keyListener, layer)
    -- }
end

function GameInput.pressingLeft()
    return ((not _touch == nil and _touch.x < _visibleSize.width / 2) or _key_left)
end

function GameInput.pressingRight()
    return ((not _touch == nil and _touch.x >= _visibleSize.width / 2) or _key_right)
end

return GameInput