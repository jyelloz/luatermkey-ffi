package = "luatermkey-ffi"
version = "git-1"
source = {
  url = "https://github.com/jyelloz/luatermkey-ffi.git",
}
description = {
  summary = "libtermkey FFI bindings for Lua",
  homepage = "https://github.com/jyelloz/luatermkey-ffi",
  license = "MIT/X11",
}
dependencies = {
   "lua >= 5.1, < 5.3",
   "luabitop",
}
external_dependencies = {
  TERMKEY = {
    library = "termkey",
  }
}
build = {
  type = "builtin",
  modules = {
    ["termkey"] = "termkey.lua",
    ["termkey_h"] = "termkey_h.lua",
  },
}
