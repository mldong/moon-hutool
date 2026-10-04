///|
/// moon-hutool/text —— 字符串门面（hutool `StrUtil`/`CharSequenceUtil` 的 MoonBit 对位）
///
/// 契约：`docs/spec/01-text.md`。本文件此刻是**签名骨架**（口径 5：只包 core 给不了的语义层，不转发同一语义），
/// 函数体一律 `abort("…未实现…")`：`moon check` 全绿、`moon test` 预期红。
/// 期望值权威在 `text_test.mbt` 与 spec 表——实现期只许把红变绿，改期望值须单独一笔并给外部读数来源（门禁 G5）。
///
/// 三条贯穿性口径（都是本机编译器裁决出来的，不是风格偏好）：
/// 1. **入参一律 `String`**：MoonBit 无 null，不在每个函数上铺 `Option`；只有"缺失本身是业务语义"的两处
///    保留 Option 形态（`trim_opt`、`first_non_blank`）。hutool `isBlank(null)=true` 由调用方在边界
///    `unwrap_or("")` 等价达成——差异声明见 spec 1.1。
/// 2. 空白判定 = core `Char::is_whitespace`（Unicode White_Space 子集）**并集** hutool 独有的 7 个码点
///    （U+0000 U+200C U+180E U+2800 U+3164 U+FEFF U+202A）；U+0000 算空白这条必须保留（多数实现会漏）。
/// 3. **视图类型不作对外契约**：编译器实证 `String` 字面量不隐式转 `StringView`、`String` 也没有 `as_view`，
///    写进入参会让每个调用点都要手工转换 ⇒ 返回值同样给 `String`（core 内部收 `StringView` 是它的取舍，
///    我们这把尺子是"调用点零转换成本"）。
///
/// 骨架期每个函数体里的 `let _ = (...)` 是给零警告门禁用的（参数未使用会报 unused_value），
/// 实现落地时随函数体一起消失——这不是风格装饰，别在实现前删。

///|
/// 是否为空白：`None`、空串、全为空白字符均判真（hutool `StrUtil.isBlank`）
pub fn is_blank(s : String) -> Bool {
  let _ = s
  abort("moon-hutool: text.is_blank 未实现（spec 01-text #1.2）")
}

///|
/// 是否为空：`None` 或长度为 0（hutool `isEmpty`）——与 `is_blank` 分档，不合并
pub fn is_empty(s : String) -> Bool {
  let _ = s
  abort("moon-hutool: text.is_empty 未实现（spec 01-text #1.3）")
}

///|
/// 去空白；`None` 透传 `None`（hutool `trimToNull`）
pub fn trim_opt(s : String?) -> String? {
  let _ = s
  abort("moon-hutool: text.trim_opt 未实现（spec 01-text #1.4）")
}

///|
/// 去两端空白（hutool `trim`）
pub fn trim(s : String) -> String {
  let _ = s
  abort("moon-hutool: text.trim 未实现（spec 01-text #1.4）")
}

///|
/// 按单字符切分，`trim_result` 为真时逐段去空白（hutool `splitTrim`）
///
/// 空输入返回空数组；连续分隔符**保留空段**（Java `String.split` 会吞尾空串，差异见 spec 1.5）
pub fn split(
  s : String,
  sep : Char,
  trim_result? : Bool = false,
) -> Array[String] {
  let _ = (s, sep, trim_result)
  abort("moon-hutool: text.split 未实现（spec 01-text #1.5）")
}

///|
/// 用分隔符连接（hutool `CollUtil.join`）；`None` 元素按空串出（见 spec 1.6）
pub fn join(items : Array[String], sep : String) -> String {
  let _ = (items, sep)
  abort("moon-hutool: text.join 未实现（spec 01-text #1.6）")
}

///|
/// 取分隔符**之前**的部分；未命中返回整串（hutool `subBefore`）
pub fn sub_before(s : String, sep : String) -> String {
  let _ = (s, sep)
  abort("moon-hutool: text.sub_before 未实现（spec 01-text #1.7）")
}

