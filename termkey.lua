local ffi = require('ffi')
local bit = require('bit')
require('termkey_h')

local C = ffi.load('libtermkey')

local M = {}

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

  interpret_mouse=C.termkey_interpret_mouse,

  interpret_position=C.termkey_interpret_position,

  interpret_modereport=C.termkey_interpret_modereport,

  interpret_csi=C.termkey_interpret_csi,

  strfkey=C.termkey_strfkey,
  strpkey=C.termkey_strpkey,

  keycmp=C.termkey_keycmp,

  has_flags=function(self, flag, ...)
    local flags = bit.bor(flag, ...)
    return bit.band(self:get_flags(), flags) == flags
  end

}

local function termkey_t_gc(self)
  C.termkey_destroy(ffi.gc(self, nil))
end

local mt = {
  __gc=termkey_t_gc, -- XXX: not sure if this does anything
  __index=index,
}

local termkey_t = ffi.metatype(ffi.typeof('TermKey'), mt)
local termkeykey_t = ffi.typeof('TermKeyKey')

function M.TermKey(fd, flags)
  return ffi.gc(C.termkey_new(fd, flags), termkey_t_gc)
end

function M.TermKeyAbstract(term, flags)
  return ffi.gc(C.termkey_new_abstract(term, flags), termkey_t_gc)
end

function M.TermKeyKey()
  return ffi.new(termkeykey_t)
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

M.Method = {
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

return M
