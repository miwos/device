// @ts-check

import { Bridge } from "@miwos/bridge";
import { NodeSerialTransport } from "@miwos/bridge/dist/NodeSerialTransport.js";
import chokidar from "chokidar";
import pico from "picocolors";
import fs from "fs/promises";
import { createColorize } from "colorize-template";

const colorize = createColorize({
  ...pico,
  success: pico.green,
  error: pico.red,
  warn: pico.yellow,
});

const pathToPosix = (path) => path.replace(/\\/g, "/");

const bridge = new Bridge(new NodeSerialTransport(), { debug: false });
await bridge.open({ path: "COM11" });
bridge.on("/log/:type", ({ args: [text] }, { type }) => {
  const colors = {
    error: pico.red,
    warn: pico.yellow,
    info: pico.gray,
  };

  const color = colors[type] ?? pico.white;
  console[type]?.(color(text));
});

bridge.on("/data/unknown", (data) =>
  console.log(colorize`${new TextDecoder().decode(data)}`)
);

const replaceRootDir = (path, newRoot) => {
  const parts = path.split("/");
  parts[0] = newRoot;
  return parts.join("/");
};

/** @param {string} path */
const syncFile = async (path, update = true) => {
  path = pathToPosix(path);
  const pathOnDevice = replaceRootDir(path, "lua");

  await bridge.writeFile(pathOnDevice, await fs.readFile(path, "utf8"));

  const isHotReplaced = await bridge.request("/lua/update", pathOnDevice);

  if (isHotReplaced) {
    console.log(pico.green(`hmr update ${path}`));
  } else {
    console.log(pico.green(`reload ${path}`));
  }
};

const watcher = chokidar.watch("src/**/*");
watcher.on("change", syncFile);

// console.log(await bridge.getDir("/", true));
