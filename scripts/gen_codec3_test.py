#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""批③ 片一（Caesar / Rot）期望生成器：把腿读数逐档灌成用例，一格都不手打。

用法（两份腿读数，落在工作树外、不提交）：

    python scripts/gen_codec3_test.py <CaesarLeg.txt> <RotLeg.txt>

产出 `codec/caesar_test.mbt` 与 `codec/rot_test.mbt`。

六条纪律（都在本仓前几轮实撞过）：

1. **夹具与期望串一律由码位数组现造**（测试里的 `cc3([...])` helper）。腿里的 `\\uXXXX` 是 Java 层
   转义，而 MoonBit 字符串里那种写法会掉进插值 ⇒ 照抄必错；两侧都按十进制码位灌，值由脚本现算。
2. **一块一档**：`enc`/`dec`/`rt` 各按 shift 切成独立用例。`assert_eq` 一红就中断所在块，
   全塞一块会把"块内还没跑的"藏起来（`cron` 轮那条：204 条里 100 多条从没被执行过）。
3. **抛错档折成形状串**：复用 `codec_test.mbt` 里已有的 `err_text`，期望写成
   `"ShiftUnderflow -14"` —— 那个负数就是参照异常消息里带的下标，读数原样交出、不夹成正数。
4. **`null` 档不落断言**：参照侧那三条 `IllegalArgumentException` 在 `String` 非空的类型下
   结构上到不了（spec §13.4 记着，不假装有覆盖）。
5. **`number_support` 不写字面量**：`true`/`false` 出现在断言实参位会被 G17（死格形状棘轮）计数，
   所以走文件顶上的两个具名常量 `NUM_ON` / `NUM_OFF`。
6. **helper 只定义一处**：同包多个 `_test.mbt` 共享顶层命名空间，`cc3` 定义在 Caesar 那份里，
   Rot 那份直接用并在头部点明这件事（改名或复制都会造出第二份真相）。
"""
import io
import re
import sys

if len(sys.argv) < 3:
    sys.exit("用法：python scripts/gen_codec3_test.py <CaesarLeg.txt> <RotLeg.txt>")

HELPER_DOC = """///|
/// 夹具与期望串一律由码位数组现造（`cc3` 定义在同包的 `caesar_test.mbt` 里——
/// 同包多个 `_test.mbt` 共享顶层命名空间，重复定义判 `declared twice`）。
///
/// - Note: 腿的输出是 Java 层转义（`\\uXXXX` 显形非 ASCII），MoonBit 字符串里那层写法不合法，
///   所以这里一律按十进制码位现造——夹具与期望串同一条通道，杜绝手打。

"""

HEAD = """///|
/// 批③ 片一（%s）的期望面：**全部由腿灌，手打零条**。
/// 契约 `docs/spec/05-codec.md` §13；腿 `%s`。
/// 此刻函数体是 `PR-B：契约骨架` 的 abort ⇒ 这批用例红是设计态（门禁 G5：落地笔只许把红变绿）。

"""

HELPER = """///|
/// 由码位数组现造夹具与期望串。
fn cc3(codes : Array[Int]) -> String {
  let out : Array[Char] = []
  for c in codes {
    match c.to_char() {
      Some(ch) => out.push(ch)
      None => abort("夹具码位非法：" + c.to_string())
    }
  }
  String::from_array(out)
}

"""

NUM_HEAD = """///|
/// `number_support` 两档的具名常量（断言实参位上出现 `true`/`false` 字面串会被 G17 计数）
let num_on : Bool = true
let num_off : Bool = false

