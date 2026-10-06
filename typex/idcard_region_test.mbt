///|
// moon-hutool/typex —— 港澳台 10 位族（ROADMAP 第 23 行第五批，#23.108–#23.110）
// 期望值全部由生成脚本从参照腿灌入（手打零条）：腿 Temp/convsrc/hktw_rows.tsv（真 hutool-core + JDK 17）。
// 腿 216 行＝215 VAL + 1 ERR；其中 53 行是工装里台湾那一段循环跑了两遍留下的重复，
// 生成脚本按 (标签,夹具) 去重且断言两次读数逐字节相同 ⇒ 唯一夹具 163 条：115 条进断言（`TW_BAD_DIGITS`
// 那 26 条按腿自己的构样规则展开成 234 条，所以本文件共 323 条），48 条（`TWTABLE`/`CARD10`/`SRC_*`/`TW_EDGE_null`）
// 只进 spec §19 的证据与不收档；那 1 条 ERR 是参照对 `null` 抛 NPE，见 §19.2。
// 18 位那一支读年份：夹具一律传腿执行当年 2026（本库把宿主时钟做成显式参数，与 §13.3 同处置）。

///|
test "\u{53f0}\u{6e7e}\u{5341}\u{4f4d}\u{ff1a}26 \u{679a}\u{9996}\u{5b57}\u{6bcd}\u{5404}\u{6709}\u{4e00}\u{679a}\u{901a}\u{8fc7}\u{7684}\u{6821}\u{9a8c}\u{4f4d}\u{ff08}\u{9996}\u{5b57}\u{6bcd}\u{8868}\u{7531}\u{53c2}\u{7167}\u{53cd}\u{5c04}\u{8bfb}\u{51fa}\u{3001}\u{4e0d}\u{5916}\u{9732}\u{ff09}" {
  assert_eq(@typex.idcard_is_valid_tw_card("A123456789"), true) // TW_VALID_ONE|A
  assert_eq(@typex.idcard_is_valid_tw_card("B123456780"), true) // TW_VALID_ONE|B
  assert_eq(@typex.idcard_is_valid_tw_card("C123456781"), true) // TW_VALID_ONE|C
  assert_eq(@typex.idcard_is_valid_tw_card("D123456782"), true) // TW_VALID_ONE|D
  assert_eq(@typex.idcard_is_valid_tw_card("E123456783"), true) // TW_VALID_ONE|E
  assert_eq(@typex.idcard_is_valid_tw_card("F123456784"), true) // TW_VALID_ONE|F
  assert_eq(@typex.idcard_is_valid_tw_card("G123456785"), true) // TW_VALID_ONE|G
  assert_eq(@typex.idcard_is_valid_tw_card("H123456786"), true) // TW_VALID_ONE|H
  assert_eq(@typex.idcard_is_valid_tw_card("I123456781"), true) // TW_VALID_ONE|I
  assert_eq(@typex.idcard_is_valid_tw_card("J123456787"), true) // TW_VALID_ONE|J
  assert_eq(@typex.idcard_is_valid_tw_card("K123456788"), true) // TW_VALID_ONE|K
  assert_eq(@typex.idcard_is_valid_tw_card("L123456788"), true) // TW_VALID_ONE|L
  assert_eq(@typex.idcard_is_valid_tw_card("M123456789"), true) // TW_VALID_ONE|M
  assert_eq(@typex.idcard_is_valid_tw_card("N123456780"), true) // TW_VALID_ONE|N
  assert_eq(@typex.idcard_is_valid_tw_card("O123456782"), true) // TW_VALID_ONE|O
  assert_eq(@typex.idcard_is_valid_tw_card("P123456781"), true) // TW_VALID_ONE|P
  assert_eq(@typex.idcard_is_valid_tw_card("Q123456782"), true) // TW_VALID_ONE|Q
  assert_eq(@typex.idcard_is_valid_tw_card("R123456783"), true) // TW_VALID_ONE|R
  assert_eq(@typex.idcard_is_valid_tw_card("S123456784"), true) // TW_VALID_ONE|S
  assert_eq(@typex.idcard_is_valid_tw_card("T123456785"), true) // TW_VALID_ONE|T
  assert_eq(@typex.idcard_is_valid_tw_card("U123456786"), true) // TW_VALID_ONE|U
  assert_eq(@typex.idcard_is_valid_tw_card("V123456787"), true) // TW_VALID_ONE|V
  assert_eq(@typex.idcard_is_valid_tw_card("W123456789"), true) // TW_VALID_ONE|W
  assert_eq(@typex.idcard_is_valid_tw_card("X123456787"), true) // TW_VALID_ONE|X
  assert_eq(@typex.idcard_is_valid_tw_card("Y123456788"), true) // TW_VALID_ONE|Y
  assert_eq(@typex.idcard_is_valid_tw_card("Z123456780"), true) // TW_VALID_ONE|Z
}

