--[[
    A simple timer class.
    Timers can be used with callbacks or by polling the finished/tick flag.

    @author Nick Aversano
    @see https://github.com/HaxeFlixel/flixel/blob/master/flixel/util/FlxTimer.hx
--]]


local Timer = class("Timer")
local TimeManager = require("TimeManager")

-- Instanctiates but does not start it.
-- @see Timer:start()
function Timer:ctor()
    -- how much time the timer was set for
    self.time = 0
    -- how many loops the timer was set for
    self.loops = 0
    -- pauses or checks to see if the timer is paused
    self.paused = false
    -- check to see if the timer is finished
    self.finished = false
    -- check to see if a loop has just passed (true when callback is called)
    self.tick = false
    
    -- private instance fields:
    self._callback = nil
    self._timeCounter = 0
    self._loopsCounter = 0
    self._inManager = false
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
    
    TimeManager.addTimer(self)
    
    return self
end

-- Makes the timer loop forever.
function Timer:loopForever()
    self.loops = 0
    return self
end

-- Called by TimeManager.update to update the timer. Don't call this manually.
function Timer:update(dt)
    self._timeCounter = self._timeCounter + dt

    while ((self._timeCounter >= self.time) and not self.paused and not self.finished) do

        self._timeCounter = self._timeCounter - self.time
        self._loopsCounter = self._loopsCounter + 1
        self.tick = true

        if (self._callback) then self._callback(self) end

        if (self.loops > 0 and self._loopsCounter >= self.loops) then
            self.finished = true --queue timer to be removed from times
        end
    end
end

-- Stops the timer.
function Timer:cancel()
    self.finished = true
    TimeManager.removeTimer(self)
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