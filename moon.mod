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

version = "0.1.0"

readme = "README.md"

repository = "https://github.com/mldong/moon-hutool"

license = "Apache-2.0"

keywords = [
  "moonbit",
  "hutool",
  "utility",
  "core-only",
  "string",
  "date",
  "digest",
  "cron",
  "scheduler",
]

preferred_target = "wasm"

description = "Hutool-style utility library for MoonBit: all packages depend only on moonbitlang/core (no FFI, fully synchronous); the single exception is the `sched` package, which imports official `moonbitlang/async` for timer firing and therefore ships on three targets, not four"

import {
  "moonbitlang/async@0.22.4",
}