///|
test "\u{53f0}\u{6e7e}\u{5341}\u{4f4d}\u{ff1a}\u{5176}\u{4f59}\u{6821}\u{9a8c}\u{4f4d}\u{5168}\u{4e0d}\u{901a}\u{8fc7}\u{ff08}\u{817f}\u{7ed9}\u{6bcf}\u{679a}\u{9996}\u{5b57}\u{6bcd} 9 \u{679a}\u{ff0c}\u{5408}\u{8ba1} 234 \u{679a}\u{ff09}" {
  assert_eq(@typex.idcard_is_valid_tw_card("A123456780"), false) // TW_BAD_DIGITS|A
  assert_eq(@typex.idcard_is_valid_tw_card("A123456781"), false) // TW_BAD_DIGITS|A
  assert_eq(@typex.idcard_is_valid_tw_card("A123456782"), false) // TW_BAD_DIGITS|A
  assert_eq(@typex.idcard_is_valid_tw_card("A123456783"), false) // TW_BAD_DIGITS|A
  assert_eq(@typex.idcard_is_valid_tw_card("A123456784"), false) // TW_BAD_DIGITS|A
  assert_eq(@typex.idcard_is_valid_tw_card("A123456785"), false) // TW_BAD_DIGITS|A
  assert_eq(@typex.idcard_is_valid_tw_card("A123456786"), false) // TW_BAD_DIGITS|A
  assert_eq(@typex.idcard_is_valid_tw_card("A123456787"), false) // TW_BAD_DIGITS|A
  assert_eq(@typex.idcard_is_valid_tw_card("A123456788"), false) // TW_BAD_DIGITS|A
  assert_eq(@typex.idcard_is_valid_tw_card("B123456781"), false) // TW_BAD_DIGITS|B
  assert_eq(@typex.idcard_is_valid_tw_card("B123456782"), false) // TW_BAD_DIGITS|B
  assert_eq(@typex.idcard_is_valid_tw_card("B123456783"), false) // TW_BAD_DIGITS|B
  assert_eq(@typex.idcard_is_valid_tw_card("B123456784"), false) // TW_BAD_DIGITS|B
  assert_eq(@typex.idcard_is_valid_tw_card("B123456785"), false) // TW_BAD_DIGITS|B
  assert_eq(@typex.idcard_is_valid_tw_card("B123456786"), false) // TW_BAD_DIGITS|B
  assert_eq(@typex.idcard_is_valid_tw_card("B123456787"), false) // TW_BAD_DIGITS|B
  assert_eq(@typex.idcard_is_valid_tw_card("B123456788"), false) // TW_BAD_DIGITS|B
  assert_eq(@typex.idcard_is_valid_tw_card("B123456789"), false) // TW_BAD_DIGITS|B
  assert_eq(@typex.idcard_is_valid_tw_card("C123456780"), false) // TW_BAD_DIGITS|C
  assert_eq(@typex.idcard_is_valid_tw_card("C123456782"), false) // TW_BAD_DIGITS|C
  assert_eq(@typex.idcard_is_valid_tw_card("C123456783"), false) // TW_BAD_DIGITS|C
  assert_eq(@typex.idcard_is_valid_tw_card("C123456784"), false) // TW_BAD_DIGITS|C
  assert_eq(@typex.idcard_is_valid_tw_card("C123456785"), false) // TW_BAD_DIGITS|C
  assert_eq(@typex.idcard_is_valid_tw_card("C123456786"), false) // TW_BAD_DIGITS|C
  assert_eq(@typex.idcard_is_valid_tw_card("C123456787"), false) // TW_BAD_DIGITS|C
  assert_eq(@typex.idcard_is_valid_tw_card("C123456788"), false) // TW_BAD_DIGITS|C
  assert_eq(@typex.idcard_is_valid_tw_card("C123456789"), false) // TW_BAD_DIGITS|C
  assert_eq(@typex.idcard_is_valid_tw_card("D123456780"), false) // TW_BAD_DIGITS|D
  assert_eq(@typex.idcard_is_valid_tw_card("D123456781"), false) // TW_BAD_DIGITS|D
  assert_eq(@typex.idcard_is_valid_tw_card("D123456783"), false) // TW_BAD_DIGITS|D
  assert_eq(@typex.idcard_is_valid_tw_card("D123456784"), false) // TW_BAD_DIGITS|D
  assert_eq(@typex.idcard_is_valid_tw_card("D123456785"), false) // TW_BAD_DIGITS|D
  assert_eq(@typex.idcard_is_valid_tw_card("D123456786"), false) // TW_BAD_DIGITS|D
  assert_eq(@typex.idcard_is_valid_tw_card("D123456787"), false) // TW_BAD_DIGITS|D
  assert_eq(@typex.idcard_is_valid_tw_card("D123456788"), false) // TW_BAD_DIGITS|D
  assert_eq(@typex.idcard_is_valid_tw_card("D123456789"), false) // TW_BAD_DIGITS|D
  assert_eq(@typex.idcard_is_valid_tw_card("E123456780"), false) // TW_BAD_DIGITS|E
  assert_eq(@typex.idcard_is_valid_tw_card("E123456781"), false) // TW_BAD_DIGITS|E
  assert_eq(@typex.idcard_is_valid_tw_card("E123456782"), false) // TW_BAD_DIGITS|E
  assert_eq(@typex.idcard_is_valid_tw_card("E123456784"), false) // TW_BAD_DIGITS|E
  assert_eq(@typex.idcard_is_valid_tw_card("E123456785"), false) // TW_BAD_DIGITS|E
  assert_eq(@typex.idcard_is_valid_tw_card("E123456786"), false) // TW_BAD_DIGITS|E
  assert_eq(@typex.idcard_is_valid_tw_card("E123456787"), false) // TW_BAD_DIGITS|E
  assert_eq(@typex.idcard_is_valid_tw_card("E123456788"), false) // TW_BAD_DIGITS|E
  assert_eq(@typex.idcard_is_valid_tw_card("E123456789"), false) // TW_BAD_DIGITS|E
  assert_eq(@typex.idcard_is_valid_tw_card("F123456780"), false) // TW_BAD_DIGITS|F
  assert_eq(@typex.idcard_is_valid_tw_card("F123456781"), false) // TW_BAD_DIGITS|F
  assert_eq(@typex.idcard_is_valid_tw_card("F123456782"), false) // TW_BAD_DIGITS|F
  assert_eq(@typex.idcard_is_valid_tw_card("F123456783"), false) // TW_BAD_DIGITS|F
  assert_eq(@typex.idcard_is_valid_tw_card("F123456785"), false) // TW_BAD_DIGITS|F
  assert_eq(@typex.idcard_is_valid_tw_card("F123456786"), false) // TW_BAD_DIGITS|F
  assert_eq(@typex.idcard_is_valid_tw_card("F123456787"), false) // TW_BAD_DIGITS|F
  assert_eq(@typex.idcard_is_valid_tw_card("F123456788"), false) // TW_BAD_DIGITS|F
  assert_eq(@typex.idcard_is_valid_tw_card("F123456789"), false) // TW_BAD_DIGITS|F
  assert_eq(@typex.idcard_is_valid_tw_card("G123456780"), false) // TW_BAD_DIGITS|G
  assert_eq(@typex.idcard_is_valid_tw_card("G123456781"), false) // TW_BAD_DIGITS|G
  assert_eq(@typex.idcard_is_valid_tw_card("G123456782"), false) // TW_BAD_DIGITS|G
  assert_eq(@typex.idcard_is_valid_tw_card("G123456783"), false) // TW_BAD_DIGITS|G
  assert_eq(@typex.idcard_is_valid_tw_card("G123456784"), false) // TW_BAD_DIGITS|G
  assert_eq(@typex.idcard_is_valid_tw_card("G123456786"), false) // TW_BAD_DIGITS|G
  assert_eq(@typex.idcard_is_valid_tw_card("G123456787"), false) // TW_BAD_DIGITS|G
  assert_eq(@typex.idcard_is_valid_tw_card("G123456788"), false) // TW_BAD_DIGITS|G
  assert_eq(@typex.idcard_is_valid_tw_card("G123456789"), false) // TW_BAD_DIGITS|G
  assert_eq(@typex.idcard_is_valid_tw_card("H123456780"), false) // TW_BAD_DIGITS|H
  assert_eq(@typex.idcard_is_valid_tw_card("H123456781"), false) // TW_BAD_DIGITS|H
  assert_eq(@typex.idcard_is_valid_tw_card("H123456782"), false) // TW_BAD_DIGITS|H
  assert_eq(@typex.idcard_is_valid_tw_card("H123456783"), false) // TW_BAD_DIGITS|H
  assert_eq(@typex.idcard_is_valid_tw_card("H123456784"), false) // TW_BAD_DIGITS|H
  assert_eq(@typex.idcard_is_valid_tw_card("H123456785"), false) // TW_BAD_DIGITS|H
  assert_eq(@typex.idcard_is_valid_tw_card("H123456787"), false) // TW_BAD_DIGITS|H
  assert_eq(@typex.idcard_is_valid_tw_card("H123456788"), false) // TW_BAD_DIGITS|H
  assert_eq(@typex.idcard_is_valid_tw_card("H123456789"), false) // TW_BAD_DIGITS|H
  assert_eq(@typex.idcard_is_valid_tw_card("I123456780"), false) // TW_BAD_DIGITS|I
  assert_eq(@typex.idcard_is_valid_tw_card("I123456782"), false) // TW_BAD_DIGITS|I
  assert_eq(@typex.idcard_is_valid_tw_card("I123456783"), false) // TW_BAD_DIGITS|I
  assert_eq(@typex.idcard_is_valid_tw_card("I123456784"), false) // TW_BAD_DIGITS|I
  assert_eq(@typex.idcard_is_valid_tw_card("I123456785"), false) // TW_BAD_DIGITS|I
  assert_eq(@typex.idcard_is_valid_tw_card("I123456786"), false) // TW_BAD_DIGITS|I
  assert_eq(@typex.idcard_is_valid_tw_card("I123456787"), false) // TW_BAD_DIGITS|I
  assert_eq(@typex.idcard_is_valid_tw_card("I123456788"), false) // TW_BAD_DIGITS|I
  assert_eq(@typex.idcard_is_valid_tw_card("I123456789"), false) // TW_BAD_DIGITS|I
  assert_eq(@typex.idcard_is_valid_tw_card("J123456780"), false) // TW_BAD_DIGITS|J
  assert_eq(@typex.idcard_is_valid_tw_card("J123456781"), false) // TW_BAD_DIGITS|J
  assert_eq(@typex.idcard_is_valid_tw_card("J123456782"), false) // TW_BAD_DIGITS|J
  assert_eq(@typex.idcard_is_valid_tw_card("J123456783"), false) // TW_BAD_DIGITS|J
  assert_eq(@typex.idcard_is_valid_tw_card("J123456784"), false) // TW_BAD_DIGITS|J
  assert_eq(@typex.idcard_is_valid_tw_card("J123456785"), false) // TW_BAD_DIGITS|J
  assert_eq(@typex.idcard_is_valid_tw_card("J123456786"), false) // TW_BAD_DIGITS|J
  assert_eq(@typex.idcard_is_valid_tw_card("J123456788"), false) // TW_BAD_DIGITS|J
  assert_eq(@typex.idcard_is_valid_tw_card("J123456789"), false) // TW_BAD_DIGITS|J
  assert_eq(@typex.idcard_is_valid_tw_card("K123456780"), false) // TW_BAD_DIGITS|K
  assert_eq(@typex.idcard_is_valid_tw_card("K123456781"), false) // TW_BAD_DIGITS|K
  assert_eq(@typex.idcard_is_valid_tw_card("K123456782"), false) // TW_BAD_DIGITS|K
  assert_eq(@typex.idcard_is_valid_tw_card("K123456783"), false) // TW_BAD_DIGITS|K
  assert_eq(@typex.idcard_is_valid_tw_card("K123456784"), false) // TW_BAD_DIGITS|K
  assert_eq(@typex.idcard_is_valid_tw_card("K123456785"), false) // TW_BAD_DIGITS|K
  assert_eq(@typex.idcard_is_valid_tw_card("K123456786"), false) // TW_BAD_DIGITS|K
  assert_eq(@typex.idcard_is_valid_tw_card("K123456787"), false) // TW_BAD_DIGITS|K
  assert_eq(@typex.idcard_is_valid_tw_card("K123456789"), false) // TW_BAD_DIGITS|K
  assert_eq(@typex.idcard_is_valid_tw_card("L123456780"), false) // TW_BAD_DIGITS|L
  assert_eq(@typex.idcard_is_valid_tw_card("L123456781"), false) // TW_BAD_DIGITS|L
  assert_eq(@typex.idcard_is_valid_tw_card("L123456782"), false) // TW_BAD_DIGITS|L
  assert_eq(@typex.idcard_is_valid_tw_card("L123456783"), false) // TW_BAD_DIGITS|L
  assert_eq(@typex.idcard_is_valid_tw_card("L123456784"), false) // TW_BAD_DIGITS|L
  assert_eq(@typex.idcard_is_valid_tw_card("L123456785"), false) // TW_BAD_DIGITS|L
  assert_eq(@typex.idcard_is_valid_tw_card("L123456786"), false) // TW_BAD_DIGITS|L
  assert_eq(@typex.idcard_is_valid_tw_card("L123456787"), false) // TW_BAD_DIGITS|L
  assert_eq(@typex.idcard_is_valid_tw_card("L123456789"), false) // TW_BAD_DIGITS|L
  assert_eq(@typex.idcard_is_valid_tw_card("M123456780"), false) // TW_BAD_DIGITS|M
  assert_eq(@typex.idcard_is_valid_tw_card("M123456781"), false) // TW_BAD_DIGITS|M
  assert_eq(@typex.idcard_is_valid_tw_card("M123456782"), false) // TW_BAD_DIGITS|M
  assert_eq(@typex.idcard_is_valid_tw_card("M123456783"), false) // TW_BAD_DIGITS|M
  assert_eq(@typex.idcard_is_valid_tw_card("M123456784"), false) // TW_BAD_DIGITS|M
  assert_eq(@typex.idcard_is_valid_tw_card("M123456785"), false) // TW_BAD_DIGITS|M
  assert_eq(@typex.idcard_is_valid_tw_card("M123456786"), false) // TW_BAD_DIGITS|M
  assert_eq(@typex.idcard_is_valid_tw_card("M123456787"), false) // TW_BAD_DIGITS|M
  assert_eq(@typex.idcard_is_valid_tw_card("M123456788"), false) // TW_BAD_DIGITS|M
  assert_eq(@typex.idcard_is_valid_tw_card("N123456781"), false) // TW_BAD_DIGITS|N
  assert_eq(@typex.idcard_is_valid_tw_card("N123456782"), false) // TW_BAD_DIGITS|N
  assert_eq(@typex.idcard_is_valid_tw_card("N123456783"), false) // TW_BAD_DIGITS|N
  assert_eq(@typex.idcard_is_valid_tw_card("N123456784"), false) // TW_BAD_DIGITS|N
  assert_eq(@typex.idcard_is_valid_tw_card("N123456785"), false) // TW_BAD_DIGITS|N
  assert_eq(@typex.idcard_is_valid_tw_card("N123456786"), false) // TW_BAD_DIGITS|N
  assert_eq(@typex.idcard_is_valid_tw_card("N123456787"), false) // TW_BAD_DIGITS|N
  assert_eq(@typex.idcard_is_valid_tw_card("N123456788"), false) // TW_BAD_DIGITS|N
  assert_eq(@typex.idcard_is_valid_tw_card("N123456789"), false) // TW_BAD_DIGITS|N
  assert_eq(@typex.idcard_is_valid_tw_card("O123456780"), false) // TW_BAD_DIGITS|O
  assert_eq(@typex.idcard_is_valid_tw_card("O123456781"), false) // TW_BAD_DIGITS|O
  assert_eq(@typex.idcard_is_valid_tw_card("O123456783"), false) // TW_BAD_DIGITS|O
  assert_eq(@typex.idcard_is_valid_tw_card("O123456784"), false) // TW_BAD_DIGITS|O
  assert_eq(@typex.idcard_is_valid_tw_card("O123456785"), false) // TW_BAD_DIGITS|O
  assert_eq(@typex.idcard_is_valid_tw_card("O123456786"), false) // TW_BAD_DIGITS|O
  assert_eq(@typex.idcard_is_valid_tw_card("O123456787"), false) // TW_BAD_DIGITS|O
  assert_eq(@typex.idcard_is_valid_tw_card("O123456788"), false) // TW_BAD_DIGITS|O
  assert_eq(@typex.idcard_is_valid_tw_card("O123456789"), false) // TW_BAD_DIGITS|O
  assert_eq(@typex.idcard_is_valid_tw_card("P123456780"), false) // TW_BAD_DIGITS|P
  assert_eq(@typex.idcard_is_valid_tw_card("P123456782"), false) // TW_BAD_DIGITS|P
  assert_eq(@typex.idcard_is_valid_tw_card("P123456783"), false) // TW_BAD_DIGITS|P
  assert_eq(@typex.idcard_is_valid_tw_card("P123456784"), false) // TW_BAD_DIGITS|P
  assert_eq(@typex.idcard_is_valid_tw_card("P123456785"), false) // TW_BAD_DIGITS|P
  assert_eq(@typex.idcard_is_valid_tw_card("P123456786"), false) // TW_BAD_DIGITS|P
  assert_eq(@typex.idcard_is_valid_tw_card("P123456787"), false) // TW_BAD_DIGITS|P
  assert_eq(@typex.idcard_is_valid_tw_card("P123456788"), false) // TW_BAD_DIGITS|P
  assert_eq(@typex.idcard_is_valid_tw_card("P123456789"), false) // TW_BAD_DIGITS|P
  assert_eq(@typex.idcard_is_valid_tw_card("Q123456780"), false) // TW_BAD_DIGITS|Q
  assert_eq(@typex.idcard_is_valid_tw_card("Q123456781"), false) // TW_BAD_DIGITS|Q
  assert_eq(@typex.idcard_is_valid_tw_card("Q123456783"), false) // TW_BAD_DIGITS|Q
  assert_eq(@typex.idcard_is_valid_tw_card("Q123456784"), false) // TW_BAD_DIGITS|Q
  assert_eq(@typex.idcard_is_valid_tw_card("Q123456785"), false) // TW_BAD_DIGITS|Q
  assert_eq(@typex.idcard_is_valid_tw_card("Q123456786"), false) // TW_BAD_DIGITS|Q
  assert_eq(@typex.idcard_is_valid_tw_card("Q123456787"), false) // TW_BAD_DIGITS|Q
  assert_eq(@typex.idcard_is_valid_tw_card("Q123456788"), false) // TW_BAD_DIGITS|Q
  assert_eq(@typex.idcard_is_valid_tw_card("Q123456789"), false) // TW_BAD_DIGITS|Q
  assert_eq(@typex.idcard_is_valid_tw_card("R123456780"), false) // TW_BAD_DIGITS|R
  assert_eq(@typex.idcard_is_valid_tw_card("R123456781"), false) // TW_BAD_DIGITS|R
  assert_eq(@typex.idcard_is_valid_tw_card("R123456782"), false) // TW_BAD_DIGITS|R
  assert_eq(@typex.idcard_is_valid_tw_card("R123456784"), false) // TW_BAD_DIGITS|R
  assert_eq(@typex.idcard_is_valid_tw_card("R123456785"), false) // TW_BAD_DIGITS|R
  assert_eq(@typex.idcard_is_valid_tw_card("R123456786"), false) // TW_BAD_DIGITS|R
  assert_eq(@typex.idcard_is_valid_tw_card("R123456787"), false) // TW_BAD_DIGITS|R
  assert_eq(@typex.idcard_is_valid_tw_card("R123456788"), false) // TW_BAD_DIGITS|R
  assert_eq(@typex.idcard_is_valid_tw_card("R123456789"), false) // TW_BAD_DIGITS|R
  assert_eq(@typex.idcard_is_valid_tw_card("S123456780"), false) // TW_BAD_DIGITS|S
  assert_eq(@typex.idcard_is_valid_tw_card("S123456781"), false) // TW_BAD_DIGITS|S
  assert_eq(@typex.idcard_is_valid_tw_card("S123456782"), false) // TW_BAD_DIGITS|S
  assert_eq(@typex.idcard_is_valid_tw_card("S123456783"), false) // TW_BAD_DIGITS|S
  assert_eq(@typex.idcard_is_valid_tw_card("S123456785"), false) // TW_BAD_DIGITS|S
  assert_eq(@typex.idcard_is_valid_tw_card("S123456786"), false) // TW_BAD_DIGITS|S
  assert_eq(@typex.idcard_is_valid_tw_card("S123456787"), false) // TW_BAD_DIGITS|S
  assert_eq(@typex.idcard_is_valid_tw_card("S123456788"), false) // TW_BAD_DIGITS|S
  assert_eq(@typex.idcard_is_valid_tw_card("S123456789"), false) // TW_BAD_DIGITS|S
  assert_eq(@typex.idcard_is_valid_tw_card("T123456780"), false) // TW_BAD_DIGITS|T
  assert_eq(@typex.idcard_is_valid_tw_card("T123456781"), false) // TW_BAD_DIGITS|T
  assert_eq(@typex.idcard_is_valid_tw_card("T123456782"), false) // TW_BAD_DIGITS|T
  assert_eq(@typex.idcard_is_valid_tw_card("T123456783"), false) // TW_BAD_DIGITS|T
  assert_eq(@typex.idcard_is_valid_tw_card("T123456784"), false) // TW_BAD_DIGITS|T
  assert_eq(@typex.idcard_is_valid_tw_card("T123456786"), false) // TW_BAD_DIGITS|T
  assert_eq(@typex.idcard_is_valid_tw_card("T123456787"), false) // TW_BAD_DIGITS|T
  assert_eq(@typex.idcard_is_valid_tw_card("T123456788"), false) // TW_BAD_DIGITS|T
  assert_eq(@typex.idcard_is_valid_tw_card("T123456789"), false) // TW_BAD_DIGITS|T
  assert_eq(@typex.idcard_is_valid_tw_card("U123456780"), false) // TW_BAD_DIGITS|U
  assert_eq(@typex.idcard_is_valid_tw_card("U123456781"), false) // TW_BAD_DIGITS|U
  assert_eq(@typex.idcard_is_valid_tw_card("U123456782"), false) // TW_BAD_DIGITS|U
  assert_eq(@typex.idcard_is_valid_tw_card("U123456783"), false) // TW_BAD_DIGITS|U
  assert_eq(@typex.idcard_is_valid_tw_card("U123456784"), false) // TW_BAD_DIGITS|U
  assert_eq(@typex.idcard_is_valid_tw_card("U123456785"), false) // TW_BAD_DIGITS|U
  assert_eq(@typex.idcard_is_valid_tw_card("U123456787"), false) // TW_BAD_DIGITS|U
  assert_eq(@typex.idcard_is_valid_tw_card("U123456788"), false) // TW_BAD_DIGITS|U
  assert_eq(@typex.idcard_is_valid_tw_card("U123456789"), false) // TW_BAD_DIGITS|U
  assert_eq(@typex.idcard_is_valid_tw_card("V123456780"), false) // TW_BAD_DIGITS|V
  assert_eq(@typex.idcard_is_valid_tw_card("V123456781"), false) // TW_BAD_DIGITS|V
  assert_eq(@typex.idcard_is_valid_tw_card("V123456782"), false) // TW_BAD_DIGITS|V
  assert_eq(@typex.idcard_is_valid_tw_card("V123456783"), false) // TW_BAD_DIGITS|V
  assert_eq(@typex.idcard_is_valid_tw_card("V123456784"), false) // TW_BAD_DIGITS|V
  assert_eq(@typex.idcard_is_valid_tw_card("V123456785"), false) // TW_BAD_DIGITS|V
  assert_eq(@typex.idcard_is_valid_tw_card("V123456786"), false) // TW_BAD_DIGITS|V
  assert_eq(@typex.idcard_is_valid_tw_card("V123456788"), false) // TW_BAD_DIGITS|V
  assert_eq(@typex.idcard_is_valid_tw_card("V123456789"), false) // TW_BAD_DIGITS|V
  assert_eq(@typex.idcard_is_valid_tw_card("W123456780"), false) // TW_BAD_DIGITS|W
  assert_eq(@typex.idcard_is_valid_tw_card("W123456781"), false) // TW_BAD_DIGITS|W
  assert_eq(@typex.idcard_is_valid_tw_card("W123456782"), false) // TW_BAD_DIGITS|W
  assert_eq(@typex.idcard_is_valid_tw_card("W123456783"), false) // TW_BAD_DIGITS|W
  assert_eq(@typex.idcard_is_valid_tw_card("W123456784"), false) // TW_BAD_DIGITS|W
  assert_eq(@typex.idcard_is_valid_tw_card("W123456785"), false) // TW_BAD_DIGITS|W
  assert_eq(@typex.idcard_is_valid_tw_card("W123456786"), false) // TW_BAD_DIGITS|W
  assert_eq(@typex.idcard_is_valid_tw_card("W123456787"), false) // TW_BAD_DIGITS|W
  assert_eq(@typex.idcard_is_valid_tw_card("W123456788"), false) // TW_BAD_DIGITS|W
  assert_eq(@typex.idcard_is_valid_tw_card("X123456780"), false) // TW_BAD_DIGITS|X
  assert_eq(@typex.idcard_is_valid_tw_card("X123456781"), false) // TW_BAD_DIGITS|X
  assert_eq(@typex.idcard_is_valid_tw_card("X123456782"), false) // TW_BAD_DIGITS|X
  assert_eq(@typex.idcard_is_valid_tw_card("X123456783"), false) // TW_BAD_DIGITS|X
  assert_eq(@typex.idcard_is_valid_tw_card("X123456784"), false) // TW_BAD_DIGITS|X
  assert_eq(@typex.idcard_is_valid_tw_card("X123456785"), false) // TW_BAD_DIGITS|X
  assert_eq(@typex.idcard_is_valid_tw_card("X123456786"), false) // TW_BAD_DIGITS|X
  assert_eq(@typex.idcard_is_valid_tw_card("X123456788"), false) // TW_BAD_DIGITS|X
  assert_eq(@typex.idcard_is_valid_tw_card("X123456789"), false) // TW_BAD_DIGITS|X
  assert_eq(@typex.idcard_is_valid_tw_card("Y123456780"), false) // TW_BAD_DIGITS|Y
  assert_eq(@typex.idcard_is_valid_tw_card("Y123456781"), false) // TW_BAD_DIGITS|Y
  assert_eq(@typex.idcard_is_valid_tw_card("Y123456782"), false) // TW_BAD_DIGITS|Y
  assert_eq(@typex.idcard_is_valid_tw_card("Y123456783"), false) // TW_BAD_DIGITS|Y
  assert_eq(@typex.idcard_is_valid_tw_card("Y123456784"), false) // TW_BAD_DIGITS|Y
  assert_eq(@typex.idcard_is_valid_tw_card("Y123456785"), false) // TW_BAD_DIGITS|Y
  assert_eq(@typex.idcard_is_valid_tw_card("Y123456786"), false) // TW_BAD_DIGITS|Y
  assert_eq(@typex.idcard_is_valid_tw_card("Y123456787"), false) // TW_BAD_DIGITS|Y
  assert_eq(@typex.idcard_is_valid_tw_card("Y123456789"), false) // TW_BAD_DIGITS|Y
  assert_eq(@typex.idcard_is_valid_tw_card("Z123456781"), false) // TW_BAD_DIGITS|Z
  assert_eq(@typex.idcard_is_valid_tw_card("Z123456782"), false) // TW_BAD_DIGITS|Z
  assert_eq(@typex.idcard_is_valid_tw_card("Z123456783"), false) // TW_BAD_DIGITS|Z
  assert_eq(@typex.idcard_is_valid_tw_card("Z123456784"), false) // TW_BAD_DIGITS|Z
  assert_eq(@typex.idcard_is_valid_tw_card("Z123456785"), false) // TW_BAD_DIGITS|Z
  assert_eq(@typex.idcard_is_valid_tw_card("Z123456786"), false) // TW_BAD_DIGITS|Z
  assert_eq(@typex.idcard_is_valid_tw_card("Z123456787"), false) // TW_BAD_DIGITS|Z
  assert_eq(@typex.idcard_is_valid_tw_card("Z123456788"), false) // TW_BAD_DIGITS|Z
  assert_eq(@typex.idcard_is_valid_tw_card("Z123456789"), false) // TW_BAD_DIGITS|Z
}