"""


def read(path):
    return io.open(path, encoding="utf-8", newline="").read().splitlines()


def to_codes(s):
    """把腿的 esc 形式（`\\uXXXX` 与裸 ASCII 混排）解成十进制码位数组字面量。"""
    out, i = [], 0
    while i < len(s):
        if s[i] == "\\" and i + 5 < len(s) and s[i + 1] == "u":
            out.append(int(s[i + 2:i + 6], 16))
            i += 6
        else:
            out.append(ord(s[i]))
            i += 1
    return "[" + ", ".join(str(x) for x in out) + "]"


def rows(lines, fam):
    # 用**最后一个** `||` 分头/值：夹具本身可以是空串，`CC|enc||0||` 这种行若按第一个 `||` 切
    # 会把 shift 掉进值里（第一次跑就是这里 IndexError）。
    for l in lines:
        if not l.startswith(fam + "|"):
            continue
        head, sep, val = l.rpartition("||")
        if not sep:
            continue
        yield head.split("|"), val


def expect_of(val):
    """(期望表达式, 来源标签, 是否抛错档)"""
    if val.startswith("ERR:"):
        m = re.match(r"ERR:([\w.$]+):(.*)$", val)
        cls, msg = m.group(1), m.group(2)
        assert cls.endswith("StringIndexOutOfBoundsException"), " unexpected 异常族: " + cls
        n = int(msg.rsplit(":", 1)[-1].strip())
        return '"ShiftUnderflow %d"' % n, "抛档 %s ⇒ %s" % (cls.split(".")[-1], msg), True
    return "cc3(%s)" % to_codes(val), "读数腿", False


# ============================ Caesar ============================
clines = read(sys.argv[1])
tbl = {}
cenc, cdec, crt = {}, {}, {}
null_arms = 0
for p, val in rows(clines, "CC"):
    f = p[1]
    if f in ("table-len", "table-codes", "table-esc"):
        tbl[f] = val
    elif f in ("null-enc", "null-dec"):
        # 参照的入参校验档：类名与文案都留档（`String` 非空 ⇒ 本库结构上到不了，不落断言）
        null_arms += 1
        tbl[f] = val
    elif f in ("enc", "dec"):
        key, shift = p[2], p[3]
        if "ERR:java.lang.IllegalArgumentException" in val:
            null_arms += 1
            continue
        (cenc if f == "enc" else cdec).setdefault(int(shift), []).append((key, val))
    elif f == "rt":
        crt.setdefault(int(p[3]), []).append((p[2], val))

assert {"table-len", "table-codes", "table-esc", "null-enc", "null-dec"} <= set(tbl), \
    "表常量与两条 null 档读数不齐：%s" % sorted(tbl)
assert null_arms == 2, "Caesar 的 null 档应恰好两条（enc/dec 各一），现读 %d" % null_arms

cb = [HEAD % ("Caesar", "scripts/CaesarLeg.java"), HELPER]
cb.append("// 到不了档（不落断言，理由与读数在 spec §13.4）：参照对 `null` 入参抛——")
cb.append("//   %s" % tbl.get("null-enc", "{缺读数}"))
cb.append("//   %s" % tbl.get("null-dec", "{缺读数}"))
cb.append("// 本库入参是 `String`（非空类型），这一档结构上到不了；造个假错误反而是发明语义。")
cb.append("")
cb.append('test "codec #13.1 caesar_table：52 字符交替表（不是 A-Z 再 a-z）" {')
cb.append("  assert_eq(@codec.caesar_table.length(), %s) // 读数腿  CC|table-len" % tbl["table-len"])
cb.append("  assert_eq(@codec.caesar_table, cc3([%s])) // 读数腿  CC|table-codes" % tbl["table-codes"])
cb.append("}")
cb.append("")

for sh in sorted(cenc):
    cb.append('test "codec #13.1 encode shift=%d（%d 档夹具逐个点名）" {' % (sh, len(cenc[sh])))
    for key, val in cenc[sh]:
        exp, why, threw = expect_of(val)
        call = "@codec.caesar_encode(cc3(%s), %d)" % (to_codes(key), sh)
        cb.append("  assert_eq(%s, %s) // %s  %s"
                  % (("err_text(() => %s)" % call) if threw else call, exp, why,
                     "夹具 " + key))
    cb.append("}")
    cb.append("")

for sh in sorted(cdec):
    cb.append('test "codec #13.1 decode shift=%d（%d 档夹具；这一侧从不抛）" {' % (sh, len(cdec[sh])))
    bad = 0
    for key, val in cdec[sh]:
        if val.startswith("ERR:"):
            bad += 1
        exp, why, threw = expect_of(val)
        cb.append("  assert_eq(@codec.caesar_decode(cc3(%s), %d), %s) // %s  夹具 %s"
                  % (to_codes(key), sh, exp, why, key))
    assert bad == 0, "decode 侧出现 %d 条抛错读数，与字节码那条 +52 归一不符" % bad
    cb.append("}")
    cb.append("")

for sh in sorted(crt):
    same = sum(1 for _, v in crt[sh] if v == "SAME")
    cb.append('test "codec #13.1 往返 decode(encode(x)) shift=%d：%d/%d 档复原，其余逐个点名" {'
              % (sh, same, len(crt[sh])))
    for key, val in crt[sh]:
        codes = to_codes(key)
        body = ("@codec.caesar_decode(@codec.caesar_encode(cc3(%s), %d), %d)" % (codes, sh, sh))
        if val == "SAME":
            cb.append("  assert_eq(%s, cc3(%s)) // 规则腿  腿 CC|rt 该行标 SAME" % (body, codes))
        elif val.startswith("DIFF:"):
            cb.append("  assert_eq(%s, cc3(%s)) // 读数腿  不复原档 %s ⇒ %s"
                      % (body, to_codes(val[5:]), key, val))
    cb.append("}")
    cb.append("")

io.open("codec/caesar_test.mbt", "w", encoding="utf-8", newline="\n").write("\n".join(cb))

# ============================ Rot ============================
rlines = read(sys.argv[2])
renc, rdec, rrt, re13, rd13 = {}, {}, {}, [], []
rnull = {}
r_null = 0
for p, val in rows(rlines, "RT"):
    f = p[1]
    if f in ("null-enc", "null-dec"):
        r_null += 1
        rnull[f] = val
    elif f in ("e13", "d13"):
        (re13 if f == "e13" else rd13).append((p[2], val))
    elif f == "enc":
        key, shift, num = p[2], p[3], p[4]
        if "ERR:java.lang.IllegalArgumentException" in val:
            r_null += 1
            continue
        renc.setdefault((int(shift), num), []).append((key, val))
    elif f == "dec":
        key, shift, num = p[2], p[3], p[4]
        if "ERR:java.lang.IllegalArgumentException" in val:
            r_null += 1
            continue
        rdec.setdefault((int(shift), num), []).append((key, val))
    elif f == "rt":
        rrt.setdefault((int(p[3]), p[4]), []).append((p[2], val))
assert r_null == 2, "Rot 的 null 档应恰好两条，现读 %d" % r_null

rb = [HEAD % ("Rot", "scripts/RotLeg.java"), HELPER_DOC]
rb.append(NUM_HEAD)
rb.append("// 到不了档（不落断言，理由与读数在 spec §13.4）：参照对 `null` 入参抛——")
rb.append("//   %s" % rnull.get("null-enc", "{缺读数}"))
rb.append("//   %s" % rnull.get("null-dec", "{缺读数}"))
rb.append("// 两条文案不同（`message must not be null` / `rot must not be null`），留档就是为了这条：")
rb.append("// 参照那两个形参名不同，本库都到不了，但读数不许合并。")
rb.append("")
# 默认档的判别夹具：腿对同一条夹具给了两侧读数，`true?1|false?0` 就是"单参档落在 true 侧"的证据。
# 所以这里既钉"单参档 == true 侧"，也钉"含数字的夹具在 false 侧**不等**"——后者才真把默认值判死。
off_lookup = dict(renc.get((13, "false"), []))
rb.append('test "codec #13.3 encode13 的默认档：number_support 实测是 true（不是 false）" {')
disc = 0
for key, val in re13:
    v = val.split("|true?")[0]
    codes = to_codes(key)
    rb.append("  assert_eq(@codec.rot13_encode(cc3(%s)), cc3(%s)) // 读数腿  RT|e13 %s ⇒ %s"
              % (codes, to_codes(v), key, v))
    rb.append("  assert_eq(@codec.rot_encode(cc3(%s), 13, num_on), cc3(%s)) // 规则腿  单参档走 true 侧"
              % (codes, to_codes(v)))
    if key in off_lookup and off_lookup[key] != v:
        disc += 1
        rb.append("  assert_true(@codec.rot_encode(cc3(%s), 13, num_off) != cc3(%s)) "
                  "// 读数腿  同夹具 false 侧是 %s ⇒ 默认值只能是 true"
                  % (codes, to_codes(v), off_lookup[key]))
rb.append("  // 判别档共 %d 条：不含数字的夹具两侧同值，靠这些条定不了默认值" % disc)
rb.append("}")
rb.append("")

rb.append('test "codec #13.3 decode13 与 encode13 不是互逆（腿逐条给分布）" {')
inv = sum(1 for _, v in rd13 if v.endswith("|dec13selfinv|1"))
rb.append("  // 25 条夹具里 %d 条 `decode13 == encode13`，其余不等 ⇒ 自逆只能逐档钉" % inv)
for key, val in rd13:
    v = val.split("|dec13selfinv|")[0]
    rb.append("  assert_eq(@codec.rot13_decode(cc3(%s)), cc3(%s)) // 读数腿  RT|d13 %s ⇒ %s"
              % (to_codes(key), to_codes(v), key, v))
rb.append("}")
rb.append("")

for (shift, num), items in sorted(renc.items()):
    nm = "num_on" if num == "true" else "num_off"
    rb.append('test "codec #13.3 encode shift=%d %s（%d 档夹具）" {' % (shift, nm, len(items)))
    for key, val in items:
        rb.append("  assert_eq(@codec.rot_encode(cc3(%s), %d, %s), cc3(%s)) // 读数腿  夹具 %s ⇒ %s"
                  % (to_codes(key), shift, nm, to_codes(val), key, val))
    rb.append("}")
    rb.append("")

for (shift, num), items in sorted(rdec.items()):
    nm = "num_on" if num == "true" else "num_off"
    rb.append('test "codec #13.3 decode shift=%d %s（%d 档夹具）" {' % (shift, nm, len(items)))
    for key, val in items:
        rb.append("  assert_eq(@codec.rot_decode(cc3(%s), %d, %s), cc3(%s)) // 读数腿  夹具 %s ⇒ %s"
                  % (to_codes(key), shift, nm, to_codes(val), key, val))
    rb.append("}")
    rb.append("")

for (shift, num), items in sorted(rrt.items()):
    nm = "num_on" if num == "true" else "num_off"
    same = sum(1 for _, v in items if v == "SAME")
    rb.append('test "codec #13.3 往返 shift=%d %s：%d/%d 档复原" {' % (shift, nm, same, len(items)))
    for key, val in items:
        if val == "SAME":
            rb.append("  assert_eq(@codec.rot_decode(@codec.rot_encode(cc3(%s), %d, %s), %d, %s), cc3(%s)) "
                      "// 规则腿  SAME 档" % (to_codes(key), shift, nm, shift, nm, to_codes(key)))
        elif val.startswith("DIFF:"):
            rb.append("  assert_eq(@codec.rot_decode(@codec.rot_encode(cc3(%s), %d, %s), %d, %s), cc3(%s)) "
                      "// 读数腿  不复原档 %s ⇒ %s"
                      % (to_codes(key), shift, nm, shift, nm, to_codes(val[5:]), key, val))
    rb.append("}")
    rb.append("")

io.open("codec/rot_test.mbt", "w", encoding="utf-8", newline="\n").write("\n".join(rb))

sys.stderr.write(
    "caesar 块 %d / rot 块 %d；断言行 %d + %d\n" % (
        sum(1 for x in cb if x.startswith("test ")),
        sum(1 for x in rb if x.startswith("test ")),
        sum(1 for x in cb if x.startswith("  assert")),
        sum(1 for x in rb if x.startswith("  assert")),
    )
)
