#!/usr/bin/env python
# num 第五批补档生成器：把 Num5Leg.java 的读数灌成 num/num_deep5_test.mbt。
# 一条断言一个 test 块；期望只从腿的读数取，手打零条。
# 用法：python scripts/gen_num5_test.py <num5_leg.txt>
import io
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if len(sys.argv) < 2:
    raise SystemExit("用法：python scripts/gen_num5_test.py <num5_leg.txt>")
LEG = os.path.abspath(sys.argv[1])
OUT = os.path.join(REPO, "num", "num_deep5_test.mbt")

HEAD = '''///|
// num 深档补档（10-08）——Money 三族（元/分/串）、分配负余数档、中文数字正向补零档、
// 反向坏档与"万万"档、缩写两位小数档、计算器负指数档。
// 期望全部由 Num5Leg.java 现读灌入（hutool-core 5.8.35 · JDK 17.0.14 · -Dfile.encoding=UTF-8），手打零条。
// 腿给的是 hutool 的读数；异常档只钉"抛不抛"，变体名不由这条腿授权（映射表在 spec 08-num §5 与 §10.4）。

///|
fn n5_tag_of_text(s : String) -> Bool {
  // 只问 Money 的十进制解析收不收，具体哪一档不在本批授权面里
  try {
    let _ = @num.Money::from_yuan_str(s)
    true
  } catch {
    _ => false
  }
}

///|
fn n5_yuan(s : String) -> Double {
  try {
    @num.Money::from_yuan_str(s).to_yuan()
  } catch {
    _ => 0.0
  }
}

///|
fn n5_yuan2(s : String) -> String {
  try {
    @num.Money::from_yuan_str(s).cent().to_string()
  } catch {
    _ => "RAISE"
  }
}

///|
fn n5_str(s : String) -> String {
  try {
    @num.Money::from_yuan_str(s).to_string()
  } catch {
    _ => "RAISE"
  }
}

///|
fn n5_sum(ms : Array[@num.Money]) -> Int64 {
  let mut acc = 0L
  for m in ms {
    acc = acc + m.cent()
  }
  acc
}

///|
fn n5_even_sum(s : String, n : Int) -> Int64 {
  try {
    n5_sum(@num.Money::from_yuan_str(s).allocate_even(n))
  } catch {
    _ => -999999999L
  }
}

///|
fn n5_ratio_sum(s : String, rs : Array[Int]) -> Int64 {
  try {
    n5_sum(@num.Money::from_yuan_str(s).allocate_by_ratio(rs))
  } catch {
    _ => -999999999L
  }
}

///|
fn n5_join(ms : Array[@num.Money]) -> String {
  let mut out = ""
  for m in ms {
    if out != "" {
      out = out + ";"
    }
    out = out + m.cent().to_string()
  }
  out
}

///|
fn n5_even(s : String, n : Int) -> String {
  try {
    let m = @num.Money::from_yuan_str(s)
    n5_join(@num.Money::allocate_even(m, n))
  } catch {
    _ => "RAISE"
  }
}

///|
fn n5_ratio(s : String, rs : Array[Int]) -> String {
  try {
    let m = @num.Money::from_yuan_str(s)
    n5_join(@num.Money::allocate_by_ratio(m, rs))
  } catch {
    _ => "RAISE"
  }
}

///|
fn n5_int(t : String) -> String {
  try {
    @num.int_of_chinese(t).to_string()
  } catch {
    _ => "RAISE"
  }
}

///|
fn n5_money(t : String) -> String {
  try {
    @num.money_of_chinese(t).to_string()
  } catch {
    _ => "RAISE"
  }
}

///|
fn n5_cn(t : String) -> String {
  try {
    @num.chinese_of(t)
  } catch {
    _ => "RAISE"
  }
}

///|
fn n5_cn_upper(t : String) -> String {
  try {
    @num.chinese_upper_of(t)
  } catch {
    _ => "RAISE"
  }
}

///|
fn n5_abcn(v : Int64) -> String {
  @num.chinese_abbrev(v)
}

///|
fn n5_aben(v : Int64) -> String {
  @num.english_abbrev(v)
}

///|
fn n5_calc(e : String) -> Double {
  try {
    @num.num_calculate(e)
  } catch {
    _ => 0.0
  }
}

'''