///|
test "\u{53f0}\u{6e7e}\u{5341}\u{4f4d}\u{8fb9}\u{754c}\u{ff1a}\u{7a7a}\u{4e32}\u{3001}\u{957f}\u{5ea6} 9/11\u{3001}\u{5c0f}\u{5199}\u{5b57}\u{6bcd}\u{3001}\u{6570}\u{5b57}\u{5f00}\u{5934}\u{3001}\u{4e2d}\u{6bb5}\u{5939}\u{5b57}\u{6bcd}\u{3001}\u{6821}\u{9a8c}\u{4f4d}\u{9519}\u{4e00}\u{683c}" {
  assert_eq(@typex.idcard_is_valid_tw_card(""), false) // TW_EDGE_empty|
  assert_eq(@typex.idcard_is_valid_tw_card("A1234567"), false) // TW_EDGE_len9|A1234567
  assert_eq(@typex.idcard_is_valid_tw_card("A1234567890"), false) // TW_EDGE_len11|A1234567890
  assert_eq(@typex.idcard_is_valid_tw_card("a12345678"), false) // TW_EDGE_lower|a12345678
  assert_eq(@typex.idcard_is_valid_tw_card("112345678"), false) // TW_EDGE_digit1|112345678
  assert_eq(@typex.idcard_is_valid_tw_card("A1B345679"), false) // TW_EDGE_midLetter|A1B345679
  assert_eq(@typex.idcard_is_valid_tw_card("A123456780"), false) // TW_EDGE_badCheck|A123456780
  assert_eq(@typex.idcard_is_valid_tw_card("A123456789"), true) // TW_EDGE_ok|A123456789
}

