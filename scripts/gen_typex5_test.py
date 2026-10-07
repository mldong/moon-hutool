#!/usr/bin/env python
# typex 第八批补档的期望生成器：把 TypexLeg5.java 的逐对直读灌成 typex/typex_leg5_test.mbt。
# 用法：python scripts/gen_typex5_test.py <leg5.txt>
# 期望只从腿的读数取，手打零条；参照抛/形状不同源的两族走 DECL 表（值＝红样回填，不是照实现手打）。
import io
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if len(sys.argv) < 2:
    raise SystemExit("用法：python scripts/gen_typex5_test.py <leg5.txt>")
LEG = os.path.abspath(sys.argv[1])
OUT = os.path.join(REPO, "typex", "typex_leg5_test.mbt")

HEAD = '''///|
// typex 第八批补档（10-08）——Version 预发/构建段的分词支路、港澳台形状闸的收尾档、15 位省码闸、
// 坏后缀与未知档位串。期望全部由 `scripts/TypexLeg5.java` 现读灌入
// （hutool-core 5.8.35 · JDK 17.0.14 · `-Dfile.encoding=UTF-8`），手打零条。
// 两条形状纪律：① 港澳台两族的夹具是**同一串只在收尾形状上变化**，校验位由腿反推（`findHk`/`findTw`），
// 所以 true 档与 false 档成对出现——若整族只有 false，那条闸坏掉也照样全绿（腿的 `G|GUARD_OK` 就是在管这件事）；
// ② `Version.compareTo` 的原始差值只承诺符号（§5 第 4 条），本库出口归一成 `-1/0/1`，
// 断言里打的是符号档，腿的原读数留在注释。
// 参照 `isValidCard10` 返回 `String[]`，与本库 `IdcardInfo10` 三槽形状不同源 ⇒ `O` 行只登记不进断言（§22.2）。

'''

# 参照抛 / 无同形状参照 ⇒ 钉本库形状；值＝首轮红样回填（`assert_eq` 的 actual），依据行写进注释
DECL = {
    "desens-unknown": (
        't5_des("abcDEF", "NOT_A_KIND")',
        "abcDEF",
        "未知档位串照参照 `switch` 的空 `default` 给原串（#23.96 函数注释那行），枚举穷尽 ⇒ 参照无此档读数",
    ),
    "ds-bad-suffix": (
        't5_amount(1L, "XB")',
        "RAISE",
        "坏后缀：参照 `DataSizeUtil.parse` 对 `1 XB` 抛 `IllegalArgumentException`（腿 `B` 行），"
        "本库同判拒但对位 `DataSizeError::BadText`（§15.5 错误映射那行）",
    ),
    "phone-hi-tail": (
        't5_phone_sub_after("010-123456" + "\\u{1F600}")',
        "456",
        "高代理恰落在切片尾：参照（Java `String`）留孤立代理项，本库丢弃（§11.5 那行）",
    ),
    "phone-lo-head": (
        't5_phone_lo()',
        "345",
        "低代理恰落在切片头：同上，参照留、本库丢（§11.5 那行）",
    ),
}


def to_moon(s):
    if s == "{null}":
        return None
    out = []
    for ch in s:
        o = ord(ch)
        if ch == '"':
            out.append('\\"')
        elif ch == chr(92):
            out.append(chr(92) + chr(92))
        elif 0x20 <= o < 0x7F:
            out.append(ch)
        else:
            out.append("\\u{%X}" % o)
    return '"' + "".join(out) + '"'


def sign(reading):
    try:
        v = int(reading)
    except ValueError:
        return None
    return "1" if v > 0 else ("-1" if v < 0 else "0")


