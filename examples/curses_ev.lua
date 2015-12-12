local os = require('os')
local curses = require('curses')
local signal = require('posix.signal')
local ev = require('ev')
local termkey = require('termkey')

local misc = require('misc')

-- this is a slightly bigger example using libev to watch stdin asynchronously
-- and curses to draw to the screen.

os.setlocale(nil, nil)

local loop = ev.Loop.default

local function quit()
  loop:unloop()
  curses.endwin()
end

local sigint = ev.Signal.new(
  function(loop, sig, revents)
    quit()
    print("handled SIGINT")
  end,
  signal.SIGINT
)

local tk = termkey.TermKey(0, 0)
local stdscr = curses.initscr()

curses.start_color()

curses.init_pair(1, curses.COLOR_YELLOW, curses.COLOR_RED)
curses.init_pair(2, curses.COLOR_RED, curses.COLOR_YELLOW)
curses.init_pair(3, curses.COLOR_WHITE, curses.COLOR_BLUE)
curses.init_pair(4, curses.COLOR_WHITE, curses.COLOR_MAGENTA)

curses.curs_set(0)
curses.nl(false)

stdscr:clear()

stdscr:wbkgd(curses.color_pair(1))

local function draw()
  stdscr:clear()
  stdscr:border()
  stdscr:mvaddstr(0, 2, ' Window Title ')
  stdscr:mvaddch(0, curses.cols() - 3, curses.ACS_BULLET)
  stdscr:refresh()
end

draw()

function timer_closure()
  local state = misc.cycle(4)
  return function(loop, timer, revents)
    local pair = curses.color_pair(state())
    stdscr:wbkgd(pair)
    draw()
  end
end

local timer = ev.Timer.new(timer_closure(), 0.5, 0.5)

local function handle_mouse(key)

  local close_y = 1
  local close_x = curses.cols() - 2

  local _, event, button, line, col = tk:interpret_mouse(key)

  if event ~= termkey.MouseEvent.PRESS then
    return
  end

  if button ~= 1 then
    return
  end

  if line == close_y and col == close_x then
    quit()
    print('handled window close')
  end

end

local function handle_unicode(key)
  local text = key:text()
  if text == 'q' or text == 'Q' then
    quit()
    print(string.format('handled key \'%s\'', text))
  end
end

local function on_input(loop, io, revents)

  tk:advisereadable()

  local key = termkey.TermKeyKey()
  local result = tk:getkey(key)

  if result == termkey.Result.KEY then

    local key_type = key.type

    if key_type == termkey.Type.UNICODE then
      handle_unicode(key)
    elseif key_type == termkey.Type.MOUSE then
      handle_mouse(key)
    end

  end

end

local stdin = ev.IO.new(on_input, 0, ev.READ)

sigint:start(loop)
stdin:start(loop)
timer:start(loop)

misc.MouseEnable(1002)
pcall(function() loop:loop() end)
misc.MouseDisable(1002)
