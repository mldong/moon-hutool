///|
// moon-hutool/date 内置时区表契约用例（黑盒）。**生成件，勿手改**：
// 生成器 scripts/gen_zone_table.py，每条期望都是参照腿 scripts/TzLeg.java 的机器读数。
// 参照代次：JDK 17.0.14 · lib/tzdb.dat 101731 bytes · 窗口 [1970-01-01, 2050-01-01)。
// 夹具构造子 `d` / `dt` 复用 date/date_test.mbt 的同名 helper（同包测试共享顶层命名空间）。
// 本包 DateTime 没有 Debug 实例（assert_eq 要它就把整个类型架上去），⇒ 判等一律两侧过 ztag。

///|
fn ztag(o : @date.DateTime?) -> String {
  match o {
    None => "null"
    Some(v) => v.to_iso_string()
  }
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 1/19 块，本块 200 条）" {
  assert_eq(@date.zone_offset_minutes("Africa/Abidjan", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Abidjan", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Abidjan", 961070400000L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Africa/Abidjan", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Abidjan", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Abidjan", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Accra", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Accra", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Accra", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Accra", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Accra", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Accra", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Addis_Ababa", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Africa/Addis_Ababa", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Addis_Ababa", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Addis_Ababa", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Addis_Ababa", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Addis_Ababa", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Algiers", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Africa/Algiers", 515556000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Algiers", 961070400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Algiers", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Algiers", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Algiers", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Asmara", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Africa/Asmara", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Asmara", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Asmara", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Asmara", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Asmara", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Asmera", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Africa/Asmera", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Asmera", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Asmera", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Asmera", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Asmera", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Bamako", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Bamako", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Bamako", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Bamako", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Bamako", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Bamako", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Bangui", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Bangui", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Bangui", 961070400000L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Africa/Bangui", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Bangui", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Bangui", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Banjul", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Banjul", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Banjul", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Banjul", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Banjul", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Banjul", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Bissau", 0L), Some(-60))
  assert_eq(@date.zone_offset_minutes("Africa/Bissau", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Bissau", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Bissau", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Bissau", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Bissau", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Blantyre", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Blantyre", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Blantyre", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Blantyre", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Blantyre", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Blantyre", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Brazzaville", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Africa/Brazzaville", 515556000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Brazzaville", 961070400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Brazzaville", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Brazzaville", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Brazzaville", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Bujumbura", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Bujumbura", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Bujumbura", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Bujumbura", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Bujumbura", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Bujumbura", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 0L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 515556000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 961070400000L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Casablanca", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 515556000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 961070400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Ceuta", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Ceuta", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Ceuta", 961070400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Ceuta", 1710052200000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Ceuta", 1730613600000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Ceuta", 2145916799000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Conakry", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Conakry", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Conakry", 961070400000L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Africa/Conakry", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Conakry", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Conakry", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Dakar", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Dakar", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Dakar", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Dakar", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Dakar", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Dakar", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Dar_es_Salaam", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Africa/Dar_es_Salaam", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Dar_es_Salaam", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Dar_es_Salaam", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Dar_es_Salaam", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Dar_es_Salaam", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Djibouti", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Africa/Djibouti", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Djibouti", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Djibouti", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Djibouti", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Djibouti", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Douala", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Douala", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Douala", 961070400000L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Africa/Douala", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Douala", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Douala", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Africa/El_Aaiun", 0L), Some(-60))
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 515556000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 961070400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Freetown", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Africa/Freetown", 515556000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Freetown", 961070400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Freetown", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Freetown", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Freetown", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Gaborone", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Gaborone", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Gaborone", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Gaborone", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Gaborone", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Gaborone", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Harare", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Harare", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Harare", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Harare", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Harare", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Harare", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Johannesburg", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Johannesburg", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Johannesburg", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Johannesburg", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Johannesburg", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Johannesburg", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Juba", 0L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Juba", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Juba", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Juba", 1710052200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Juba", 1730613600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Juba", 2145916799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Kampala", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Africa/Kampala", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Kampala", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Kampala", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Kampala", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Kampala", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Khartoum", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Khartoum", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Khartoum", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Khartoum", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Khartoum", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Khartoum", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Kigali", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Kigali", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Kigali", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Kigali", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Kigali", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Kigali", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Kinshasa", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Africa/Kinshasa", 515556000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Kinshasa", 961070400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Kinshasa", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Kinshasa", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Kinshasa", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Lagos", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Lagos", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Lagos", 961070400000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Lagos", 1710052200000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Lagos", 1730613600000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Lagos", 2145916799000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Libreville", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Africa/Libreville", 515556000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Libreville", 961070400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Libreville", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Libreville", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Libreville", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Lome", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Lome", 515556000000L), Some(0))
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 2/19 块，本块 200 条）" {
  assert_eq(@date.zone_offset_minutes("Africa/Lome", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Lome", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Lome", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Lome", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Africa/Luanda", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Luanda", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Luanda", 961070400000L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Africa/Luanda", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Luanda", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Luanda", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Lubumbashi", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Lubumbashi", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Lubumbashi", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Lubumbashi", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Lubumbashi", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Lubumbashi", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Lusaka", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Lusaka", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Lusaka", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Lusaka", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Lusaka", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Lusaka", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Malabo", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Malabo", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Malabo", 961070400000L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Africa/Malabo", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Malabo", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Malabo", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Maputo", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Maputo", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Maputo", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Maputo", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Maputo", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Maputo", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Maseru", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Maseru", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Maseru", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Maseru", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Maseru", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Maseru", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Mbabane", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Mbabane", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Mbabane", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Mbabane", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Mbabane", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Mbabane", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Mogadishu", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Africa/Mogadishu", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Mogadishu", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Mogadishu", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Mogadishu", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Mogadishu", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Monrovia", 0L), Some(-44))
  assert_eq(
    @date.zone_offset_minutes("Africa/Monrovia", 515556000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Monrovia", 961070400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Monrovia", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Monrovia", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Monrovia", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Nairobi", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Africa/Nairobi", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Nairobi", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Nairobi", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Nairobi", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Nairobi", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Ndjamena", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Africa/Ndjamena", 515556000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Ndjamena", 961070400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Ndjamena", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Ndjamena", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Ndjamena", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Niamey", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Niamey", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Niamey", 961070400000L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Africa/Niamey", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Niamey", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Niamey", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Nouakchott", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Africa/Nouakchott", 515556000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Nouakchott", 961070400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Nouakchott", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Nouakchott", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Nouakchott", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Ouagadougou", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Africa/Ouagadougou", 515556000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Ouagadougou", 961070400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Ouagadougou", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Ouagadougou", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Ouagadougou", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Porto-Novo", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Africa/Porto-Novo", 515556000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Porto-Novo", 961070400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Porto-Novo", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Porto-Novo", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Porto-Novo", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Sao_Tome", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Africa/Sao_Tome", 515556000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Sao_Tome", 961070400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Sao_Tome", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Sao_Tome", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Sao_Tome", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Timbuktu", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Africa/Timbuktu", 515556000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Timbuktu", 961070400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Timbuktu", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Timbuktu", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Timbuktu", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Tripoli", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Tripoli", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Tripoli", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Tripoli", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Tripoli", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Tripoli", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Tunis", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Tunis", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Tunis", 961070400000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Tunis", 1710052200000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Tunis", 1730613600000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Tunis", 2145916799000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Africa/Windhoek", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Windhoek", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Windhoek", 961070400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Windhoek", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Windhoek", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Windhoek", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("America/Adak", 0L), Some(-660))
  assert_eq(
    @date.zone_offset_minutes("America/Adak", 515556000000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Adak", 961070400000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Adak", 1710052200000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Adak", 1730613600000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Adak", 2145916799000L),
    Some(-600),
  )
  assert_eq(@date.zone_offset_minutes("America/Anchorage", 0L), Some(-600))
  assert_eq(
    @date.zone_offset_minutes("America/Anchorage", 515556000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Anchorage", 961070400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Anchorage", 1710052200000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Anchorage", 1730613600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Anchorage", 2145916799000L),
    Some(-540),
  )
  assert_eq(@date.zone_offset_minutes("America/Anguilla", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Anguilla", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Anguilla", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Anguilla", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Anguilla", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Anguilla", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Antigua", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Antigua", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Antigua", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Antigua", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Antigua", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Antigua", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Araguaina", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Araguaina", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Araguaina", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Araguaina", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Araguaina", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Araguaina", 2145916799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Buenos_Aires", 0L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Buenos_Aires", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Buenos_Aires", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Buenos_Aires", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Buenos_Aires", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Buenos_Aires", 2145916799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Catamarca", 0L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Catamarca", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Catamarca", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Catamarca", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Catamarca", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Catamarca", 2145916799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/ComodRivadavia", 0L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/ComodRivadavia", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/ComodRivadavia", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes(
      "America/Argentina/ComodRivadavia", 1710052200000L,
    ),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes(
      "America/Argentina/ComodRivadavia", 1730613600000L,
    ),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes(
      "America/Argentina/ComodRivadavia", 2145916799000L,
    ),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Cordoba", 0L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Cordoba", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Cordoba", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Cordoba", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Cordoba", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Cordoba", 2145916799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Jujuy", 0L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Jujuy", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Jujuy", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Jujuy", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Jujuy", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Jujuy", 2145916799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/La_Rioja", 0L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/La_Rioja", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/La_Rioja", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/La_Rioja", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/La_Rioja", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/La_Rioja", 2145916799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Mendoza", 0L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Mendoza", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Mendoza", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Mendoza", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Mendoza", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Mendoza", 2145916799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Rio_Gallegos", 0L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Rio_Gallegos", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Rio_Gallegos", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Rio_Gallegos", 1710052200000L),
    Some(-180),
  )
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 3/19 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Rio_Gallegos", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Rio_Gallegos", 2145916799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Salta", 0L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Salta", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Salta", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Salta", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Salta", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Salta", 2145916799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/San_Juan", 0L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/San_Juan", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/San_Juan", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/San_Juan", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/San_Juan", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/San_Juan", 2145916799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/San_Luis", 0L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/San_Luis", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/San_Luis", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/San_Luis", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/San_Luis", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/San_Luis", 2145916799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Tucuman", 0L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Tucuman", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Tucuman", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Tucuman", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Tucuman", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Tucuman", 2145916799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Ushuaia", 0L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Ushuaia", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Ushuaia", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Ushuaia", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Ushuaia", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Argentina/Ushuaia", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Aruba", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Aruba", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Aruba", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Aruba", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Aruba", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Aruba", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Asuncion", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Asuncion", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Asuncion", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Asuncion", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Asuncion", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Asuncion", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Atikokan", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Atikokan", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Atikokan", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Atikokan", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Atikokan", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Atikokan", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Atka", 0L), Some(-660))
  assert_eq(
    @date.zone_offset_minutes("America/Atka", 515556000000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Atka", 961070400000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Atka", 1710052200000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Atka", 1730613600000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Atka", 2145916799000L),
    Some(-600),
  )
  assert_eq(@date.zone_offset_minutes("America/Bahia", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Bahia", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Bahia", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Bahia", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Bahia", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Bahia", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Bahia_Banderas", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("America/Bahia_Banderas", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Bahia_Banderas", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Bahia_Banderas", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Bahia_Banderas", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Bahia_Banderas", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Barbados", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Barbados", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Barbados", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Barbados", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Barbados", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Barbados", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Belem", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Belem", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Belem", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Belem", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Belem", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Belem", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Belize", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Belize", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Belize", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Belize", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Belize", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Belize", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Blanc-Sablon", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Blanc-Sablon", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Blanc-Sablon", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Blanc-Sablon", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Blanc-Sablon", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Blanc-Sablon", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Boa_Vista", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Boa_Vista", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boa_Vista", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boa_Vista", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boa_Vista", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boa_Vista", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Bogota", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Bogota", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Bogota", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Bogota", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Bogota", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Bogota", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Boise", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("America/Buenos_Aires", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Buenos_Aires", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Buenos_Aires", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Buenos_Aires", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Buenos_Aires", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Buenos_Aires", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Cambridge_Bay", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("America/Cambridge_Bay", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cambridge_Bay", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cambridge_Bay", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cambridge_Bay", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cambridge_Bay", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("America/Campo_Grande", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Campo_Grande", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Campo_Grande", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Campo_Grande", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Campo_Grande", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Campo_Grande", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Cancun", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Cancun", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cancun", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cancun", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cancun", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cancun", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Caracas", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Caracas", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Caracas", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Caracas", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Caracas", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Caracas", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Catamarca", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Catamarca", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Catamarca", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Catamarca", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Catamarca", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Catamarca", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Cayenne", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Cayenne", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cayenne", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cayenne", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cayenne", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cayenne", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Cayman", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Cayman", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cayman", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cayman", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cayman", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cayman", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Chicago", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Chihuahua", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Chihuahua", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chihuahua", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chihuahua", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chihuahua", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chihuahua", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Ciudad_Juarez", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Ciudad_Juarez", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Ciudad_Juarez", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Ciudad_Juarez", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Ciudad_Juarez", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Ciudad_Juarez", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("America/Coral_Harbour", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Coral_Harbour", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Coral_Harbour", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Coral_Harbour", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Coral_Harbour", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Coral_Harbour", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Cordoba", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Cordoba", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cordoba", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cordoba", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cordoba", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cordoba", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Costa_Rica", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Costa_Rica", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Costa_Rica", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Costa_Rica", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Costa_Rica", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Costa_Rica", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Creston", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("America/Creston", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Creston", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Creston", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Creston", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Creston", 2145916799000L),
    Some(-420),
  )
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 4/19 块，本块 200 条）" {
  assert_eq(@date.zone_offset_minutes("America/Cuiaba", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Cuiaba", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cuiaba", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cuiaba", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cuiaba", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Cuiaba", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Curacao", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Curacao", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Curacao", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Curacao", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Curacao", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Curacao", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Danmarkshavn", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Danmarkshavn", 515556000000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Danmarkshavn", 961070400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Danmarkshavn", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Danmarkshavn", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Danmarkshavn", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("America/Dawson", 0L), Some(-540))
  assert_eq(
    @date.zone_offset_minutes("America/Dawson", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Dawson", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Dawson", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Dawson", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Dawson", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("America/Dawson_Creek", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("America/Dawson_Creek", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Dawson_Creek", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Dawson_Creek", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Dawson_Creek", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Dawson_Creek", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("America/Denver", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("America/Detroit", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Detroit", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Detroit", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Detroit", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Detroit", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Detroit", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Dominica", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Dominica", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Dominica", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Dominica", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Dominica", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Dominica", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Edmonton", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("America/Edmonton", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Edmonton", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Edmonton", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Edmonton", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Edmonton", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("America/Eirunepe", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Eirunepe", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Eirunepe", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Eirunepe", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Eirunepe", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Eirunepe", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/El_Salvador", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/El_Salvador", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/El_Salvador", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/El_Salvador", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/El_Salvador", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/El_Salvador", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Ensenada", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("America/Ensenada", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Ensenada", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Ensenada", 1710052200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Ensenada", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Ensenada", 2145916799000L),
    Some(-480),
  )
  assert_eq(@date.zone_offset_minutes("America/Fort_Nelson", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("America/Fort_Nelson", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Fort_Nelson", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Fort_Nelson", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Fort_Nelson", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Fort_Nelson", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("America/Fort_Wayne", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Fort_Wayne", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Fort_Wayne", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Fort_Wayne", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Fort_Wayne", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Fort_Wayne", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Fortaleza", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Fortaleza", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Fortaleza", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Fortaleza", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Fortaleza", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Fortaleza", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Glace_Bay", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Glace_Bay", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Glace_Bay", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Glace_Bay", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Glace_Bay", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Glace_Bay", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Godthab", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Godthab", 515556000000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Godthab", 961070400000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Godthab", 1710052200000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Godthab", 1730613600000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Godthab", 2145916799000L),
    Some(-120),
  )
  assert_eq(@date.zone_offset_minutes("America/Goose_Bay", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Grand_Turk", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Grand_Turk", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Grand_Turk", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Grand_Turk", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Grand_Turk", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Grand_Turk", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Grenada", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Grenada", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Grenada", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Grenada", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Grenada", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Grenada", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Guadeloupe", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Guadeloupe", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guadeloupe", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guadeloupe", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guadeloupe", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guadeloupe", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Guatemala", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Guatemala", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guatemala", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guatemala", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guatemala", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guatemala", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Guayaquil", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Guayaquil", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guayaquil", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guayaquil", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guayaquil", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guayaquil", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Guyana", 0L), Some(-225))
  assert_eq(
    @date.zone_offset_minutes("America/Guyana", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guyana", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guyana", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guyana", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Guyana", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Halifax", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Havana", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Havana", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Havana", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Havana", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Havana", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Havana", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Hermosillo", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("America/Hermosillo", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Hermosillo", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Hermosillo", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Hermosillo", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Hermosillo", 2145916799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Indianapolis", 0L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Indianapolis", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Indianapolis", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Indianapolis", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Indianapolis", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Indianapolis", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Indiana/Knox", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Knox", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Knox", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Knox", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Knox", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Knox", 2145916799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Marengo", 0L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Marengo", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Marengo", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Marengo", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Marengo", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Marengo", 2145916799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Petersburg", 0L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Petersburg", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Petersburg", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Petersburg", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Petersburg", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Petersburg", 2145916799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Tell_City", 0L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Tell_City", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Tell_City", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Tell_City", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Tell_City", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Tell_City", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Indiana/Vevay", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Vevay", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Vevay", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Vevay", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Vevay", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Vevay", 2145916799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Vincennes", 0L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Vincennes", 515556000000L),
    Some(-300),
  )
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 5/19 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Vincennes", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Vincennes", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Vincennes", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Vincennes", 2145916799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Winamac", 0L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Winamac", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Winamac", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Winamac", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Winamac", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indiana/Winamac", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Indianapolis", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Indianapolis", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indianapolis", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indianapolis", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indianapolis", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Indianapolis", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Inuvik", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("America/Inuvik", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Inuvik", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Inuvik", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Inuvik", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Inuvik", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("America/Iqaluit", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Iqaluit", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Iqaluit", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Iqaluit", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Iqaluit", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Iqaluit", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Jamaica", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Jamaica", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Jamaica", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Jamaica", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Jamaica", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Jamaica", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Jujuy", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Jujuy", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Jujuy", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Jujuy", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Jujuy", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Jujuy", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Juneau", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("America/Juneau", 515556000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Juneau", 961070400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Juneau", 1710052200000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Juneau", 1730613600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Juneau", 2145916799000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kentucky/Louisville", 0L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kentucky/Louisville", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kentucky/Louisville", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kentucky/Louisville", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kentucky/Louisville", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kentucky/Louisville", 2145916799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kentucky/Monticello", 0L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kentucky/Monticello", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kentucky/Monticello", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kentucky/Monticello", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kentucky/Monticello", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kentucky/Monticello", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Knox_IN", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Knox_IN", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Knox_IN", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Knox_IN", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Knox_IN", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Knox_IN", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Kralendijk", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Kralendijk", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kralendijk", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kralendijk", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kralendijk", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Kralendijk", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/La_Paz", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/La_Paz", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/La_Paz", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/La_Paz", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/La_Paz", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/La_Paz", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Lima", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Lima", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Lima", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Lima", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Lima", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Lima", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Los_Angeles", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1710052200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2145916799000L),
    Some(-480),
  )
  assert_eq(@date.zone_offset_minutes("America/Louisville", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Louisville", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Louisville", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Louisville", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Louisville", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Louisville", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Lower_Princes", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Lower_Princes", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Lower_Princes", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Lower_Princes", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Lower_Princes", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Lower_Princes", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Maceio", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Maceio", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Maceio", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Maceio", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Maceio", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Maceio", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Managua", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Managua", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Managua", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Managua", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Managua", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Managua", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Manaus", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Manaus", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Manaus", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Manaus", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Manaus", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Manaus", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Marigot", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Marigot", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Marigot", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Marigot", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Marigot", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Marigot", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Martinique", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Martinique", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Martinique", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Martinique", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Martinique", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Martinique", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Matamoros", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Matamoros", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Matamoros", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Matamoros", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Matamoros", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Matamoros", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Mazatlan", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("America/Mazatlan", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Mazatlan", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Mazatlan", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Mazatlan", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Mazatlan", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("America/Mendoza", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Mendoza", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Mendoza", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Mendoza", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Mendoza", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Mendoza", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Menominee", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Menominee", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Menominee", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Menominee", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Menominee", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Menominee", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Merida", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Merida", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Merida", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Merida", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Merida", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Merida", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Metlakatla", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("America/Metlakatla", 515556000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Metlakatla", 961070400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Metlakatla", 1710052200000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Metlakatla", 1730613600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Metlakatla", 2145916799000L),
    Some(-540),
  )
  assert_eq(@date.zone_offset_minutes("America/Mexico_City", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Mexico_City", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Mexico_City", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Mexico_City", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Mexico_City", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Mexico_City", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Miquelon", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Miquelon", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Miquelon", 961070400000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Miquelon", 1710052200000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Miquelon", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Miquelon", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Moncton", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Moncton", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Moncton", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Moncton", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Moncton", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Moncton", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Monterrey", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Monterrey", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Monterrey", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Monterrey", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Monterrey", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Monterrey", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Montevideo", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Montevideo", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montevideo", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montevideo", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montevideo", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montevideo", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Montreal", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1710052200000L),
    Some(-300),
  )
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 6/19 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Montserrat", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Montserrat", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montserrat", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montserrat", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montserrat", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montserrat", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Nassau", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/New_York", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Nipigon", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Nome", 0L), Some(-660))
  assert_eq(
    @date.zone_offset_minutes("America/Nome", 515556000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nome", 961070400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nome", 1710052200000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nome", 1730613600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nome", 2145916799000L),
    Some(-540),
  )
  assert_eq(@date.zone_offset_minutes("America/Noronha", 0L), Some(-120))
  assert_eq(
    @date.zone_offset_minutes("America/Noronha", 515556000000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Noronha", 961070400000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Noronha", 1710052200000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Noronha", 1730613600000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Noronha", 2145916799000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/Beulah", 0L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/Beulah", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/Beulah", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/Beulah", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/Beulah", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/Beulah", 2145916799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/Center", 0L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/Center", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/Center", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/Center", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/Center", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/Center", 2145916799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/New_Salem", 0L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/New_Salem", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/New_Salem", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/New_Salem", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/New_Salem", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/North_Dakota/New_Salem", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Nuuk", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Nuuk", 515556000000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nuuk", 961070400000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nuuk", 1710052200000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nuuk", 1730613600000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nuuk", 2145916799000L),
    Some(-120),
  )
  assert_eq(@date.zone_offset_minutes("America/Ojinaga", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Ojinaga", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Ojinaga", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Ojinaga", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Ojinaga", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Ojinaga", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Panama", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Panama", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Panama", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Panama", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Panama", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Panama", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Pangnirtung", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Pangnirtung", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Pangnirtung", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Pangnirtung", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Pangnirtung", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Pangnirtung", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Paramaribo", 0L), Some(-210))
  assert_eq(
    @date.zone_offset_minutes("America/Paramaribo", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Paramaribo", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Paramaribo", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Paramaribo", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Paramaribo", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Phoenix", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("America/Phoenix", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Phoenix", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Phoenix", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Phoenix", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Phoenix", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("America/Port-au-Prince", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Port-au-Prince", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Port-au-Prince", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Port-au-Prince", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Port-au-Prince", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Port-au-Prince", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Port_of_Spain", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Port_of_Spain", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Port_of_Spain", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Port_of_Spain", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Port_of_Spain", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Port_of_Spain", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Porto_Acre", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Porto_Acre", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Porto_Acre", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Porto_Acre", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Porto_Acre", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Porto_Acre", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Porto_Velho", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Porto_Velho", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Porto_Velho", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Porto_Velho", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Porto_Velho", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Porto_Velho", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Puerto_Rico", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Puerto_Rico", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Puerto_Rico", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Puerto_Rico", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Puerto_Rico", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Puerto_Rico", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Punta_Arenas", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Punta_Arenas", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Punta_Arenas", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Punta_Arenas", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Punta_Arenas", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Punta_Arenas", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Rainy_River", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Rainy_River", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rainy_River", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rainy_River", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rainy_River", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rainy_River", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Rankin_Inlet", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Rankin_Inlet", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rankin_Inlet", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rankin_Inlet", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rankin_Inlet", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rankin_Inlet", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Recife", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Recife", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Recife", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Recife", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Recife", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Recife", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Regina", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Regina", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Regina", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Regina", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Regina", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Regina", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Resolute", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Resolute", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Resolute", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Resolute", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Resolute", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Resolute", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Rio_Branco", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Rio_Branco", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rio_Branco", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rio_Branco", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rio_Branco", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rio_Branco", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Rosario", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Rosario", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rosario", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rosario", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rosario", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Rosario", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Santa_Isabel", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("America/Santa_Isabel", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santa_Isabel", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santa_Isabel", 1710052200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santa_Isabel", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santa_Isabel", 2145916799000L),
    Some(-480),
  )
  assert_eq(@date.zone_offset_minutes("America/Santarem", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Santarem", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santarem", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santarem", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santarem", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santarem", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Santiago", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("America/Santo_Domingo", 0L), Some(-270))
  assert_eq(
    @date.zone_offset_minutes("America/Santo_Domingo", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santo_Domingo", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santo_Domingo", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santo_Domingo", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santo_Domingo", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Sao_Paulo", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("America/Sao_Paulo", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Sao_Paulo", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Sao_Paulo", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Sao_Paulo", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Sao_Paulo", 2145916799000L),
    Some(-180),
  )
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 7/19 块，本块 200 条）" {
  assert_eq(@date.zone_offset_minutes("America/Scoresbysund", 0L), Some(-120))
  assert_eq(
    @date.zone_offset_minutes("America/Scoresbysund", 515556000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Scoresbysund", 961070400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Scoresbysund", 1710052200000L),
    Some(-60),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Scoresbysund", 1730613600000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Scoresbysund", 2145916799000L),
    Some(-120),
  )
  assert_eq(@date.zone_offset_minutes("America/Shiprock", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("America/Shiprock", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Shiprock", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Shiprock", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Shiprock", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Shiprock", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("America/Sitka", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("America/Sitka", 515556000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Sitka", 961070400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Sitka", 1710052200000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Sitka", 1730613600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Sitka", 2145916799000L),
    Some(-540),
  )
  assert_eq(@date.zone_offset_minutes("America/St_Barthelemy", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/St_Barthelemy", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Barthelemy", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Barthelemy", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Barthelemy", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Barthelemy", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/St_Johns", 0L), Some(-210))
  assert_eq(
    @date.zone_offset_minutes("America/St_Johns", 515556000000L),
    Some(-150),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Johns", 961070400000L),
    Some(-150),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Johns", 1710052200000L),
    Some(-150),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Johns", 1730613600000L),
    Some(-210),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Johns", 2145916799000L),
    Some(-210),
  )
  assert_eq(@date.zone_offset_minutes("America/St_Kitts", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/St_Kitts", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Kitts", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Kitts", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Kitts", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Kitts", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/St_Lucia", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/St_Lucia", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Lucia", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Lucia", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Lucia", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Lucia", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/St_Thomas", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/St_Thomas", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Thomas", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Thomas", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Thomas", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Thomas", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/St_Vincent", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/St_Vincent", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Vincent", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Vincent", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Vincent", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/St_Vincent", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Swift_Current", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("America/Swift_Current", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Swift_Current", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Swift_Current", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Swift_Current", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Swift_Current", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Tegucigalpa", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Tegucigalpa", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Tegucigalpa", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Tegucigalpa", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Tegucigalpa", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Tegucigalpa", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Thule", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Thule", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Thule", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Thule", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Thule", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Thule", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Thunder_Bay", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Thunder_Bay", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Thunder_Bay", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Thunder_Bay", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Thunder_Bay", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Thunder_Bay", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Tijuana", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("America/Tijuana", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Tijuana", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Tijuana", 1710052200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Tijuana", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Tijuana", 2145916799000L),
    Some(-480),
  )
  assert_eq(@date.zone_offset_minutes("America/Toronto", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("America/Toronto", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Toronto", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Toronto", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Toronto", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Toronto", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("America/Tortola", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Tortola", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Tortola", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Tortola", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Tortola", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Tortola", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Vancouver", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("America/Vancouver", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Vancouver", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Vancouver", 1710052200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Vancouver", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Vancouver", 2145916799000L),
    Some(-480),
  )
  assert_eq(@date.zone_offset_minutes("America/Virgin", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("America/Virgin", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Virgin", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Virgin", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Virgin", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Virgin", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("America/Whitehorse", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("America/Whitehorse", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Whitehorse", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Whitehorse", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Whitehorse", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Whitehorse", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("America/Winnipeg", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Winnipeg", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Winnipeg", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Winnipeg", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Winnipeg", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Winnipeg", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("America/Yakutat", 0L), Some(-540))
  assert_eq(
    @date.zone_offset_minutes("America/Yakutat", 515556000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Yakutat", 961070400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Yakutat", 1710052200000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Yakutat", 1730613600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Yakutat", 2145916799000L),
    Some(-540),
  )
  assert_eq(@date.zone_offset_minutes("America/Yellowknife", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("America/Yellowknife", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Yellowknife", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Yellowknife", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Yellowknife", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Yellowknife", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("Antarctica/Casey", 0L), Some(480))
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Casey", 515556000000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Casey", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Casey", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Casey", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Casey", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Antarctica/Davis", 0L), Some(420))
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Davis", 515556000000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Davis", 961070400000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Davis", 1710052200000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Davis", 1730613600000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Davis", 2145916799000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/DumontDUrville", 0L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/DumontDUrville", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/DumontDUrville", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/DumontDUrville", 1710052200000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/DumontDUrville", 1730613600000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/DumontDUrville", 2145916799000L),
    Some(600),
  )
  assert_eq(@date.zone_offset_minutes("Antarctica/Macquarie", 0L), Some(660))
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Macquarie", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Macquarie", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Macquarie", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Macquarie", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Macquarie", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Antarctica/Mawson", 0L), Some(360))
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Mawson", 515556000000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Mawson", 961070400000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Mawson", 1710052200000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Mawson", 1730613600000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Mawson", 2145916799000L),
    Some(300),
  )
  assert_eq(@date.zone_offset_minutes("Antarctica/McMurdo", 0L), Some(720))
  assert_eq(
    @date.zone_offset_minutes("Antarctica/McMurdo", 515556000000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/McMurdo", 961070400000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/McMurdo", 1710052200000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/McMurdo", 1730613600000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/McMurdo", 2145916799000L),
    Some(780),
  )
  assert_eq(@date.zone_offset_minutes("Antarctica/Palmer", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Palmer", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Palmer", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Palmer", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Palmer", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Palmer", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("Antarctica/Rothera", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Rothera", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Rothera", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Rothera", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Rothera", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Rothera", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("Antarctica/South_Pole", 0L), Some(720))
  assert_eq(
    @date.zone_offset_minutes("Antarctica/South_Pole", 515556000000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/South_Pole", 961070400000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/South_Pole", 1710052200000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/South_Pole", 1730613600000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/South_Pole", 2145916799000L),
    Some(780),
  )
  assert_eq(@date.zone_offset_minutes("Antarctica/Syowa", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Syowa", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Syowa", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Syowa", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Syowa", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Syowa", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Antarctica/Troll", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Troll", 515556000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Troll", 961070400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Troll", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Troll", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Troll", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Antarctica/Vostok", 0L), Some(420))
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Vostok", 515556000000L),
    Some(420),
  )
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 8/19 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Vostok", 961070400000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Vostok", 1710052200000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Vostok", 1730613600000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Antarctica/Vostok", 2145916799000L),
    Some(300),
  )
  assert_eq(@date.zone_offset_minutes("Arctic/Longyearbyen", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Arctic/Longyearbyen", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Arctic/Longyearbyen", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Arctic/Longyearbyen", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Arctic/Longyearbyen", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Arctic/Longyearbyen", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Aden", 0L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Aden", 515556000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Aden", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Aden", 1710052200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Aden", 1730613600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Aden", 2145916799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Almaty", 0L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Almaty", 515556000000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Almaty", 961070400000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Almaty", 1710052200000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Almaty", 1730613600000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Almaty", 2145916799000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Amman", 0L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Amman", 515556000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Amman", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Amman", 1710052200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Amman", 1730613600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Amman", 2145916799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Anadyr", 0L), Some(780))
  assert_eq(@date.zone_offset_minutes("Asia/Anadyr", 515556000000L), Some(780))
  assert_eq(@date.zone_offset_minutes("Asia/Anadyr", 961070400000L), Some(780))
  assert_eq(@date.zone_offset_minutes("Asia/Anadyr", 1710052200000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Asia/Anadyr", 1730613600000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Asia/Anadyr", 2145916799000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Asia/Aqtau", 0L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Aqtau", 515556000000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Aqtau", 961070400000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Aqtau", 1710052200000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Aqtau", 1730613600000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Aqtau", 2145916799000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Aqtobe", 0L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Aqtobe", 515556000000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Aqtobe", 961070400000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Aqtobe", 1710052200000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Aqtobe", 1730613600000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Aqtobe", 2145916799000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Ashgabat", 0L), Some(300))
  assert_eq(
    @date.zone_offset_minutes("Asia/Ashgabat", 515556000000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ashgabat", 961070400000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ashgabat", 1710052200000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ashgabat", 1730613600000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ashgabat", 2145916799000L),
    Some(300),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Ashkhabad", 0L), Some(300))
  assert_eq(
    @date.zone_offset_minutes("Asia/Ashkhabad", 515556000000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ashkhabad", 961070400000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ashkhabad", 1710052200000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ashkhabad", 1730613600000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ashkhabad", 2145916799000L),
    Some(300),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Atyrau", 0L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Atyrau", 515556000000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Atyrau", 961070400000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Atyrau", 1710052200000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Atyrau", 1730613600000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Atyrau", 2145916799000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Baghdad", 0L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Baghdad", 515556000000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Baghdad", 961070400000L), Some(240))
  assert_eq(
    @date.zone_offset_minutes("Asia/Baghdad", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Baghdad", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Baghdad", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Bahrain", 0L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Bahrain", 515556000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Bahrain", 961070400000L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Asia/Bahrain", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Bahrain", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Bahrain", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Baku", 0L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Baku", 515556000000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Baku", 961070400000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Baku", 1710052200000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Baku", 1730613600000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Baku", 2145916799000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Bangkok", 0L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Bangkok", 515556000000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Bangkok", 961070400000L), Some(420))
  assert_eq(
    @date.zone_offset_minutes("Asia/Bangkok", 1710052200000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Bangkok", 1730613600000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Bangkok", 2145916799000L),
    Some(420),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Barnaul", 0L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Barnaul", 515556000000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Barnaul", 961070400000L), Some(420))
  assert_eq(
    @date.zone_offset_minutes("Asia/Barnaul", 1710052200000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Barnaul", 1730613600000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Barnaul", 2145916799000L),
    Some(420),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Beirut", 0L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Beirut", 515556000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Beirut", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Beirut", 1710052200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Beirut", 1730613600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Beirut", 2145916799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Bishkek", 0L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Bishkek", 515556000000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Bishkek", 961070400000L), Some(360))
  assert_eq(
    @date.zone_offset_minutes("Asia/Bishkek", 1710052200000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Bishkek", 1730613600000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Bishkek", 2145916799000L),
    Some(360),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Brunei", 0L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Brunei", 515556000000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Brunei", 961070400000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Brunei", 1710052200000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Brunei", 1730613600000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Brunei", 2145916799000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Calcutta", 0L), Some(330))
  assert_eq(
    @date.zone_offset_minutes("Asia/Calcutta", 515556000000L),
    Some(330),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Calcutta", 961070400000L),
    Some(330),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Calcutta", 1710052200000L),
    Some(330),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Calcutta", 1730613600000L),
    Some(330),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Calcutta", 2145916799000L),
    Some(330),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Chita", 0L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Chita", 515556000000L), Some(600))
  assert_eq(@date.zone_offset_minutes("Asia/Chita", 961070400000L), Some(600))
  assert_eq(@date.zone_offset_minutes("Asia/Chita", 1710052200000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Chita", 1730613600000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Chita", 2145916799000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Choibalsan", 0L), Some(420))
  assert_eq(
    @date.zone_offset_minutes("Asia/Choibalsan", 515556000000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Choibalsan", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Choibalsan", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Choibalsan", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Choibalsan", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Chongqing", 0L), Some(480))
  assert_eq(
    @date.zone_offset_minutes("Asia/Chongqing", 515556000000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Chongqing", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Chongqing", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Chongqing", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Chongqing", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Chungking", 0L), Some(480))
  assert_eq(
    @date.zone_offset_minutes("Asia/Chungking", 515556000000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Chungking", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Chungking", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Chungking", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Chungking", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Colombo", 0L), Some(330))
  assert_eq(@date.zone_offset_minutes("Asia/Colombo", 515556000000L), Some(330))
  assert_eq(@date.zone_offset_minutes("Asia/Colombo", 961070400000L), Some(360))
  assert_eq(
    @date.zone_offset_minutes("Asia/Colombo", 1710052200000L),
    Some(330),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Colombo", 1730613600000L),
    Some(330),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Colombo", 2145916799000L),
    Some(330),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Dacca", 0L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Dacca", 515556000000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Dacca", 961070400000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Dacca", 1710052200000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Dacca", 1730613600000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Dacca", 2145916799000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Damascus", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Dhaka", 0L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Dhaka", 515556000000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Dhaka", 961070400000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Dhaka", 1710052200000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Dhaka", 1730613600000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Dhaka", 2145916799000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Dili", 0L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Dili", 515556000000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Dili", 961070400000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Dili", 1710052200000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Dili", 1730613600000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Dili", 2145916799000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Dubai", 0L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Dubai", 515556000000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Dubai", 961070400000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Dubai", 1710052200000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Dubai", 1730613600000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Dubai", 2145916799000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Dushanbe", 0L), Some(360))
  assert_eq(
    @date.zone_offset_minutes("Asia/Dushanbe", 515556000000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Dushanbe", 961070400000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Dushanbe", 1710052200000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Dushanbe", 1730613600000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Dushanbe", 2145916799000L),
    Some(300),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Famagusta", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Asia/Famagusta", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Famagusta", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Famagusta", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Famagusta", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Famagusta", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 0L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1710052200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1730613600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2145916799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Harbin", 0L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Harbin", 515556000000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Harbin", 961070400000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Harbin", 1710052200000L), Some(480))
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 9/19 块，本块 200 条）" {
  assert_eq(@date.zone_offset_minutes("Asia/Harbin", 1730613600000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Harbin", 2145916799000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 0L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1710052200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1730613600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2145916799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Ho_Chi_Minh", 0L), Some(480))
  assert_eq(
    @date.zone_offset_minutes("Asia/Ho_Chi_Minh", 515556000000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ho_Chi_Minh", 961070400000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ho_Chi_Minh", 1710052200000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ho_Chi_Minh", 1730613600000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ho_Chi_Minh", 2145916799000L),
    Some(420),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Hong_Kong", 0L), Some(480))
  assert_eq(
    @date.zone_offset_minutes("Asia/Hong_Kong", 515556000000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Hong_Kong", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Hong_Kong", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Hong_Kong", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Hong_Kong", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Hovd", 0L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Hovd", 515556000000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Hovd", 961070400000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Hovd", 1710052200000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Hovd", 1730613600000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Hovd", 2145916799000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Irkutsk", 0L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Irkutsk", 515556000000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Irkutsk", 961070400000L), Some(540))
  assert_eq(
    @date.zone_offset_minutes("Asia/Irkutsk", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Irkutsk", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Irkutsk", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Istanbul", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Asia/Istanbul", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Istanbul", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Istanbul", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Istanbul", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Istanbul", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Jakarta", 0L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Jakarta", 515556000000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Jakarta", 961070400000L), Some(420))
  assert_eq(
    @date.zone_offset_minutes("Asia/Jakarta", 1710052200000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Jakarta", 1730613600000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Jakarta", 2145916799000L),
    Some(420),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Jayapura", 0L), Some(540))
  assert_eq(
    @date.zone_offset_minutes("Asia/Jayapura", 515556000000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Jayapura", 961070400000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Jayapura", 1710052200000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Jayapura", 1730613600000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Jayapura", 2145916799000L),
    Some(540),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Jerusalem", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Asia/Jerusalem", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Jerusalem", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Jerusalem", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Jerusalem", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Jerusalem", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Kabul", 0L), Some(270))
  assert_eq(@date.zone_offset_minutes("Asia/Kabul", 515556000000L), Some(270))
  assert_eq(@date.zone_offset_minutes("Asia/Kabul", 961070400000L), Some(270))
  assert_eq(@date.zone_offset_minutes("Asia/Kabul", 1710052200000L), Some(270))
  assert_eq(@date.zone_offset_minutes("Asia/Kabul", 1730613600000L), Some(270))
  assert_eq(@date.zone_offset_minutes("Asia/Kabul", 2145916799000L), Some(270))
  assert_eq(@date.zone_offset_minutes("Asia/Kamchatka", 0L), Some(720))
  assert_eq(
    @date.zone_offset_minutes("Asia/Kamchatka", 515556000000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kamchatka", 961070400000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kamchatka", 1710052200000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kamchatka", 1730613600000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kamchatka", 2145916799000L),
    Some(720),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Karachi", 0L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Karachi", 515556000000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Karachi", 961070400000L), Some(300))
  assert_eq(
    @date.zone_offset_minutes("Asia/Karachi", 1710052200000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Karachi", 1730613600000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Karachi", 2145916799000L),
    Some(300),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Kashgar", 0L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Kashgar", 515556000000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Kashgar", 961070400000L), Some(360))
  assert_eq(
    @date.zone_offset_minutes("Asia/Kashgar", 1710052200000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kashgar", 1730613600000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kashgar", 2145916799000L),
    Some(360),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Kathmandu", 0L), Some(330))
  assert_eq(
    @date.zone_offset_minutes("Asia/Kathmandu", 515556000000L),
    Some(345),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kathmandu", 961070400000L),
    Some(345),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kathmandu", 1710052200000L),
    Some(345),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kathmandu", 1730613600000L),
    Some(345),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kathmandu", 2145916799000L),
    Some(345),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Katmandu", 0L), Some(330))
  assert_eq(
    @date.zone_offset_minutes("Asia/Katmandu", 515556000000L),
    Some(345),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Katmandu", 961070400000L),
    Some(345),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Katmandu", 1710052200000L),
    Some(345),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Katmandu", 1730613600000L),
    Some(345),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Katmandu", 2145916799000L),
    Some(345),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Khandyga", 0L), Some(540))
  assert_eq(
    @date.zone_offset_minutes("Asia/Khandyga", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Khandyga", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Khandyga", 1710052200000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Khandyga", 1730613600000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Khandyga", 2145916799000L),
    Some(540),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Kolkata", 0L), Some(330))
  assert_eq(@date.zone_offset_minutes("Asia/Kolkata", 515556000000L), Some(330))
  assert_eq(@date.zone_offset_minutes("Asia/Kolkata", 961070400000L), Some(330))
  assert_eq(
    @date.zone_offset_minutes("Asia/Kolkata", 1710052200000L),
    Some(330),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kolkata", 1730613600000L),
    Some(330),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kolkata", 2145916799000L),
    Some(330),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Krasnoyarsk", 0L), Some(420))
  assert_eq(
    @date.zone_offset_minutes("Asia/Krasnoyarsk", 515556000000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Krasnoyarsk", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Krasnoyarsk", 1710052200000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Krasnoyarsk", 1730613600000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Krasnoyarsk", 2145916799000L),
    Some(420),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Kuala_Lumpur", 0L), Some(450))
  assert_eq(
    @date.zone_offset_minutes("Asia/Kuala_Lumpur", 515556000000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kuala_Lumpur", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kuala_Lumpur", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kuala_Lumpur", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kuala_Lumpur", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Kuching", 0L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Kuching", 515556000000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Kuching", 961070400000L), Some(480))
  assert_eq(
    @date.zone_offset_minutes("Asia/Kuching", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kuching", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Kuching", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Kuwait", 0L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Kuwait", 515556000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Kuwait", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Kuwait", 1710052200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Kuwait", 1730613600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Kuwait", 2145916799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Macao", 0L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Macao", 515556000000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Macao", 961070400000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Macao", 1710052200000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Macao", 1730613600000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Macao", 2145916799000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Macau", 0L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Macau", 515556000000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Macau", 961070400000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Macau", 1710052200000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Macau", 1730613600000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Macau", 2145916799000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Magadan", 0L), Some(660))
  assert_eq(@date.zone_offset_minutes("Asia/Magadan", 515556000000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Asia/Magadan", 961070400000L), Some(720))
  assert_eq(
    @date.zone_offset_minutes("Asia/Magadan", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Magadan", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Magadan", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Makassar", 0L), Some(480))
  assert_eq(
    @date.zone_offset_minutes("Asia/Makassar", 515556000000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Makassar", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Makassar", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Makassar", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Makassar", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Manila", 0L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Manila", 515556000000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Manila", 961070400000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Manila", 1710052200000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Manila", 1730613600000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Manila", 2145916799000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Muscat", 0L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Muscat", 515556000000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Muscat", 961070400000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Muscat", 1710052200000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Muscat", 1730613600000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Muscat", 2145916799000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Nicosia", 0L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Nicosia", 515556000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Nicosia", 961070400000L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Asia/Nicosia", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Nicosia", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Nicosia", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Novokuznetsk", 0L), Some(420))
  assert_eq(
    @date.zone_offset_minutes("Asia/Novokuznetsk", 515556000000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Novokuznetsk", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Novokuznetsk", 1710052200000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Novokuznetsk", 1730613600000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Novokuznetsk", 2145916799000L),
    Some(420),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Novosibirsk", 0L), Some(420))
  assert_eq(
    @date.zone_offset_minutes("Asia/Novosibirsk", 515556000000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Novosibirsk", 961070400000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Novosibirsk", 1710052200000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Novosibirsk", 1730613600000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Novosibirsk", 2145916799000L),
    Some(420),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Omsk", 0L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Omsk", 515556000000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Omsk", 961070400000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Omsk", 1710052200000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Omsk", 1730613600000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Omsk", 2145916799000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Oral", 0L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Oral", 515556000000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Oral", 961070400000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Oral", 1710052200000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Oral", 1730613600000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Oral", 2145916799000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Phnom_Penh", 0L), Some(420))
  assert_eq(
    @date.zone_offset_minutes("Asia/Phnom_Penh", 515556000000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Phnom_Penh", 961070400000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Phnom_Penh", 1710052200000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Phnom_Penh", 1730613600000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Phnom_Penh", 2145916799000L),
    Some(420),
  )
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 10/19 块，本块 200 条）" {
  assert_eq(@date.zone_offset_minutes("Asia/Pontianak", 0L), Some(480))
  assert_eq(
    @date.zone_offset_minutes("Asia/Pontianak", 515556000000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Pontianak", 961070400000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Pontianak", 1710052200000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Pontianak", 1730613600000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Pontianak", 2145916799000L),
    Some(420),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Pyongyang", 0L), Some(540))
  assert_eq(
    @date.zone_offset_minutes("Asia/Pyongyang", 515556000000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Pyongyang", 961070400000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Pyongyang", 1710052200000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Pyongyang", 1730613600000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Pyongyang", 2145916799000L),
    Some(540),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Qatar", 0L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Qatar", 515556000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Qatar", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Qatar", 1710052200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Qatar", 1730613600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Qatar", 2145916799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Qostanay", 0L), Some(300))
  assert_eq(
    @date.zone_offset_minutes("Asia/Qostanay", 515556000000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Qostanay", 961070400000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Qostanay", 1710052200000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Qostanay", 1730613600000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Qostanay", 2145916799000L),
    Some(300),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Qyzylorda", 0L), Some(300))
  assert_eq(
    @date.zone_offset_minutes("Asia/Qyzylorda", 515556000000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Qyzylorda", 961070400000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Qyzylorda", 1710052200000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Qyzylorda", 1730613600000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Qyzylorda", 2145916799000L),
    Some(300),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Rangoon", 0L), Some(390))
  assert_eq(@date.zone_offset_minutes("Asia/Rangoon", 515556000000L), Some(390))
  assert_eq(@date.zone_offset_minutes("Asia/Rangoon", 961070400000L), Some(390))
  assert_eq(
    @date.zone_offset_minutes("Asia/Rangoon", 1710052200000L),
    Some(390),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Rangoon", 1730613600000L),
    Some(390),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Rangoon", 2145916799000L),
    Some(390),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Riyadh", 0L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Riyadh", 515556000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Riyadh", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Riyadh", 1710052200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Riyadh", 1730613600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Riyadh", 2145916799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Saigon", 0L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Saigon", 515556000000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Saigon", 961070400000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Saigon", 1710052200000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Saigon", 1730613600000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Saigon", 2145916799000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Sakhalin", 0L), Some(660))
  assert_eq(
    @date.zone_offset_minutes("Asia/Sakhalin", 515556000000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Sakhalin", 961070400000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Sakhalin", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Sakhalin", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Sakhalin", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Samarkand", 0L), Some(300))
  assert_eq(
    @date.zone_offset_minutes("Asia/Samarkand", 515556000000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Samarkand", 961070400000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Samarkand", 1710052200000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Samarkand", 1730613600000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Samarkand", 2145916799000L),
    Some(300),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Seoul", 0L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Seoul", 515556000000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Seoul", 961070400000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Seoul", 1710052200000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Seoul", 1730613600000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Seoul", 2145916799000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Shanghai", 0L), Some(480))
  assert_eq(
    @date.zone_offset_minutes("Asia/Shanghai", 515556000000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Shanghai", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Shanghai", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Shanghai", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Shanghai", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Singapore", 0L), Some(450))
  assert_eq(
    @date.zone_offset_minutes("Asia/Singapore", 515556000000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Singapore", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Singapore", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Singapore", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Singapore", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Srednekolymsk", 0L), Some(660))
  assert_eq(
    @date.zone_offset_minutes("Asia/Srednekolymsk", 515556000000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Srednekolymsk", 961070400000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Srednekolymsk", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Srednekolymsk", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Srednekolymsk", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Taipei", 0L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Taipei", 515556000000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Taipei", 961070400000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Taipei", 1710052200000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Taipei", 1730613600000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Taipei", 2145916799000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Tashkent", 0L), Some(360))
  assert_eq(
    @date.zone_offset_minutes("Asia/Tashkent", 515556000000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Tashkent", 961070400000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Tashkent", 1710052200000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Tashkent", 1730613600000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Tashkent", 2145916799000L),
    Some(300),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Tbilisi", 0L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Tbilisi", 515556000000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Asia/Tbilisi", 961070400000L), Some(300))
  assert_eq(
    @date.zone_offset_minutes("Asia/Tbilisi", 1710052200000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Tbilisi", 1730613600000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Tbilisi", 2145916799000L),
    Some(240),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Tehran", 0L), Some(210))
  assert_eq(@date.zone_offset_minutes("Asia/Tehran", 515556000000L), Some(210))
  assert_eq(@date.zone_offset_minutes("Asia/Tehran", 961070400000L), Some(270))
  assert_eq(@date.zone_offset_minutes("Asia/Tehran", 1710052200000L), Some(210))
  assert_eq(@date.zone_offset_minutes("Asia/Tehran", 1730613600000L), Some(210))
  assert_eq(@date.zone_offset_minutes("Asia/Tehran", 2145916799000L), Some(210))
  assert_eq(@date.zone_offset_minutes("Asia/Tel_Aviv", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Asia/Tel_Aviv", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Tel_Aviv", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Tel_Aviv", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Tel_Aviv", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Tel_Aviv", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Thimbu", 0L), Some(330))
  assert_eq(@date.zone_offset_minutes("Asia/Thimbu", 515556000000L), Some(330))
  assert_eq(@date.zone_offset_minutes("Asia/Thimbu", 961070400000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Thimbu", 1710052200000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Thimbu", 1730613600000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Thimbu", 2145916799000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Thimphu", 0L), Some(330))
  assert_eq(@date.zone_offset_minutes("Asia/Thimphu", 515556000000L), Some(330))
  assert_eq(@date.zone_offset_minutes("Asia/Thimphu", 961070400000L), Some(360))
  assert_eq(
    @date.zone_offset_minutes("Asia/Thimphu", 1710052200000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Thimphu", 1730613600000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Thimphu", 2145916799000L),
    Some(360),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Tokyo", 0L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Tokyo", 515556000000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Tokyo", 961070400000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Tokyo", 1710052200000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Tokyo", 1730613600000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Tokyo", 2145916799000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Tomsk", 0L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Tomsk", 515556000000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Tomsk", 961070400000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Tomsk", 1710052200000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Tomsk", 1730613600000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Tomsk", 2145916799000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Asia/Ujung_Pandang", 0L), Some(480))
  assert_eq(
    @date.zone_offset_minutes("Asia/Ujung_Pandang", 515556000000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ujung_Pandang", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ujung_Pandang", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ujung_Pandang", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ujung_Pandang", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Ulaanbaatar", 0L), Some(420))
  assert_eq(
    @date.zone_offset_minutes("Asia/Ulaanbaatar", 515556000000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ulaanbaatar", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ulaanbaatar", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ulaanbaatar", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ulaanbaatar", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Ulan_Bator", 0L), Some(420))
  assert_eq(
    @date.zone_offset_minutes("Asia/Ulan_Bator", 515556000000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ulan_Bator", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ulan_Bator", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ulan_Bator", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ulan_Bator", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Urumqi", 0L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Urumqi", 515556000000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Urumqi", 961070400000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Urumqi", 1710052200000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Urumqi", 1730613600000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Urumqi", 2145916799000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Asia/Ust-Nera", 0L), Some(540))
  assert_eq(
    @date.zone_offset_minutes("Asia/Ust-Nera", 515556000000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ust-Nera", 961070400000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ust-Nera", 1710052200000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ust-Nera", 1730613600000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Ust-Nera", 2145916799000L),
    Some(600),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Vientiane", 0L), Some(420))
  assert_eq(
    @date.zone_offset_minutes("Asia/Vientiane", 515556000000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Vientiane", 961070400000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Vientiane", 1710052200000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Vientiane", 1730613600000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Vientiane", 2145916799000L),
    Some(420),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Vladivostok", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Asia/Vladivostok", 515556000000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Vladivostok", 961070400000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Vladivostok", 1710052200000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Vladivostok", 1730613600000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Vladivostok", 2145916799000L),
    Some(600),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Yakutsk", 0L), Some(540))
  assert_eq(@date.zone_offset_minutes("Asia/Yakutsk", 515556000000L), Some(600))
  assert_eq(@date.zone_offset_minutes("Asia/Yakutsk", 961070400000L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Asia/Yakutsk", 1710052200000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Yakutsk", 1730613600000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Yakutsk", 2145916799000L),
    Some(540),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Yangon", 0L), Some(390))
  assert_eq(@date.zone_offset_minutes("Asia/Yangon", 515556000000L), Some(390))
  assert_eq(@date.zone_offset_minutes("Asia/Yangon", 961070400000L), Some(390))
  assert_eq(@date.zone_offset_minutes("Asia/Yangon", 1710052200000L), Some(390))
  assert_eq(@date.zone_offset_minutes("Asia/Yangon", 1730613600000L), Some(390))
  assert_eq(@date.zone_offset_minutes("Asia/Yangon", 2145916799000L), Some(390))
  assert_eq(@date.zone_offset_minutes("Asia/Yekaterinburg", 0L), Some(300))
  assert_eq(
    @date.zone_offset_minutes("Asia/Yekaterinburg", 515556000000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Yekaterinburg", 961070400000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Yekaterinburg", 1710052200000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Yekaterinburg", 1730613600000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Yekaterinburg", 2145916799000L),
    Some(300),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Yerevan", 0L), Some(240))
  assert_eq(@date.zone_offset_minutes("Asia/Yerevan", 515556000000L), Some(300))
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 11/19 块，本块 200 条）" {
  assert_eq(@date.zone_offset_minutes("Asia/Yerevan", 961070400000L), Some(300))
  assert_eq(
    @date.zone_offset_minutes("Asia/Yerevan", 1710052200000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Yerevan", 1730613600000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Yerevan", 2145916799000L),
    Some(240),
  )
  assert_eq(@date.zone_offset_minutes("Atlantic/Azores", 0L), Some(-60))
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Azores", 515556000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Azores", 961070400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Azores", 1710052200000L),
    Some(-60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Azores", 1730613600000L),
    Some(-60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Azores", 2145916799000L),
    Some(-60),
  )
  assert_eq(@date.zone_offset_minutes("Atlantic/Bermuda", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Bermuda", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Bermuda", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Bermuda", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Bermuda", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Bermuda", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("Atlantic/Canary", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Canary", 515556000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Canary", 961070400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Canary", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Canary", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Canary", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Atlantic/Cape_Verde", 0L), Some(-120))
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Cape_Verde", 515556000000L),
    Some(-60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Cape_Verde", 961070400000L),
    Some(-60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Cape_Verde", 1710052200000L),
    Some(-60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Cape_Verde", 1730613600000L),
    Some(-60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Cape_Verde", 2145916799000L),
    Some(-60),
  )
  assert_eq(@date.zone_offset_minutes("Atlantic/Faeroe", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Faeroe", 515556000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Faeroe", 961070400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Faeroe", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Faeroe", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Faeroe", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Atlantic/Faroe", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Faroe", 515556000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Faroe", 961070400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Faroe", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Faroe", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Faroe", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Atlantic/Jan_Mayen", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Jan_Mayen", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Jan_Mayen", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Jan_Mayen", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Jan_Mayen", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Jan_Mayen", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Atlantic/Madeira", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Madeira", 515556000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Madeira", 961070400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Madeira", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Madeira", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Madeira", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Atlantic/Reykjavik", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Reykjavik", 515556000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Reykjavik", 961070400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Reykjavik", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Reykjavik", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Reykjavik", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Atlantic/South_Georgia", 0L), Some(-120))
  assert_eq(
    @date.zone_offset_minutes("Atlantic/South_Georgia", 515556000000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/South_Georgia", 961070400000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/South_Georgia", 1710052200000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/South_Georgia", 1730613600000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/South_Georgia", 2145916799000L),
    Some(-120),
  )
  assert_eq(@date.zone_offset_minutes("Atlantic/St_Helena", 0L), Some(0))
  assert_eq(
    @date.zone_offset_minutes("Atlantic/St_Helena", 515556000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/St_Helena", 961070400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/St_Helena", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/St_Helena", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/St_Helena", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Atlantic/Stanley", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Stanley", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Stanley", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Stanley", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Stanley", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Atlantic/Stanley", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("Australia/ACT", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Australia/ACT", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/ACT", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/ACT", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/ACT", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/ACT", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Adelaide", 0L), Some(570))
  assert_eq(
    @date.zone_offset_minutes("Australia/Adelaide", 515556000000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Adelaide", 961070400000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Adelaide", 1710052200000L),
    Some(630),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Adelaide", 1730613600000L),
    Some(630),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Adelaide", 2145916799000L),
    Some(630),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Brisbane", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Australia/Brisbane", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Brisbane", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Brisbane", 1710052200000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Brisbane", 1730613600000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Brisbane", 2145916799000L),
    Some(600),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Broken_Hill", 0L), Some(570))
  assert_eq(
    @date.zone_offset_minutes("Australia/Broken_Hill", 515556000000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Broken_Hill", 961070400000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Broken_Hill", 1710052200000L),
    Some(630),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Broken_Hill", 1730613600000L),
    Some(630),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Broken_Hill", 2145916799000L),
    Some(630),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Canberra", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Australia/Canberra", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Canberra", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Canberra", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Canberra", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Canberra", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Currie", 0L), Some(660))
  assert_eq(
    @date.zone_offset_minutes("Australia/Currie", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Currie", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Currie", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Currie", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Currie", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Darwin", 0L), Some(570))
  assert_eq(
    @date.zone_offset_minutes("Australia/Darwin", 515556000000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Darwin", 961070400000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Darwin", 1710052200000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Darwin", 1730613600000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Darwin", 2145916799000L),
    Some(570),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Eucla", 0L), Some(525))
  assert_eq(
    @date.zone_offset_minutes("Australia/Eucla", 515556000000L),
    Some(525),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Eucla", 961070400000L),
    Some(525),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Eucla", 1710052200000L),
    Some(525),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Eucla", 1730613600000L),
    Some(525),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Eucla", 2145916799000L),
    Some(525),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Hobart", 0L), Some(660))
  assert_eq(
    @date.zone_offset_minutes("Australia/Hobart", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Hobart", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Hobart", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Hobart", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Hobart", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Australia/LHI", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Australia/LHI", 515556000000L),
    Some(630),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/LHI", 961070400000L),
    Some(630),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/LHI", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/LHI", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/LHI", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Lindeman", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Australia/Lindeman", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Lindeman", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Lindeman", 1710052200000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Lindeman", 1730613600000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Lindeman", 2145916799000L),
    Some(600),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Lord_Howe", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Australia/Lord_Howe", 515556000000L),
    Some(630),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Lord_Howe", 961070400000L),
    Some(630),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Lord_Howe", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Lord_Howe", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Lord_Howe", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Melbourne", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Australia/Melbourne", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Melbourne", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Melbourne", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Melbourne", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Melbourne", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Australia/NSW", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Australia/NSW", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/NSW", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/NSW", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/NSW", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/NSW", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Australia/North", 0L), Some(570))
  assert_eq(
    @date.zone_offset_minutes("Australia/North", 515556000000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/North", 961070400000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/North", 1710052200000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/North", 1730613600000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/North", 2145916799000L),
    Some(570),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Perth", 0L), Some(480))
  assert_eq(
    @date.zone_offset_minutes("Australia/Perth", 515556000000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Perth", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Perth", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Perth", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Perth", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Queensland", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Australia/Queensland", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Queensland", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Queensland", 1710052200000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Queensland", 1730613600000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Queensland", 2145916799000L),
    Some(600),
  )
  assert_eq(@date.zone_offset_minutes("Australia/South", 0L), Some(570))
  assert_eq(
    @date.zone_offset_minutes("Australia/South", 515556000000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/South", 961070400000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/South", 1710052200000L),
    Some(630),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/South", 1730613600000L),
    Some(630),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/South", 2145916799000L),
    Some(630),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Sydney", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Australia/Sydney", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Sydney", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Sydney", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Sydney", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Sydney", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Tasmania", 0L), Some(660))
  assert_eq(
    @date.zone_offset_minutes("Australia/Tasmania", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Tasmania", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Tasmania", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Tasmania", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Tasmania", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Victoria", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Australia/Victoria", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Victoria", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Victoria", 1710052200000L),
    Some(660),
  )
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 12/19 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("Australia/Victoria", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Victoria", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Australia/West", 0L), Some(480))
  assert_eq(
    @date.zone_offset_minutes("Australia/West", 515556000000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/West", 961070400000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/West", 1710052200000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/West", 1730613600000L),
    Some(480),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/West", 2145916799000L),
    Some(480),
  )
  assert_eq(@date.zone_offset_minutes("Australia/Yancowinna", 0L), Some(570))
  assert_eq(
    @date.zone_offset_minutes("Australia/Yancowinna", 515556000000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Yancowinna", 961070400000L),
    Some(570),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Yancowinna", 1710052200000L),
    Some(630),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Yancowinna", 1730613600000L),
    Some(630),
  )
  assert_eq(
    @date.zone_offset_minutes("Australia/Yancowinna", 2145916799000L),
    Some(630),
  )
  assert_eq(@date.zone_offset_minutes("Brazil/Acre", 0L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Brazil/Acre", 515556000000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Brazil/Acre", 961070400000L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("Brazil/Acre", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Brazil/Acre", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Brazil/Acre", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("Brazil/DeNoronha", 0L), Some(-120))
  assert_eq(
    @date.zone_offset_minutes("Brazil/DeNoronha", 515556000000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("Brazil/DeNoronha", 961070400000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("Brazil/DeNoronha", 1710052200000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("Brazil/DeNoronha", 1730613600000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("Brazil/DeNoronha", 2145916799000L),
    Some(-120),
  )
  assert_eq(@date.zone_offset_minutes("Brazil/East", 0L), Some(-180))
  assert_eq(@date.zone_offset_minutes("Brazil/East", 515556000000L), Some(-180))
  assert_eq(@date.zone_offset_minutes("Brazil/East", 961070400000L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("Brazil/East", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Brazil/East", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Brazil/East", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("Brazil/West", 0L), Some(-240))
  assert_eq(@date.zone_offset_minutes("Brazil/West", 515556000000L), Some(-240))
  assert_eq(@date.zone_offset_minutes("Brazil/West", 961070400000L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("Brazil/West", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Brazil/West", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Brazil/West", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("CET", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("CET", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("CET", 961070400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("CET", 1710052200000L), Some(60))
  assert_eq(@date.zone_offset_minutes("CET", 1730613600000L), Some(60))
  assert_eq(@date.zone_offset_minutes("CET", 2145916799000L), Some(60))
  assert_eq(@date.zone_offset_minutes("CST6CDT", 0L), Some(-360))
  assert_eq(@date.zone_offset_minutes("CST6CDT", 515556000000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("CST6CDT", 961070400000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("CST6CDT", 1710052200000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("CST6CDT", 1730613600000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("CST6CDT", 2145916799000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("Canada/Atlantic", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("Canada/Atlantic", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Atlantic", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Atlantic", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Atlantic", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Atlantic", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("Canada/Central", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("Canada/Central", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Central", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Central", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Central", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Central", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("Canada/Eastern", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("Canada/Eastern", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Eastern", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Eastern", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Eastern", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Eastern", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("Canada/Mountain", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("Canada/Mountain", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Mountain", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Mountain", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Mountain", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Mountain", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("Canada/Newfoundland", 0L), Some(-210))
  assert_eq(
    @date.zone_offset_minutes("Canada/Newfoundland", 515556000000L),
    Some(-150),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Newfoundland", 961070400000L),
    Some(-150),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Newfoundland", 1710052200000L),
    Some(-150),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Newfoundland", 1730613600000L),
    Some(-210),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Newfoundland", 2145916799000L),
    Some(-210),
  )
  assert_eq(@date.zone_offset_minutes("Canada/Pacific", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("Canada/Pacific", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Pacific", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Pacific", 1710052200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Pacific", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Pacific", 2145916799000L),
    Some(-480),
  )
  assert_eq(@date.zone_offset_minutes("Canada/Saskatchewan", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("Canada/Saskatchewan", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Saskatchewan", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Saskatchewan", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Saskatchewan", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Saskatchewan", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("Canada/Yukon", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("Canada/Yukon", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Yukon", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Yukon", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Yukon", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Canada/Yukon", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("Chile/Continental", 0L), Some(-180))
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1710052200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1730613600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 2145916799000L),
    Some(-180),
  )
  assert_eq(@date.zone_offset_minutes("Chile/EasterIsland", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("Cuba", 0L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Cuba", 515556000000L), Some(-240))
  assert_eq(@date.zone_offset_minutes("Cuba", 961070400000L), Some(-240))
  assert_eq(@date.zone_offset_minutes("Cuba", 1710052200000L), Some(-240))
  assert_eq(@date.zone_offset_minutes("Cuba", 1730613600000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Cuba", 2145916799000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("EET", 0L), Some(120))
  assert_eq(@date.zone_offset_minutes("EET", 515556000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("EET", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("EET", 1710052200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("EET", 1730613600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("EET", 2145916799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("EST5EDT", 0L), Some(-300))
  assert_eq(@date.zone_offset_minutes("EST5EDT", 515556000000L), Some(-240))
  assert_eq(@date.zone_offset_minutes("EST5EDT", 961070400000L), Some(-240))
  assert_eq(@date.zone_offset_minutes("EST5EDT", 1710052200000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("EST5EDT", 1730613600000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("EST5EDT", 2145916799000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Egypt", 0L), Some(120))
  assert_eq(@date.zone_offset_minutes("Egypt", 515556000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Egypt", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Egypt", 1710052200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Egypt", 1730613600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Egypt", 2145916799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Eire", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Eire", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Eire", 961070400000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Eire", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Eire", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Eire", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+0", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+0", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+0", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+0", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+0", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+0", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+1", 0L), Some(-60))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+1", 515556000000L), Some(-60))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+1", 961070400000L), Some(-60))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+1", 1710052200000L), Some(-60))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+1", 1730613600000L), Some(-60))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+1", 2145916799000L), Some(-60))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+10", 0L), Some(-600))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+10", 515556000000L), Some(-600))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+10", 961070400000L), Some(-600))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+10", 1710052200000L), Some(-600))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+10", 1730613600000L), Some(-600))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+10", 2145916799000L), Some(-600))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+11", 0L), Some(-660))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+11", 515556000000L), Some(-660))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+11", 961070400000L), Some(-660))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+11", 1710052200000L), Some(-660))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+11", 1730613600000L), Some(-660))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+11", 2145916799000L), Some(-660))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+12", 0L), Some(-720))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+12", 515556000000L), Some(-720))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+12", 961070400000L), Some(-720))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+12", 1710052200000L), Some(-720))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+12", 1730613600000L), Some(-720))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+12", 2145916799000L), Some(-720))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+2", 0L), Some(-120))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+2", 515556000000L), Some(-120))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+2", 961070400000L), Some(-120))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+2", 1710052200000L), Some(-120))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+2", 1730613600000L), Some(-120))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+2", 2145916799000L), Some(-120))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+3", 0L), Some(-180))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+3", 515556000000L), Some(-180))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+3", 961070400000L), Some(-180))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+3", 1710052200000L), Some(-180))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+3", 1730613600000L), Some(-180))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+3", 2145916799000L), Some(-180))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+4", 0L), Some(-240))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+4", 515556000000L), Some(-240))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+4", 961070400000L), Some(-240))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+4", 1710052200000L), Some(-240))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+4", 1730613600000L), Some(-240))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+4", 2145916799000L), Some(-240))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+5", 0L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+5", 515556000000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+5", 961070400000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+5", 1710052200000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+5", 1730613600000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+5", 2145916799000L), Some(-300))
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 13/19 块，本块 200 条）" {
  assert_eq(@date.zone_offset_minutes("Etc/GMT+6", 0L), Some(-360))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+6", 515556000000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+6", 961070400000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+6", 1710052200000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+6", 1730613600000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+6", 2145916799000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+7", 0L), Some(-420))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+7", 515556000000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+7", 961070400000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+7", 1710052200000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+7", 1730613600000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+7", 2145916799000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+8", 0L), Some(-480))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+8", 515556000000L), Some(-480))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+8", 961070400000L), Some(-480))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+8", 1710052200000L), Some(-480))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+8", 1730613600000L), Some(-480))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+8", 2145916799000L), Some(-480))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+9", 0L), Some(-540))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+9", 515556000000L), Some(-540))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+9", 961070400000L), Some(-540))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+9", 1710052200000L), Some(-540))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+9", 1730613600000L), Some(-540))
  assert_eq(@date.zone_offset_minutes("Etc/GMT+9", 2145916799000L), Some(-540))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-0", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-0", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-0", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-0", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-0", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-0", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-1", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-1", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-1", 961070400000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-1", 1710052200000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-1", 1730613600000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-1", 2145916799000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-10", 0L), Some(600))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-10", 515556000000L), Some(600))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-10", 961070400000L), Some(600))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-10", 1710052200000L), Some(600))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-10", 1730613600000L), Some(600))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-10", 2145916799000L), Some(600))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-11", 0L), Some(660))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-11", 515556000000L), Some(660))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-11", 961070400000L), Some(660))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-11", 1710052200000L), Some(660))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-11", 1730613600000L), Some(660))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-11", 2145916799000L), Some(660))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-12", 0L), Some(720))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-12", 515556000000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-12", 961070400000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-12", 1710052200000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-12", 1730613600000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-12", 2145916799000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-13", 0L), Some(780))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-13", 515556000000L), Some(780))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-13", 961070400000L), Some(780))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-13", 1710052200000L), Some(780))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-13", 1730613600000L), Some(780))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-13", 2145916799000L), Some(780))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-14", 0L), Some(840))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-14", 515556000000L), Some(840))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-14", 961070400000L), Some(840))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-14", 1710052200000L), Some(840))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-14", 1730613600000L), Some(840))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-14", 2145916799000L), Some(840))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-2", 0L), Some(120))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-2", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-2", 961070400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-2", 1710052200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-2", 1730613600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-2", 2145916799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-3", 0L), Some(180))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-3", 515556000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-3", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-3", 1710052200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-3", 1730613600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-3", 2145916799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-4", 0L), Some(240))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-4", 515556000000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-4", 961070400000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-4", 1710052200000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-4", 1730613600000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-4", 2145916799000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-5", 0L), Some(300))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-5", 515556000000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-5", 961070400000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-5", 1710052200000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-5", 1730613600000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-5", 2145916799000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-6", 0L), Some(360))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-6", 515556000000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-6", 961070400000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-6", 1710052200000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-6", 1730613600000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-6", 2145916799000L), Some(360))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-7", 0L), Some(420))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-7", 515556000000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-7", 961070400000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-7", 1710052200000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-7", 1730613600000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-7", 2145916799000L), Some(420))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-8", 0L), Some(480))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-8", 515556000000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-8", 961070400000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-8", 1710052200000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-8", 1730613600000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-8", 2145916799000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-9", 0L), Some(540))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-9", 515556000000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-9", 961070400000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-9", 1710052200000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-9", 1730613600000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Etc/GMT-9", 2145916799000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Etc/GMT0", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT0", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT0", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT0", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT0", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/GMT0", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Greenwich", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Greenwich", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Greenwich", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Greenwich", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Greenwich", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Greenwich", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/UCT", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/UCT", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/UCT", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/UCT", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/UCT", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/UCT", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/UTC", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/UTC", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/UTC", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/UTC", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/UTC", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/UTC", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Universal", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Universal", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Universal", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Universal", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Universal", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Universal", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Zulu", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Zulu", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Zulu", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Zulu", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Zulu", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Etc/Zulu", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Europe/Amsterdam", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Amsterdam", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Amsterdam", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Amsterdam", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Amsterdam", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Amsterdam", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Andorra", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Andorra", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Andorra", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Andorra", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Andorra", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Andorra", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Astrakhan", 0L), Some(240))
  assert_eq(
    @date.zone_offset_minutes("Europe/Astrakhan", 515556000000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Astrakhan", 961070400000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Astrakhan", 1710052200000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Astrakhan", 1730613600000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Astrakhan", 2145916799000L),
    Some(240),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Athens", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Europe/Athens", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Athens", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Athens", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Athens", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Athens", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Belfast", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Belfast", 515556000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Belfast", 961070400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Belfast", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Belfast", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Belfast", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Belgrade", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Belgrade", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Belgrade", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Belgrade", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Belgrade", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Belgrade", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Berlin", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Berlin", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Berlin", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Berlin", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Berlin", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Berlin", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Bratislava", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Bratislava", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Bratislava", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Bratislava", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Bratislava", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Bratislava", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Brussels", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Brussels", 515556000000L),
    Some(120),
  )
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 14/19 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("Europe/Brussels", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Brussels", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Brussels", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Brussels", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Bucharest", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Europe/Bucharest", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Bucharest", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Bucharest", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Bucharest", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Bucharest", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Budapest", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Budapest", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Budapest", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Budapest", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Budapest", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Budapest", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Busingen", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Busingen", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Busingen", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Busingen", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Busingen", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Busingen", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Chisinau", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Europe/Chisinau", 515556000000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Chisinau", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Chisinau", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Chisinau", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Chisinau", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Copenhagen", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Copenhagen", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Copenhagen", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Copenhagen", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Copenhagen", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Copenhagen", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Dublin", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Dublin", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Dublin", 961070400000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Dublin", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Europe/Dublin", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Europe/Dublin", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Europe/Gibraltar", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Gibraltar", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Gibraltar", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Gibraltar", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Gibraltar", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Gibraltar", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Guernsey", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Guernsey", 515556000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Guernsey", 961070400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Guernsey", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Guernsey", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Guernsey", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Helsinki", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Europe/Helsinki", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Helsinki", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Helsinki", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Helsinki", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Helsinki", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Isle_of_Man", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Isle_of_Man", 515556000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Isle_of_Man", 961070400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Isle_of_Man", 1710052200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Isle_of_Man", 1730613600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Isle_of_Man", 2145916799000L),
    Some(0),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Istanbul", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Europe/Istanbul", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Istanbul", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Istanbul", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Istanbul", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Istanbul", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Jersey", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Jersey", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Jersey", 961070400000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Jersey", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Europe/Jersey", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Europe/Jersey", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Europe/Kaliningrad", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Europe/Kaliningrad", 515556000000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Kaliningrad", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Kaliningrad", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Kaliningrad", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Kaliningrad", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Kiev", 0L), Some(180))
  assert_eq(@date.zone_offset_minutes("Europe/Kiev", 515556000000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Europe/Kiev", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Europe/Kiev", 1710052200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Kiev", 1730613600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Kiev", 2145916799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Kirov", 0L), Some(240))
  assert_eq(@date.zone_offset_minutes("Europe/Kirov", 515556000000L), Some(300))
  assert_eq(@date.zone_offset_minutes("Europe/Kirov", 961070400000L), Some(240))
  assert_eq(
    @date.zone_offset_minutes("Europe/Kirov", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Kirov", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Kirov", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Kyiv", 0L), Some(180))
  assert_eq(@date.zone_offset_minutes("Europe/Kyiv", 515556000000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Europe/Kyiv", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Europe/Kyiv", 1710052200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Kyiv", 1730613600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Kyiv", 2145916799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Lisbon", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Lisbon", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Lisbon", 961070400000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Lisbon", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Europe/Lisbon", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Europe/Lisbon", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Europe/Ljubljana", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Ljubljana", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Ljubljana", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Ljubljana", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Ljubljana", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Ljubljana", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/London", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/London", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/London", 961070400000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/London", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Europe/London", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Europe/London", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Europe/Luxembourg", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Luxembourg", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Luxembourg", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Luxembourg", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Luxembourg", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Luxembourg", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Madrid", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Madrid", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Madrid", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Madrid", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Madrid", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Madrid", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Malta", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Malta", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Malta", 961070400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Malta", 1710052200000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Malta", 1730613600000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Malta", 2145916799000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Mariehamn", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Europe/Mariehamn", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Mariehamn", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Mariehamn", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Mariehamn", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Mariehamn", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Minsk", 0L), Some(180))
  assert_eq(@date.zone_offset_minutes("Europe/Minsk", 515556000000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Europe/Minsk", 961070400000L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Europe/Minsk", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Minsk", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Minsk", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Monaco", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Monaco", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Monaco", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Monaco", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Monaco", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Monaco", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Moscow", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Europe/Moscow", 515556000000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Moscow", 961070400000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Moscow", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Moscow", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Moscow", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Nicosia", 0L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Europe/Nicosia", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Nicosia", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Nicosia", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Nicosia", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Nicosia", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Oslo", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Oslo", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Oslo", 961070400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Oslo", 1710052200000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Oslo", 1730613600000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Oslo", 2145916799000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Paris", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Paris", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Paris", 961070400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Paris", 1710052200000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Paris", 1730613600000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Paris", 2145916799000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Podgorica", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Podgorica", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Podgorica", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Podgorica", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Podgorica", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Podgorica", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Prague", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Prague", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Prague", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Prague", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Prague", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Prague", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Riga", 0L), Some(180))
  assert_eq(@date.zone_offset_minutes("Europe/Riga", 515556000000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Europe/Riga", 961070400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Riga", 1710052200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Riga", 1730613600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Riga", 2145916799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Rome", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Rome", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Rome", 961070400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Rome", 1710052200000L), Some(60))
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 15/19 块，本块 200 条）" {
  assert_eq(@date.zone_offset_minutes("Europe/Rome", 1730613600000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Rome", 2145916799000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Samara", 0L), Some(240))
  assert_eq(
    @date.zone_offset_minutes("Europe/Samara", 515556000000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Samara", 961070400000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Samara", 1710052200000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Samara", 1730613600000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Samara", 2145916799000L),
    Some(240),
  )
  assert_eq(@date.zone_offset_minutes("Europe/San_Marino", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/San_Marino", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/San_Marino", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/San_Marino", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/San_Marino", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/San_Marino", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Sarajevo", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Sarajevo", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Sarajevo", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Sarajevo", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Sarajevo", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Sarajevo", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Saratov", 0L), Some(240))
  assert_eq(
    @date.zone_offset_minutes("Europe/Saratov", 515556000000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Saratov", 961070400000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Saratov", 1710052200000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Saratov", 1730613600000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Saratov", 2145916799000L),
    Some(240),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Simferopol", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Europe/Simferopol", 515556000000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Simferopol", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Simferopol", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Simferopol", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Simferopol", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Skopje", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Skopje", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Skopje", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Skopje", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Skopje", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Skopje", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Sofia", 0L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Sofia", 515556000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Europe/Sofia", 961070400000L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Europe/Sofia", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Sofia", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Sofia", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Stockholm", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Stockholm", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Stockholm", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Stockholm", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Stockholm", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Stockholm", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Tallinn", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Europe/Tallinn", 515556000000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Tallinn", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Tallinn", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Tallinn", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Tallinn", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Tirane", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Tirane", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Tirane", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Tirane", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Tirane", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Tirane", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Tiraspol", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Europe/Tiraspol", 515556000000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Tiraspol", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Tiraspol", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Tiraspol", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Tiraspol", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Ulyanovsk", 0L), Some(240))
  assert_eq(
    @date.zone_offset_minutes("Europe/Ulyanovsk", 515556000000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Ulyanovsk", 961070400000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Ulyanovsk", 1710052200000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Ulyanovsk", 1730613600000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Ulyanovsk", 2145916799000L),
    Some(240),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Uzhgorod", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Europe/Uzhgorod", 515556000000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Uzhgorod", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Uzhgorod", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Uzhgorod", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Uzhgorod", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Vaduz", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Vaduz", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Vaduz", 961070400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Europe/Vaduz", 1710052200000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Vaduz", 1730613600000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Vaduz", 2145916799000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Europe/Vatican", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Vatican", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Vatican", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Vatican", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Vatican", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Vatican", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Vienna", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Vienna", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Vienna", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Vienna", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Vienna", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Vienna", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Vilnius", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Europe/Vilnius", 515556000000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Vilnius", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Vilnius", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Vilnius", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Vilnius", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Volgograd", 0L), Some(240))
  assert_eq(
    @date.zone_offset_minutes("Europe/Volgograd", 515556000000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Volgograd", 961070400000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Volgograd", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Volgograd", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Volgograd", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Warsaw", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Warsaw", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Warsaw", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Warsaw", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Warsaw", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Warsaw", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Zagreb", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Zagreb", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Zagreb", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Zagreb", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Zagreb", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Zagreb", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Zaporozhye", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Europe/Zaporozhye", 515556000000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Zaporozhye", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Zaporozhye", 1710052200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Zaporozhye", 1730613600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Zaporozhye", 2145916799000L),
    Some(120),
  )
  assert_eq(@date.zone_offset_minutes("Europe/Zurich", 0L), Some(60))
  assert_eq(
    @date.zone_offset_minutes("Europe/Zurich", 515556000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Zurich", 961070400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Zurich", 1710052200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Zurich", 1730613600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Europe/Zurich", 2145916799000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("GB", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("GB", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("GB", 961070400000L), Some(60))
  assert_eq(@date.zone_offset_minutes("GB", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GB", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GB", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GB-Eire", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("GB-Eire", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("GB-Eire", 961070400000L), Some(60))
  assert_eq(@date.zone_offset_minutes("GB-Eire", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GB-Eire", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GB-Eire", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GMT", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("GMT", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GMT", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GMT", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GMT", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GMT", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GMT0", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("GMT0", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GMT0", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GMT0", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GMT0", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("GMT0", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Greenwich", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Greenwich", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Greenwich", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Greenwich", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Greenwich", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Greenwich", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Hongkong", 0L), Some(480))
  assert_eq(@date.zone_offset_minutes("Hongkong", 515556000000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Hongkong", 961070400000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Hongkong", 1710052200000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Hongkong", 1730613600000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Hongkong", 2145916799000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Iceland", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Iceland", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Iceland", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Iceland", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Iceland", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Iceland", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Indian/Antananarivo", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Indian/Antananarivo", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Antananarivo", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Antananarivo", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Antananarivo", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Antananarivo", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Indian/Chagos", 0L), Some(300))
  assert_eq(
    @date.zone_offset_minutes("Indian/Chagos", 515556000000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Chagos", 961070400000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Chagos", 1710052200000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Chagos", 1730613600000L),
    Some(360),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Chagos", 2145916799000L),
    Some(360),
  )
  assert_eq(@date.zone_offset_minutes("Indian/Christmas", 0L), Some(420))
  assert_eq(
    @date.zone_offset_minutes("Indian/Christmas", 515556000000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Christmas", 961070400000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Christmas", 1710052200000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Christmas", 1730613600000L),
    Some(420),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Christmas", 2145916799000L),
    Some(420),
  )
  assert_eq(@date.zone_offset_minutes("Indian/Cocos", 0L), Some(390))
  assert_eq(@date.zone_offset_minutes("Indian/Cocos", 515556000000L), Some(390))
  assert_eq(@date.zone_offset_minutes("Indian/Cocos", 961070400000L), Some(390))
  assert_eq(
    @date.zone_offset_minutes("Indian/Cocos", 1710052200000L),
    Some(390),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Cocos", 1730613600000L),
    Some(390),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Cocos", 2145916799000L),
    Some(390),
  )
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 16/19 块，本块 200 条）" {
  assert_eq(@date.zone_offset_minutes("Indian/Comoro", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Indian/Comoro", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Comoro", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Comoro", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Comoro", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Comoro", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Indian/Kerguelen", 0L), Some(300))
  assert_eq(
    @date.zone_offset_minutes("Indian/Kerguelen", 515556000000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Kerguelen", 961070400000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Kerguelen", 1710052200000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Kerguelen", 1730613600000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Kerguelen", 2145916799000L),
    Some(300),
  )
  assert_eq(@date.zone_offset_minutes("Indian/Mahe", 0L), Some(240))
  assert_eq(@date.zone_offset_minutes("Indian/Mahe", 515556000000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Indian/Mahe", 961070400000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Indian/Mahe", 1710052200000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Indian/Mahe", 1730613600000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Indian/Mahe", 2145916799000L), Some(240))
  assert_eq(@date.zone_offset_minutes("Indian/Maldives", 0L), Some(300))
  assert_eq(
    @date.zone_offset_minutes("Indian/Maldives", 515556000000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Maldives", 961070400000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Maldives", 1710052200000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Maldives", 1730613600000L),
    Some(300),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Maldives", 2145916799000L),
    Some(300),
  )
  assert_eq(@date.zone_offset_minutes("Indian/Mauritius", 0L), Some(240))
  assert_eq(
    @date.zone_offset_minutes("Indian/Mauritius", 515556000000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Mauritius", 961070400000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Mauritius", 1710052200000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Mauritius", 1730613600000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Mauritius", 2145916799000L),
    Some(240),
  )
  assert_eq(@date.zone_offset_minutes("Indian/Mayotte", 0L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Indian/Mayotte", 515556000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Mayotte", 961070400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Mayotte", 1710052200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Mayotte", 1730613600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Mayotte", 2145916799000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Indian/Reunion", 0L), Some(240))
  assert_eq(
    @date.zone_offset_minutes("Indian/Reunion", 515556000000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Reunion", 961070400000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Reunion", 1710052200000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Reunion", 1730613600000L),
    Some(240),
  )
  assert_eq(
    @date.zone_offset_minutes("Indian/Reunion", 2145916799000L),
    Some(240),
  )
  assert_eq(@date.zone_offset_minutes("Iran", 0L), Some(210))
  assert_eq(@date.zone_offset_minutes("Iran", 515556000000L), Some(210))
  assert_eq(@date.zone_offset_minutes("Iran", 961070400000L), Some(270))
  assert_eq(@date.zone_offset_minutes("Iran", 1710052200000L), Some(210))
  assert_eq(@date.zone_offset_minutes("Iran", 1730613600000L), Some(210))
  assert_eq(@date.zone_offset_minutes("Iran", 2145916799000L), Some(210))
  assert_eq(@date.zone_offset_minutes("Israel", 0L), Some(120))
  assert_eq(@date.zone_offset_minutes("Israel", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Israel", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Israel", 1710052200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Israel", 1730613600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Israel", 2145916799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Jamaica", 0L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Jamaica", 515556000000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Jamaica", 961070400000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Jamaica", 1710052200000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Jamaica", 1730613600000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Jamaica", 2145916799000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("Japan", 0L), Some(540))
  assert_eq(@date.zone_offset_minutes("Japan", 515556000000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Japan", 961070400000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Japan", 1710052200000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Japan", 1730613600000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Japan", 2145916799000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Kwajalein", 0L), Some(-720))
  assert_eq(@date.zone_offset_minutes("Kwajalein", 515556000000L), Some(-720))
  assert_eq(@date.zone_offset_minutes("Kwajalein", 961070400000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Kwajalein", 1710052200000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Kwajalein", 1730613600000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Kwajalein", 2145916799000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Libya", 0L), Some(120))
  assert_eq(@date.zone_offset_minutes("Libya", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Libya", 961070400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Libya", 1710052200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Libya", 1730613600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Libya", 2145916799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("MET", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("MET", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("MET", 961070400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("MET", 1710052200000L), Some(60))
  assert_eq(@date.zone_offset_minutes("MET", 1730613600000L), Some(60))
  assert_eq(@date.zone_offset_minutes("MET", 2145916799000L), Some(60))
  assert_eq(@date.zone_offset_minutes("MST7MDT", 0L), Some(-420))
  assert_eq(@date.zone_offset_minutes("MST7MDT", 515556000000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("MST7MDT", 961070400000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("MST7MDT", 1710052200000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("MST7MDT", 1730613600000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("MST7MDT", 2145916799000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("Mexico/BajaNorte", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("Mexico/BajaNorte", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Mexico/BajaNorte", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Mexico/BajaNorte", 1710052200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("Mexico/BajaNorte", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Mexico/BajaNorte", 2145916799000L),
    Some(-480),
  )
  assert_eq(@date.zone_offset_minutes("Mexico/BajaSur", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("Mexico/BajaSur", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Mexico/BajaSur", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Mexico/BajaSur", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Mexico/BajaSur", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Mexico/BajaSur", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("Mexico/General", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("Mexico/General", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Mexico/General", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Mexico/General", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Mexico/General", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Mexico/General", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("NZ", 0L), Some(720))
  assert_eq(@date.zone_offset_minutes("NZ", 515556000000L), Some(720))
  assert_eq(@date.zone_offset_minutes("NZ", 961070400000L), Some(720))
  assert_eq(@date.zone_offset_minutes("NZ", 1710052200000L), Some(780))
  assert_eq(@date.zone_offset_minutes("NZ", 1730613600000L), Some(780))
  assert_eq(@date.zone_offset_minutes("NZ", 2145916799000L), Some(780))
  assert_eq(@date.zone_offset_minutes("NZ-CHAT", 0L), Some(765))
  assert_eq(@date.zone_offset_minutes("NZ-CHAT", 515556000000L), Some(765))
  assert_eq(@date.zone_offset_minutes("NZ-CHAT", 961070400000L), Some(765))
  assert_eq(@date.zone_offset_minutes("NZ-CHAT", 1710052200000L), Some(825))
  assert_eq(@date.zone_offset_minutes("NZ-CHAT", 1730613600000L), Some(825))
  assert_eq(@date.zone_offset_minutes("NZ-CHAT", 2145916799000L), Some(825))
  assert_eq(@date.zone_offset_minutes("Navajo", 0L), Some(-420))
  assert_eq(@date.zone_offset_minutes("Navajo", 515556000000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("Navajo", 961070400000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("Navajo", 1710052200000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("Navajo", 1730613600000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("Navajo", 2145916799000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("PRC", 0L), Some(480))
  assert_eq(@date.zone_offset_minutes("PRC", 515556000000L), Some(540))
  assert_eq(@date.zone_offset_minutes("PRC", 961070400000L), Some(480))
  assert_eq(@date.zone_offset_minutes("PRC", 1710052200000L), Some(480))
  assert_eq(@date.zone_offset_minutes("PRC", 1730613600000L), Some(480))
  assert_eq(@date.zone_offset_minutes("PRC", 2145916799000L), Some(480))
  assert_eq(@date.zone_offset_minutes("PST8PDT", 0L), Some(-480))
  assert_eq(@date.zone_offset_minutes("PST8PDT", 515556000000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("PST8PDT", 961070400000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("PST8PDT", 1710052200000L), Some(-480))
  assert_eq(@date.zone_offset_minutes("PST8PDT", 1730613600000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("PST8PDT", 2145916799000L), Some(-480))
  assert_eq(@date.zone_offset_minutes("Pacific/Apia", 0L), Some(-660))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Apia", 515556000000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Apia", 961070400000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Apia", 1710052200000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Apia", 1730613600000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Apia", 2145916799000L),
    Some(780),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Auckland", 0L), Some(720))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Auckland", 515556000000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Auckland", 961070400000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Auckland", 1710052200000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Auckland", 1730613600000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Auckland", 2145916799000L),
    Some(780),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Bougainville", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Bougainville", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Bougainville", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Bougainville", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Bougainville", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Bougainville", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Chatham", 0L), Some(765))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Chatham", 515556000000L),
    Some(765),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Chatham", 961070400000L),
    Some(765),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Chatham", 1710052200000L),
    Some(825),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Chatham", 1730613600000L),
    Some(825),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Chatham", 2145916799000L),
    Some(825),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Chuuk", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Chuuk", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Chuuk", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Chuuk", 1710052200000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Chuuk", 1730613600000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Chuuk", 2145916799000L),
    Some(600),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Easter", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Efate", 0L), Some(660))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Efate", 515556000000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Efate", 961070400000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Efate", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Efate", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Efate", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Enderbury", 0L), Some(-720))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Enderbury", 515556000000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Enderbury", 961070400000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Enderbury", 1710052200000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Enderbury", 1730613600000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Enderbury", 2145916799000L),
    Some(780),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Fakaofo", 0L), Some(-660))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Fakaofo", 515556000000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Fakaofo", 961070400000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Fakaofo", 1710052200000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Fakaofo", 1730613600000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Fakaofo", 2145916799000L),
    Some(780),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Fiji", 0L), Some(720))
  assert_eq(@date.zone_offset_minutes("Pacific/Fiji", 515556000000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Pacific/Fiji", 961070400000L), Some(720))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Fiji", 1710052200000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Fiji", 1730613600000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Fiji", 2145916799000L),
    Some(720),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Funafuti", 0L), Some(720))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Funafuti", 515556000000L),
    Some(720),
  )
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 17/19 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("Pacific/Funafuti", 961070400000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Funafuti", 1710052200000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Funafuti", 1730613600000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Funafuti", 2145916799000L),
    Some(720),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Galapagos", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Galapagos", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Galapagos", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Galapagos", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Galapagos", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Galapagos", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Gambier", 0L), Some(-540))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Gambier", 515556000000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Gambier", 961070400000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Gambier", 1710052200000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Gambier", 1730613600000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Gambier", 2145916799000L),
    Some(-540),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Guadalcanal", 0L), Some(660))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Guadalcanal", 515556000000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Guadalcanal", 961070400000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Guadalcanal", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Guadalcanal", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Guadalcanal", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Guam", 0L), Some(600))
  assert_eq(@date.zone_offset_minutes("Pacific/Guam", 515556000000L), Some(600))
  assert_eq(@date.zone_offset_minutes("Pacific/Guam", 961070400000L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Guam", 1710052200000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Guam", 1730613600000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Guam", 2145916799000L),
    Some(600),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Honolulu", 0L), Some(-600))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Honolulu", 515556000000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Honolulu", 961070400000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Honolulu", 1710052200000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Honolulu", 1730613600000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Honolulu", 2145916799000L),
    Some(-600),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Johnston", 0L), Some(-600))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Johnston", 515556000000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Johnston", 961070400000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Johnston", 1710052200000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Johnston", 1730613600000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Johnston", 2145916799000L),
    Some(-600),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Kanton", 0L), Some(-720))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kanton", 515556000000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kanton", 961070400000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kanton", 1710052200000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kanton", 1730613600000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kanton", 2145916799000L),
    Some(780),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Kiritimati", 0L), Some(-640))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kiritimati", 515556000000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kiritimati", 961070400000L),
    Some(840),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kiritimati", 1710052200000L),
    Some(840),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kiritimati", 1730613600000L),
    Some(840),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kiritimati", 2145916799000L),
    Some(840),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Kosrae", 0L), Some(720))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kosrae", 515556000000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kosrae", 961070400000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kosrae", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kosrae", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kosrae", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Kwajalein", 0L), Some(-720))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kwajalein", 515556000000L),
    Some(-720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kwajalein", 961070400000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kwajalein", 1710052200000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kwajalein", 1730613600000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Kwajalein", 2145916799000L),
    Some(720),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Majuro", 0L), Some(720))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Majuro", 515556000000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Majuro", 961070400000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Majuro", 1710052200000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Majuro", 1730613600000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Majuro", 2145916799000L),
    Some(720),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Marquesas", 0L), Some(-570))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Marquesas", 515556000000L),
    Some(-570),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Marquesas", 961070400000L),
    Some(-570),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Marquesas", 1710052200000L),
    Some(-570),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Marquesas", 1730613600000L),
    Some(-570),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Marquesas", 2145916799000L),
    Some(-570),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Midway", 0L), Some(-660))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Midway", 515556000000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Midway", 961070400000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Midway", 1710052200000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Midway", 1730613600000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Midway", 2145916799000L),
    Some(-660),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Nauru", 0L), Some(690))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Nauru", 515556000000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Nauru", 961070400000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Nauru", 1710052200000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Nauru", 1730613600000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Nauru", 2145916799000L),
    Some(720),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Niue", 0L), Some(-660))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Niue", 515556000000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Niue", 961070400000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Niue", 1710052200000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Niue", 1730613600000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Niue", 2145916799000L),
    Some(-660),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Norfolk", 0L), Some(690))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Norfolk", 515556000000L),
    Some(690),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Norfolk", 961070400000L),
    Some(690),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Norfolk", 1710052200000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Norfolk", 1730613600000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Norfolk", 2145916799000L),
    Some(720),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Noumea", 0L), Some(660))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Noumea", 515556000000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Noumea", 961070400000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Noumea", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Noumea", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Noumea", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Pago_Pago", 0L), Some(-660))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pago_Pago", 515556000000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pago_Pago", 961070400000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pago_Pago", 1710052200000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pago_Pago", 1730613600000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pago_Pago", 2145916799000L),
    Some(-660),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Palau", 0L), Some(540))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Palau", 515556000000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Palau", 961070400000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Palau", 1710052200000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Palau", 1730613600000L),
    Some(540),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Palau", 2145916799000L),
    Some(540),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Pitcairn", 0L), Some(-510))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pitcairn", 515556000000L),
    Some(-510),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pitcairn", 961070400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pitcairn", 1710052200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pitcairn", 1730613600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pitcairn", 2145916799000L),
    Some(-480),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Pohnpei", 0L), Some(660))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pohnpei", 515556000000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pohnpei", 961070400000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pohnpei", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pohnpei", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Pohnpei", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Ponape", 0L), Some(660))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Ponape", 515556000000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Ponape", 961070400000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Ponape", 1710052200000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Ponape", 1730613600000L),
    Some(660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Ponape", 2145916799000L),
    Some(660),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Port_Moresby", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Port_Moresby", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Port_Moresby", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Port_Moresby", 1710052200000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Port_Moresby", 1730613600000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Port_Moresby", 2145916799000L),
    Some(600),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Rarotonga", 0L), Some(-630))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Rarotonga", 515556000000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Rarotonga", 961070400000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Rarotonga", 1710052200000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Rarotonga", 1730613600000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Rarotonga", 2145916799000L),
    Some(-600),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Saipan", 0L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Saipan", 515556000000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Saipan", 961070400000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Saipan", 1710052200000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Saipan", 1730613600000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Saipan", 2145916799000L),
    Some(600),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Samoa", 0L), Some(-660))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Samoa", 515556000000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Samoa", 961070400000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Samoa", 1710052200000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Samoa", 1730613600000L),
    Some(-660),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Samoa", 2145916799000L),
    Some(-660),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Tahiti", 0L), Some(-600))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tahiti", 515556000000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tahiti", 961070400000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tahiti", 1710052200000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tahiti", 1730613600000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tahiti", 2145916799000L),
    Some(-600),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Tarawa", 0L), Some(720))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tarawa", 515556000000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tarawa", 961070400000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tarawa", 1710052200000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tarawa", 1730613600000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tarawa", 2145916799000L),
    Some(720),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Tongatapu", 0L), Some(780))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tongatapu", 515556000000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tongatapu", 961070400000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tongatapu", 1710052200000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tongatapu", 1730613600000L),
    Some(780),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Tongatapu", 2145916799000L),
    Some(780),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Truk", 0L), Some(600))
  assert_eq(@date.zone_offset_minutes("Pacific/Truk", 515556000000L), Some(600))
  assert_eq(@date.zone_offset_minutes("Pacific/Truk", 961070400000L), Some(600))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Truk", 1710052200000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Truk", 1730613600000L),
    Some(600),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Truk", 2145916799000L),
    Some(600),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Wake", 0L), Some(720))
  assert_eq(@date.zone_offset_minutes("Pacific/Wake", 515556000000L), Some(720))
  assert_eq(@date.zone_offset_minutes("Pacific/Wake", 961070400000L), Some(720))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Wake", 1710052200000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Wake", 1730613600000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Wake", 2145916799000L),
    Some(720),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Wallis", 0L), Some(720))
  assert_eq(
    @date.zone_offset_minutes("Pacific/Wallis", 515556000000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Wallis", 961070400000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Wallis", 1710052200000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Wallis", 1730613600000L),
    Some(720),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Wallis", 2145916799000L),
    Some(720),
  )
  assert_eq(@date.zone_offset_minutes("Pacific/Yap", 0L), Some(600))
  assert_eq(@date.zone_offset_minutes("Pacific/Yap", 515556000000L), Some(600))
  assert_eq(@date.zone_offset_minutes("Pacific/Yap", 961070400000L), Some(600))
  assert_eq(@date.zone_offset_minutes("Pacific/Yap", 1710052200000L), Some(600))
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 18/19 块，本块 200 条）" {
  assert_eq(@date.zone_offset_minutes("Pacific/Yap", 1730613600000L), Some(600))
  assert_eq(@date.zone_offset_minutes("Pacific/Yap", 2145916799000L), Some(600))
  assert_eq(@date.zone_offset_minutes("Poland", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Poland", 515556000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Poland", 961070400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Poland", 1710052200000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Poland", 1730613600000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Poland", 2145916799000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Portugal", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("Portugal", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Portugal", 961070400000L), Some(60))
  assert_eq(@date.zone_offset_minutes("Portugal", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Portugal", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Portugal", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("ROK", 0L), Some(540))
  assert_eq(@date.zone_offset_minutes("ROK", 515556000000L), Some(540))
  assert_eq(@date.zone_offset_minutes("ROK", 961070400000L), Some(540))
  assert_eq(@date.zone_offset_minutes("ROK", 1710052200000L), Some(540))
  assert_eq(@date.zone_offset_minutes("ROK", 1730613600000L), Some(540))
  assert_eq(@date.zone_offset_minutes("ROK", 2145916799000L), Some(540))
  assert_eq(@date.zone_offset_minutes("Singapore", 0L), Some(450))
  assert_eq(@date.zone_offset_minutes("Singapore", 515556000000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Singapore", 961070400000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Singapore", 1710052200000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Singapore", 1730613600000L), Some(480))
  assert_eq(@date.zone_offset_minutes("Singapore", 2145916799000L), Some(480))
  assert_eq(@date.zone_offset_minutes("SystemV/AST4", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("SystemV/AST4", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/AST4", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/AST4", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/AST4", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/AST4", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("SystemV/AST4ADT", 0L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("SystemV/AST4ADT", 515556000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/AST4ADT", 961070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/AST4ADT", 1710052200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/AST4ADT", 1730613600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/AST4ADT", 2145916799000L),
    Some(-240),
  )
  assert_eq(@date.zone_offset_minutes("SystemV/CST6", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("SystemV/CST6", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/CST6", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/CST6", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/CST6", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/CST6", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("SystemV/CST6CDT", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("SystemV/CST6CDT", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/CST6CDT", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/CST6CDT", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/CST6CDT", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/CST6CDT", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("SystemV/EST5", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("SystemV/EST5", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/EST5", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/EST5", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/EST5", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/EST5", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("SystemV/EST5EDT", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("SystemV/EST5EDT", 515556000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/EST5EDT", 961070400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/EST5EDT", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/EST5EDT", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/EST5EDT", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("SystemV/HST10", 0L), Some(-600))
  assert_eq(
    @date.zone_offset_minutes("SystemV/HST10", 515556000000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/HST10", 961070400000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/HST10", 1710052200000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/HST10", 1730613600000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/HST10", 2145916799000L),
    Some(-600),
  )
  assert_eq(@date.zone_offset_minutes("SystemV/MST7", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("SystemV/MST7", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/MST7", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/MST7", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/MST7", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/MST7", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("SystemV/MST7MDT", 0L), Some(-420))
  assert_eq(
    @date.zone_offset_minutes("SystemV/MST7MDT", 515556000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/MST7MDT", 961070400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/MST7MDT", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/MST7MDT", 1730613600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/MST7MDT", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("SystemV/PST8", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("SystemV/PST8", 515556000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/PST8", 961070400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/PST8", 1710052200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/PST8", 1730613600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/PST8", 2145916799000L),
    Some(-480),
  )
  assert_eq(@date.zone_offset_minutes("SystemV/PST8PDT", 0L), Some(-480))
  assert_eq(
    @date.zone_offset_minutes("SystemV/PST8PDT", 515556000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/PST8PDT", 961070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/PST8PDT", 1710052200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/PST8PDT", 1730613600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/PST8PDT", 2145916799000L),
    Some(-480),
  )
  assert_eq(@date.zone_offset_minutes("SystemV/YST9", 0L), Some(-540))
  assert_eq(
    @date.zone_offset_minutes("SystemV/YST9", 515556000000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/YST9", 961070400000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/YST9", 1710052200000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/YST9", 1730613600000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/YST9", 2145916799000L),
    Some(-540),
  )
  assert_eq(@date.zone_offset_minutes("SystemV/YST9YDT", 0L), Some(-540))
  assert_eq(
    @date.zone_offset_minutes("SystemV/YST9YDT", 515556000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/YST9YDT", 961070400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/YST9YDT", 1710052200000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/YST9YDT", 1730613600000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("SystemV/YST9YDT", 2145916799000L),
    Some(-540),
  )
  assert_eq(@date.zone_offset_minutes("Turkey", 0L), Some(120))
  assert_eq(@date.zone_offset_minutes("Turkey", 515556000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Turkey", 961070400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Turkey", 1710052200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Turkey", 1730613600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Turkey", 2145916799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("UCT", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("UCT", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("UCT", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("UCT", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("UCT", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("UCT", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("US/Alaska", 0L), Some(-600))
  assert_eq(@date.zone_offset_minutes("US/Alaska", 515556000000L), Some(-480))
  assert_eq(@date.zone_offset_minutes("US/Alaska", 961070400000L), Some(-480))
  assert_eq(@date.zone_offset_minutes("US/Alaska", 1710052200000L), Some(-540))
  assert_eq(@date.zone_offset_minutes("US/Alaska", 1730613600000L), Some(-480))
  assert_eq(@date.zone_offset_minutes("US/Alaska", 2145916799000L), Some(-540))
  assert_eq(@date.zone_offset_minutes("US/Aleutian", 0L), Some(-660))
  assert_eq(@date.zone_offset_minutes("US/Aleutian", 515556000000L), Some(-540))
  assert_eq(@date.zone_offset_minutes("US/Aleutian", 961070400000L), Some(-540))
  assert_eq(
    @date.zone_offset_minutes("US/Aleutian", 1710052200000L),
    Some(-600),
  )
  assert_eq(
    @date.zone_offset_minutes("US/Aleutian", 1730613600000L),
    Some(-540),
  )
  assert_eq(
    @date.zone_offset_minutes("US/Aleutian", 2145916799000L),
    Some(-600),
  )
  assert_eq(@date.zone_offset_minutes("US/Arizona", 0L), Some(-420))
  assert_eq(@date.zone_offset_minutes("US/Arizona", 515556000000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("US/Arizona", 961070400000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("US/Arizona", 1710052200000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("US/Arizona", 1730613600000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("US/Arizona", 2145916799000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("US/Central", 0L), Some(-360))
  assert_eq(@date.zone_offset_minutes("US/Central", 515556000000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("US/Central", 961070400000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("US/Central", 1710052200000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("US/Central", 1730613600000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("US/Central", 2145916799000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("US/East-Indiana", 0L), Some(-300))
  assert_eq(
    @date.zone_offset_minutes("US/East-Indiana", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("US/East-Indiana", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("US/East-Indiana", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("US/East-Indiana", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("US/East-Indiana", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("US/Eastern", 0L), Some(-300))
  assert_eq(@date.zone_offset_minutes("US/Eastern", 515556000000L), Some(-240))
  assert_eq(@date.zone_offset_minutes("US/Eastern", 961070400000L), Some(-240))
  assert_eq(@date.zone_offset_minutes("US/Eastern", 1710052200000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("US/Eastern", 1730613600000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("US/Eastern", 2145916799000L), Some(-300))
  assert_eq(@date.zone_offset_minutes("US/Hawaii", 0L), Some(-600))
  assert_eq(@date.zone_offset_minutes("US/Hawaii", 515556000000L), Some(-600))
  assert_eq(@date.zone_offset_minutes("US/Hawaii", 961070400000L), Some(-600))
  assert_eq(@date.zone_offset_minutes("US/Hawaii", 1710052200000L), Some(-600))
  assert_eq(@date.zone_offset_minutes("US/Hawaii", 1730613600000L), Some(-600))
  assert_eq(@date.zone_offset_minutes("US/Hawaii", 2145916799000L), Some(-600))
  assert_eq(@date.zone_offset_minutes("US/Indiana-Starke", 0L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("US/Indiana-Starke", 515556000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("US/Indiana-Starke", 961070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("US/Indiana-Starke", 1710052200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("US/Indiana-Starke", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("US/Indiana-Starke", 2145916799000L),
    Some(-360),
  )
  assert_eq(@date.zone_offset_minutes("US/Michigan", 0L), Some(-300))
  assert_eq(@date.zone_offset_minutes("US/Michigan", 515556000000L), Some(-240))
  assert_eq(@date.zone_offset_minutes("US/Michigan", 961070400000L), Some(-240))
  assert_eq(
    @date.zone_offset_minutes("US/Michigan", 1710052200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("US/Michigan", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("US/Michigan", 2145916799000L),
    Some(-300),
  )
  assert_eq(@date.zone_offset_minutes("US/Mountain", 0L), Some(-420))
  assert_eq(@date.zone_offset_minutes("US/Mountain", 515556000000L), Some(-360))
  assert_eq(@date.zone_offset_minutes("US/Mountain", 961070400000L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("US/Mountain", 1710052200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("US/Mountain", 1730613600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("US/Mountain", 2145916799000L),
    Some(-420),
  )
  assert_eq(@date.zone_offset_minutes("US/Pacific", 0L), Some(-480))
  assert_eq(@date.zone_offset_minutes("US/Pacific", 515556000000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("US/Pacific", 961070400000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("US/Pacific", 1710052200000L), Some(-480))
  assert_eq(@date.zone_offset_minutes("US/Pacific", 1730613600000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("US/Pacific", 2145916799000L), Some(-480))
  assert_eq(@date.zone_offset_minutes("US/Samoa", 0L), Some(-660))
  assert_eq(@date.zone_offset_minutes("US/Samoa", 515556000000L), Some(-660))
  assert_eq(@date.zone_offset_minutes("US/Samoa", 961070400000L), Some(-660))
  assert_eq(@date.zone_offset_minutes("US/Samoa", 1710052200000L), Some(-660))
  assert_eq(@date.zone_offset_minutes("US/Samoa", 1730613600000L), Some(-660))
  assert_eq(@date.zone_offset_minutes("US/Samoa", 2145916799000L), Some(-660))
  assert_eq(@date.zone_offset_minutes("UTC", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("UTC", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("UTC", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("UTC", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("UTC", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("UTC", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Universal", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Universal", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Universal", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Universal", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Universal", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Universal", 2145916799000L), Some(0))
}

///|
test "@date 内置表逐区六瞬间偏移（腿 P 行全量）（第 19/19 块，本块 18 条）" {
  assert_eq(@date.zone_offset_minutes("W-SU", 0L), Some(180))
  assert_eq(@date.zone_offset_minutes("W-SU", 515556000000L), Some(240))
  assert_eq(@date.zone_offset_minutes("W-SU", 961070400000L), Some(240))
  assert_eq(@date.zone_offset_minutes("W-SU", 1710052200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("W-SU", 1730613600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("W-SU", 2145916799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("WET", 0L), Some(60))
  assert_eq(@date.zone_offset_minutes("WET", 515556000000L), Some(60))
  assert_eq(@date.zone_offset_minutes("WET", 961070400000L), Some(60))
  assert_eq(@date.zone_offset_minutes("WET", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("WET", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("WET", 2145916799000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Zulu", 0L), Some(0))
  assert_eq(@date.zone_offset_minutes("Zulu", 515556000000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Zulu", 961070400000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Zulu", 1710052200000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Zulu", 1730613600000L), Some(0))
  assert_eq(@date.zone_offset_minutes("Zulu", 2145916799000L), Some(0))
}

///|
test "@date 段界两侧各差一段（腿 T 行，段数最多的前 10 区）（第 1/12 块，本块 200 条）" {
  assert_eq(@date.zone_offset_minutes("America/Boise", 9968399000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("America/Boise", 9968400000L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 25689599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 25689600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 41417999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 41418000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 57743999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 57744000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 73472399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 73472400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 89193599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 89193600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 104921999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 104922000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 120643199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 120643200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 129113999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 129114000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 152092799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 152092800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 162377999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 162378000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 183542399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 183542400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 199270799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 199270800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 215596799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 215596800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 230720399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 230720400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 247046399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 247046400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 262774799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 262774800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 278495999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 278496000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 294224399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 294224400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 309945599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 309945600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 325673999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 325674000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 341395199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 341395200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 357123599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 357123600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 372844799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 372844800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 388573199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 388573200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 404899199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 404899200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 420022799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 420022800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 436348799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 436348800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 452077199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 452077200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 467798399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 467798400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 483526799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 483526800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 499247999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 499248000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 514976399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 514976400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 530697599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 530697600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 544611599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 544611600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 562147199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 562147200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 576061199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 576061200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 594201599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 594201600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 607510799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 607510800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 625651199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 625651200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 638960399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 638960400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 657100799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 657100800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 671014799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 671014800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 688550399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 688550400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 702464399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 702464400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 719999999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 720000000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 733913999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 733914000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 752054399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 752054400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 765363599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 765363600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 783503999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 783504000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 796813199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 796813200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 814953599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 814953600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 828867599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 828867600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 846403199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 846403200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 860317199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 860317200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 877852799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 877852800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 891766799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 891766800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 909302399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 909302400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 923216399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 923216400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 941356799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 941356800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 954665999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 954666000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 972806399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 972806400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 986115599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 986115600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1004255999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1004256000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1018169999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1018170000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1035705599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1035705600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1049619599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1049619600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1067155199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1067155200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1081069199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1081069200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1099209599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1099209600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1112518799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1112518800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1130659199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1130659200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1143968399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1143968400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1162108799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1162108800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1173603599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1173603600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1194163199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1194163200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1205053199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1205053200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1225612799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1225612800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1236502799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1236502800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1257062399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1257062400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1268557199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1268557200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1289116799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1289116800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1300006799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1300006800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1320566399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1320566400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1331456399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1331456400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1352015999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1352016000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1362905999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1362906000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1383465599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1383465600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1394355599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1394355600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1414915199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1414915200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1425805199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1425805200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1446364799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1446364800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1457859599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1457859600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1478419199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1478419200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1489309199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1489309200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1509868799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1509868800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1520758799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1520758800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1541318399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1541318400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1552208399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1552208400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1572767999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1572768000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1583657999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1583658000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1604217599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1604217600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1615712399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1615712400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1636271999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1636272000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1647161999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1647162000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1667721599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1667721600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1678611599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1678611600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1699171199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1699171200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1710061199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1710061200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1730620799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1730620800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1741510799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1741510800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1762070399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1762070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1772960399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1772960400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1793519999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1793520000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1805014799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1805014800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1825574399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1825574400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1836464399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1836464400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1857023999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1857024000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1867913999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1867914000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1888473599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1888473600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1899363599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1899363600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1919923199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1919923200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1930813199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1930813200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1951372799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1951372800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1962867599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1962867600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1983427199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1983427200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1994317199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1994317200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2014876799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2014876800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2025766799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2025766800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2046326399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2046326400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2057216399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2057216400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2077775999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2077776000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2088665999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2088666000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2109225599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2109225600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2120115599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2120115600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2140675199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2140675200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2152169999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2152170000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2172729599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2172729600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2183619599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2183619600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2204179199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2204179200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2215069199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2215069200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2235628799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2235628800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2246518799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2246518800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2267078399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2267078400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2277968399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2277968400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2298527999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2298528000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2309417999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2309418000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2329977599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2329977600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2341472399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2341472400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2362031999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2362032000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2372921999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2372922000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2393481599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2393481600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2404371599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2404371600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2424931199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2424931200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2435821199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2435821200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2456380799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2456380800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2467270799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2467270800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2487830399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2487830400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2499325199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2499325200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2519884799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 2519884800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 9964799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 9964800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 25685999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 25686000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 41414399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 41414400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 57740399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 57740400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 73468799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 73468800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 89189999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 89190000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 104918399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 104918400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 120639599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 120639600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 126691199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 126691200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 152089199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 152089200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 162374399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 162374400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 183538799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 183538800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 199267199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 199267200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 215593199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 215593200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 230716799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 230716800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 247042799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 247042800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 262771199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 262771200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 278492399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 278492400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 294220799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 294220800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 309941999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 309942000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 325670399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 325670400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 341391599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 341391600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 357119999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 357120000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 372841199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 372841200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 388569599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 388569600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 404895599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 404895600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 420019199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 420019200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 436345199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 436345200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 452073599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 452073600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 467794799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 467794800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 483523199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 483523200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 499244399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 499244400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 514972799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 514972800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 530693999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 530694000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 544607999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 544608000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 562143599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 562143600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 576057599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 576057600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 594197999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 594198000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 607507199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 607507200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 625647599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 625647600000L),
    Some(-360),
  )
}

///|
test "@date 段界两侧各差一段（腿 T 行，段数最多的前 10 区）（第 2/12 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 638956799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 638956800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 657097199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 657097200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 671011199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 671011200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 688546799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 688546800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 702460799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 702460800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 719996399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 719996400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 733910399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 733910400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 752050799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 752050800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 765359999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 765360000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 783500399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 783500400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 796809599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 796809600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 814949999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 814950000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 828863999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 828864000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 846399599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 846399600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 860313599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 860313600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 877849199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 877849200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 891763199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 891763200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 909298799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 909298800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 923212799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 923212800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 941353199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 941353200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 954662399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 954662400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 972802799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 972802800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 986111999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 986112000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1004252399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1004252400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1018166399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1018166400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1035701999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1035702000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1049615999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1049616000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1067151599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1067151600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1081065599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1081065600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1099205999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1099206000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1112515199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1112515200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1130655599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1130655600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1143964799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1143964800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1162105199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1162105200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1173599999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1173600000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1194159599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1194159600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1205049599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1205049600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1225609199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1225609200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1236499199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1236499200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1257058799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1257058800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1268553599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1268553600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1289113199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1289113200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1300003199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1300003200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1320562799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1320562800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1331452799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1331452800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1352012399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1352012400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1362902399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1362902400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1383461999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1383462000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1394351999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1394352000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1414911599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1414911600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1425801599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1425801600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1446361199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1446361200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1457855999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1457856000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1478415599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1478415600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1489305599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1489305600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1509865199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1509865200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1520755199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1520755200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1541314799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1541314800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1552204799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1552204800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1572764399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1572764400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1583654399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1583654400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1604213999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1604214000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1615708799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1615708800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1636268399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1636268400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1647158399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1647158400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1667717999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1667718000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1678607999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1678608000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1699167599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1699167600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1710057599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1710057600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1730617199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1730617200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1741507199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1741507200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1762066799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1762066800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1772956799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1772956800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1793516399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1793516400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1805011199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1805011200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1825570799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1825570800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1836460799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1836460800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1857020399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1857020400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1867910399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1867910400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1888469999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1888470000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1899359999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1899360000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1919919599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1919919600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1930809599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1930809600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1951369199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1951369200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1962863999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1962864000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1983423599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1983423600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1994313599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1994313600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2014873199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2014873200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2025763199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2025763200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2046322799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2046322800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2057212799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2057212800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2077772399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2077772400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2088662399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2088662400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2109221999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2109222000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2120111999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2120112000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2140671599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2140671600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2152166399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2152166400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2172725999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2172726000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2183615999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2183616000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2204175599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2204175600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2215065599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2215065600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2235625199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2235625200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2246515199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2246515200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2267074799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2267074800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2277964799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2277964800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2298524399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2298524400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2309414399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2309414400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2329973999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2329974000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2341468799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2341468800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2362028399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2362028400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2372918399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2372918400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2393477999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2393478000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2404367999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2404368000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2424927599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2424927600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2435817599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2435817600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2456377199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2456377200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2467267199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2467267200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2487826799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2487826800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2499321599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2499321600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2519881199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 2519881200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 9968399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 9968400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 25689599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 25689600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 41417999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 41418000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 57743999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 57744000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 73472399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 73472400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 89193599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 89193600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 104921999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 104922000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 120643199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 120643200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 126694799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 126694800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 152092799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 152092800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 162377999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 162378000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 183542399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 183542400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 199270799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 199270800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 215596799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 215596800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 230720399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 230720400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 247046399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 247046400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 262774799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 262774800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 278495999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 278496000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 294224399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 294224400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 309945599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 309945600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 325673999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 325674000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 341395199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 341395200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 357123599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 357123600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 372844799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 372844800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 388573199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 388573200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 404899199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 404899200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 420022799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 420022800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 436348799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 436348800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 452077199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 452077200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 467798399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 467798400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 483526799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 483526800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 499247999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 499248000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 514976399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 514976400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 530697599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 530697600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 544611599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 544611600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 562147199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 562147200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 576061199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 576061200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 594201599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 594201600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 607510799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 607510800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 625651199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 625651200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 638960399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 638960400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 657100799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 657100800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 671014799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 671014800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 688550399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 688550400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 702464399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 702464400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 719999999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 720000000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 733913999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 733914000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 752054399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 752054400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 765363599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 765363600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 783503999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 783504000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 796813199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 796813200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 814953599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 814953600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 828867599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 828867600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 846403199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 846403200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 860317199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 860317200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 877852799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 877852800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 891766799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 891766800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 909302399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 909302400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 923216399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 923216400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 941356799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 941356800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 954665999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 954666000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 972806399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 972806400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 986115599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 986115600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1004255999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1004256000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1018169999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1018170000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1035705599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1035705600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1049619599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1049619600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1067155199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1067155200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1081069199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1081069200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1099209599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1099209600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1112518799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1112518800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1130659199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1130659200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1143968399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1143968400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1162108799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1162108800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1173603599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1173603600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1194163199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1194163200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1205053199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1205053200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1225612799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1225612800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1236502799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1236502800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1257062399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1257062400000L),
    Some(-420),
  )
}

///|
test "@date 段界两侧各差一段（腿 T 行，段数最多的前 10 区）（第 3/12 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1268557199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1268557200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1289116799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1289116800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1300006799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1300006800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1320566399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1320566400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1331456399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1331456400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1352015999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1352016000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1362905999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1362906000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1383465599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1383465600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1394355599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1394355600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1414915199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1414915200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1425805199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1425805200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1446364799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1446364800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1457859599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1457859600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1478419199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1478419200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1489309199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1489309200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1509868799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1509868800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1520758799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1520758800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1541318399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1541318400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1552208399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1552208400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1572767999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1572768000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1583657999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1583658000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1604217599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1604217600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1615712399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1615712400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1636271999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1636272000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1647161999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1647162000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1667721599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1667721600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1678611599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1678611600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1699171199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1699171200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1710061199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1710061200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1730620799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1730620800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1741510799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1741510800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1762070399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1762070400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1772960399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1772960400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1793519999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1793520000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1805014799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1805014800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1825574399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1825574400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1836464399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1836464400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1857023999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1857024000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1867913999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1867914000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1888473599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1888473600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1899363599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1899363600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1919923199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1919923200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1930813199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1930813200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1951372799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1951372800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1962867599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1962867600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1983427199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1983427200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1994317199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1994317200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2014876799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2014876800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2025766799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2025766800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2046326399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2046326400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2057216399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2057216400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2077775999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2077776000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2088665999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2088666000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2109225599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2109225600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2120115599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2120115600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2140675199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2140675200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2152169999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2152170000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2172729599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2172729600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2183619599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2183619600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2204179199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2204179200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2215069199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2215069200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2235628799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2235628800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2246518799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2246518800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2267078399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2267078400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2277968399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2277968400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2298527999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2298528000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2309417999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2309418000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2329977599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2329977600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2341472399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2341472400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2362031999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2362032000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2372921999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2372922000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2393481599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2393481600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2404371599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2404371600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2424931199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2424931200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2435821199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2435821200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2456380799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2456380800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2467270799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2467270800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2487830399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2487830400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2499325199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2499325200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2519884799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 2519884800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 9957599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 9957600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 25678799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 25678800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 41407199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 41407200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 57733199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 57733200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 73461599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 73461600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 89182799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 89182800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 104911199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 104911200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 120632399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 120632400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 136360799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 136360800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 152081999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 152082000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 167810399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 167810400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 183531599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 183531600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 199259999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 199260000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 215585999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 215586000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 230709599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 230709600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 247035599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 247035600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 262763999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 262764000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 278485199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 278485200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 294213599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 294213600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 309934799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 309934800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 325663199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 325663200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 341384399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 341384400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 357112799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 357112800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 372833999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 372834000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 388562399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 388562400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 404888399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 404888400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 420011999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 420012000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 436337999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 436338000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 452066399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 452066400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 467787599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 467787600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 483515999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 483516000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 499237199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 499237200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 514965599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 514965600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 530686799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 530686800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 544593659000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 544593660000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 562129259000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 562129260000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 576043259000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 576043260000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 594180059000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 594180060000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 607492859000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 607492860000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 625633259000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 625633260000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 638942459000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 638942460000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 657082859000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 657082860000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 670996859000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 670996860000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 688532459000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 688532460000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 702446459000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 702446460000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 719982059000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 719982060000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 733896059000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 733896060000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 752036459000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 752036460000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 765345659000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 765345660000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 783486059000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 783486060000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 796795259000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 796795260000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 814935659000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 814935660000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 828849659000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 828849660000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 846385259000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 846385260000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 860299259000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 860299260000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 877834859000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 877834860000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 891748859000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 891748860000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 909284459000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 909284460000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 923198459000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 923198460000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 941338859000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 941338860000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 954648059000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 954648060000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 972788459000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 972788460000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 986097659000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 986097660000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1004238059000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1004238060000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1018152059000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1018152060000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1035687659000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1035687660000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1049601659000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1049601660000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1067137259000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1067137260000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1081051259000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1081051260000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1099191659000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1099191660000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1112500859000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1112500860000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1130641259000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1130641260000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1143950459000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1143950460000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1162090859000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1162090860000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1173585659000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1173585660000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1194145259000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1194145260000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1205035259000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1205035260000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1225594859000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1225594860000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1236484859000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1236484860000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1257044459000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1257044460000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1268539259000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1268539260000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1289098859000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1289098860000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1299988859000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1299988860000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1320555599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1320555600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1331445599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1331445600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1352005199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1352005200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1362895199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1362895200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1383454799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1383454800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1394344799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1394344800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1414904399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1414904400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1425794399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1425794400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1446353999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1446354000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1457848799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1457848800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1478408399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1478408400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1489298399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1489298400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1509857999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1509858000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1520747999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1520748000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1541307599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1541307600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1552197599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1552197600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1572757199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1572757200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1583647199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1583647200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1604206799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1604206800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1615701599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1615701600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1636261199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1636261200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1647151199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1647151200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1667710799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1667710800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1678600799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1678600800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1699160399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1699160400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1710050399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1710050400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1730609999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1730610000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1741499999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1741500000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1762059599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1762059600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1772949599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1772949600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1793509199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1793509200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1805003999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1805004000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1825563599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1825563600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1836453599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1836453600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1857013199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1857013200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1867903199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1867903200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1888462799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1888462800000L),
    Some(-240),
  )
}

///|
test "@date 段界两侧各差一段（腿 T 行，段数最多的前 10 区）（第 4/12 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1899352799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1899352800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1919912399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1919912400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1930802399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1930802400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1951361999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1951362000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1962856799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1962856800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1983416399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1983416400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1994306399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1994306400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2014865999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2014866000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2025755999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2025756000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2046315599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2046315600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2057205599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2057205600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2077765199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2077765200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2088655199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2088655200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2109214799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2109214800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2120104799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2120104800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2140664399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2140664400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2152159199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2152159200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2172718799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2172718800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2183608799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2183608800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2204168399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2204168400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2215058399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2215058400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2235617999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2235618000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2246507999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2246508000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2267067599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2267067600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2277957599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2277957600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2298517199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2298517200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2309407199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2309407200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2329966799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2329966800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2341461599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2341461600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2362021199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2362021200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2372911199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2372911200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2393470799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2393470800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2404360799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2404360800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2424920399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2424920400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2435810399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2435810400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2456369999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2456370000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2467259999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2467260000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2487819599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2487819600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2499314399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2499314400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2519873999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 2519874000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 9957599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 9957600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 25678799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 25678800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 41407199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 41407200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 57733199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 57733200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 73461599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 73461600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 89182799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 89182800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 104911199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 104911200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 120632399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 120632400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 136360799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 136360800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 152081999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 152082000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 167810399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 167810400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 183531599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 183531600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 199259999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 199260000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 215585999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 215586000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 230709599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 230709600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 247035599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 247035600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 262763999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 262764000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 278485199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 278485200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 294213599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 294213600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 309934799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 309934800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 325663199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 325663200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 341384399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 341384400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 357112799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 357112800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 372833999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 372834000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 388562399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 388562400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 404888399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 404888400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 420011999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 420012000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 436337999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 436338000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 452066399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 452066400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 467787599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 467787600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 483515999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 483516000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 499237199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 499237200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 514965599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 514965600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 530686799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 530686800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 544600799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 544600800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 562136399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 562136400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 576050399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 576050400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 594190799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 594190800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 607499999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 607500000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 625640399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 625640400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 638949599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 638949600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 657089999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 657090000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 671003999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 671004000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 688539599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 688539600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 702453599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 702453600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 719989199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 719989200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 733903199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 733903200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 752043599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 752043600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 765352799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 765352800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 783493199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 783493200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 796802399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 796802400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 814942799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 814942800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 828856799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 828856800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 846392399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 846392400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 860306399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 860306400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 877841999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 877842000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 891755999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 891756000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 909291599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 909291600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 923205599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 923205600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 941345999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 941346000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 954655199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 954655200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 972795599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 972795600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 986104799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 986104800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1004245199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1004245200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1018159199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1018159200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1035694799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1035694800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1049608799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1049608800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1067144399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1067144400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1081058399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1081058400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1099198799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1099198800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1112507999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1112508000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1130648399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1130648400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1143957599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1143957600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1162097999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1162098000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1173592799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1173592800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1194152399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1194152400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1205042399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1205042400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1225601999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1225602000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1236491999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1236492000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1257051599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1257051600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1268546399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1268546400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1289105999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1289106000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1299995999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1299996000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1320555599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1320555600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1331445599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1331445600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1352005199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1352005200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1362895199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1362895200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1383454799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1383454800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1394344799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1394344800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1414904399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1414904400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1425794399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1425794400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1446353999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1446354000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1457848799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1457848800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1478408399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1478408400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1489298399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1489298400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1509857999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1509858000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1520747999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1520748000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1541307599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1541307600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1552197599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1552197600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1572757199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1572757200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1583647199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1583647200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1604206799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1604206800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1615701599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1615701600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1636261199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1636261200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1647151199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1647151200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1667710799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1667710800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1678600799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1678600800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1699160399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1699160400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1710050399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1710050400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1730609999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1730610000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1741499999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1741500000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1762059599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1762059600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1772949599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1772949600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1793509199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1793509200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1805003999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1805004000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1825563599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1825563600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1836453599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1836453600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1857013199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1857013200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1867903199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1867903200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1888462799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1888462800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1899352799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1899352800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1919912399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1919912400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1930802399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1930802400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1951361999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1951362000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1962856799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1962856800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1983416399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1983416400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1994306399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1994306400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2014865999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2014866000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2025755999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2025756000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2046315599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2046315600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2057205599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2057205600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2077765199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2077765200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2088655199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2088655200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2109214799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2109214800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2120104799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2120104800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2140664399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2140664400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2152159199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2152159200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2172718799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2172718800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2183608799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2183608800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2204168399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2204168400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2215058399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2215058400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2235617999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2235618000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2246507999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2246508000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2267067599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2267067600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2277957599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2277957600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2298517199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2298517200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2309407199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2309407200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2329966799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2329966800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2341461599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2341461600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2362021199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2362021200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2372911199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2372911200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2393470799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2393470800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2404360799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2404360800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2424920399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2424920400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2435810399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2435810400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2456369999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2456370000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2467259999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2467260000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2487819599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2487819600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2499314399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2499314400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2519873999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 2519874000000L),
    Some(-240),
  )
}

///|
test "@date 段界两侧各差一段（腿 T 行，段数最多的前 10 区）（第 5/12 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 9971999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 9972000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 25693199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 25693200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 41421599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 41421600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 57747599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 57747600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 73475999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 73476000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 89197199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 89197200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 104925599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 104925600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 120646799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 120646800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 126698399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 126698400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 152096399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 152096400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 162381599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 162381600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 183545999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 183546000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 199274399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 199274400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 215600399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 215600400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 230723999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 230724000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 247049999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 247050000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 262778399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 262778400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 278499599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 278499600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 294227999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 294228000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 309949199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 309949200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 325677599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 325677600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 341398799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 341398800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 357127199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 357127200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 372848399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 372848400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 388576799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 388576800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 404902799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 404902800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 420026399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 420026400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 436352399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 436352400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 452080799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 452080800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 467801999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 467802000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 483530399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 483530400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 499251599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 499251600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 514979999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 514980000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 530701199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 530701200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 544615199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 544615200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 562150799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 562150800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 576064799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 576064800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 594205199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 594205200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 607514399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 607514400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 625654799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 625654800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 638963999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 638964000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 657104399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 657104400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 671018399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 671018400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 688553999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 688554000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 702467999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 702468000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 720003599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 720003600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 733917599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 733917600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 752057999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 752058000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 765367199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 765367200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 783507599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 783507600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 796816799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 796816800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 814957199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 814957200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 828871199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 828871200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 846406799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 846406800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 860320799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 860320800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 877856399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 877856400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 891770399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 891770400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 909305999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 909306000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 923219999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 923220000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 941360399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 941360400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 954669599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 954669600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 972809999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 972810000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 986119199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 986119200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1004259599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1004259600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1018173599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1018173600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1035709199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1035709200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1049623199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1049623200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1067158799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1067158800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1081072799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1081072800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1099213199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1099213200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1112522399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1112522400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1130662799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1130662800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1143971999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1143972000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1162112399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1162112400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1173607199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1173607200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1194166799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1194166800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1205056799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1205056800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1225616399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1225616400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1236506399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1236506400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1257065999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1257066000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1268560799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1268560800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1289120399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1289120400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1300010399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1300010400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1320569999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1320570000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1331459999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1331460000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1352019599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1352019600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1362909599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1362909600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1383469199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1383469200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1394359199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1394359200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1414918799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1414918800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1425808799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1425808800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1446368399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1446368400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1457863199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1457863200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1478422799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1478422800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1489312799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1489312800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1509872399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1509872400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1520762399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1520762400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1541321999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1541322000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1552211999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1552212000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1572771599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1572771600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1583661599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1583661600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1604221199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1604221200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1615715999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1615716000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1636275599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1636275600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1647165599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1647165600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1667725199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1667725200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1678615199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1678615200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1699174799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1699174800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1710064799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1710064800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1730624399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1730624400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1741514399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1741514400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1762073999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1762074000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1772963999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1772964000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1793523599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1793523600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1805018399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1805018400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1825577999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1825578000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1836467999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1836468000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1857027599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1857027600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1867917599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1867917600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1888477199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1888477200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1899367199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1899367200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1919926799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1919926800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1930816799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1930816800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1951376399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1951376400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1962871199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1962871200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1983430799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1983430800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1994320799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1994320800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2014880399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2014880400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2025770399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2025770400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2046329999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2046330000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2057219999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2057220000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2077779599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2077779600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2088669599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2088669600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2109229199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2109229200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2120119199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2120119200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2140678799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2140678800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2152173599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2152173600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2172733199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2172733200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2183623199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2183623200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2204182799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2204182800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2215072799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2215072800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2235632399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2235632400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2246522399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2246522400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2267081999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2267082000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2277971999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2277972000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2298531599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2298531600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2309421599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2309421600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2329981199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2329981200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2341475999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2341476000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2362035599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2362035600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2372925599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2372925600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2393485199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2393485200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2404375199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2404375200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2424934799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2424934800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2435824799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2435824800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2456384399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2456384400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2467274399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2467274400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2487833999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2487834000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2499328799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2499328800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2519888399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 2519888400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 9961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 9961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 25682399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 25682400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 41410799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 41410800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 57736799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 57736800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 73465199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 73465200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 89186399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 89186400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 104914799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 104914800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 120635999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 120636000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 136364399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 136364400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 152085599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 152085600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 167813999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 167814000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 183535199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 183535200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 199263599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 199263600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 215589599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 215589600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 230713199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 230713200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 247039199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 247039200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 262767599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 262767600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 278488799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 278488800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 294217199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 294217200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 309938399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 309938400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 325666799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 325666800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 341387999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 341388000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 357116399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 357116400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 372837599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 372837600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 388565999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 388566000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 404891999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 404892000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 420015599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 420015600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 436341599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 436341600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 452069999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 452070000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 467791199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 467791200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 483519599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 483519600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 499240799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 499240800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 514969199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 514969200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 530690399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 530690400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 544604399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 544604400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 562139999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 562140000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 576053999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 576054000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 594194399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 594194400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 607503599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 607503600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 625643999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 625644000000L),
    Some(-300),
  )
}

///|
test "@date 段界两侧各差一段（腿 T 行，段数最多的前 10 区）（第 6/12 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 638953199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 638953200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 657093599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 657093600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 671007599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 671007600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 688543199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 688543200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 702457199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 702457200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 719992799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 719992800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 733906799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 733906800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 752047199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 752047200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 765356399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 765356400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 783496799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 783496800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 796805999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 796806000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 814946399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 814946400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 828860399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 828860400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 846395999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 846396000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 860309999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 860310000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 877845599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 877845600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 891759599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 891759600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 909295199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 909295200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 923209199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 923209200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 941349599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 941349600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 954658799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 954658800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 972799199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 972799200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 986108399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 986108400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1004248799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1004248800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1018162799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1018162800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1035698399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1035698400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1049612399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1049612400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1067147999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1067148000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1081061999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1081062000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1099202399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1099202400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1112511599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1112511600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1130651999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1130652000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1143961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1143961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1162101599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1162101600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1173596399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1173596400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1194155999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1194156000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1205045999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1205046000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1225605599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1225605600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1236495599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1236495600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1257055199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1257055200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1268549999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1268550000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1289109599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1289109600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1299999599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1299999600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1320559199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1320559200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1331449199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1331449200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1352008799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1352008800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1362898799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1362898800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1383458399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1383458400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1394348399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1394348400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1414907999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1414908000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1425797999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1425798000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1446357599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1446357600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1457852399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1457852400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1478411999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1478412000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1489301999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1489302000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1509861599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1509861600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1520751599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1520751600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1541311199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1541311200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1552201199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1552201200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1572760799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1572760800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1583650799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1583650800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1604210399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1604210400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1615705199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1615705200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1636264799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1636264800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1647154799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1647154800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1667714399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1667714400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1678604399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1678604400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1699163999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1699164000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1710053999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1710054000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1730613599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1741503599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1741503600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1762063199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1762063200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1772953199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1772953200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1793512799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1793512800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1805007599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1805007600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1825567199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1825567200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1836457199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1836457200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1857016799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1857016800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1867906799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1867906800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1888466399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1888466400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1899356399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1899356400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1919915999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1919916000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1930805999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1930806000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1951365599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1951365600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1962860399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1962860400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1983419999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1983420000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1994309999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1994310000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2014869599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2014869600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2025759599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2025759600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2046319199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2046319200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2057209199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2057209200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2077768799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2077768800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2088658799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2088658800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2109218399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2109218400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2120108399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2120108400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2140667999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2140668000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2152162799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2152162800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2172722399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2172722400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2183612399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2183612400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2204171999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2204172000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2215061999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2215062000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2235621599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2235621600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2246511599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2246511600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2267071199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2267071200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2277961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2277961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2298520799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2298520800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2309410799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2309410800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2329970399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2329970400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2341465199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2341465200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2362024799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2362024800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2372914799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2372914800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2393474399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2393474400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2404364399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2404364400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2424923999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2424924000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2435813999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2435814000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2456373599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2456373600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2467263599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2467263600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2487823199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2487823200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2499317999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2499318000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2519877599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 2519877600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 9961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 9961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 25682399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 25682400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 41410799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 41410800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 57736799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 57736800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 73465199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 73465200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 89186399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 89186400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 104914799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 104914800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 120635999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 120636000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 136364399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 136364400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 152085599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 152085600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 167813999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 167814000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 183535199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 183535200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 199263599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 199263600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 215589599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 215589600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 230713199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 230713200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 247039199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 247039200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 262767599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 262767600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 278488799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 278488800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 294217199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 294217200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 309938399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 309938400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 325666799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 325666800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 341387999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 341388000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 357116399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 357116400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 372837599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 372837600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 388565999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 388566000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 404891999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 404892000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 420015599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 420015600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 436341599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 436341600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 452069999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 452070000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 467791199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 467791200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 483519599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 483519600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 499240799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 499240800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 514969199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 514969200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 530690399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 530690400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 544604399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 544604400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 562139999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 562140000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 576053999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 576054000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 594194399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 594194400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 607503599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 607503600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 625643999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 625644000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 638953199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 638953200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 657093599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 657093600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 671007599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 671007600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 688543199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 688543200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 702457199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 702457200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 719992799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 719992800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 733906799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 733906800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 752047199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 752047200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 765356399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 765356400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 783496799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 783496800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 796805999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 796806000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 814946399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 814946400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 828860399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 828860400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 846395999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 846396000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 860309999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 860310000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 877845599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 877845600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 891759599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 891759600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 909295199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 909295200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 923209199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 923209200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 941349599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 941349600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 954658799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 954658800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 972799199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 972799200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 986108399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 986108400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1004248799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1004248800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1018162799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1018162800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1035698399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1035698400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1049612399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1049612400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1067147999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1067148000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1081061999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1081062000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1099202399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1099202400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1112511599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1112511600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1130651999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1130652000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1143961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1143961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1162101599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1162101600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1173596399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1173596400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1194155999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1194156000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1205045999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1205046000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1225605599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1225605600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1236495599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1236495600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1257055199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1257055200000L),
    Some(-300),
  )
}

///|
test "@date 段界两侧各差一段（腿 T 行，段数最多的前 10 区）（第 7/12 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1268549999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1268550000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1289109599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1289109600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1299999599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1299999600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1320559199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1320559200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1331449199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1331449200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1352008799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1352008800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1362898799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1362898800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1383458399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1383458400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1394348399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1394348400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1414907999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1414908000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1425797999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1425798000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1446357599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1446357600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1457852399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1457852400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1478411999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1478412000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1489301999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1489302000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1509861599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1509861600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1520751599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1520751600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1541311199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1541311200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1552201199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1552201200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1572760799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1572760800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1583650799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1583650800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1604210399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1604210400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1615705199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1615705200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1636264799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1636264800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1647154799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1647154800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1667714399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1667714400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1678604399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1678604400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1699163999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1699164000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1710053999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1710054000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1730613599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1741503599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1741503600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1762063199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1762063200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1772953199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1772953200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1793512799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1793512800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1805007599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1805007600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1825567199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1825567200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1836457199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1836457200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1857016799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1857016800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1867906799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1867906800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1888466399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1888466400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1899356399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1899356400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1919915999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1919916000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1930805999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1930806000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1951365599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1951365600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1962860399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1962860400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1983419999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1983420000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1994309999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1994310000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2014869599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2014869600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2025759599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2025759600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2046319199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2046319200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2057209199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2057209200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2077768799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2077768800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2088658799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2088658800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2109218399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2109218400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2120108399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2120108400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2140667999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2140668000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2152162799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2152162800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2172722399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2172722400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2183612399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2183612400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2204171999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2204172000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2215061999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2215062000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2235621599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2235621600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2246511599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2246511600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2267071199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2267071200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2277961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2277961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2298520799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2298520800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2309410799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2309410800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2329970399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2329970400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2341465199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2341465200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2362024799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2362024800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2372914799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2372914800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2393474399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2393474400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2404364399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2404364400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2424923999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2424924000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2435813999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2435814000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2456373599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2456373600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2467263599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2467263600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2487823199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2487823200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2499317999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2499318000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2519877599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 2519877600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 9961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 9961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 25682399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 25682400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 41410799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 41410800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 57736799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 57736800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 73465199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 73465200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 89186399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 89186400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 104914799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 104914800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 120635999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 120636000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 126687599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 126687600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 152085599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 152085600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 162370799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 162370800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 183535199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 183535200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 199263599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 199263600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 215589599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 215589600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 230713199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 230713200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 247039199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 247039200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 262767599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 262767600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 278488799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 278488800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 294217199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 294217200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 309938399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 309938400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 325666799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 325666800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 341387999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 341388000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 357116399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 357116400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 372837599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 372837600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 388565999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 388566000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 404891999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 404892000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 420015599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 420015600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 436341599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 436341600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 452069999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 452070000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 467791199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 467791200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 483519599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 483519600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 499240799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 499240800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 514969199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 514969200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 530690399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 530690400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 544604399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 544604400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 562139999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 562140000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 576053999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 576054000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 594194399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 594194400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 607503599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 607503600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 625643999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 625644000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 638953199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 638953200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 657093599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 657093600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 671007599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 671007600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 688543199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 688543200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 702457199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 702457200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 719992799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 719992800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 733906799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 733906800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 752047199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 752047200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 765356399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 765356400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 783496799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 783496800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 796805999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 796806000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 814946399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 814946400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 828860399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 828860400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 846395999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 846396000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 860309999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 860310000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 877845599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 877845600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 891759599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 891759600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 909295199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 909295200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 923209199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 923209200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 941349599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 941349600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 954658799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 954658800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 972799199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 972799200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 986108399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 986108400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1004248799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1004248800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1018162799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1018162800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1035698399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1035698400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1049612399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1049612400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1067147999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1067148000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1081061999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1081062000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1099202399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1099202400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1112511599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1112511600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1130651999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1130652000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1143961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1143961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1162101599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1162101600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1173596399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1173596400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1194155999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1194156000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1205045999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1205046000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1225605599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1225605600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1236495599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1236495600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1257055199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1257055200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1268549999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1268550000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1289109599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1289109600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1299999599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1299999600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1320559199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1320559200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1331449199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1331449200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1352008799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1352008800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1362898799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1362898800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1383458399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1383458400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1394348399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1394348400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1414907999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1414908000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1425797999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1425798000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1446357599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1446357600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1457852399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1457852400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1478411999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1478412000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1489301999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1489302000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1509861599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1509861600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1520751599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1520751600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1541311199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1541311200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1552201199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1552201200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1572760799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1572760800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1583650799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1583650800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1604210399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1604210400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1615705199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1615705200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1636264799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1636264800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1647154799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1647154800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1667714399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1667714400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1678604399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1678604400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1699163999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1699164000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1710053999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1710054000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1730613599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1741503599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1741503600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1762063199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1762063200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1772953199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1772953200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1793512799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1793512800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1805007599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1805007600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1825567199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1825567200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1836457199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1836457200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1857016799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1857016800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1867906799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1867906800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1888466399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1888466400000L),
    Some(-300),
  )
}

///|
test "@date 段界两侧各差一段（腿 T 行，段数最多的前 10 区）（第 8/12 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1899356399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1899356400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1919915999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1919916000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1930805999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1930806000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1951365599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1951365600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1962860399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1962860400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1983419999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1983420000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1994309999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1994310000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2014869599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2014869600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2025759599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2025759600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2046319199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2046319200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2057209199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2057209200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2077768799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2077768800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2088658799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2088658800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2109218399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2109218400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2120108399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2120108400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2140667999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2140668000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2152162799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2152162800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2172722399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2172722400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2183612399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2183612400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2204171999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2204172000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2215061999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2215062000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2235621599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2235621600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2246511599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2246511600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2267071199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2267071200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2277961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2277961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2298520799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2298520800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2309410799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2309410800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2329970399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2329970400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2341465199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2341465200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2362024799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2362024800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2372914799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2372914800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2393474399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2393474400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2404364399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2404364400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2424923999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2424924000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2435813999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2435814000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2456373599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2456373600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2467263599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2467263600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2487823199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2487823200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2499317999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2499318000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2519877599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 2519877600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 9961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 9961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 25682399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 25682400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 41410799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 41410800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 57736799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 57736800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 73465199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 73465200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 89186399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 89186400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 104914799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 104914800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 120635999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 120636000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 136364399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 136364400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 152085599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 152085600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 167813999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 167814000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 183535199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 183535200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 199263599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 199263600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 215589599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 215589600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 230713199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 230713200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 247039199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 247039200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 262767599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 262767600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 278488799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 278488800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 294217199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 294217200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 309938399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 309938400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 325666799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 325666800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 341387999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 341388000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 357116399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 357116400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 372837599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 372837600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 388565999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 388566000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 404891999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 404892000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 420015599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 420015600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 436341599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 436341600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 452069999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 452070000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 467791199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 467791200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 483519599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 483519600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 499240799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 499240800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 514969199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 514969200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 530690399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 530690400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 544604399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 544604400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 562139999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 562140000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 576053999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 576054000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 594194399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 594194400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 607503599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 607503600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 625643999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 625644000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 638953199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 638953200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 657093599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 657093600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 671007599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 671007600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 688543199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 688543200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 702457199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 702457200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 719992799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 719992800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 733906799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 733906800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 752047199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 752047200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 765356399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 765356400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 783496799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 783496800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 796805999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 796806000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 814946399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 814946400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 828860399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 828860400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 846395999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 846396000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 860309999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 860310000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 877845599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 877845600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 891759599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 891759600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 909295199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 909295200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 923209199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 923209200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 941349599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 941349600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 954658799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 954658800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 972799199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 972799200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 986108399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 986108400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1004248799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1004248800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1018162799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1018162800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1035698399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1035698400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1049612399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1049612400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1067147999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1067148000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1081061999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1081062000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1099202399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1099202400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1112511599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1112511600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1130651999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1130652000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1143961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1143961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1162101599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1162101600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1173596399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1173596400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1194155999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1194156000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1205045999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1205046000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1225605599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1225605600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1236495599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1236495600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1257055199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1257055200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1268549999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1268550000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1289109599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1289109600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1299999599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1299999600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1320559199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1320559200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1331449199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1331449200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1352008799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1352008800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1362898799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1362898800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1383458399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1383458400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1394348399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1394348400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1414907999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1414908000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1425797999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1425798000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1446357599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1446357600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1457852399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1457852400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1478411999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1478412000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1489301999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1489302000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1509861599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1509861600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1520751599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1520751600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1541311199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1541311200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1552201199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1552201200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1572760799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1572760800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1583650799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1583650800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1604210399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1604210400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1615705199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1615705200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1636264799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1636264800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1647154799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1647154800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1667714399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1667714400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1678604399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1678604400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1699163999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1699164000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1710053999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1710054000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1730613599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1730613600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1741503599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1741503600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1762063199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1762063200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1772953199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1772953200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1793512799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1793512800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1805007599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1805007600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1825567199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1825567200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1836457199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1836457200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1857016799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1857016800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1867906799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1867906800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1888466399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1888466400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1899356399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1899356400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1919915999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1919916000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1930805999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1930806000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1951365599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1951365600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1962860399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1962860400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1983419999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1983420000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1994309999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1994310000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2014869599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2014869600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2025759599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2025759600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2046319199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2046319200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2057209199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2057209200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2077768799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2077768800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2088658799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2088658800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2109218399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2109218400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2120108399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2120108400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2140667999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2140668000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2152162799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2152162800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2172722399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2172722400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2183612399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2183612400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2204171999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2204172000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2215061999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2215062000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2235621599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2235621600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2246511599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2246511600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2267071199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2267071200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2277961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2277961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2298520799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2298520800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2309410799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2309410800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2329970399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2329970400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2341465199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2341465200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2362024799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2362024800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2372914799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2372914800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2393474399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2393474400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2404364399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2404364400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2424923999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2424924000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2435813999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2435814000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2456373599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2456373600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2467263599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2467263600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2487823199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2487823200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2499317999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2499318000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2519877599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 2519877600000L),
    Some(-300),
  )
}

///|
test "@date 段界两侧各差一段（腿 T 行，段数最多的前 10 区）（第 9/12 块，本块 200 条）" {
  assert_eq(@date.zone_offset_minutes("America/Boise", 9968399000L), Some(-420))
  assert_eq(@date.zone_offset_minutes("America/Boise", 9968400000L), Some(-360))
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 25689599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 25689600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 41417999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 41418000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 57743999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 57744000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 73472399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 73472400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 89193599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 89193600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 104921999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 104922000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 120643199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 120643200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 129113999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 129114000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 152092799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 152092800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 162377999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 162378000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 183542399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 183542400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 199270799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 199270800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 215596799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 215596800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 230720399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 230720400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 247046399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 247046400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 262774799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 262774800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 278495999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 278496000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 294224399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 294224400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 309945599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 309945600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 325673999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 325674000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 341395199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 341395200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 357123599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 357123600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 372844799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 372844800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 388573199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 388573200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 404899199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 404899200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 420022799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 420022800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 436348799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 436348800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 452077199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 452077200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 467798399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 467798400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 483526799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 483526800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 499247999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 499248000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 514976399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 514976400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 530697599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 530697600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 544611599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 544611600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 562147199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 562147200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 576061199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 576061200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 594201599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 594201600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 607510799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 607510800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 625651199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 625651200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 638960399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 638960400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 657100799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 657100800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 671014799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 671014800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 688550399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 688550400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 702464399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 702464400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 719999999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 720000000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 733913999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 733914000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 752054399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 752054400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 765363599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 765363600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 783503999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 783504000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 796813199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 796813200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 814953599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 814953600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 828867599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 828867600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 846403199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 846403200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 860317199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 860317200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 877852799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 877852800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 891766799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 891766800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 909302399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 909302400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 923216399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 923216400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 941356799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 941356800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 954665999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 954666000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 972806399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 972806400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 986115599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 986115600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1004255999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1004256000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1018169999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1018170000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1035705599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1035705600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1049619599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1049619600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1067155199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1067155200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1081069199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1081069200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1099209599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1099209600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1112518799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1112518800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1130659199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1130659200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1143968399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1143968400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1162108799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1162108800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1173603599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1173603600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1194163199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1194163200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1205053199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1205053200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1225612799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Boise", 1225612800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 9964799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 9964800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 25685999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 25686000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 41414399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 41414400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 57740399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 57740400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 73468799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 73468800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 89189999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 89190000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 104918399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 104918400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 120639599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 120639600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 126691199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 126691200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 152089199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 152089200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 162374399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 162374400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 183538799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 183538800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 199267199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 199267200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 215593199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 215593200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 230716799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 230716800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 247042799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 247042800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 262771199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 262771200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 278492399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 278492400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 294220799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 294220800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 309941999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 309942000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 325670399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 325670400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 341391599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 341391600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 357119999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 357120000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 372841199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 372841200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 388569599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 388569600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 404895599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 404895600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 420019199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 420019200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 436345199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 436345200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 452073599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 452073600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 467794799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 467794800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 483523199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 483523200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 499244399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 499244400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 514972799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 514972800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 530693999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 530694000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 544607999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 544608000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 562143599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 562143600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 576057599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 576057600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 594197999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 594198000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 607507199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 607507200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 625647599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 625647600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 638956799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 638956800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 657097199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 657097200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 671011199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 671011200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 688546799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 688546800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 702460799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 702460800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 719996399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 719996400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 733910399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 733910400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 752050799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 752050800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 765359999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 765360000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 783500399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 783500400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 796809599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 796809600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 814949999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 814950000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 828863999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 828864000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 846399599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 846399600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 860313599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 860313600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 877849199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 877849200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 891763199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 891763200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 909298799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 909298800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 923212799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 923212800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 941353199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 941353200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 954662399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 954662400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 972802799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 972802800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 986111999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 986112000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1004252399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1004252400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1018166399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1018166400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1035701999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1035702000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1049615999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1049616000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1067151599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1067151600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1081065599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1081065600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1099205999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1099206000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1112515199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1112515200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1130655599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1130655600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1143964799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1143964800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1162105199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1162105200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1173599999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1173600000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1194159599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1194159600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1205049599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1205049600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1225609199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Chicago", 1225609200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 9968399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 9968400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 25689599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 25689600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 41417999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 41418000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 57743999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 57744000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 73472399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 73472400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 89193599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 89193600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 104921999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 104922000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 120643199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 120643200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 126694799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 126694800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 152092799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 152092800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 162377999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 162378000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 183542399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 183542400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 199270799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 199270800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 215596799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 215596800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 230720399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 230720400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 247046399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 247046400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 262774799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 262774800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 278495999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 278496000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 294224399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 294224400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 309945599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 309945600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 325673999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 325674000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 341395199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 341395200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 357123599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 357123600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 372844799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 372844800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 388573199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 388573200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 404899199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 404899200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 420022799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 420022800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 436348799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 436348800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 452077199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 452077200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 467798399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 467798400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 483526799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 483526800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 499247999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 499248000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 514976399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 514976400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 530697599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 530697600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 544611599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 544611600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 562147199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 562147200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 576061199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 576061200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 594201599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 594201600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 607510799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 607510800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 625651199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 625651200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 638960399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 638960400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 657100799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 657100800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 671014799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 671014800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 688550399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 688550400000L),
    Some(-420),
  )
}

///|
test "@date 段界两侧各差一段（腿 T 行，段数最多的前 10 区）（第 10/12 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 702464399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 702464400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 719999999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 720000000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 733913999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 733914000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 752054399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 752054400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 765363599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 765363600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 783503999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 783504000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 796813199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 796813200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 814953599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 814953600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 828867599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 828867600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 846403199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 846403200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 860317199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 860317200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 877852799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 877852800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 891766799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 891766800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 909302399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 909302400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 923216399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 923216400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 941356799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 941356800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 954665999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 954666000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 972806399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 972806400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 986115599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 986115600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1004255999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1004256000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1018169999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1018170000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1035705599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1035705600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1049619599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1049619600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1067155199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1067155200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1081069199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1081069200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1099209599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1099209600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1112518799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1112518800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1130659199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1130659200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1143968399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1143968400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1162108799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1162108800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1173603599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1173603600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1194163199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1194163200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1205053199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1205053200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1225612799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Denver", 1225612800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 9957599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 9957600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 25678799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 25678800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 41407199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 41407200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 57733199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 57733200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 73461599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 73461600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 89182799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 89182800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 104911199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 104911200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 120632399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 120632400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 136360799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 136360800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 152081999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 152082000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 167810399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 167810400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 183531599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 183531600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 199259999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 199260000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 215585999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 215586000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 230709599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 230709600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 247035599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 247035600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 262763999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 262764000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 278485199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 278485200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 294213599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 294213600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 309934799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 309934800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 325663199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 325663200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 341384399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 341384400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 357112799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 357112800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 372833999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 372834000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 388562399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 388562400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 404888399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 404888400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 420011999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 420012000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 436337999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 436338000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 452066399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 452066400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 467787599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 467787600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 483515999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 483516000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 499237199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 499237200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 514965599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 514965600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 530686799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 530686800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 544593659000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 544593660000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 562129259000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 562129260000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 576043259000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 576043260000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 594180059000L),
    Some(-120),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 594180060000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 607492859000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 607492860000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 625633259000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 625633260000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 638942459000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 638942460000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 657082859000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 657082860000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 670996859000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 670996860000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 688532459000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 688532460000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 702446459000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 702446460000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 719982059000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 719982060000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 733896059000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 733896060000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 752036459000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 752036460000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 765345659000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 765345660000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 783486059000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 783486060000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 796795259000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 796795260000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 814935659000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 814935660000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 828849659000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 828849660000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 846385259000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 846385260000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 860299259000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 860299260000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 877834859000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 877834860000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 891748859000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 891748860000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 909284459000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 909284460000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 923198459000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 923198460000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 941338859000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 941338860000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 954648059000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 954648060000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 972788459000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 972788460000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 986097659000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 986097660000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1004238059000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1004238060000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1018152059000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1018152060000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1035687659000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1035687660000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1049601659000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1049601660000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1067137259000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1067137260000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1081051259000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1081051260000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1099191659000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1099191660000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1112500859000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1112500860000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1130641259000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1130641260000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1143950459000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1143950460000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1162090859000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1162090860000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1173585659000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1173585660000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1194145259000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1194145260000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1205035259000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1205035260000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1225594859000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1225594860000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1236484859000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1236484860000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1257044459000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1257044460000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1268539259000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1268539260000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1289098859000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1289098860000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1299988859000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1299988860000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1320555599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1320555600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1331445599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1331445600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1352005199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Goose_Bay", 1352005200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 9957599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 9957600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 25678799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 25678800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 41407199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 41407200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 57733199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 57733200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 73461599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 73461600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 89182799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 89182800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 104911199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 104911200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 120632399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 120632400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 136360799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 136360800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 152081999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 152082000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 167810399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 167810400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 183531599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 183531600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 199259999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 199260000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 215585999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 215586000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 230709599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 230709600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 247035599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 247035600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 262763999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 262764000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 278485199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 278485200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 294213599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 294213600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 309934799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 309934800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 325663199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 325663200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 341384399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 341384400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 357112799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 357112800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 372833999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 372834000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 388562399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 388562400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 404888399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 404888400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 420011999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 420012000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 436337999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 436338000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 452066399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 452066400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 467787599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 467787600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 483515999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 483516000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 499237199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 499237200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 514965599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 514965600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 530686799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 530686800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 544600799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 544600800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 562136399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 562136400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 576050399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 576050400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 594190799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 594190800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 607499999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 607500000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 625640399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 625640400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 638949599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 638949600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 657089999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 657090000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 671003999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 671004000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 688539599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 688539600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 702453599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 702453600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 719989199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 719989200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 733903199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 733903200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 752043599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 752043600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 765352799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 765352800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 783493199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 783493200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 796802399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 796802400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 814942799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 814942800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 828856799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 828856800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 846392399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 846392400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 860306399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 860306400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 877841999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 877842000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 891755999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 891756000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 909291599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 909291600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 923205599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 923205600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 941345999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 941346000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 954655199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 954655200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 972795599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 972795600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 986104799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 986104800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1004245199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1004245200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1018159199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1018159200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1035694799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1035694800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1049608799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1049608800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1067144399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1067144400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1081058399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1081058400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1099198799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1099198800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1112507999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1112508000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1130648399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1130648400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1143957599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1143957600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1162097999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1162098000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1173592799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1173592800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1194152399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1194152400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1205042399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1205042400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1225601999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Halifax", 1225602000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 9971999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 9972000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 25693199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 25693200000L),
    Some(-480),
  )
}

///|
test "@date 段界两侧各差一段（腿 T 行，段数最多的前 10 区）（第 11/12 块，本块 200 条）" {
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 41421599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 41421600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 57747599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 57747600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 73475999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 73476000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 89197199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 89197200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 104925599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 104925600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 120646799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 120646800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 126698399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 126698400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 152096399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 152096400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 162381599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 162381600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 183545999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 183546000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 199274399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 199274400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 215600399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 215600400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 230723999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 230724000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 247049999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 247050000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 262778399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 262778400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 278499599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 278499600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 294227999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 294228000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 309949199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 309949200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 325677599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 325677600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 341398799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 341398800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 357127199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 357127200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 372848399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 372848400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 388576799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 388576800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 404902799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 404902800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 420026399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 420026400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 436352399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 436352400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 452080799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 452080800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 467801999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 467802000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 483530399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 483530400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 499251599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 499251600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 514979999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 514980000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 530701199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 530701200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 544615199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 544615200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 562150799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 562150800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 576064799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 576064800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 594205199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 594205200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 607514399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 607514400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 625654799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 625654800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 638963999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 638964000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 657104399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 657104400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 671018399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 671018400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 688553999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 688554000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 702467999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 702468000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 720003599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 720003600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 733917599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 733917600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 752057999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 752058000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 765367199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 765367200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 783507599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 783507600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 796816799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 796816800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 814957199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 814957200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 828871199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 828871200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 846406799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 846406800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 860320799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 860320800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 877856399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 877856400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 891770399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 891770400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 909305999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 909306000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 923219999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 923220000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 941360399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 941360400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 954669599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 954669600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 972809999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 972810000000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 986119199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 986119200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1004259599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1004259600000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1018173599000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1018173600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1035709199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1035709200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1049623199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1049623200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1067158799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1067158800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1081072799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1081072800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1099213199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1099213200000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1112522399000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1112522400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1130662799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1130662800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1143971999000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1143972000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1162112399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1162112400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1173607199000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1173607200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1194166799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1194166800000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1205056799000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1205056800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1225616399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Los_Angeles", 1225616400000L),
    Some(-480),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 9961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 9961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 25682399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 25682400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 41410799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 41410800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 57736799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 57736800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 73465199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 73465200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 89186399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 89186400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 104914799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 104914800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 120635999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 120636000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 136364399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 136364400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 152085599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 152085600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 167813999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 167814000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 183535199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 183535200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 199263599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 199263600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 215589599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 215589600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 230713199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 230713200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 247039199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 247039200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 262767599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 262767600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 278488799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 278488800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 294217199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 294217200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 309938399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 309938400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 325666799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 325666800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 341387999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 341388000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 357116399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 357116400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 372837599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 372837600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 388565999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 388566000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 404891999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 404892000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 420015599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 420015600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 436341599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 436341600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 452069999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 452070000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 467791199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 467791200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 483519599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 483519600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 499240799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 499240800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 514969199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 514969200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 530690399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 530690400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 544604399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 544604400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 562139999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 562140000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 576053999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 576054000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 594194399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 594194400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 607503599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 607503600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 625643999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 625644000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 638953199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 638953200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 657093599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 657093600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 671007599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 671007600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 688543199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 688543200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 702457199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 702457200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 719992799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 719992800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 733906799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 733906800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 752047199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 752047200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 765356399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 765356400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 783496799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 783496800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 796805999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 796806000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 814946399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 814946400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 828860399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 828860400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 846395999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 846396000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 860309999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 860310000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 877845599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 877845600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 891759599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 891759600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 909295199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 909295200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 923209199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 923209200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 941349599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 941349600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 954658799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 954658800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 972799199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 972799200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 986108399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 986108400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1004248799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1004248800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1018162799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1018162800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1035698399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1035698400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1049612399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1049612400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1067147999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1067148000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1081061999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1081062000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1099202399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1099202400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1112511599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1112511600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1130651999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1130652000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1143961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1143961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1162101599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1162101600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1173596399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1173596400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1194155999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1194156000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1205045999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1205046000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1225605599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Montreal", 1225605600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 9961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 9961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 25682399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 25682400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 41410799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 41410800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 57736799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 57736800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 73465199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 73465200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 89186399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 89186400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 104914799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 104914800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 120635999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 120636000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 136364399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 136364400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 152085599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 152085600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 167813999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 167814000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 183535199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 183535200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 199263599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 199263600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 215589599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 215589600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 230713199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 230713200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 247039199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 247039200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 262767599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 262767600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 278488799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 278488800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 294217199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 294217200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 309938399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 309938400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 325666799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 325666800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 341387999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 341388000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 357116399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 357116400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 372837599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 372837600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 388565999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 388566000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 404891999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 404892000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 420015599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 420015600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 436341599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 436341600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 452069999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 452070000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 467791199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 467791200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 483519599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 483519600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 499240799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 499240800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 514969199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 514969200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 530690399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 530690400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 544604399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 544604400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 562139999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 562140000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 576053999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 576054000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 594194399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 594194400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 607503599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 607503600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 625643999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 625644000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 638953199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 638953200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 657093599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 657093600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 671007599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 671007600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 688543199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 688543200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 702457199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 702457200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 719992799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 719992800000L),
    Some(-300),
  )
}

///|
test "@date 段界两侧各差一段（腿 T 行，段数最多的前 10 区）（第 12/12 块，本块 188 条）" {
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 733906799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 733906800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 752047199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 752047200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 765356399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 765356400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 783496799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 783496800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 796805999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 796806000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 814946399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 814946400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 828860399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 828860400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 846395999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 846396000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 860309999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 860310000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 877845599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 877845600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 891759599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 891759600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 909295199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 909295200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 923209199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 923209200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 941349599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 941349600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 954658799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 954658800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 972799199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 972799200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 986108399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 986108400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1004248799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1004248800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1018162799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1018162800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1035698399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1035698400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1049612399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1049612400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1067147999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1067148000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1081061999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1081062000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1099202399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1099202400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1112511599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1112511600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1130651999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1130652000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1143961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1143961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1162101599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1162101600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1173596399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1173596400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1194155999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1194156000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1205045999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1205046000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1225605599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nassau", 1225605600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 9961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 9961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 25682399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 25682400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 41410799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 41410800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 57736799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 57736800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 73465199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 73465200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 89186399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 89186400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 104914799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 104914800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 120635999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 120636000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 126687599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 126687600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 152085599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 152085600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 162370799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 162370800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 183535199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 183535200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 199263599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 199263600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 215589599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 215589600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 230713199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 230713200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 247039199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 247039200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 262767599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 262767600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 278488799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 278488800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 294217199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 294217200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 309938399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 309938400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 325666799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 325666800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 341387999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 341388000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 357116399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 357116400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 372837599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 372837600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 388565999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 388566000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 404891999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 404892000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 420015599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 420015600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 436341599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 436341600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 452069999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 452070000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 467791199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 467791200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 483519599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 483519600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 499240799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 499240800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 514969199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 514969200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 530690399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 530690400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 544604399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 544604400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 562139999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 562140000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 576053999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 576054000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 594194399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 594194400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 607503599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 607503600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 625643999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 625644000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 638953199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 638953200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 657093599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 657093600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 671007599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 671007600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 688543199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 688543200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 702457199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 702457200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 719992799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 719992800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 733906799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 733906800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 752047199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 752047200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 765356399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 765356400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 783496799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 783496800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 796805999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 796806000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 814946399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 814946400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 828860399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 828860400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 846395999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 846396000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 860309999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 860310000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 877845599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 877845600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 891759599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 891759600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 909295199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 909295200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 923209199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 923209200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 941349599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 941349600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 954658799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 954658800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 972799199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 972799200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 986108399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 986108400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1004248799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1004248800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1018162799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1018162800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1035698399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1035698400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1049612399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1049612400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1067147999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1067148000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1081061999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1081062000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1099202399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1099202400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1112511599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1112511600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1130651999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1130652000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1143961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1143961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1162101599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1162101600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1173596399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1173596400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1194155999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1194156000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1205045999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1205046000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1225605599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/New_York", 1225605600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 9961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 9961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 25682399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 25682400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 41410799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 41410800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 57736799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 57736800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 73465199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 73465200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 89186399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 89186400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 104914799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 104914800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 120635999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 120636000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 136364399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 136364400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 152085599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 152085600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 167813999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 167814000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 183535199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 183535200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 199263599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 199263600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 215589599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 215589600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 230713199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 230713200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 247039199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 247039200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 262767599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 262767600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 278488799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 278488800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 294217199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 294217200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 309938399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 309938400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 325666799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 325666800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 341387999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 341388000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 357116399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 357116400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 372837599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 372837600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 388565999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 388566000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 404891999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 404892000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 420015599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 420015600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 436341599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 436341600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 452069999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 452070000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 467791199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 467791200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 483519599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 483519600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 499240799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 499240800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 514969199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 514969200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 530690399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 530690400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 544604399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 544604400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 562139999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 562140000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 576053999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 576054000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 594194399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 594194400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 607503599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 607503600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 625643999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 625644000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 638953199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 638953200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 657093599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 657093600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 671007599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 671007600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 688543199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 688543200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 702457199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 702457200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 719992799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 719992800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 733906799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 733906800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 752047199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 752047200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 765356399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 765356400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 783496799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 783496800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 796805999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 796806000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 814946399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 814946400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 828860399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 828860400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 846395999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 846396000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 860309999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 860310000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 877845599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 877845600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 891759599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 891759600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 909295199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 909295200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 923209199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 923209200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 941349599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 941349600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 954658799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 954658800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 972799199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 972799200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 986108399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 986108400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1004248799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1004248800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1018162799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1018162800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1035698399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1035698400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1049612399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1049612400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1067147999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1067148000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1081061999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1081062000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1099202399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1099202400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1112511599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1112511600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1130651999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1130652000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1143961199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1143961200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1162101599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1162101600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1173596399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1173596400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1194155999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1194156000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1205045999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1205046000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1225605599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Nipigon", 1225605600000L),
    Some(-300),
  )
}

///|
test "@date 墙上时刻的合法偏移：0 档（前跳空洞）/ 1 档 / 2 档（回拨重叠），顺序照腿 V 行" {
  // 腿 V 行：America/New_York|2024-11-03T01:30 -> n=2 -240|-300
  assert_eq(
    @date.zone_offsets_at_wall("America/New_York", dt(2024, 11, 3, 1, 30, 0, 0)),
    [-240, -300],
  )
  // 腿 V 行：America/New_York|2024-03-10T02:30 -> n=0 
  assert_eq(
    @date.zone_offsets_at_wall("America/New_York", dt(2024, 3, 10, 2, 30, 0, 0)),
    [],
  )
  // 腿 V 行：Asia/Shanghai|2024-06-01T12:00 -> n=1 480
  assert_eq(
    @date.zone_offsets_at_wall("Asia/Shanghai", dt(2024, 6, 1, 12, 0, 0, 0)),
    [480],
  )
  // 腿 V 行：Asia/Shanghai|1986-05-04T02:30 -> n=0 
  assert_eq(
    @date.zone_offsets_at_wall("Asia/Shanghai", dt(1986, 5, 4, 2, 30, 0, 0)),
    [],
  )
  // 腿 V 行：Pacific/Chatham|2024-04-07T00:15 -> n=1 825
  assert_eq(
    @date.zone_offsets_at_wall("Pacific/Chatham", dt(2024, 4, 7, 0, 15, 0, 0)),
    [825],
  )
  // 腿 V 行：Europe/London|2024-10-27T01:30 -> n=2 60|0
  assert_eq(
    @date.zone_offsets_at_wall("Europe/London", dt(2024, 10, 27, 1, 30, 0, 0)),
    [60, 0],
  )
  // 腿 V 行：Australia/Lord_Howe|2024-04-07T02:15 -> n=1 630
  assert_eq(
    @date.zone_offsets_at_wall(
      "Australia/Lord_Howe",
      dt(2024, 4, 7, 2, 15, 0, 0),
    ),
    [630],
  )
  // 腿 V 行：Australia/Lord_Howe|2024-10-06T01:45 -> n=1 630
  assert_eq(
    @date.zone_offsets_at_wall(
      "Australia/Lord_Howe",
      dt(2024, 10, 6, 1, 45, 0, 0),
    ),
    [630],
  )
  // 腿 V 行：UTC|2024-06-01T12:00 -> n=1 0
  assert_eq(@date.zone_offsets_at_wall("UTC", dt(2024, 6, 1, 12, 0, 0, 0)), [0])
  // 腿 V 行：Asia/Kathmandu|2024-06-01T12:00 -> n=1 345
  assert_eq(
    @date.zone_offsets_at_wall("Asia/Kathmandu", dt(2024, 6, 1, 12, 0, 0, 0)),
    [345],
  )
}

///|
test "@date datetime_in：瞬间 + 区名 = 墙上时刻（腿 W 行直读，含 45 分偏移与 30 分夏令时档）" {
  assert_eq(
    ztag(@date.datetime_in("UTC", 0L)),
    ztag(Some(dt(1970, 1, 1, 0, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("UTC", 515556000000L)),
    ztag(Some(dt(1986, 5, 4, 2, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("UTC", 961070400000L)),
    ztag(Some(dt(2000, 6, 15, 12, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("UTC", 1710052200000L)),
    ztag(Some(dt(2024, 3, 10, 6, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("UTC", 1730613600000L)),
    ztag(Some(dt(2024, 11, 3, 6, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("UTC", 2145916799000L)),
    ztag(Some(dt(2037, 12, 31, 23, 59, 59, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Shanghai", 0L)),
    ztag(Some(dt(1970, 1, 1, 8, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Shanghai", 515556000000L)),
    ztag(Some(dt(1986, 5, 4, 11, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Shanghai", 961070400000L)),
    ztag(Some(dt(2000, 6, 15, 20, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Shanghai", 1710052200000L)),
    ztag(Some(dt(2024, 3, 10, 14, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Shanghai", 1730613600000L)),
    ztag(Some(dt(2024, 11, 3, 14, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Shanghai", 2145916799000L)),
    ztag(Some(dt(2038, 1, 1, 7, 59, 59, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Kathmandu", 0L)),
    ztag(Some(dt(1970, 1, 1, 5, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Kathmandu", 515556000000L)),
    ztag(Some(dt(1986, 5, 4, 7, 45, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Kathmandu", 961070400000L)),
    ztag(Some(dt(2000, 6, 15, 17, 45, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Kathmandu", 1710052200000L)),
    ztag(Some(dt(2024, 3, 10, 12, 15, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Kathmandu", 1730613600000L)),
    ztag(Some(dt(2024, 11, 3, 11, 45, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Kathmandu", 2145916799000L)),
    ztag(Some(dt(2038, 1, 1, 5, 44, 59, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Pacific/Chatham", 0L)),
    ztag(Some(dt(1970, 1, 1, 12, 45, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Pacific/Chatham", 515556000000L)),
    ztag(Some(dt(1986, 5, 4, 14, 45, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Pacific/Chatham", 961070400000L)),
    ztag(Some(dt(2000, 6, 16, 0, 45, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Pacific/Chatham", 1710052200000L)),
    ztag(Some(dt(2024, 3, 10, 20, 15, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Pacific/Chatham", 1730613600000L)),
    ztag(Some(dt(2024, 11, 3, 19, 45, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Pacific/Chatham", 2145916799000L)),
    ztag(Some(dt(2038, 1, 1, 13, 44, 59, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Australia/Lord_Howe", 0L)),
    ztag(Some(dt(1970, 1, 1, 10, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Australia/Lord_Howe", 515556000000L)),
    ztag(Some(dt(1986, 5, 4, 12, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Australia/Lord_Howe", 961070400000L)),
    ztag(Some(dt(2000, 6, 15, 22, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Australia/Lord_Howe", 1710052200000L)),
    ztag(Some(dt(2024, 3, 10, 17, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Australia/Lord_Howe", 1730613600000L)),
    ztag(Some(dt(2024, 11, 3, 17, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Australia/Lord_Howe", 2145916799000L)),
    ztag(Some(dt(2038, 1, 1, 10, 59, 59, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("America/New_York", 0L)),
    ztag(Some(dt(1969, 12, 31, 19, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("America/New_York", 515556000000L)),
    ztag(Some(dt(1986, 5, 3, 22, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("America/New_York", 961070400000L)),
    ztag(Some(dt(2000, 6, 15, 8, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("America/New_York", 1710052200000L)),
    ztag(Some(dt(2024, 3, 10, 1, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("America/New_York", 1730613600000L)),
    ztag(Some(dt(2024, 11, 3, 1, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("America/New_York", 2145916799000L)),
    ztag(Some(dt(2037, 12, 31, 18, 59, 59, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Etc/GMT+5", 0L)),
    ztag(Some(dt(1969, 12, 31, 19, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Etc/GMT+5", 515556000000L)),
    ztag(Some(dt(1986, 5, 3, 21, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Etc/GMT+5", 961070400000L)),
    ztag(Some(dt(2000, 6, 15, 7, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Etc/GMT+5", 1710052200000L)),
    ztag(Some(dt(2024, 3, 10, 1, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Etc/GMT+5", 1730613600000L)),
    ztag(Some(dt(2024, 11, 3, 1, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.datetime_in("Etc/GMT+5", 2145916799000L)),
    ztag(Some(dt(2037, 12, 31, 18, 59, 59, 0))),
  )
}

///|
test "@date 认不出的区名：本库给 None / false；参照侧 TimeZone 静默回落 GMT（分岔见 spec §5.3）" {
  // 参照读数：TimeZone=0 | ZoneId_ERR_ZoneRulesException
  assert_eq(@date.zone_offset_minutes("Nowhere/Nowhere", 2524607999999L), None)
  assert_eq(@date.zone_exists("Nowhere/Nowhere"), false)
  assert_eq(ztag(@date.datetime_in("Nowhere/Nowhere", 2524607999999L)), "null")
  assert_eq(
    @date.zone_offsets_at_wall("Nowhere/Nowhere", dt(2024, 6, 1, 12, 0, 0, 0)),
    [],
  )
  // 参照读数：TimeZone=0 | ZoneId_ERR_DateTimeException
  assert_eq(@date.zone_offset_minutes("", 2524607999999L), None)
  assert_eq(@date.zone_exists(""), false)
  assert_eq(ztag(@date.datetime_in("", 2524607999999L)), "null")
  assert_eq(@date.zone_offsets_at_wall("", dt(2024, 6, 1, 12, 0, 0, 0)), [])
  // 参照读数：TimeZone=0 | ZoneId_ERR_ZoneRulesException
  assert_eq(@date.zone_offset_minutes("asia/shanghai", 2524607999999L), None)
  assert_eq(@date.zone_exists("asia/shanghai"), false)
  assert_eq(ztag(@date.datetime_in("asia/shanghai", 2524607999999L)), "null")
  assert_eq(
    @date.zone_offsets_at_wall("asia/shanghai", dt(2024, 6, 1, 12, 0, 0, 0)),
    [],
  )
  // 参照读数：TimeZone=0 | ZoneId_ERR_ZoneRulesException
  assert_eq(@date.zone_offset_minutes("Shanghai", 2524607999999L), None)
  assert_eq(@date.zone_exists("Shanghai"), false)
  assert_eq(ztag(@date.datetime_in("Shanghai", 2524607999999L)), "null")
  assert_eq(
    @date.zone_offsets_at_wall("Shanghai", dt(2024, 6, 1, 12, 0, 0, 0)),
    [],
  )
  // 参照读数：TimeZone=480 | ZoneId_ERR_DateTimeException
  assert_eq(@date.zone_offset_minutes("GMT+8:00", 2524607999999L), None)
  assert_eq(@date.zone_exists("GMT+8:00"), false)
  assert_eq(ztag(@date.datetime_in("GMT+8:00", 2524607999999L)), "null")
  assert_eq(
    @date.zone_offsets_at_wall("GMT+8:00", dt(2024, 6, 1, 12, 0, 0, 0)),
    [],
  )
}

///|
test "@date 窗口边界：下界含、上界不含，窗外一律 None（不向外推）" {
  // 腿 D 行首段：Asia/Shanghai|0 -> 480 / UTC|2524607999 -> 0
  assert_eq(@date.zone_offset_minutes("Asia/Shanghai", 0L), Some(480))
  assert_eq(@date.zone_offset_minutes("Asia/Shanghai", -1L), None)
  assert_eq(@date.zone_offset_minutes("Asia/Shanghai", 2524608000000L), None)
  assert_eq(@date.zone_offset_minutes("UTC", 2524607999999L), Some(0))
}

///|
test "@date 区名清单：条数与首尾读数照腿，且返回的是拷贝（改它不影响后续查表）" {
  assert_eq(@date.zone_names()[0], "Africa/Abidjan")
  assert_eq(@date.zone_names()[1], "Africa/Accra")
  assert_eq(@date.zone_names()[2], "Africa/Addis_Ababa")
  assert_eq(@date.zone_names()[600], "W-SU")
  assert_eq(@date.zone_names()[601], "WET")
  assert_eq(@date.zone_names()[602], "Zulu")
  assert_eq(@date.zone_names().length(), 603)
  assert_eq(@date.zone_count(), 603)
  let dirty = @date.zone_names()
  dirty[0] = "Poisoned/Name"
  assert_eq(@date.zone_names()[0], "Africa/Abidjan")
  assert_eq(@date.zone_exists("Africa/Abidjan"), true)
  // 表序判据不靠这一条单独撑：上面「逐区六瞬间」把 603 个区各查了 6 次，
  // 表序与自带比较器一旦不同序，二分必对某个区给 None，那一整块当场报红。
  assert_eq(@date.zone_exists("Asia/Pyongyang"), true)
}

///|
test "@date now_in：同一次时钟读数的等价式 + 形状下界，两次读时钟的抖动不进断言（口径同 #2.10）" {
  let ms = @date.now_millis()
  // 腿 P 行：Asia/Shanghai 在窗口内任一时刻的偏移里，当下这一档是 480
  assert_eq(
    ztag(@date.datetime_in("Asia/Shanghai", ms)),
    ztag(Some(@date.DateTime::from_epoch_millis(ms, 480))),
  )
  assert_eq(ztag(@date.now_in("Nowhere/Nowhere")), "null")
  match @date.now_in("Asia/Shanghai") {
    None => assert_eq(0, 1)
    Some(dt2) => {
      assert_eq(dt2.date.year >= 2026, true)
      assert_eq(dt2.hour >= 0 && dt2.hour <= 23, true)
      assert_eq(dt2.minute >= 0 && dt2.minute <= 59, true)
    }
  }
}
