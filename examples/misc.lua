local M = {}

function M.MouseEnable(mode)
  io.write(string.format('\027[?%dh', mode))
  io.flush()
end

function M.MouseDisable(mode)
  io.write(string.format('\027[?%dl', mode))
  io.flush()
end

function M.cycle(n)
  local i = 1
  return function()
    local result = i
    i = i + 1
    if i > n then i = 1 end
    return result
  end
end

return M
