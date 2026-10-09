///|
// hutool `URLUtil` 的**纯串半边**：data URI 组装（契约 05 §12）。
//
// 这批为什么只剩两件（读数在 `scripts/UrlPureLeg.java`）：`URLUtil` 其余公开面要么走
// `java.net.URI`/`URL`（宿主解析器），要么走 `Charset` 字节转换（`URLEncodeUtil` 那一族）。
// `getDataUri(String,String,String)` 与 `getDataUriBase64(String,String)` 只吃串、只出串，
// 腿能全覆盖 ⇒ 期望一条都不用手写。
// `completeUrl` 看着也是纯串，实测**不是**——判 deferred 的逐条读数与理由在 §12.2。
//
// 三条会咬人的形状（都由腿的 D 行现读，不是"应该是这样"）：
//   1. **数据原样带过**：不 URL 编码、不百分号转义。`100%` 就出 `...,100%`，空格中文都原样。
//   2. **charset 串也原样带过**：`GBK`/`gbk`/`nope` 都照写（参照根本没查 charset 表），
//      空串 ⇒ 整段 `;charset` 省略 ⇒ `data:text/plain,hi`。
//   3. **base64 不校验**：`getDataUriBase64("text/plain","not-base64!!")` 照出。
//      它是拼装器不是编码器——给它什么串就拼什么（要真 base64 走本包 `b64_encode*`）。

///|
/// 组装 data URI（`URLUtil.getDataUri(String mime, String charset, String data)`）。
/// 形状：`data:` + mime +（charset 非空则 `;` + charset 原文）+ `,` + data 原文。
/// ⚠ 参照另有一个**四参重载** `getDataUri(String, Charset, String, String)`，第 3、4 参的语义
/// 与三参版**不是**"多了个属性"这么简单：腿打出来 `("text/plain", UTF_8, "hi", "a=1")` 给
/// `data:text/plain;charset=UTF-8;hi,a=1` —— 第 3 参是**属性段**、第 4 参才是数据，
/// 且 charset 走 `Charset.name()`（出 `UTF-8` 而不是传入的 `utf-8`）。
/// 本库不收这一档：它要求调用方手里有个 `Charset` 对象，而"名字大小写随宿主 charset 表变"
/// 的形状在零依赖库里没有对应物；要带属性段的形状，等 §12.2 一起拍。
pub fn data_uri(mime : String, charset : String, data : String) -> String {
  abort("PR-B：契约骨架，契约见 docs/spec/05-codec.md #12.1")
}

///|
/// 组装 base64 档 data URI（`URLUtil.getDataUriBase64`）：`data:` + mime + `;base64,` + 原文。
/// mime 给空串时出 `data:;base64,...`（腿 D 行的 null/空串两档都在，本库只收空串档）。
pub fn data_uri_base64(mime : String, base64 : String) -> String {
  abort("PR-B：契约骨架，契约见 docs/spec/05-codec.md #12.1")
}
