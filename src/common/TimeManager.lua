--[[
    Updates all Timer instances.
--]]

local TimeManager = {}

local timers = {}
local schedulerID
local didExit = false
local tag

-- Updates all timers. Called on every game update by.
function TimeManager.update(dt)
    -- TODO: test this with scene transitions. should clear all running Timers when switching scenes
    -- and auto-start this function, while still working with live-reload.
    if didExit then
        local newTag = cc.Director:getInstance():getRunningScene():getTag()
        print("tag: " .. tag .. " newTag: " .. newTag)
        if not tag == newTag then
            TimeManager.clear()
            tag = newTag
        end
        didExit = false
    end
    if not tag then
        local function onNodeEvent(event)
            if event == "exit" then
                didExit = true
            end
        end
        cc.Director:getInstance():getRunningScene():registerScriptHandler(onNodeEvent)
        tag = cc.Director:getInstance():getRunningScene():getTag()
    end

    -- iterate from back to front to allow items to be removed during the loop
    for i=#timers,1,-1 do
        timers[i].tick = false
        if timers[i].finished and timers[i]._inManager then
            TimeManager.removeTimer(timers[i])
        else
            timers[i]:update(dt)
        end
    end
end

-- Schedules the TimeManager's update function
function TimeManager.init()
    if schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)
    end
    schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(TimeManager.update, 0, false)
end

function TimeManager.addTimer(self)
    if (not self._inManager) then
        timers[#timers+1] = self
        self._inManager = true
    end
end

function TimeManager.removeTimer(self)
    if (self._inManager) then
        -- find self in timers
        local index = -1
        for i=1, #timers do
            if timers[i] == self then index = i break end
        end
        -- remove timer if it exists
        if index >= 0 then table.remove(timers, index) end
        self._inManager = false
    end
end

-- removes all timers from the time manager
function TimeManager.clear()
    timers = {}
end

TimeManager.init()

return TimeManager