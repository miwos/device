#ifndef LuaLog_h
#define LuaLog_h

#include <Bridge.h>
#include <Logger.h>
#include <Lua.h>

namespace LuaLog {
  int log(lua_State *L) {
    // Use zero-based index
    auto type = static_cast<Logger::LogType>(luaL_checkinteger(L, -2) - 1);

    const char *text = luaL_checkstring(L, -1);
    Logger::log(type, text);

    return 0;
  }

  int flush(lua_State *L) {
    Bridge::serial->endPacket();
    return 0;
  }

  void install() {
    luaL_Reg lib[] = {{"_log", log}, {"flush", flush}, {NULL, NULL}};
    luaL_register(Lua::L, "Log", lib);
  }
} // namespace LuaLog

#endif