#ifndef LuaFileSystem_h
#define LuaFileSystem_h

#include <FileSystem.h>
#include <Lua.h>

namespace LuaFileSystem {
  char fileName[FileSystem::maxFileNameLength];

  int_fast32_t listFiles(lua_State *L) {
    const char *dirName = luaL_checkstring(L, -1);

    FatFile dir;
    FatFile file;

    if (!dir.open(dirName))
      return luaL_error(L, "failed to open dir %s", dirName);

    if (!dir.isDir()) return 0;
    dir.rewind();

    lua_newtable(L);
    int i = 0;
    while (file.openNext(&dir, O_READ)) {
      if (!file.isHidden() && !file.isDir()) {
        file.getName(fileName, sizeof(fileName));
        lua_pushstring(L, fileName);
        lua_rawseti(L, -2, i + 1);
        i++;
      }
      file.close();
    }

    dir.close();
    return 1;
  }

  void install() {
    luaL_Reg lib[] = {{"listFiles", listFiles}, {NULL, NULL}};
    luaL_register(Lua::L, "FileSystem", lib);
  }
} // namespace LuaFileSystem

#endif