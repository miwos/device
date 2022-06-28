Timer = _G.Timer or {}
Timer.Sec = 1000000
Timer.Milli = 1000
local events = {}

function Timer.update(now)
  local finishedCallbacks = {}

  for callback, time in pairs(events) do
    if time <= now then
      events[callback] = nil
      finishedCallbacks[#finishedCallbacks + 1] = callback
    end
  end

  for _, callback in ipairs(finishedCallbacks) do
    callback()
  end
end

function Timer.schedule(callback, time)
  events[callback] = time
  return callback
end

function Timer.delay(callback, delay)
  events[callback] = Timer.now() + delay
  return callback
end
