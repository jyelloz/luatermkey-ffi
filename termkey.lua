local ffi = require('ffi')
local bit = require('bit')
require('termkey_h')

local C = ffi.load('libtermkey')

local M = {}

local termkeymousevent_boxed_t = ffi.typeof('TermKeyMouseEvent[1]')
local int_boxed_t = ffi.typeof('int[1]')
local string_50_t = ffi.typeof('char[50]')

local index = {

  start=C.termkey_start,
  stop=C.termkey_stop,
  is_started=C.termkey_is_started,

  get_fd=C.termkey_get_fd,

  get_flags=C.termkey_get_flags,
  set_flags=C.termkey_set_flags,

  get_waittime=C.termkey_get_waittime,
  set_waittime=C.termkey_set_waittime,

  get_canonflags=C.termkey_get_canonflags,
  set_canonflags=C.termkey_set_canonflags,

  get_buffer_size=C.termkey_get_buffer_size,
  set_buffer_size=C.termkey_set_buffer_size,

  get_buffer_remaining=C.termkey_get_buffer_remaining,

  canonicalise=C.termkey_canonicalise,

  getkey=C.termkey_getkey,
  getkey_force=C.termkey_getkey_force,
  waitkey=C.termkey_waitkey,

  advisereadable=C.termkey_advisereadable,

  push_bytes=C.termkey_push_bytes,

  register_keyname=C.termkey_register_keyname,
  get_keyname=C.termkey_get_keyname,
  lookup_keyname=C.termkey_lookup_keyname,

  keyname2sym=C.termkey_keyname2sym,

  interpret_mouse=function(self, key)
    local event = termkeymousevent_boxed_t()
    local button = int_boxed_t()
    local line = int_boxed_t()
    local col = int_boxed_t()
    local result = C.termkey_interpret_mouse (
      self,
      key,
      event,
      button,
      line,
      col
    )
    return result, event[0], button[0], line[0], col[0]
  end,

  interpret_position=C.termkey_interpret_position,

  interpret_modereport=C.termkey_interpret_modereport,

  interpret_csi=C.termkey_interpret_csi,

  strfkey=C.termkey_strfkey,
  strpkey=C.termkey_strpkey,

  format_key=function(self, key, format)
    local buffer = string_50_t()
    return ffi.string(
      buffer,
      self:strfkey(buffer, 50, key, format)
    )
  end,

  keycmp=C.termkey_keycmp,

  has_flags=function(self, flag, ...)
    local flags = bit.bor(flag, ...)
    return bit.band(self:get_flags(), flags) == flags
  end,

}

local function termkey_t_gc(self)
  C.termkey_destroy(ffi.gc(self, nil))
end

local mt = {
  __gc=termkey_t_gc, -- XXX: not sure if this does anything
  __index=index,
}

local termkeykey_index = {

  text=function(self)
    return ffi.string(self.utf8)
  end,

  has_mods=function(self, mod, ...)
    local mods = bit.bor(mod, ...)
    return bit.band(self.modifiers, mods) == mods
  end,

}

local termkeykey_mt = {
  __index=termkeykey_index,
}

local termkey_t = ffi.metatype(ffi.typeof('TermKey'), mt)
local termkeykey_t = ffi.metatype(ffi.typeof('TermKeyKey'), termkeykey_mt)

function M.TermKey(fd, flags)
  return ffi.gc(C.termkey_new(fd, flags), termkey_t_gc)
end

function M.TermKeyAbstract(term, flags)
  return ffi.gc(C.termkey_new_abstract(term, flags), termkey_t_gc)
end

function M.TermKeyKey()
  return termkeykey_t()
end

M.Flags = {
  NOINTERPRET=C.TERMKEY_FLAG_NOINTERPRET,
  CONVERTKP=C.TERMKEY_FLAG_CONVERTKP,
  RAW=C.TERMKEY_FLAG_RAW,
  UTF8=C.TERMKEY_FLAG_UTF8,
  NOTERMIOS=C.TERMKEY_FLAG_NOTERMIOS,
  SPACESYMBOL=C.TERMKEY_FLAG_SPACESYMBOL,
  CTRLC=C.TERMKEY_FLAG_CTRLC,
  EINTR=C.TERMKEY_FLAG_EINTR,
}

M.Type = {
  UNICODE=C.TERMKEY_TYPE_UNICODE,
  FUNCTION=C.TERMKEY_TYPE_FUNCTION,
  KEYSYM=C.TERMKEY_TYPE_KEYSYM,
  MOUSE=C.TERMKEY_TYPE_MOUSE,
  POSITION=C.TERMKEY_TYPE_POSITION,
  MODEREPORT=C.TERMKEY_TYPE_MODEREPORT,
  CSI=C.TERMKEY_TYPE_UNKNOWN_CSI,
}

M.Result = {
  NONE=C.TERMKEY_RES_NONE,
  KEY=C.TERMKEY_RES_KEY,
  EOF=C.TERMKEY_RES_EOF,
  AGAIN=C.TERMKEY_RES_AGAIN,
  ERROR=C.TERMKEY_RES_ERROR,
}

M.MouseEvent = {
  UNKNOWN=C.TERMKEY_MOUSE_UNKNOWN,
  PRESS=C.TERMKEY_MOUSE_PRESS,
  DRAG=C.TERMKEY_MOUSE_DRAG,
  RELEASE=C.TERMKEY_MOUSE_RELEASE,
}

