local termkey = require('termkey')
local misc = require('misc')

local tk = termkey.TermKey(0, termkey.Flags.CTRLC)

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
          print(('mouse#%d press (%d, %d)'):format(button, line, col))
        elseif event == termkey.MouseEvent.RELEASE then
          print(('mouse#%d release (%d, %d)'):format(button, line, col))
        elseif event == termkey.MouseEvent.DRAG then
          print(('mouse#%d drag (%d, %d)'):format(button, line, col))
        end
      elseif key_type == termkey.Type.UNICODE then
        local text = key:text()
        print('unicode event ' .. text)
        if text == 'q' then
          break
        elseif text == 'c' and key:has_mods(termkey.Mod.CTRL) then
          local keystring = tk:format_key(key, 0)
          print(('quitting due to key %q'):format(keystring))
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
