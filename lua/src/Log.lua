local utils = require('utils')

Log = _G.Log or {}

---@class LogType
local LogType = {
  Info = 1,
  Warn = 2,
  Error = 3,
  Dump = 4,
}

---@param type LogType
function Log.log(type, ...)
  local args = { ... }
  local message = ''
  for i = 1, select('#', ...) do
    message = message .. (i > 1 and ', ' or '') .. tostring(args[i])
  end
  Log._log(type, message)
end

function Log.error(...)
  Log.log(LogType.Error, ...)
end

function Log.warn(...)
  Log.log(LogType.Warn, ...)
end

function Log.info(...)
  Log.log(LogType.Info, ...)
end

function Log.dump(...)
  local args = { ... }
  local dump = ''

  for i = 1, select('#', ...) do
    local value = args[i]
    dump = dump
      .. (i > 1 and ', ' or '')
      .. (
        type(value) == 'table' and utils.serializeTable(value)
        or utils.serializeValue(value)
      )
  end

  Log._log(LogType.Dump, '{' .. dump .. '}')
end

local timers = {}
function Log.time(label)
  timers[label] = Timer.now()
end

function Log.timeEnd(label)
  Log.info(label .. ': ' .. Timer.now() - timers[label] .. 'μs')
  timers[label] = nil
end
