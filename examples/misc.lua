local M = {}

function M.MouseEnable(mode)
  print(string.format('\027[?%dh', mode))
end

function M.MouseDisable(mode)
  print(string.format('\027[?%dl', mode))
end

return M