///|
/// 取分隔符**之后**的部分；未命中返回空串（hutool `subAfter`，与 subBefore 不对称）
pub fn sub_after(s : String, sep : String) -> String {
  let _ = (s, sep)
  abort("moon-hutool: text.sub_after 未实现（spec 01-text #1.7）")
}

///|
/// 取两个界定符之间的内容；任一未命中返回空串（hutool `subBetween`）
pub fn sub_between(
  s : String,
  left : String,
  right : String,
  include_sep? : Bool = false,
) -> String {
  let _ = (s, left, right, include_sep)
  abort("moon-hutool: text.sub_between 未实现（spec 01-text #1.7）")
}

///|
/// `{}` 占位格式化（hutool `StrUtil.format` → `StrFormatter`）
///
/// 三条硬语义：前一字符为 `\` 的 `{}` 当字面量并把 `\\` 折成 `\`；参数少于占位符时**原样留下**；
/// 位置索引语法 `{0}` **不做**（那是 JDK `MessageFormat`，语义与 `{}` 不同）
pub fn format(template : String, args : Array[String]) -> String {
  let _ = (template, args)
  abort("moon-hutool: text.format 未实现（spec 01-text #1.8）")
}

///|
/// 版本串比较：逐段按数值比较，缺段补零（hutool `compareVersion`）
pub fn compare_version(a : String, b : String) -> Int {
  let _ = (a, b)
  abort("moon-hutool: text.compare_version 未实现（spec 01-text #1.9）")
}

///|
/// 返回第一个非空白项（hutool `firstNonBlank`）
pub fn first_non_blank(candidates : Array[String?]) -> String? {
  let _ = candidates
  abort("moon-hutool: text.first_non_blank 未实现（spec 01-text #1.10）")
}

///|
/// 区间掩码：`[start, end)` 用 `mask` 替换（hutool `CharSequenceUtil.hide`）
///
/// 下标按**码点**计（不是 UTF-16 单元）；越界夹紧不报错——与 core `[]` 的夹紧语义对齐（spec 1.11）
pub fn hide(s : String, start : Int, end : Int, mask : Char) -> String {
  let _ = (s, start, end, mask)
  abort("moon-hutool: text.hide 未实现（spec 01-text #1.11）")
}

///|
/// 命名法互转（hutool `text.NamingCase`，其全仓唯一实现处）
///
/// 三条坑：连续大写当专有名词不拆；`to_camel_case` **只在含分隔符时转换**否则原样返回；
/// 转换时其余字符转小写。期望值此刻只冻结了最确定的两条，其余待从 v5-master 反推后冻结（spec 1.12）
pub fn to_underline_case(name : String) -> String {
  let _ = name
  abort("moon-hutool: text.to_underline_case 未实现（spec 01-text #1.12）")
}

///|
/// 见 `to_underline_case`（hutool `toCamelCase(name, '_')`）
pub fn to_camel_case(name : String) -> String {
  let _ = name
  abort("moon-hutool: text.to_camel_case 未实现（spec 01-text #1.12）")
}

///|
/// 见 `to_underline_case`（hutool `toKebabCase`）
pub fn to_kebab_case(name : String) -> String {
  let _ = name
  abort("moon-hutool: text.to_kebab_case 未实现（spec 01-text #1.12）")
}

///|
/// 见 `to_underline_case`（hutool `toPascalCase` = `upperFirst(toCamelCase)`）
pub fn to_pascal_case(name : String) -> String {
  let _ = name
  abort("moon-hutool: text.to_pascal_case 未实现（spec 01-text #1.12）")
}

///|
/// 首字母大写（**ASCII 档**；非 ASCII 原样返回——core `to_upper` 只处理 ASCII，本库不假装 Unicode）
pub fn upper_first(s : String) -> String {
  let _ = s
  abort("moon-hutool: text.upper_first 未实现（spec 01-text #1.13）")
}

///|
/// 首字母小写（同上，ASCII 档）
pub fn lower_first(s : String) -> String {
  let _ = s
  abort("moon-hutool: text.lower_first 未实现（spec 01-text #1.13）")
}
