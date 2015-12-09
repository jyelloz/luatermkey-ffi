local termkey = require('termkey')
local misc = require('misc')

local tk = termkey.TermKey(0, 0)

local function main()
  while true do

    local key = termkey.TermKeyKey()
    local result = tk:waitkey(key)

    if result == termkey.Result.EOF or result == termkey.Result.ERROR then
      break
    end

    if result == termkey.Result.KEY then

      local key_type = key.type

      if key_type == termkey.Type.MOUSE then
        local _, event, button, line, col = tk:interpret_mouse(key)
        if event == termkey.MouseEvent.PRESS then
          print(string.format('mouse press (%d, %d)', line, col))
        elseif event == termkey.MouseEvent.RELEASE then
          print(string.format('mouse release (%d, %d)', line, col))
        elseif event == termkey.MouseEvent.DRAG then
          print(string.format('mouse drag (%d, %d)', line, col))
        end
      elseif key_type == termkey.Type.UNICODE then
        local text = key:text()
        print('unicode event ' .. text)
        if text == 'q' then
          break
        end
      elseif key_type == termkey.Type.KEYSYM then
        print('keysym event')
      end

    end

  end
end

misc.MouseEnable(1002)
pcall(main)
misc.MouseDisable(1002)
