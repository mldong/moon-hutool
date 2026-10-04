// `derive(Eq, Compare)` 只给出 trait 实现；本版编译器会把实现的方法**隐式提升成同名方法**并报
// `implicit_impl_as_method` 警告（零警告是门禁）。core 自己的做法是在单独的 `extends.mbt` 里
// 写显式 `extend`（见 `moonbitlang/core/argparse/extends.mbt`），这里照抄这个形状。
//
// 这一笔不是装饰：`d1 == d2`、`d1 < d2` 这些手感全靠它，而隐式提升是"将来会移除"的废弃路径。

///|
pub extend Date with Eq::{equal, not_equal}

///|
pub extend Date with Compare::{compare, op_lt, op_le, op_ge, op_gt}

///|
pub extend DateTime with Eq::{equal, not_equal}

///|
pub extend DateTime with Compare::{compare, op_lt, op_le, op_ge, op_gt}