///|
test "\u{9999}\u{6e2f}\u{5341}\u{4f4d}\u{ff1a}26 \u{679a}\u{9996}\u{5b57}\u{6bcd}\u{5404}\u{6709}\u{4e00}\u{679a}\u{901a}\u{8fc7}\u{7684}\u{6821}\u{9a8c}\u{4f4d}\u{ff08}\u{6821}\u{9a8c}\u{6863}\u{542b}\u{5b57}\u{7b26} A\u{ff0c}\u{817f}\u{91cc}\u{6709}\u{9996}\u{5b57}\u{6bcd}\u{53ea}\u{80fd}\u{9760} A \u{901a}\u{8fc7}\u{ff09}" {
  assert_eq(@typex.idcard_is_valid_hk_card("A1234563"), true) // HK_VALID_ONE|A
  assert_eq(@typex.idcard_is_valid_hk_card("B1234566"), true) // HK_VALID_ONE|B
  assert_eq(@typex.idcard_is_valid_hk_card("C1234569"), true) // HK_VALID_ONE|C
  assert_eq(@typex.idcard_is_valid_hk_card("D1234561"), true) // HK_VALID_ONE|D
  assert_eq(@typex.idcard_is_valid_hk_card("E1234564"), true) // HK_VALID_ONE|E
  assert_eq(@typex.idcard_is_valid_hk_card("F1234567"), true) // HK_VALID_ONE|F
  assert_eq(@typex.idcard_is_valid_hk_card("G123456A"), true) // HK_VALID_ONE|G
  assert_eq(@typex.idcard_is_valid_hk_card("H1234562"), true) // HK_VALID_ONE|H
  assert_eq(@typex.idcard_is_valid_hk_card("I1234565"), true) // HK_VALID_ONE|I
  assert_eq(@typex.idcard_is_valid_hk_card("J1234568"), true) // HK_VALID_ONE|J
  assert_eq(@typex.idcard_is_valid_hk_card("K1234560"), true) // HK_VALID_ONE|K
  assert_eq(@typex.idcard_is_valid_hk_card("L1234563"), true) // HK_VALID_ONE|L
  assert_eq(@typex.idcard_is_valid_hk_card("M1234566"), true) // HK_VALID_ONE|M
  assert_eq(@typex.idcard_is_valid_hk_card("N1234569"), true) // HK_VALID_ONE|N
  assert_eq(@typex.idcard_is_valid_hk_card("O1234561"), true) // HK_VALID_ONE|O
  assert_eq(@typex.idcard_is_valid_hk_card("P1234564"), true) // HK_VALID_ONE|P
  assert_eq(@typex.idcard_is_valid_hk_card("Q1234567"), true) // HK_VALID_ONE|Q
  assert_eq(@typex.idcard_is_valid_hk_card("R123456A"), true) // HK_VALID_ONE|R
  assert_eq(@typex.idcard_is_valid_hk_card("S1234562"), true) // HK_VALID_ONE|S
  assert_eq(@typex.idcard_is_valid_hk_card("T1234565"), true) // HK_VALID_ONE|T
  assert_eq(@typex.idcard_is_valid_hk_card("U1234568"), true) // HK_VALID_ONE|U
  assert_eq(@typex.idcard_is_valid_hk_card("V1234560"), true) // HK_VALID_ONE|V
  assert_eq(@typex.idcard_is_valid_hk_card("W1234563"), true) // HK_VALID_ONE|W
  assert_eq(@typex.idcard_is_valid_hk_card("X1234566"), true) // HK_VALID_ONE|X
  assert_eq(@typex.idcard_is_valid_hk_card("Y1234569"), true) // HK_VALID_ONE|Y
  assert_eq(@typex.idcard_is_valid_hk_card("Z1234561"), true) // HK_VALID_ONE|Z
}

