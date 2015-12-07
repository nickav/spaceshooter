--[[
    A simple timer class.
    Timer.updateAll(dt) must be called on each update step.
    Timers can be used with callbacks or by polling the finished flag.

    @author Nick Aversano
    @see https://github.com/HaxeFlixel/flixel/blob/master/flixel/util/FlxTimer.hx
--]]
require "helpers"

local Timer = class("Timer")
local timers = {}

local function _addTimer(self)
    if (not self._inManager) then
        table.insert(timers, self)
        self._inManager = true
    end
end

local function _removeTimer(self)
    if (self._inManager) then
        table.remove(timers, table.find(self))
        self._inManager = false
    end
end

-- Updates all timers. Must be called on every game update.
function Timer.updateAll(dt)
    -- iterate from back to front to allow items to be removed
    for i=#timers,1,-1 do
        if timers[i].finished and timers[i]._inManager then
            _removeTimer(timers[i])
        else
            timers[i]:update(dt)
        end
    end
end

-- Forces all timers to clear. Useful because live code pushing will add
-- multiple timers for the same instance if the timer hasn't finished.
-- Use this at the start of your code for consistency with live-reloading.
function Timer.clearAll()
    timers = {}
end

-- Instanctiates and starts the timer if time is set.
-- @see Timer:start()
function Timer:ctor(time, loops, callback)
    -- how much time the timer was set for
    self.time = 0
    -- how many loops the timer was set for
    self.loops = 0
    -- pauses or checks to see if the timer is paused
    self.paused = false
    -- check to see if the timer is finished
    self.finished = false
    
    -- private instance fields:
    self._callback = nil
    self._timeCounter = 0
    self._loopsCounter = 0
    self._inManager = false
    
    if time then self:start(time, loops, callback) end
end

-- Starts or resumes the timer. If the timer was paused,
-- then all the pameters are ignored and the timer is resumed.
--
-- @param   time      Seconds it takes for the timer to go off
-- @param   loops     How many times should the timer go off. Default is 1. 0 means "Loop forever".
-- @param   callback  Optional, triggered when the timer runs out, once for each loop.
--
-- @return  a reference to itself (handy for chaining or whatever).
function Timer:start(time, callback, loops)
    if (self.paused) then
        self.paused = false
        return self
    end
    self.time = time or 1
    self.loops = loops or 1
    self._callback = callback
    self.finished = false
    self.paused = false
    self._timeCounter = 0
    
    _addTimer(self)
    
    return self
end

-- Called by Timer.updateAll to update the timer. Don't call this manually.
function Timer:update(dt)
    self._timeCounter = self._timeCounter + dt

    while ((self._timeCounter >= self.time) and not self.paused and not self.finished) do
    
        self._timeCounter = self._timeCounter - self.time
        self._loopsCounter = self._loopsCounter + 1

        if (self._callback) then self._callback(self) end

        if (self.loops > 0 and self._loopsCounter >= self.loops) then
            self.finished = true --queue timer to be removed from times
        end
    end
end

-- Makes the timer loop forever.
function Timer:loopForever()
    self.loops = 0
    return self
end

-- Stops the timer.
function Timer:cancel()
    self.finished = true
    _removeTimer(self)
end

-- Resets the timer for its original time or the new time specified.
function Timer:reset(time)
    self:start(time or self.time)
    return self
end

-- How much time is left on the timer.
function Timer:getTimeLeft()
    if self.finished then return 0 end
    return self.time - self._timeCounter
end

-- How many loops are left on the timer.
function Timer:getLoopsLeft()
    return self.loops - self._loopsCounter
end

return Timer