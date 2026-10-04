// `derive(Eq, Compare)` 只给 trait 实现；本版编译器会把实现的方法隐式提升成同名方法并报警告
// （零警告是门禁）。显式 `extend` 是 core 自己的做法，形状抄 `moonbitlang/core/argparse/extends.mbt`。

///|
pub extend SnowflakeParts with Eq::{equal, not_equal}

///|
pub extend SnowflakeParts with Compare::{compare, op_lt, op_le, op_ge, op_gt}

///|
pub extend IdRange with Eq::{equal, not_equal}

///|
pub extend IdRange with Compare::{compare, op_lt, op_le, op_ge, op_gt}
