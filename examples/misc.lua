local M = {}

function M.MouseEnable(mode)
  print(string.format('\027[?%dh', mode))
end

function M.MouseDisable(mode)
  print(string.format('\027[?%dl', mode))
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