# 登记而不钉的 22 档（两侧读数都写进 docs/spec/08-num.md 的新章节，钉任何一侧都是替对方立法）
DROP = {
    "mb-5",              # "1e3"：参照走 BigDecimal 收 e 记法，本库 #8.18 判非十进制
    "ae-m1p00-3", "ar-m1p00-1_1_1",   # 负档：#8.23/#8.24 明写"不进参照对撞"，改由不变量钉
    "rn-11",             # 空串：参照 chineseToNumber("") 给 0，本库判坏
    "rbm-1", "rbm-2", "rbm-3",         # "万万"档：参照 money 侧给 0.00
    "ac-100000", "ac-105000", "ac-1000000", "ac-10050000",   # 中文缩写尾零位数
    "aw-1005",           # 英文缩写：spec #15 自己记的参照读数是 1k，本库给 1.01k ⇒ 疑实现缺陷
}
for _i in range(2, 12):
    DROP.add("rm-%d" % _i)   # 「没有元键」与错误形状两族：#8.36 声明分岔，本批仍按"登记"处理


def leg_cent(seen, src):
    """原值分数一律回查腿的 MC 行（不变量的右侧也必须是读数，不许我手打）"""
    for inp, val in seen.get("MC", []):
        if inp == src:
            if val.startswith("ERR"):
                raise SystemExit("MC 行 %s 不是数值读数，做不了不变量右侧" % src)
            return val + "L"
    raise SystemExit("腿里缺 MC|%s 这一行，补上再出文件" % src)