///|
test "\u{9999}\u{6e2f}\u{5341}\u{4f4d}\u{8fb9}\u{754c}\u{ff1a}\u{5355}\u{53cc}\u{5b57}\u{6bcd}\u{3001}\u{62ec}\u{53f7}\u{7684}\u{4e09}\u{79cd}\u{6302}\u{6cd5}\u{3001}\u{5c0f}\u{5199}\u{3001}\u{4e09}\u{5b57}\u{6bcd}\u{3001}\u{4e94}\u{4f4d}\u{6570}\u{5b57}\u{3001}\u{6821}\u{9a8c}\u{4f4d} Z\u{3001}\u{7a7a}\u{4e32}" {
  assert_eq(@typex.idcard_is_valid_hk_card("A1234563"), true) // HK_EDGE_ok|A1234563
  assert_eq(@typex.idcard_is_valid_hk_card("AB1234569"), true) // HK_EDGE_two_ok|AB1234569
  assert_eq(@typex.idcard_is_valid_hk_card("A123456(3)"), true) // HK_EDGE_paren|A123456(3)
  assert_eq(@typex.idcard_is_valid_hk_card("A1234563)"), true) // HK_EDGE_paren_only_right|A1234563)
  assert_eq(@typex.idcard_is_valid_hk_card("A123456(3"), true) // HK_EDGE_paren_only_left|A123456(3
  assert_eq(@typex.idcard_is_valid_hk_card("a1234563"), false) // HK_EDGE_lower|a1234563
  assert_eq(@typex.idcard_is_valid_hk_card("ABC123453"), false) // HK_EDGE_three_letters|ABC123453
  assert_eq(@typex.idcard_is_valid_hk_card("A123453"), false) // HK_EDGE_5digits|A123453
  assert_eq(@typex.idcard_is_valid_hk_card("A123456Z"), false) // HK_EDGE_badCheck|A123456Z
  assert_eq(@typex.idcard_is_valid_hk_card(""), false) // HK_EDGE_empty|
}

