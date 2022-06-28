#ifndef LuaTimer_h
#define LuaTimer_h

#include <Arduino.h>
#include <Lua.h>

namespace LuaTimer {
  uint32_t currentTime = 0;

  namespace {
    int updateRef = -1;
    bool updateIsStored = false;

    void storeUpdate() {
      updateRef = Lua::storeFunction("Timer", "update");
      if (updateRef != -1) updateIsStored = true;
    }
  } // namespace

  int now(lua_State *L) {
    lua_pushinteger(Lua::L, micros());
    return 1;
  }

  void install() {
    updateIsStored = false;
    storeUpdate();
    luaL_Reg lib[] = {{"now", now}, {NULL, NULL}};
    luaL_register(Lua::L, "Timer", lib);
  }

  void update() {
    // `__update__` will only be available after `init.lua` has been executed
    // so we might have to try multiple times.
    if (!updateIsStored) storeUpdate();

    currentTime = micros();
    // Don't log an error if we can't find the function because this gets called
    // thousands of times per second!
    if (Lua::getFunction(updateRef, false)) {
      lua_pushinteger(Lua::L, currentTime);
      lua_pcall(Lua::L, 1, 0, 0);
    }
  }
} // namespace LuaTimer

#endif