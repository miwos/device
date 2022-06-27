local utils = {}

---From https://stackoverflow.com/a/66370080/12207499, thanks PiFace!
function utils.isArray(t)
  return type(t) == 'table' and #t > 0 and next(t, #t) == nil
end

local function serializeValue(value)
  local valueType = type(value)
  local shouldUseQuotes = valueType ~= 'boolean'
    and valueType ~= 'number'
    and valueType ~= 'nil'
  return shouldUseQuotes and ("'" .. tostring(value) .. "'") or tostring(value)
end

local function serializeKey(key)
  return type(key) == 'string' and key or '[' .. key .. ']'
end

---Based on https://stackoverflow.com/a/64796533/12207499, thanks Francisco!
local function serializeTable(t, done, pretty)
  done = done or {}
  done[t] = true

  local str = pretty and '{ ' or '{'
  local key, value = next(t, nil)
  while key do
    local serialized
    if type(value) == 'table' and not done[value] then
      done[value] = true
      serialized = serializeTable(value, done, pretty)
      done[value] = nil
    else
      serialized = serializeValue(value)
    end

    str = str
      .. (
        utils.isArray(t) and serialized
        or serializeKey(key) .. (pretty and ' = ' or '=') .. serialized
      )

    key, value = next(t, key)
    if key then
      str = str .. (pretty and ', ' or ',')
    end
  end
  return str .. (pretty and ' }' or '}')
end

function utils.serialize(value, pretty)
  return type(value) == 'table' and serializeTable(value, nil, pretty)
    or serializeValue(value)
end

function utils.indent(depth)
  return string.rep(' ', depth * 2)
end

return utils
