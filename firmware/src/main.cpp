#include <Arduino.h>
#include <Bridge.h>
#include <FileSystem.h>
#include <Lua.h>
#include <LuaFileSystem.h>
#include <LuaLog.h>
#include <SlipSerial.h>

SlipSerial serial(Serial);

int ref;

void setup() {
  Serial.begin(9600);
  while (!Serial) {
  }

  Bridge::begin(serial);
  FileSystem::begin();
  Lua::begin();

  Lua::onSetup([]() {
    LuaLog::install();
    LuaFileSystem::install();
  });
}

void loop() { Bridge::update(); }