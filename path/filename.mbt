///|
// hutool `cn.hutool.core.io.file.FileNameUtil` 的**纯字符串档**（契约 15 §11）。
//
// 范围切法（读数在 `scripts/FileNameLeg.java`）：`FileNameUtil` 每个方法都有 `File` 与 `String`
// 两个重载，`File` 档带宿主语义（`File.separator`、`isDirectory` 的尾斜杠规则）——本库零 FFI，
// **只收 String 档**，`File` 重载整条判 excluded（census 那行的理由栏写的就是这个）。
//
// 两件同义委托不重复出公开面：
//   `getSuffix` ≡ `extName`、`getPrefix` ≡ `mainName`——腿逐档并排打两侧读数，
//   每一条都同字符串（例：`archive.tar.gz` 都给 `tar.gz` / `archive`）。
//   参照那侧只是别名，本库再造一件就是"两个名字一件事"，实现轮一改就一漏。
//
// 两条会咬人的形状（都不是"顺手统一"的对象）：
//   * **点开头**的串：`.bashrc` 的 ext 是 `bashrc`、主名是**空串**（参照这么给，腿 N 行现读）；
//   * **复合扩展名**只认反射读来的 `SPECIAL_SUFFIX` 那四条（`tar.bz2`/`tar.Z`/`tar.gz`/`tar.xz`，
//     大小写按表里原样），命中时 `ext_name` 给两段、`main_name` 跟着少两段；
//     `x.tar.gz.txt` 命中的是尾巴 ⇒ 给 `txt`（腿 N 行两侧都在）。

///|
/// 取路径尾巴（`FileNameUtil.getName(String)`）：按 `/` 与 `\` **两种分隔符**取最后一段——
/// 参照不认宿主（它就是纯串处理），混分隔符 `a\b/c.txt` 给 `c.txt`（腿 N 行）。
/// 尾随分隔符（`/tmp/`）给 `tmp`；空串给空串。
pub fn name_of(s : String) -> String {
  abort("PR-B：契约骨架，契约见 docs/spec/15-path.md #11.1~#11.6")
}

///|
/// 主名（`FileNameUtil.mainName`，参照的 `getPrefix` 是它的别名）：去分隔符尾巴后再去最后一个
/// 点及其后——但**复合扩展名整段去**（`archive.tar.gz` → `archive`）。
/// `.bashrc` → 空串（点开头那一档照参照来，不"顺手改成 `bashrc`"）。
pub fn main_name(s : String) -> String {
  abort("PR-B：契约骨架，契约见 docs/spec/15-path.md #11.1~#11.6")
}

///|
/// 扩展名（`FileNameUtil.extName`，参照的 `getSuffix` 是它的别名）：最后一个点之后的部分，
/// 复合扩展名给两段（`tar.gz`）；无点、尾随点（`a.`）、只有分隔符尾巴（`/tmp/`）都给空串。
pub fn ext_name(s : String) -> String {
  abort("PR-B：契约骨架，契约见 docs/spec/15-path.md #11.1~#11.6")
}

///|
/// 清掉 Windows 文件名非法字符（`FileNameUtil.cleanInvalid`）。字符集不是"猜的九个"：
/// 反射读 `FILE_NAME_INVALID_PATTERN_WIN` 现读为 `[\\/:*?"<>|\r\n]`（腿 CONST 行），
/// 分隔符**也在**里面 ⇒ `cleanInvalid("/tmp/")` 给 `tmp`，这是参照行为不是笔误。
pub fn clean_invalid(s : String) -> String {
  abort("PR-B：契约骨架，契约见 docs/spec/15-path.md #11.1~#11.6")
}

///|
/// 是否含上述非法字符（`FileNameUtil.containsInvalid`）：空串 false；`/tmp/` true。
pub fn contains_invalid(s : String) -> Bool {
  abort("PR-B：契约骨架，契约见 docs/spec/15-path.md #11.1~#11.6")
}

///|
/// 是否属于给定类型之一（`FileNameUtil.isType(String, String...)`）。四条实测形状：
///   * **大小写不敏感**（`a.TXT` 命中 `txt`，类型表里的 `Tar.GZ` 也命中 `tar.gz`）；
///   * 类型**不带点**——`[".txt"]` 永不命中（腿 IT 行）；
///   * 复合扩展名按两段比：`a.tar.gz` 命中 `tar.gz` 而**不**命中 `gz`（腿 IT 行三档都在）；
///   * 空类型串是个真值档：无扩展名的文件（`noext`）对 `[""]` 给 **true**（腿 IT 行），
///     表里有 null 元素时该项永不命中。空表恒 false。
pub fn is_type(s : String, types : Array[String]) -> Bool {
  abort("PR-B：契约骨架，契约见 docs/spec/15-path.md #11.1~#11.6")
}