M.Mod = {
  SHIFT=C.TERMKEY_KEYMOD_SHIFT,
  ALT=C.TERMKEY_KEYMOD_ALT,
  CTRL=C.TERMKEY_KEYMOD_CTRL,
}

M.Format = {
  LONGMOD=C.TERMKEY_FORMAT_LONGMOD,
  CARETCTRL=C.TERMKEY_FORMAT_CARETCTRL,
  ALTISMETA=C.TERMKEY_FORMAT_ALTISMETA,
  WRAPBRACKET=C.TERMKEY_FORMAT_WRAPBRACKET,
  SPACEMOD=C.TERMKEY_FORMAT_SPACEMOD,
  LOWERMOD=C.TERMKEY_FORMAT_LOWERMOD,
  LOWERSPACE=C.TERMKEY_FORMAT_LOWERSPACE,

  POS=C.TERMKEY_FORMAT_MOUSE_POS,

  VIM=bit.bor(C.TERMKEY_FORMAT_ALTISMETA, C.TERMKEY_FORMAT_WRAPBRACKET),
  URWID=bit.bor(
    C.TERMKEY_FORMAT_LONGMOD,
    C.TERMKEY_FORMAT_ALTISMETA,
    C.TERMKEY_FORMAT_LOWERMOD,
    C.TERMKEY_FORMAT_SPACEMOD,
    C.TERMKEY_FORMAT_LOWERSPACE
  ),
}

M.Sym = {

  UNKNOWN=C.TERMKEY_SYM_UNKNOWN,
  NONE=C.TERMKEY_SYM_NONE,

  BACKSPACE=C.TERMKEY_SYM_BACKSPACE,
  TAB=C.TERMKEY_SYM_TAB,
  ENTER=C.TERMKEY_SYM_ENTER,
  ESCAPE=C.TERMKEY_SYM_ESCAPE,

  SPACE=C.TERMKEY_SYM_SPACE,
  DEL=C.TERMKEY_SYM_DEL,

  UP=C.TERMKEY_SYM_UP,
  DOWN=C.TERMKEY_SYM_DOWN,
  LEFT=C.TERMKEY_SYM_LEFT,
  RIGHT=C.TERMKEY_SYM_RIGHT,
  BEGIN=C.TERMKEY_SYM_BEGIN,
  FIND=C.TERMKEY_SYM_FIND,
  INSERT=C.TERMKEY_SYM_INSERT,
  DELETE=C.TERMKEY_SYM_DELETE,
  SELECT=C.TERMKEY_SYM_SELECT,
  PAGEUP=C.TERMKEY_SYM_PAGEUP,
  PAGEDOWN=C.TERMKEY_SYM_PAGEDOWN,
  HOME=C.TERMKEY_SYM_HOME,
  END=C.TERMKEY_SYM_END,

  CANCEL=C.TERMKEY_SYM_CANCEL,
  CLEAR=C.TERMKEY_SYM_CLEAR,
  CLOSE=C.TERMKEY_SYM_CLOSE,
  COMMAND=C.TERMKEY_SYM_COMMAND,
  COPY=C.TERMKEY_SYM_COPY,
  EXIT=C.TERMKEY_SYM_EXIT,
  HELP=C.TERMKEY_SYM_HELP,
  MARK=C.TERMKEY_SYM_MARK,
  MESSAGE=C.TERMKEY_SYM_MESSAGE,
  MOVE=C.TERMKEY_SYM_MOVE,
  OPEN=C.TERMKEY_SYM_OPEN,
  OPTIONS=C.TERMKEY_SYM_OPTIONS,
  PRINT=C.TERMKEY_SYM_PRINT,
  REDO=C.TERMKEY_SYM_REDO,
  REFERENCE=C.TERMKEY_SYM_REFERENCE,
  REFRESH=C.TERMKEY_SYM_REFRESH,
  REPLACE=C.TERMKEY_SYM_REPLACE,
  RESTART=C.TERMKEY_SYM_RESTART,
  RESUME=C.TERMKEY_SYM_RESUME,
  SAVE=C.TERMKEY_SYM_SAVE,
  SUSPEND=C.TERMKEY_SYM_SUSPEND,
  UNDO=C.TERMKEY_SYM_UNDO,

  KP0=C.TERMKEY_SYM_KP0,
  KP1=C.TERMKEY_SYM_KP1,
  KP2=C.TERMKEY_SYM_KP2,
  KP3=C.TERMKEY_SYM_KP3,
  KP4=C.TERMKEY_SYM_KP4,
  KP5=C.TERMKEY_SYM_KP5,
  KP6=C.TERMKEY_SYM_KP6,
  KP7=C.TERMKEY_SYM_KP7,
  KP8=C.TERMKEY_SYM_KP8,
  KP9=C.TERMKEY_SYM_KP9,
  KPENTER=C.TERMKEY_SYM_KPENTER,
  KPPLUS=C.TERMKEY_SYM_KPPLUS,
  KPMINUS=C.TERMKEY_SYM_KPMINUS,
  KPMULT=C.TERMKEY_SYM_KPMULT,
  KPDIV=C.TERMKEY_SYM_KPDIV,
  KPCOMMA=C.TERMKEY_SYM_KPCOMMA,
  KPPERIOD=C.TERMKEY_SYM_KPPERIOD,
  KPEQUALS=C.TERMKEY_SYM_KPEQUALS,

}

return M
