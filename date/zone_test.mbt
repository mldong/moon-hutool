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
test "@date 内置表逐区六瞬间偏移（腿 P 行全量，3618 条）" {
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
test "@date 段界两侧各差一段（腿 T 行，段数最多的前 10 区，共 1150 条）" {
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 142379999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 142380000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 150843599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 150843600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 167176799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 167176800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 178664399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 178664400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 334101599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 334101600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 337730399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 337730400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 452642399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 452642400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 462319199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 462319200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 482277599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 482277600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 494369999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 494370000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 516751199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 516751200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 526424399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 526424400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 545435999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 545436000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 558478799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 558478800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 576626399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 576626400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 589323599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 589323600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 609890399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 609890400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 620773199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 620773200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 638315999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 638316000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 651617999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 651618000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 669765599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 669765600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 683672399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 683672400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 701819999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 701820000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 715726799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 715726800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 733701599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 733701600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 747176399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 747176400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 765151199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 765151200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 778021199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 778021200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 796600799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 796600800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 810075599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 810075600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 828655199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 828655200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 843170399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 843170400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 860104799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 860104800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 874619999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 874620000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 891554399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 891554400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 906069599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 906069600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 924213599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 924213600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 939934799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 939934800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 956267999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 956268000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 971989199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 971989200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 987717599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 987717600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1003438799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1003438800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1019167199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1019167200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1034888399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1034888400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1050616799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1050616800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1066337999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1066338000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1082066399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1082066400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1096581599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1096581600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1113515999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1113516000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1128380399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1128380400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1143842399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1143842400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1158872399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1158872400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1175378399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1175378400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1189637999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1189638000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1206655199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1206655200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1220216399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1220216400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1238104799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1238104800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1252015199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1252015200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1269554399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1269554400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1281473999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1281474000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1301608859000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1301608860000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1312145999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1312146000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1314655199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1314655200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1317329999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1317330000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1333058399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1333058400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1348178399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1348178400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1364507999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1364508000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1380229199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1380229200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1395957599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1395957600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1414097999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1414098000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1427493599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1427493600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1445551199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1445551200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1458946799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1458946800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1477691999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1477692000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1490396399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1490396400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1509141599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1509141600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1521845999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1521846000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1540591199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1540591200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1553810399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1553810400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1572037199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1572037200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1585346399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1585346400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1603490399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1603490400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1616795999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1616796000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1635458399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1635458400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1648331999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1648332000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1666997999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1666998000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1682726399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1682726400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1698447599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1698447600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1713571199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1713571200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1729897199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1729897200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1744415999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1744416000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1761346799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1761346800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1774655999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1774656000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1792796399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1792796400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1806105599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1806105600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1824850799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1824850800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1837555199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1837555200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1856300399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1856300400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1869004799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1869004800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1887749999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1887750000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1901059199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1901059200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1919199599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1919199600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1932508799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1932508800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1950649199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1950649200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1963958399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1963958400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1982703599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1982703600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1995407999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 1995408000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2014153199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2014153200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2026857599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2026857600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2045602799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2045602800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2058307199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2058307200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2077052399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2077052400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2090361599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2090361600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2107897199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2107897200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2121811199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2121811200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2138741999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2138742000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2153260799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2153260800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2168981999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2168982000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2184710399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2184710400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2199826799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2199826800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2216159999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2216160000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2230066799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2230066800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2234303999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2234304000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2234905199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2234905200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2248214399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2248214400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2260911599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2260911600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2264543999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2264544000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2266354799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2266354800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2279663999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2279664000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2291756399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2291756400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2295388799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2295388800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2297804399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2297804400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2311113599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2311113600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2321996399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2321996400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2326233599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2326233600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2329253999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2329254000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2342563199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2342563200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2352841199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2352841200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2356473599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2356473600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2361308399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2361308400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2374012799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2374012800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2383685999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2383686000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2387318399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2387318400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2392757999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2392758000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2405462399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2405462400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2413925999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2413926000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2418163199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2418163200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2424207599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2424207600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2437516799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2437516800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2444770799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2444770800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2448403199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2448403200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2455657199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2455657200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2468966399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2468966400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2475010799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2475010800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2479247999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2479248000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2487106799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2487106800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2500415999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2500416000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2505855599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2505855600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2509487999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2509488000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2519161199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Hebron", 2519161200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 142379999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 142380000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 150843599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 150843600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 167176799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 167176800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 178664399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 178664400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 334101599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 334101600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 337730399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 337730400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 452642399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 452642400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 462319199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 462319200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 482277599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 482277600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 494369999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 494370000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 516751199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 516751200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 526424399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 526424400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 545435999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 545436000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 558478799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 558478800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 576626399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 576626400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 589323599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 589323600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 609890399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 609890400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 620773199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 620773200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 638315999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 638316000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 651617999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 651618000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 669765599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 669765600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 683672399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 683672400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 701819999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 701820000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 715726799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 715726800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 733701599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 733701600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 747176399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 747176400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 765151199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 765151200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 778021199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 778021200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 796600799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 796600800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 810075599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 810075600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 828655199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 828655200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 843170399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 843170400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 860104799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 860104800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 874619999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 874620000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 891554399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 891554400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 906069599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 906069600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 924213599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 924213600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 939934799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 939934800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 956267999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 956268000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 971989199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 971989200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 987717599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 987717600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1003438799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1003438800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1019167199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1019167200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1034888399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1034888400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1050616799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1050616800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1066337999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1066338000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1082066399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1082066400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1096581599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1096581600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1113515999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1113516000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1128380399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1128380400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1143842399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1143842400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1158872399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1158872400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1175378399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1175378400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1189637999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1189638000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1206655199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1206655200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1219957199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1219957200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1238104799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1238104800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1252015199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1252015200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1269640859000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1269640860000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1281473999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1281474000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1301608859000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1301608860000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1312145999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1312146000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1333058399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1333058400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1348178399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1348178400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1364507999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1364508000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1380229199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1380229200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1395957599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1395957600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1414097999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1414098000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1427493599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1427493600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1445551199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1445551200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1458946799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1458946800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1477691999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1477692000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1490396399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1490396400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1509141599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1509141600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1521845999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1521846000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1540591199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1540591200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1553810399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1553810400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1572037199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1572037200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1585346399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1585346400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1603490399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1603490400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1616795999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1616796000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1635458399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1635458400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1648331999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1648332000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1666997999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1666998000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1682726399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1682726400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1698447599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1698447600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1713571199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1713571200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1729897199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1729897200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1744415999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1744416000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1761346799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1761346800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1774655999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1774656000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1792796399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1792796400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1806105599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1806105600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1824850799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1824850800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1837555199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1837555200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1856300399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1856300400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1869004799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1869004800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1887749999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1887750000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1901059199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1901059200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1919199599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1919199600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1932508799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1932508800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1950649199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1950649200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1963958399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1963958400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1982703599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1982703600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1995407999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 1995408000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2014153199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2014153200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2026857599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2026857600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2045602799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2045602800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2058307199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2058307200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2077052399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2077052400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2090361599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2090361600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2107897199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2107897200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2121811199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2121811200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2138741999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2138742000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2153260799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2153260800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2168981999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2168982000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2184710399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2184710400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2199826799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2199826800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2216159999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2216160000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2230066799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2230066800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2234303999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2234304000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2234905199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2234905200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2248214399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2248214400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2260911599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2260911600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2264543999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2264544000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2266354799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2266354800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2279663999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2279664000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2291756399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2291756400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2295388799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2295388800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2297804399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2297804400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2311113599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2311113600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2321996399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2321996400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2326233599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2326233600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2329253999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2329254000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2342563199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2342563200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2352841199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2352841200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2356473599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2356473600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2361308399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2361308400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2374012799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2374012800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2383685999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2383686000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2387318399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2387318400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2392757999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2392758000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2405462399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2405462400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2413925999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2413926000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2418163199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2418163200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2424207599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2424207600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2437516799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2437516800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2444770799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2444770800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2448403199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2448403200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2455657199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2455657200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2468966399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2468966400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2475010799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2475010800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2479247999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2479248000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2487106799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2487106800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2500415999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2500416000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2505855599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2505855600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2509487999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2509488000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2519161199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Gaza", 2519161200000L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 141263999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 141264000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 147221999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 147222000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 199756799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 199756800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 207701999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 207702000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 231292799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 231292800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 244249199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 244249200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 265507199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 265507200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 271033199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 271033200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 448243199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 448243200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 504917999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 504918000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1212278399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1212278400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1220223599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1220223600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1243814399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1243814400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1250809199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1250809200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1272758399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1272758400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1281221999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1281222000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1301788799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1301788800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1312066799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1312066800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1335664799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1335664800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1342749599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1342749600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1345427999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1345428000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1348970399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1348970400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1367114399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1367114400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1373162399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1373162400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1376099999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1376100000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1382839199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1382839200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1396144799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1396144800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1403920799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1403920800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1406944799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1406944800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1414288799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1414288800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1427594399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1427594400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1434247199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1434247200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1437271199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1437271200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1445738399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1445738400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1459043999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1459044000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1465091999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1465092000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1468115999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1468116000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1477792799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1477792800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1490493599000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1490493600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1495331999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1495332000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1498960799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1498960800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1509242399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1509242400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1521943199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1521943200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1526176799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1526176800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1529200799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1529200800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1557021599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1557021600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1560045599000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1560045600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1587261599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1587261600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1590890399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1590890400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1618106399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1618106400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1621130399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1621130400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1648346399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1648346400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1651975199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1651975200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1679191199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1679191200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1682215199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1682215200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1710035999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1710036000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1713059999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1713060000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1740275999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1740276000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1743904799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1743904800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1771120799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1771120800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1774144799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1774144800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1801965599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1801965600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1804989599000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1804989600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1832205599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1832205600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1835834399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1835834400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1863050399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1863050400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1866074399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1866074400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1893290399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1893290400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1896919199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1896919200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1924135199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1924135200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1927159199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1927159200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1954979999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1954980000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1958003999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1958004000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1985219999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1985220000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1988848799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 1988848800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2016064799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2016064800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2019088799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2019088800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2046304799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2046304800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2049933599000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2049933600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2077149599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2077149600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2080778399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2080778400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2107994399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2107994400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2111018399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2111018400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2138234399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2138234400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2141863199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2141863200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2169079199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2169079200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2172103199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2172103200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2199923999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2199924000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2202947999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2202948000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2230163999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2230164000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2233792799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2233792800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2261008799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2261008800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2264032799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2264032800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2291248799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2291248800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2294877599000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2294877600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2322093599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2322093600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2325722399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2325722400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2352938399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2352938400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2355962399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2355962400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2383178399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2383178400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2386807199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2386807200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2414023199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2414023200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2417047199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2417047200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2444867999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2444868000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2447891999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2447892000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2475107999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2475108000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2478736799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2478736800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2505952799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2505952800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2508976799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Casablanca", 2508976800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 7527599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 7527600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 24465599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 24465600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 37767599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 37767600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 55915199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 55915200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 69217199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 69217200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 87969599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 87969600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 100666799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 100666800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 118209599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 118209600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 132116399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 132116400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 150868799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 150868800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 163565999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 163566000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 182318399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 182318400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 195620399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 195620400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 213767999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 213768000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 227069999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 227070000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 245217599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 245217600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 258519599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 258519600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 277271999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 277272000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 289969199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 289969200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 308721599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 308721600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 321418799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 321418800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 340171199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 340171200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 353473199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 353473200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 371620799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 371620800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 384922799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 384922800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 403070399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 403070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 416372399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 416372400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 434519999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 434520000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 447821999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 447822000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 466574399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 466574400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 479271599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 479271600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 498023999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 498024000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 510721199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 510721200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 529473599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 529473600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 545194799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 545194800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 560923199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 560923200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 574225199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 574225200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 592372799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 592372800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 605674799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 605674800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 624427199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 624427200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 637124399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 637124400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 653457599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 653457600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 668573999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 668574000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 687326399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 687326400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 700628399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 700628400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 718775999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 718776000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 732077999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 732078000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 750225599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 750225600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 763527599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 763527600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 781675199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 781675200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 794977199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 794977200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 813729599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 813729600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 826426799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 826426800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 845179199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 845179200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 859690799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 859690800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 876628799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 876628800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 889930799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 889930800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 906868799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 906868800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 923194799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 923194800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 939527999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 939528000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 952829999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 952830000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 971582399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 971582400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 984279599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 984279600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1003031999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1003032000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1015729199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1015729200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1034481599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1034481600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1047178799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1047178800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1065931199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1065931200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1079233199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1079233200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1097380799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1097380800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1110682799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1110682800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1128830399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1128830400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1142132399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1142132400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1160884799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1160884800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1173581999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1173582000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1192334399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1192334400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1206845999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1206846000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1223783999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1223784000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1237085999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1237086000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1255233599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1255233600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1270349999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1270350000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1286683199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1286683200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1304823599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1304823600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1313899199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1313899200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1335668399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1335668400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1346558399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1346558400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1367117999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1367118000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1378612799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1378612800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1398567599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1398567600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1410062399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1410062400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1463281199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1463281200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1471147199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1471147200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1494730799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1494730800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1502596799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1502596800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1526180399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1526180400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1534046399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1534046400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1554605999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1554606000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1567915199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1567915200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1586055599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1586055600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1599364799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1599364800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1617505199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1617505200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1630814399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1630814400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1648954799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1648954800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1662868799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1662868800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1680404399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1680404400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1693713599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1693713600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1712458799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1712458800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1725767999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("America/Santiago", 1725768000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 7527599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 7527600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 24465599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 24465600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 37767599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 37767600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 55915199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 55915200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 69217199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 69217200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 87969599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 87969600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 100666799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 100666800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 118209599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 118209600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 132116399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 132116400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 150868799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 150868800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 163565999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 163566000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 182318399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 182318400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 195620399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 195620400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 213767999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 213768000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 227069999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 227070000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 245217599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 245217600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 258519599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 258519600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 277271999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 277272000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 289969199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 289969200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 308721599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 308721600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 321418799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 321418800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 340171199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 340171200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 353473199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 353473200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 371620799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 371620800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 384922799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 384922800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 403070399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 403070400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 416372399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 416372400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 434519999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 434520000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 447821999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 447822000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 466574399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 466574400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 479271599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 479271600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 498023999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 498024000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 510721199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 510721200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 529473599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 529473600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 545194799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 545194800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 560923199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 560923200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 574225199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 574225200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 592372799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 592372800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 605674799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 605674800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 624427199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 624427200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 637124399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 637124400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 653457599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 653457600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 668573999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 668574000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 687326399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 687326400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 700628399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 700628400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 718775999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 718776000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 732077999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 732078000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 750225599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 750225600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 763527599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 763527600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 781675199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 781675200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 794977199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 794977200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 813729599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 813729600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 826426799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 826426800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 845179199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 845179200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 859690799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 859690800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 876628799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 876628800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 889930799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 889930800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 906868799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 906868800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 923194799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 923194800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 939527999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 939528000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 952829999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 952830000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 971582399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 971582400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 984279599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 984279600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1003031999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1003032000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1015729199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1015729200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1034481599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1034481600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1047178799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1047178800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1065931199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1065931200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1079233199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1079233200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1097380799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1097380800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1110682799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1110682800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1128830399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1128830400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1142132399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1142132400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1160884799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1160884800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1173581999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1173582000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1192334399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1192334400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1206845999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1206846000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1223783999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1223784000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1237085999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1237086000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1255233599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1255233600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1270349999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1270350000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1286683199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1286683200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1304823599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1304823600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1313899199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1313899200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1335668399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1335668400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1346558399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1346558400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1367117999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1367118000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1378612799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1378612800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1398567599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1398567600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1410062399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1410062400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1463281199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1463281200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1471147199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1471147200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1494730799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1494730800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1502596799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1502596800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1526180399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1526180400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1534046399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1534046400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1554605999000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1554606000000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1567915199000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1567915200000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1586055599000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1586055600000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1599364799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1599364800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1617505199000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1617505200000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1630814399000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1630814400000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1648954799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1648954800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1662868799000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1662868800000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1680404399000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1680404400000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1693713599000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1693713600000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1712458799000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1712458800000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1725767999000L),
    Some(-240),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/Continental", 1725768000000L),
    Some(-180),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 7527599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 7527600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 24465599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 24465600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 37767599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 37767600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 55915199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 55915200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 69217199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 69217200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 87969599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 87969600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 100666799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 100666800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 118209599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 118209600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 132116399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 132116400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 150868799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 150868800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 163565999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 163566000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 182318399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 182318400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 195620399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 195620400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 213767999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 213768000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 227069999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 227070000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 245217599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 245217600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 258519599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 258519600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 277271999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 277272000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 289969199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 289969200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 308721599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 308721600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 321418799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 321418800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 340171199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 340171200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 353473199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 353473200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 371620799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 371620800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 403070399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 403070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 416372399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 416372400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 434519999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 434520000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 447821999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 447822000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 466574399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 466574400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 479271599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 479271600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 498023999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 498024000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 510721199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 510721200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 529473599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 529473600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 545194799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 545194800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 560923199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 560923200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 574225199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 574225200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 592372799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 592372800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 605674799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 605674800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 624427199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 624427200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 637124399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 637124400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 653457599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 653457600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 668573999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 668574000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 687326399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 687326400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 700628399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 700628400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 718775999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 718776000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 732077999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 732078000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 750225599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 750225600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 763527599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 763527600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 781675199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 781675200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 794977199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 794977200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 813729599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 813729600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 826426799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 826426800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 845179199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 845179200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 859690799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 859690800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 876628799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 876628800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 889930799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 889930800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 906868799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 906868800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 923194799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 923194800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 939527999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 939528000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 952829999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 952830000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 971582399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 971582400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 984279599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 984279600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1003031999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1003032000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1015729199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1015729200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1034481599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1034481600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1047178799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1047178800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1065931199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1065931200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1079233199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1079233200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1097380799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1097380800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1110682799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1110682800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1128830399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1128830400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1142132399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1142132400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1160884799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1160884800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1173581999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1173582000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1192334399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1192334400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1206845999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1206846000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1223783999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1223784000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1237085999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1237086000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1255233599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1255233600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1270349999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1270350000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1286683199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1286683200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1304823599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1304823600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1313899199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1313899200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1335668399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1335668400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1346558399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1346558400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1367117999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1367118000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1378612799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1378612800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1398567599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1398567600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1410062399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1410062400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1463281199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1463281200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1471147199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1471147200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1494730799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1494730800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1502596799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1502596800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1526180399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1526180400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1534046399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1534046400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1554605999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1554606000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1567915199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1567915200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1586055599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1586055600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1599364799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1599364800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1617505199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1617505200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1630814399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1630814400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1648954799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1648954800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1662868799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1662868800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1680404399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1680404400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1693713599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1693713600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1712458799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1712458800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1725767999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Chile/EasterIsland", 1725768000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 7527599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 7527600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 24465599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 24465600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 37767599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 37767600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 55915199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 55915200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 69217199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 69217200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 87969599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 87969600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 100666799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 100666800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 118209599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 118209600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 132116399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 132116400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 150868799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 150868800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 163565999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 163566000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 182318399000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 182318400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 195620399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 195620400000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 213767999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 213768000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 227069999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 227070000000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 245217599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 245217600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 258519599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 258519600000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 277271999000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 277272000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 289969199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 289969200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 308721599000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 308721600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 321418799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 321418800000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 340171199000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 340171200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 353473199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 353473200000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 371620799000L),
    Some(-420),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 371620800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 403070399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 403070400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 416372399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 416372400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 434519999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 434520000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 447821999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 447822000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 466574399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 466574400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 479271599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 479271600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 498023999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 498024000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 510721199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 510721200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 529473599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 529473600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 545194799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 545194800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 560923199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 560923200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 574225199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 574225200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 592372799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 592372800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 605674799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 605674800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 624427199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 624427200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 637124399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 637124400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 653457599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 653457600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 668573999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 668574000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 687326399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 687326400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 700628399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 700628400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 718775999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 718776000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 732077999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 732078000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 750225599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 750225600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 763527599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 763527600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 781675199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 781675200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 794977199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 794977200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 813729599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 813729600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 826426799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 826426800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 845179199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 845179200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 859690799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 859690800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 876628799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 876628800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 889930799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 889930800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 906868799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 906868800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 923194799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 923194800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 939527999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 939528000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 952829999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 952830000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 971582399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 971582400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 984279599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 984279600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1003031999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1003032000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1015729199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1015729200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1034481599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1034481600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1047178799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1047178800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1065931199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1065931200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1079233199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1079233200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1097380799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1097380800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1110682799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1110682800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1128830399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1128830400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1142132399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1142132400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1160884799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1160884800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1173581999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1173582000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1192334399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1192334400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1206845999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1206846000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1223783999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1223784000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1237085999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1237086000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1255233599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1255233600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1270349999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1270350000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1286683199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1286683200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1304823599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1304823600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1313899199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1313899200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1335668399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1335668400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1346558399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1346558400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1367117999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1367118000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1378612799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1378612800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1398567599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1398567600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1410062399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1410062400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1463281199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1463281200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1471147199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1471147200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1494730799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1494730800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1502596799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1502596800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1526180399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1526180400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1534046399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1534046400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1554605999000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1554606000000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1567915199000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1567915200000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1586055599000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1586055600000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1599364799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1599364800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1617505199000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1617505200000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1630814399000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1630814400000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1648954799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1648954800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1662868799000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1662868800000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1680404399000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1680404400000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1693713599000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1693713600000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1712458799000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1712458800000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1725767999000L),
    Some(-360),
  )
  assert_eq(
    @date.zone_offset_minutes("Pacific/Easter", 1725768000000L),
    Some(-300),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 198291599000L),
    Some(-60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 198291600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 199756799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 199756800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 207701999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 207702000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 231292799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 231292800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 244249199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 244249200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 265507199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 265507200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 271033199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 271033200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1212278399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1212278400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1220223599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1220223600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1243814399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1243814400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1250809199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1250809200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1272758399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1272758400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1281221999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1281222000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1301788799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1301788800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1312066799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1312066800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1335664799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1335664800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1342749599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1342749600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1345427999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1345428000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1348970399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1348970400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1367114399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1367114400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1373162399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1373162400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1376099999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1376100000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1382839199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1382839200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1396144799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1396144800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1403920799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1403920800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1406944799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1406944800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1414288799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1414288800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1427594399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1427594400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1434247199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1434247200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1437271199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1437271200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1445738399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1445738400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1459043999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1459044000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1465091999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1465092000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1468115999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1468116000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1477792799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1477792800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1490493599000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1490493600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1495331999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1495332000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1498960799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1498960800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1509242399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1509242400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1521943199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1521943200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1526176799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1526176800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1529200799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1529200800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1557021599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1557021600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1560045599000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1560045600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1587261599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1587261600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1590890399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1590890400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1618106399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1618106400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1621130399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1621130400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1648346399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1648346400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1651975199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1651975200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1679191199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1679191200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1682215199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1682215200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1710035999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1710036000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1713059999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1713060000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1740275999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1740276000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1743904799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1743904800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1771120799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1771120800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1774144799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1774144800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1801965599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1801965600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1804989599000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1804989600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1832205599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1832205600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1835834399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1835834400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1863050399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1863050400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1866074399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1866074400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1893290399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1893290400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1896919199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1896919200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1924135199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1924135200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1927159199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1927159200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1954979999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1954980000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1958003999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1958004000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1985219999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1985220000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1988848799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 1988848800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2016064799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2016064800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2019088799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2019088800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2046304799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2046304800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2049933599000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2049933600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2077149599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2077149600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2080778399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2080778400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2107994399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2107994400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2111018399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2111018400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2138234399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2138234400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2141863199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2141863200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2169079199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2169079200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2172103199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2172103200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2199923999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2199924000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2202947999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2202948000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2230163999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2230164000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2233792799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2233792800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2261008799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2261008800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2264032799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2264032800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2291248799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2291248800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2294877599000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2294877600000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2322093599000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2322093600000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2325722399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2325722400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2352938399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2352938400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2355962399000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2355962400000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2383178399000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2383178400000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2386807199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2386807200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2414023199000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2414023200000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2417047199000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2417047200000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2444867999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2444868000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2447891999000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2447892000000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2475107999000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2475108000000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2478736799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2478736800000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2505952799000L),
    Some(60),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2505952800000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2508976799000L),
    Some(0),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/El_Aaiun", 2508976800000L),
    Some(60),
  )
  assert_eq(@date.zone_offset_minutes("Asia/Damascus", 10367999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Damascus", 10368000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Damascus", 23583599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Damascus", 23583600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Damascus", 41903999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Damascus", 41904000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Damascus", 55119599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Damascus", 55119600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Damascus", 73526399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Asia/Damascus", 73526400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Damascus", 86741999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Asia/Damascus", 86742000000L), Some(120))
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 105062399000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 105062400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 118277999000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 118278000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 136598399000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 136598400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 149813999000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 149814000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 168134399000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 168134400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 181349999000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 181350000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 199756799000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 199756800000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 212972399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 212972400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 231292799000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 231292800000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 241916399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 241916400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 262828799000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 262828800000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 273452399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 273452400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 418694399000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 418694400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 433810799000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 433810800000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 450316799000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 450316800000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 465433199000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 465433200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 508895999000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 508896000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 529196399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 529196400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 541555199000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 541555200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 562633199000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 562633200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 574387199000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 574387200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 594255599000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 594255600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 607305599000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 607305600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 623199599000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 623199600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 638927999000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 638928000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 654649199000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 654649200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 670456799000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 670456800000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 686264399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 686264400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 702683999000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 702684000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 717886799000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 717886800000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 733096799000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 733096800000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 748904399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 748904400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 765151199000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 765151200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 780958799000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 780958800000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 796687199000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 796687200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 812494799000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 812494800000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 828309599000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 828309600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 844117199000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 844117200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 859759199000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 859759200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 875653199000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 875653200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 891208799000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 891208800000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 907189199000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 907189200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 922917599000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 922917600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 938725199000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 938725200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 954539999000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 954540000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 970347599000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 970347600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 986075999000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 986076000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1001883599000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1001883600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1017611999000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1017612000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1033419599000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1033419600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1049147999000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1049148000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1064955599000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1064955600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1080770399000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1080770400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1096577999000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1096578000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1112306399000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1112306400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1128113999000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1128114000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1143842399000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1143842400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1158872399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1158872400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1175205599000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1175205600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1193950799000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1193950800000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1207259999000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1207260000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1225486799000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1225486800000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1238104799000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1238104800000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1256849999000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1256850000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1270159199000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1270159200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1288299599000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1288299600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1301608799000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1301608800000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1319749199000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1319749200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1333058399000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1333058400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1351198799000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1351198800000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1364507999000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1364508000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1382648399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1382648400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1395957599000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1395957600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1414702799000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1414702800000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1427407199000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1427407200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1446152399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1446152400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1458856799000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1458856800000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1477601999000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1477602000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1490911199000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1490911200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1509051599000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1509051600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1522360799000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1522360800000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1540501199000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1540501200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1553810399000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1553810400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1571950799000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1571950800000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1585259999000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1585260000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1604005199000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1604005200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1616709599000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1616709600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1635454799000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1635454800000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1648159199000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Asia/Damascus", 1648159200000L),
    Some(180),
  )
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 10364399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 10364400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 23587199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 23587200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 41900399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 41900400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 55123199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 55123200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 73522799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 73522800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 86745599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 86745600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 105058799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 105058800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 118281599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 118281600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 136594799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 136594800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 149817599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 149817600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 168130799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 168130800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 181353599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 181353600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 199753199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 199753200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 212975999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 212976000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 231289199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 231289200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 244511999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 244512000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 262825199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 262825200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 276047999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 276048000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 294361199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 294361200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 307583999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 307584000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 325983599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 325983600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 339206399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 339206400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 357519599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 357519600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 370742399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 370742400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 396399599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 396399600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 402278399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 402278400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 426812399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 426812400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 433814399000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 433814400000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 452213999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 452214000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 465436799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 465436800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 483749999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 483750000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 496972799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 496972800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 515285999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 515286000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 528508799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 528508800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 546821999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 546822000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 560044799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 560044800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 578444399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 578444400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 591667199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 591667200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 610412399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 610412400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 623203199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 623203200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 641516399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 641516400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 654739199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 654739200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 673052399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 673052400000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 686275199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 686275200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 704674799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 704674800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 717897599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 717897600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 736210799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 736210800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 749433599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 749433600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 767746799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 767746800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 780969599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 780969600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 799019999000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 799020000000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 812321999000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 812322000000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 830469599000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 830469600000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 843771599000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 843771600000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 861919199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 861919200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 875221199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 875221200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 893368799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 893368800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 906670799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 906670800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 925423199000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 925423200000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 938725199000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 938725200000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 956872799000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 956872800000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 970174799000L), Some(180))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 970174800000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 988322399000L), Some(120))
  assert_eq(@date.zone_offset_minutes("Africa/Cairo", 988322400000L), Some(180))
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1001624399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1001624400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1019771999000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1019772000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1033073999000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1033074000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1051221599000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1051221600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1064523599000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1064523600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1083275999000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1083276000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1096577999000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1096578000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1114725599000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1114725600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1128027599000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1128027600000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1146175199000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1146175200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1158872399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1158872400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1177624799000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1177624800000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1189112399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1189112400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1209074399000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1209074400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1219957199000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1219957200000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1240523999000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1240524000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1250801999000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1250802000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1272578399000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1272578400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1281473999000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1281474000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1284069599000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1284069600000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1285880399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1285880400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1400191199000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1400191200000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1403816399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1403816400000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1406843999000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1406844000000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1411678799000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1411678800000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1682632799000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1682632800000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1698353999000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1698354000000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1714082399000L),
    Some(120),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1714082400000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1730408399000L),
    Some(180),
  )
  assert_eq(
    @date.zone_offset_minutes("Africa/Cairo", 1730408400000L),
    Some(120),
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
