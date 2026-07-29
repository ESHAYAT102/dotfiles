"use strict";

const { spawn } = require("node:child_process");
const { closeSync, constants, openSync, writeSync } = require("node:fs");
const { tmpdir } = require("node:os");
const { join } = require("node:path");

module.exports.default = function () {
  const fifo = join(process.env.XDG_RUNTIME_DIR || tmpdir(), `vicinae-confetti-${process.getuid()}`);
  try {
    const fd = openSync(fifo, constants.O_WRONLY | constants.O_NONBLOCK);
    writeSync(fd, "1");
    closeSync(fd);
    return;
  } catch {}
  spawn(join(__dirname, "confetti.py"), { detached: true, stdio: "ignore" }).unref();
};