def main():
    text = io.open(LEG, encoding="utf-8", errors="replace").read().replace("\r", "")
    if "G|GUARD_OK|distinct3" not in text:
        raise SystemExit("腿自检缺失或失败（没有 G|GUARD_OK|distinct3）：%s" % LEG)
    rows = [ln.split("|") for ln in text.splitlines() if ln.strip()]
    v_rows = [r for r in rows if r[0] == "V"]
    h_rows = [r for r in rows if r[0] in ("H", "H2")]
    w_rows = [r for r in rows if r[0] == "W"]
    f_rows = [r for r in rows if r[0] == "F"]
    o_rows = [r for r in rows if r[0] == "O"]
    b_rows = [r for r in rows if r[0] == "B"]
    assert len(v_rows) >= 6, "V 行只有 %d 条，形状不对 ⇒ 不出文件" % len(v_rows)
    assert len(h_rows) >= 8, "H 行只有 %d 条" % len(h_rows)
    # 族内必须既有 true 也有 false，否则整族恒假（见 HEAD 那条纪律）
    for tag, fam, idx in (("HK", h_rows, 3), ("TW-bool", [r for r in w_rows if not r[3].startswith("ERR")], 3)):
        vals = set(r[idx] for r in fam)
        assert "true" in vals and "false" in vals, "%s 族读数只有 %s ⇒ 拒绝出文件" % (tag, vals)

    body = HEAD
    body += '''///|
fn t5_vc(a : String, b : String) -> String {
  @typex.version_compare(@typex.version_of(a), @typex.version_of(b)).to_string()
}

///|
fn t5_hk(s : String) -> String {
  @typex.idcard_is_valid_hk_card(s).to_string()
}

///|
fn t5_tw(s : String) -> String {
  @typex.idcard_is_valid_tw_card(s).to_string()
}

///|
fn t5_id15(s : String) -> String {
  @typex.idcard_is_valid_15(s).to_string()
}

///|
fn t5_amount(n : Int64, s : String) -> String {
  @typex.data_size_of_amount_suffix(n, s).to_string() catch {
    _ => "RAISE"
  }
}

///|
// 高代理落在切片尾：`010-123456`（10 码元）+ 一个补充平面字符（第 11、12 码元是高低代理），
// `phone_sub_after` 取第 7..11 码元 ⇒ 切片正好切进代理对
fn t5_phone_sub_after(s : String) -> String {
  @typex.phone_sub_after(s)
}

///|
// 低代理落在切片头：`010-12`（6 码元）+ 一个补充平面字符（第 7、8 码元是高低代理）+ `34567`
fn t5_phone_lo() -> String {
  @typex.phone_sub_after("010-12\\u{1F600}34567")
}

///|
fn t5_des(text : String, kind : String) -> String {
  match @typex.desensitize_kind(text, kind) {
    None => "null"
    Some(v) => v
  }
}

///|
'''
    n = 0
    for r in v_rows:
        _, name, a, b, reading = r[0], r[1], r[2], r[3], r[4]
        exp = sign(reading)
        assert exp is not None, "V 行读数不是整数：%s" % reading
        n += 1
        body += ('///|\ntest "typex 分词直读 %02d · %s" {\n'
                 '  // compare(%s, %s) ｜ 参照 compareTo=%s ｜ 本库出口只承诺符号（§5 第 4 条）\n'
                 '  assert_eq(t5_vc(%s, %s), "%s")\n}\n\n'
                 % (n, name, a, b, reading, to_moon(a), to_moon(b), exp))
    for r in h_rows:
        n += 1
        body += ('///|\ntest "typex 港形直读 %02d · %s" {\n'
                 '  // isValidHKCard(%s) ｜ 参照=%s\n'
                 '  assert_eq(t5_hk(%s), "%s")\n}\n\n'
                 % (n, r[1], r[2], r[3], to_moon(r[2]), r[3]))
    for r in w_rows:
        n += 1
        ref = r[3]
        if ref.startswith("ERR:"):
            body += ('///|\ntest "typex 台形直读 %02d · %s（声明档）" {\n'
                     '  // isValidTWCard(%s) ｜ 参照=%s ⇒ 参照在坏形状上抛，本库三件都不设这枚错误面，'
                     '这类串一律判假（§22.1 那行）\n'
                     '  assert_eq(t5_tw(%s), "false")\n}\n\n'
                     % (n, r[1], r[2], ref, to_moon(r[2])))
        else:
            body += ('///|\ntest "typex 台形直读 %02d · %s" {\n'
                     '  // isValidTWCard(%s) ｜ 参照=%s\n'
                     '  assert_eq(t5_tw(%s), "%s")\n}\n\n'
                     % (n, r[1], r[2], ref, to_moon(r[2]), ref))
    for r in f_rows:
        n += 1
        body += ('///|\ntest "typex 十五位省码直读 %02d · %s" {\n'
                 '  // isValidCard15(%s) ｜ 参照=%s\n'
                 '  assert_eq(t5_id15(%s), "%s")\n}\n\n'
                 % (n, r[1], r[2], r[3], to_moon(r[2]), r[3]))
    for key in sorted(DECL):
        call, exp, why = DECL[key]
        n += 1
        body += ('///|\ntest "typex 声明档 %02d · %s" {\n'
                 '  // %s\n  assert_eq(%s, %s)\n}\n\n'
                 % (n, key, why, call, to_moon(exp) if not exp.startswith("<") else '"<TBD>"'))
    body += ("// 参照 `isValidCard10` 的 %d 条读数（返回 `String[]`，本库无同形状出口 ⇒ 不进断言，§22.2）：\n"
             % len(o_rows))
    for r in o_rows:
        body += "// O|%s|%s|%s\n" % (r[1], r[2], r[3] if len(r) > 3 else "")
    for r in b_rows:
        body += "// B|%s|%s\n" % (r[1], r[2])
    io.open(OUT, "w", encoding="utf-8", newline="\n").write(body)
    print("V=%d H=%d W=%d F=%d O=%d B=%d blocks=%d file=%s"
          % (len(v_rows), len(h_rows), len(w_rows), len(f_rows), len(o_rows), len(b_rows), n, OUT))


main()
