local os = require('os')
local curses = require('curses')
local ev = require('ev')
local termkey = require('termkey')

local misc = require('misc')

-- this is a slightly bigger example using libev to watch stdin asynchronously
-- and curses to draw to the screen.

os.setlocale(nil, nil)

local tk = termkey.TermKey(0, 0)
local stdscr = curses.initscr()

curses.start_color()

curses.init_pair(1, curses.COLOR_YELLOW, curses.COLOR_RED)
curses.init_pair(2, curses.COLOR_RED, curses.COLOR_YELLOW)
curses.init_pair(3, curses.COLOR_WHITE, curses.COLOR_BLUE)
curses.init_pair(4, curses.COLOR_WHITE, curses.COLOR_MAGENTA)

curses.nl(false)

stdscr:clear()

stdscr:wbkgd(curses.color_pair(1))

local function draw()
  stdscr:clear()
  stdscr:border()
  stdscr:mvaddstr(0, 2, ' Window Title ')
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

local function quit(loop, io)
  io:stop(loop)
  timer:stop(loop)
end

local function handle_mouse(key, loop, io)

end

local function handle_unicode(key, loop, io)
  local text = key:text()
  if text == 'q' then
    quit(loop, io)
  end
end

local function on_input(loop, io, revents)

  local key = termkey.TermKeyKey()
  local result = tk:waitkey(key)

  if result == termkey.Result.KEY then

    local key_type = key.type

    if key_type == termkey.Type.UNICODE then
      handle_unicode(key, loop, io)
    elseif key_type == termkey.Type.MOUSE then
      handle_mouse(key, loop, io)
    end

  end

end

local stdin = ev.IO.new(on_input, 0, ev.READ)

local loop = ev.Loop.default

stdin:start(loop)
timer:start(loop)

misc.MouseEnable(1002)
pcall(function() loop:loop() end)
misc.MouseDisable(1002)

curses.endwin()
