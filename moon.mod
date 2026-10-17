// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "mldong/moon-hutool"

version = "0.1.3"

readme = "README.md"

repository = "https://github.com/mldong/moon-hutool"

license = "Apache-2.0"

keywords = [
  "moonbit",
  "hutool",
  "utility",
  "string",
  "date",
  "digest",
  "cron",
  "scheduler",
  "http",
]

preferred_target = "wasm"

description = "Hutool-style utility library for MoonBit: all packages depend only on moonbitlang/core (no FFI, fully synchronous); the two exceptions both build on official `moonbitlang/async` — `sched` (cron timer firing, three targets) and `http` (injectable HTTP transport port, native+wasm only)"

import {
  "moonbitlang/async@0.22.4",
}