def lit(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def read_leg():
    rows = []
    for raw in io.open(LEG, encoding="utf-8", errors="replace").read().replace("\r", "").splitlines():
        f = raw.split("|")
        if len(f) < 3 or f[0] == "G":
            continue
        rows.append((f[0], f[1:-1], f[-1]))
    return rows


BLOCKS = []


def blk(name, comment, expr):
    if name in DROP:
        return
    BLOCKS.append((name, comment, expr))


def blk_inv(name, comment, expr):
    """不变量块不受 DROP 影响：#8.23/#8.24 明写负档"不进参照对撞，改由两条不变量当判据" """
    BLOCKS.append((name, comment, expr))


IDX = {}


def idx(kind, inp):
    """稳定序号：hash() 每进程随机，块名必须可复跑复现"""
    k = seen_state.get(kind)
    return k.index(inp) + 1


def main():
    rows = read_leg()
    global seen_state
    seen = {}
    for k, inps, val in rows:
        seen.setdefault(k, []).append((inps[0] if len(inps) == 1 else inps, val))
    seen_state = {k: [i for i, _ in v] for k, v in seen.items()}

    for inp, val in seen.get("MC", []):
        ok = not val.startswith("ERR")
        blk("mc-%s" % inp.replace("-", "m"),
            "Money 分位 ｜ 入参=%s ｜ 参照=%s" % (inp, val),
            'assert_eq(n5_yuan2(%s), %s)' % (lit(inp), lit(val if ok else "RAISE")))
    for inp, val in seen.get("MY", []):
        if val.startswith("ERR"):
            blk("my-tag-%s" % inp.replace("-", "m"),
                "Money 解析档 ｜ 入参=%s ｜ 参照=%s" % (inp, val),
                'assert_eq(n5_tag_of_text(%s), false)' % lit(inp))
        else:
            blk("my-%s" % inp.replace("-", "m").replace(".", "p"),
                "Money 元值 ｜ 入参=%s ｜ 参照 Double.toString=%s" % (inp, val),
                'assert_eq(n5_yuan(%s), %s)' % (lit(inp), val))
    for inp, val in seen.get("MS", []):
        blk("ms-%s" % inp.replace("-", "m"),
            "Money 串形 ｜ 入参=%s ｜ 参照 toString=%s" % (inp, val),
            'assert_eq(n5_str(%s), %s)' % (lit(inp), lit(val)))
    for inp, val in seen.get("MB", []):
        want = "false" if val.startswith("ERR") else "true"
        blk("mb-%d" % idx("MB", inp),
            "Money 坏输入 ｜ 入参=%r ｜ 参照=%s" % (inp, val),
            'assert_eq(n5_tag_of_text(%s), %s)' % (lit(inp), want))
    for inp, val in seen.get("AE", []):
        src, n = inp[0], inp[1]
        exp = "RAISE" if val.startswith("ERR") else val
        blk("ae-%s-%s" % (src.replace("-", "m").replace(".", "p"), n.replace("-", "m")),
            "allocate_even ｜ 入参=%s ｜ 参照=%s" % (inp, val),
            'assert_eq(n5_even(%s, %s), %s)' % (lit(src), n, lit(exp)))
        if src.startswith("-"):
            blk_inv("ae-inv-%s-%s" % (src.replace("-", "m").replace(".", "p"), n.replace("-", "m")),
                    "allocate_even 负档不变量 ｜ 入参=%s ｜ 参照=%s（#8.23：负档不进对撞，改由不变量钉）" % (inp, val),
                    'assert_eq(n5_even_sum(%s, %s), %s)' % (lit(src), n, leg_cent(seen, src)))
    for inp, val in seen.get("AR", []):
        src, r = inp[0], inp[1]
        rs = "[" + ", ".join(r.split(",")) + "]"
        exp = "RAISE" if val.startswith("ERR") else val
        blk("ar-%s-%s" % (src.replace("-", "m").replace(".", "p"), r.replace(",", "_")),
            "allocate_by_ratio ｜ 入参=%s ｜ 参照=%s" % (inp, val),
            'assert_eq(n5_ratio(%s, %s), %s)' % (lit(src), rs, lit(exp)))
        if src.startswith("-"):
            blk_inv("ar-inv-%s-%s" % (src.replace("-", "m").replace(".", "p"), r.replace(",", "_")),
                    "allocate_by_ratio 负档不变量 ｜ 入参=%s ｜ 参照=%s（#8.24 同一条）" % (inp, val),
                    'assert_eq(n5_ratio_sum(%s, %s), %s)' % (lit(src), rs, leg_cent(seen, src)))
    for inp, val in seen.get("CF", []):
        blk("cf-%s" % inp, "chinese_of ｜ 入参=%s ｜ 参照 format(v,false)=%s" % (inp, val),
            'assert_eq(n5_cn(%s), %s)' % (lit(inp), lit(val)))
    for inp, val in seen.get("CFU", []):
        blk("cfu-%s" % inp, "chinese_upper_of ｜ 入参=%s ｜ 参照 format(v,true)=%s" % (inp, val),
            'assert_eq(n5_cn_upper(%s), %s)' % (lit(inp), lit(val)))
    for inp, val in seen.get("RN", []):
        exp = "RAISE" if val.startswith("ERR") else val
        blk("rn-%d" % idx("RN", inp), "int_of_chinese ｜ 入参=%s ｜ 参照=%s" % (inp, val),
            'assert_eq(n5_int(%s), %s)' % (lit(inp), lit(exp)))
    for inp, val in seen.get("RM", []):
        exp = "RAISE" if val.startswith("ERR") or val == "NULL" else val
        blk("rm-%d" % idx("RM", inp), "money_of_chinese ｜ 入参=%s ｜ 参照=%s" % (inp, val),
            'assert_eq(n5_money(%s), %s)' % (lit(inp), lit(exp)))
    for inp, val in seen.get("RB", []):
        exp = "RAISE" if val.startswith("ERR") else val
        blk("rb-%d" % idx("RB", inp), "int_of_chinese 万万档 ｜ 入参=%s ｜ 参照=%s" % (inp, val),
            'assert_eq(n5_int(%s), %s)' % (lit(inp), lit(exp)))
    for inp, val in seen.get("RBM", []):
        exp = "RAISE" if val.startswith("ERR") or val == "NULL" else val
        blk("rbm-%d" % idx("RBM", inp), "money_of_chinese 万万档 ｜ 入参=%s ｜ 参照=%s" % (inp, val),
            'assert_eq(n5_money(%s), %s)' % (lit(inp), lit(exp)))
    for inp, val in seen.get("AC", []):
        blk("ac-%s" % inp.replace("-", "m"), "chinese_abbrev ｜ 入参=%s ｜ 参照 formatSimple=%s" % (inp, val),
            'assert_eq(n5_abcn(%sL), %s)' % (inp, lit(val)))
    for inp, val in seen.get("AW", []):
        blk("aw-%s" % inp.replace("-", "m"), "english_abbrev ｜ 入参=%s ｜ 参照 formatSimple=%s" % (inp, val),
            'assert_eq(n5_aben(%sL), %s)' % (inp, lit(val)))
    for inp, val in seen.get("CC", []):
        if val.startswith("ERR"):
            blk("cc-tag-%d" % idx("CC", inp), "num_calculate ｜ 入参=%s ｜ 参照=%s" % (inp, val),
                'assert_eq(n5_calc_tag(%s), "RAISE")' % lit(inp))
        else:
            blk("cc-%d" % idx("CC", inp), "num_calculate 负指数档 ｜ 入参=%s ｜ 参照=%s" % (inp, val),
                'assert_eq(n5_calc(%s), %s)' % (lit(inp), val))

    body = HEAD + "\n\n".join(
        '///|\ntest "num 深档 %s" {\n  // %s\n  %s\n}' % (n, c, e) for n, c, e in BLOCKS) + "\n"
    io.open(OUT, "w", encoding="utf-8", newline="\n").write(body)
    print("blocks=%d file=%s" % (len(BLOCKS), OUT))


main()
