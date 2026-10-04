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

keywords = ["moonbit", "hutool", "utility", "zero-dependency", "string", "date", "digest"]

preferred_target = "wasm"

description = "Zero-dependency Hutool-style utility library for MoonBit: depends only on moonbitlang/core, no FFI, no async, four targets"