///|
test "\u{603b}\u{6d3e}\u{53d1}\u{ff1a}\u{6309}\u{957f}\u{5ea6} 18/15/10 \u{5206}\u{6863}\u{ff0c}\u{5176}\u{4f59}\u{957f}\u{5ea6}\u{4e0e}\u{7a7a}\u{767d}\u{4e00}\u{5f8b}\u{5047}\u{ff1b}\u{5341}\u{4f4d}\u{6863}\u{53ea}\u{8ba4}\u{6ee1}\u{5341}\u{4e2a}\u{5b57}\u{7b26}\u{7684}" {
  assert_eq(@typex.idcard_is_valid_card("", 2026), false) // CARD|
  assert_eq(@typex.idcard_is_valid_card("   ", 2026), false) // CARD|   
  assert_eq(@typex.idcard_is_valid_card("12345678901234567", 2026), false) // CARD|12345678901234567
  assert_eq(@typex.idcard_is_valid_card("1234567890123456789", 2026), false) // CARD|1234567890123456789
  assert_eq(@typex.idcard_is_valid_card("12345678901", 2026), false) // CARD|12345678901
  assert_eq(@typex.idcard_is_valid_card("11010519491231002X", 2026), true) // CARD|11010519491231002X
  assert_eq(@typex.idcard_is_valid_card("11010519491231002Y", 2026), false) // CARD|11010519491231002Y
  assert_eq(@typex.idcard_is_valid_card("110105491231002", 2026), true) // CARD|110105491231002
  assert_eq(@typex.idcard_is_valid_card("A123456789", 2026), true) // CARD|A123456789
  assert_eq(@typex.idcard_is_valid_card("A123456780", 2026), false) // CARD|A123456780
  assert_eq(@typex.idcard_is_valid_card("A1234563", 2026), false) // CARD|A1234563
  assert_eq(@typex.idcard_is_valid_card("A123456Z", 2026), false) // CARD|A123456Z
  assert_eq(@typex.idcard_is_valid_card("1123456789", 2026), false) // CARD|1123456789
  assert_eq(@typex.idcard_is_valid_card("5123456(7)", 2026), true) // CARD|5123456(7)
  assert_eq(@typex.idcard_is_valid_card("7123456(9)", 2026), true) // CARD|7123456(9)
  assert_eq(@typex.idcard_is_valid_card("a123456789", 2026), false) // CARD|a123456789
  assert_eq(@typex.idcard_is_valid_card("M12345678", 2026), false) // CARD|M12345678
  assert_eq(@typex.idcard_is_valid_card("A12345678", 2026), false) // CARD|A12345678
  assert_eq(@typex.idcard_is_valid_card("112345678", 2026), false) // CARD|112345678
}
