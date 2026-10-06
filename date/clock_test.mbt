// moon-hutool/date 第三批（可注入时钟源）契约用例（黑盒）。**生成件，勿手改**：
// 生成器 scripts/gen_clock_test.py，每条期望都是参照腿 scripts/TzLeg.java 的机器读数
// （E 行=逐区日历日、W 行=七区墙上时刻、U 行=坏区名在参照侧的行为）。
// helper d / dt 复用 date/date_test.mbt，ztag 复用 date/zone_test.mbt（同包测试共享顶层命名空间，
// 所以本文件自己的两个 tag 助手一律加 cl_ 前缀）。

///|
fn cl_date_tag(d : @date.Date?) -> String {
  match d {
    None => "null"
    Some(v) => v.to_iso_string()
  }
}

///|
test "@date date_of 全表逐区日历日（腿 E 行，1970 与当下两档）（第 1/7 块，本块 200 条）" {
  assert_eq(cl_date_tag(@date.date_of("Africa/Abidjan", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Abidjan", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Accra", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Accra", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Addis_Ababa", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Addis_Ababa", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Algiers", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Algiers", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Asmara", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Asmara", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Asmera", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Asmera", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Bamako", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Bamako", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Bangui", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Bangui", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Banjul", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Banjul", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Bissau", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Bissau", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Blantyre", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Blantyre", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Brazzaville", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Brazzaville", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Bujumbura", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Bujumbura", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Cairo", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Cairo", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Casablanca", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Casablanca", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Ceuta", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Ceuta", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Conakry", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Conakry", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Dakar", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Dakar", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Dar_es_Salaam", 0L)),
    "1970-01-01",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Dar_es_Salaam", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Djibouti", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Djibouti", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Douala", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Douala", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/El_Aaiun", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/El_Aaiun", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Freetown", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Freetown", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Gaborone", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Gaborone", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Harare", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Harare", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Johannesburg", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Johannesburg", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Juba", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Juba", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Kampala", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Kampala", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Khartoum", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Khartoum", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Kigali", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Kigali", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Kinshasa", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Kinshasa", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Lagos", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Lagos", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Libreville", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Libreville", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Lome", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Lome", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Luanda", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Luanda", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Lubumbashi", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Lubumbashi", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Lusaka", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Lusaka", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Malabo", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Malabo", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Maputo", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Maputo", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Maseru", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Maseru", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Mbabane", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Mbabane", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Mogadishu", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Mogadishu", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Monrovia", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Monrovia", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Nairobi", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Nairobi", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Ndjamena", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Ndjamena", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Niamey", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Niamey", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Nouakchott", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Nouakchott", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Ouagadougou", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Ouagadougou", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Porto-Novo", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Porto-Novo", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Sao_Tome", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Sao_Tome", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Timbuktu", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Timbuktu", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Tripoli", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Tripoli", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Tunis", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Tunis", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Africa/Windhoek", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Windhoek", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Adak", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Adak", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Anchorage", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Anchorage", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Anguilla", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Anguilla", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Antigua", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Antigua", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Araguaina", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Araguaina", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Buenos_Aires", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Buenos_Aires", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Catamarca", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Catamarca", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/ComodRivadavia", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(
      @date.date_of("America/Argentina/ComodRivadavia", 1791244800000L),
    ),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Cordoba", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Cordoba", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Jujuy", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Jujuy", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/La_Rioja", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/La_Rioja", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Mendoza", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Mendoza", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Rio_Gallegos", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Rio_Gallegos", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Salta", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Salta", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/San_Juan", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/San_Juan", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/San_Luis", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/San_Luis", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Tucuman", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Tucuman", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Ushuaia", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/Ushuaia", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Aruba", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Aruba", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Asuncion", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Asuncion", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Atikokan", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Atikokan", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Atka", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Atka", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Bahia", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Bahia", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Bahia_Banderas", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Bahia_Banderas", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Barbados", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Barbados", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Belem", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Belem", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Belize", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Belize", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Blanc-Sablon", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Blanc-Sablon", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Boa_Vista", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Boa_Vista", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Bogota", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Bogota", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Boise", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Boise", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Buenos_Aires", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Buenos_Aires", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Cambridge_Bay", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Cambridge_Bay", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Campo_Grande", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Campo_Grande", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Cancun", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Cancun", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Caracas", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Caracas", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Catamarca", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Catamarca", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Cayenne", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Cayenne", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Cayman", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Cayman", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Chicago", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Chicago", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Chihuahua", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Chihuahua", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Ciudad_Juarez", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Ciudad_Juarez", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Coral_Harbour", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Coral_Harbour", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Cordoba", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Cordoba", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Costa_Rica", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Costa_Rica", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Creston", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Creston", 1791244800000L)),
    "2026-10-05",
  )
}

///|
test "@date date_of 全表逐区日历日（腿 E 行，1970 与当下两档）（第 2/7 块，本块 200 条）" {
  assert_eq(cl_date_tag(@date.date_of("America/Cuiaba", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Cuiaba", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Curacao", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Curacao", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Danmarkshavn", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Danmarkshavn", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Dawson", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Dawson", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Dawson_Creek", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Dawson_Creek", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Denver", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Denver", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Detroit", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Detroit", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Dominica", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Dominica", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Edmonton", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Edmonton", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Eirunepe", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Eirunepe", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/El_Salvador", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/El_Salvador", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Ensenada", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Ensenada", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Fort_Nelson", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Fort_Nelson", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Fort_Wayne", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Fort_Wayne", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Fortaleza", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Fortaleza", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Glace_Bay", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Glace_Bay", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Godthab", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Godthab", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Goose_Bay", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Goose_Bay", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Grand_Turk", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Grand_Turk", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Grenada", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Grenada", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Guadeloupe", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Guadeloupe", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Guatemala", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Guatemala", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Guayaquil", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Guayaquil", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Guyana", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Guyana", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Halifax", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Halifax", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Havana", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Havana", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Hermosillo", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Hermosillo", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Indianapolis", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Indianapolis", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Knox", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Knox", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Marengo", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Marengo", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Petersburg", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Petersburg", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Tell_City", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Tell_City", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Vevay", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Vevay", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Vincennes", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Vincennes", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Winamac", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indiana/Winamac", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indianapolis", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Indianapolis", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Inuvik", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Inuvik", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Iqaluit", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Iqaluit", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Jamaica", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Jamaica", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Jujuy", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Jujuy", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Juneau", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Juneau", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Kentucky/Louisville", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Kentucky/Louisville", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Kentucky/Monticello", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Kentucky/Monticello", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Knox_IN", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Knox_IN", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Kralendijk", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Kralendijk", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/La_Paz", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/La_Paz", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Lima", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Lima", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Los_Angeles", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Los_Angeles", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Louisville", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Louisville", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Lower_Princes", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Lower_Princes", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Maceio", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Maceio", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Managua", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Managua", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Manaus", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Manaus", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Marigot", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Marigot", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Martinique", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Martinique", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Matamoros", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Matamoros", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Mazatlan", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Mazatlan", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Mendoza", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Mendoza", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Menominee", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Menominee", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Merida", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Merida", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Metlakatla", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Metlakatla", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Mexico_City", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Mexico_City", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Miquelon", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Miquelon", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Moncton", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Moncton", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Monterrey", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Monterrey", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Montevideo", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Montevideo", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Montreal", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Montreal", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Montserrat", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Montserrat", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Nassau", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Nassau", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/New_York", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/New_York", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Nipigon", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Nipigon", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Nome", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Nome", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Noronha", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Noronha", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/North_Dakota/Beulah", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/North_Dakota/Beulah", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/North_Dakota/Center", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/North_Dakota/Center", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/North_Dakota/New_Salem", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/North_Dakota/New_Salem", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Nuuk", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Nuuk", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Ojinaga", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Ojinaga", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Panama", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Panama", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Pangnirtung", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Pangnirtung", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Paramaribo", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Paramaribo", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Phoenix", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Phoenix", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Port-au-Prince", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Port-au-Prince", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Port_of_Spain", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Port_of_Spain", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Porto_Acre", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Porto_Acre", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Porto_Velho", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Porto_Velho", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Puerto_Rico", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Puerto_Rico", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Punta_Arenas", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Punta_Arenas", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Rainy_River", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Rainy_River", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Rankin_Inlet", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Rankin_Inlet", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Recife", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Recife", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Regina", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Regina", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Resolute", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Resolute", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Rio_Branco", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Rio_Branco", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Rosario", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Rosario", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Santa_Isabel", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Santa_Isabel", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Santarem", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Santarem", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Santiago", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Santiago", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Santo_Domingo", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Santo_Domingo", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Sao_Paulo", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Sao_Paulo", 1791244800000L)),
    "2026-10-05",
  )
}

///|
test "@date date_of 全表逐区日历日（腿 E 行，1970 与当下两档）（第 3/7 块，本块 200 条）" {
  assert_eq(
    cl_date_tag(@date.date_of("America/Scoresbysund", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Scoresbysund", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Shiprock", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Shiprock", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Sitka", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Sitka", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/St_Barthelemy", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/St_Barthelemy", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/St_Johns", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/St_Johns", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/St_Kitts", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/St_Kitts", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/St_Lucia", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/St_Lucia", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/St_Thomas", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/St_Thomas", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/St_Vincent", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/St_Vincent", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Swift_Current", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Swift_Current", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Tegucigalpa", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Tegucigalpa", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Thule", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Thule", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Thunder_Bay", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Thunder_Bay", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Tijuana", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Tijuana", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Toronto", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Toronto", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Tortola", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Tortola", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Vancouver", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Vancouver", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Virgin", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Virgin", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Whitehorse", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Whitehorse", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Winnipeg", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Winnipeg", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Yakutat", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Yakutat", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("America/Yellowknife", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("America/Yellowknife", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Antarctica/Casey", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/Casey", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Antarctica/Davis", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/Davis", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/DumontDUrville", 0L)),
    "1970-01-01",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/DumontDUrville", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/Macquarie", 0L)),
    "1970-01-01",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/Macquarie", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Antarctica/Mawson", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/Mawson", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Antarctica/McMurdo", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/McMurdo", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Antarctica/Palmer", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/Palmer", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Antarctica/Rothera", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/Rothera", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/South_Pole", 0L)),
    "1970-01-01",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/South_Pole", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Antarctica/Syowa", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/Syowa", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Antarctica/Troll", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/Troll", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Antarctica/Vostok", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Antarctica/Vostok", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Arctic/Longyearbyen", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Arctic/Longyearbyen", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Aden", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Aden", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Almaty", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Almaty", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Amman", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Amman", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Anadyr", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Anadyr", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Aqtau", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Aqtau", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Aqtobe", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Aqtobe", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Ashgabat", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Ashgabat", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Ashkhabad", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Ashkhabad", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Atyrau", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Atyrau", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Baghdad", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Baghdad", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Bahrain", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Bahrain", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Baku", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Baku", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Bangkok", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Bangkok", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Barnaul", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Barnaul", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Beirut", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Beirut", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Bishkek", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Bishkek", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Brunei", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Brunei", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Calcutta", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Calcutta", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Chita", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Chita", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Choibalsan", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Choibalsan", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Chongqing", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Chongqing", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Chungking", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Chungking", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Colombo", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Colombo", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Dacca", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Dacca", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Damascus", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Damascus", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Dhaka", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Dhaka", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Dili", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Dili", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Dubai", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Dubai", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Dushanbe", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Dushanbe", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Famagusta", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Famagusta", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Gaza", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Gaza", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Harbin", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Harbin", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Hebron", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Hebron", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Ho_Chi_Minh", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Ho_Chi_Minh", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Hong_Kong", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Hong_Kong", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Hovd", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Hovd", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Irkutsk", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Irkutsk", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Istanbul", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Istanbul", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Jakarta", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Jakarta", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Jayapura", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Jayapura", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Jerusalem", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Jerusalem", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Kabul", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Kabul", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Kamchatka", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Kamchatka", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Karachi", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Karachi", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Kashgar", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Kashgar", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Kathmandu", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Kathmandu", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Katmandu", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Katmandu", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Khandyga", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Khandyga", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Kolkata", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Kolkata", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Krasnoyarsk", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Krasnoyarsk", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Kuala_Lumpur", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Kuala_Lumpur", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Kuching", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Kuching", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Kuwait", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Kuwait", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Macao", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Macao", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Macau", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Macau", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Magadan", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Magadan", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Makassar", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Makassar", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Manila", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Manila", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Muscat", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Muscat", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Nicosia", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Nicosia", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Novokuznetsk", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Novokuznetsk", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Novosibirsk", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Novosibirsk", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Omsk", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Omsk", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Oral", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Oral", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Phnom_Penh", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Phnom_Penh", 1791244800000L)),
    "2026-10-06",
  )
}

///|
test "@date date_of 全表逐区日历日（腿 E 行，1970 与当下两档）（第 4/7 块，本块 200 条）" {
  assert_eq(cl_date_tag(@date.date_of("Asia/Pontianak", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Pontianak", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Pyongyang", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Pyongyang", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Qatar", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Qatar", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Qostanay", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Qostanay", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Qyzylorda", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Qyzylorda", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Rangoon", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Rangoon", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Riyadh", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Riyadh", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Saigon", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Saigon", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Sakhalin", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Sakhalin", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Samarkand", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Samarkand", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Seoul", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Seoul", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Shanghai", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Shanghai", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Singapore", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Singapore", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Srednekolymsk", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Srednekolymsk", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Taipei", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Taipei", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Tashkent", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Tashkent", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Tbilisi", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Tbilisi", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Tehran", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Tehran", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Tel_Aviv", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Tel_Aviv", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Thimbu", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Thimbu", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Thimphu", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Thimphu", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Tokyo", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Tokyo", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Tomsk", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Tomsk", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Ujung_Pandang", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Ujung_Pandang", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Ulaanbaatar", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Ulaanbaatar", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Ulan_Bator", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Ulan_Bator", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Urumqi", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Urumqi", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Ust-Nera", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Ust-Nera", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Vientiane", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Vientiane", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Vladivostok", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Vladivostok", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Yakutsk", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Yakutsk", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Yangon", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Yangon", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Yekaterinburg", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Yekaterinburg", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Asia/Yerevan", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Yerevan", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Atlantic/Azores", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Atlantic/Azores", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Atlantic/Bermuda", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Atlantic/Bermuda", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Atlantic/Canary", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Atlantic/Canary", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Atlantic/Cape_Verde", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Atlantic/Cape_Verde", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Atlantic/Faeroe", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Atlantic/Faeroe", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Atlantic/Faroe", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Atlantic/Faroe", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Atlantic/Jan_Mayen", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Atlantic/Jan_Mayen", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Atlantic/Madeira", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Atlantic/Madeira", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Atlantic/Reykjavik", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Atlantic/Reykjavik", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Atlantic/South_Georgia", 0L)),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Atlantic/South_Georgia", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Atlantic/St_Helena", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Atlantic/St_Helena", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Atlantic/Stanley", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Atlantic/Stanley", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/ACT", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/ACT", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/Adelaide", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Adelaide", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/Brisbane", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Brisbane", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Broken_Hill", 0L)),
    "1970-01-01",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Broken_Hill", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/Canberra", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Canberra", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/Currie", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Currie", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/Darwin", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Darwin", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/Eucla", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Eucla", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/Hobart", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Hobart", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/LHI", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/LHI", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/Lindeman", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Lindeman", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/Lord_Howe", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Lord_Howe", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/Melbourne", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Melbourne", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/NSW", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/NSW", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/North", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/North", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/Perth", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Perth", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Queensland", 0L)),
    "1970-01-01",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Queensland", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/South", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/South", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/Sydney", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Sydney", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/Tasmania", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Tasmania", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/Victoria", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Victoria", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Australia/West", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Australia/West", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Yancowinna", 0L)),
    "1970-01-01",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Yancowinna", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Brazil/Acre", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Brazil/Acre", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Brazil/DeNoronha", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Brazil/DeNoronha", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Brazil/East", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Brazil/East", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Brazil/West", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Brazil/West", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("CET", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("CET", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("CST6CDT", 0L)), "1969-12-31")
  assert_eq(cl_date_tag(@date.date_of("CST6CDT", 1791244800000L)), "2026-10-05")
  assert_eq(cl_date_tag(@date.date_of("Canada/Atlantic", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Canada/Atlantic", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Canada/Central", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Canada/Central", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Canada/Eastern", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Canada/Eastern", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Canada/Mountain", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Canada/Mountain", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Canada/Newfoundland", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Canada/Newfoundland", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Canada/Pacific", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Canada/Pacific", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Canada/Saskatchewan", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Canada/Saskatchewan", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Canada/Yukon", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Canada/Yukon", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Chile/Continental", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Chile/Continental", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Chile/EasterIsland", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Chile/EasterIsland", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Cuba", 0L)), "1969-12-31")
  assert_eq(cl_date_tag(@date.date_of("Cuba", 1791244800000L)), "2026-10-05")
  assert_eq(cl_date_tag(@date.date_of("EET", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("EET", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("EST5EDT", 0L)), "1969-12-31")
  assert_eq(cl_date_tag(@date.date_of("EST5EDT", 1791244800000L)), "2026-10-05")
  assert_eq(cl_date_tag(@date.date_of("Egypt", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("Egypt", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Eire", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("Eire", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT+0", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT+0", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT+1", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT+1", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT+10", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT+10", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT+11", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT+11", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT+12", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT+12", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT+2", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT+2", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT+3", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT+3", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT+4", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT+4", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT+5", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT+5", 1791244800000L)),
    "2026-10-05",
  )
}

///|
test "@date date_of 全表逐区日历日（腿 E 行，1970 与当下两档）（第 5/7 块，本块 200 条）" {
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT+6", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT+6", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT+7", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT+7", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT+8", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT+8", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT+9", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT+9", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-0", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-0", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-1", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-1", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-10", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-10", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-11", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-11", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-12", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-12", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-13", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-13", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-14", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-14", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-2", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-2", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-3", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-3", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-4", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-4", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-5", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-5", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-6", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-6", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-7", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-7", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-8", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-8", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT-9", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT-9", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/GMT0", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT0", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/Greenwich", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/Greenwich", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/UCT", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("Etc/UCT", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Etc/UTC", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("Etc/UTC", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Etc/Universal", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/Universal", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Etc/Zulu", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Etc/Zulu", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Amsterdam", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Amsterdam", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Andorra", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Andorra", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Astrakhan", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Astrakhan", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Athens", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Athens", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Belfast", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Belfast", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Belgrade", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Belgrade", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Berlin", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Berlin", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Bratislava", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Bratislava", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Brussels", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Brussels", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Bucharest", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Bucharest", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Budapest", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Budapest", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Busingen", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Busingen", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Chisinau", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Chisinau", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Copenhagen", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Copenhagen", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Dublin", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Dublin", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Gibraltar", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Gibraltar", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Guernsey", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Guernsey", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Helsinki", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Helsinki", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Isle_of_Man", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Isle_of_Man", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Istanbul", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Istanbul", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Jersey", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Jersey", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Kaliningrad", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Kaliningrad", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Kiev", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Kiev", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Kirov", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Kirov", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Kyiv", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Kyiv", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Lisbon", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Lisbon", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Ljubljana", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Ljubljana", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/London", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/London", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Luxembourg", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Luxembourg", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Madrid", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Madrid", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Malta", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Malta", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Mariehamn", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Mariehamn", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Minsk", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Minsk", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Monaco", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Monaco", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Moscow", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Moscow", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Nicosia", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Nicosia", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Oslo", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Oslo", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Paris", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Paris", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Podgorica", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Podgorica", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Prague", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Prague", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Riga", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Riga", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Rome", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Rome", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Samara", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Samara", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/San_Marino", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/San_Marino", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Sarajevo", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Sarajevo", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Saratov", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Saratov", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Simferopol", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Simferopol", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Skopje", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Skopje", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Sofia", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Sofia", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Stockholm", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Stockholm", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Tallinn", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Tallinn", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Tirane", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Tirane", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Tiraspol", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Tiraspol", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Ulyanovsk", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Ulyanovsk", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Uzhgorod", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Uzhgorod", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Vaduz", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Vaduz", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Vatican", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Vatican", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Vienna", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Vienna", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Vilnius", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Vilnius", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Volgograd", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Volgograd", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Warsaw", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Warsaw", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Zagreb", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Zagreb", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Zaporozhye", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Zaporozhye", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Europe/Zurich", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Zurich", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("GB", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("GB", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("GB-Eire", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("GB-Eire", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("GMT", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("GMT", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("GMT0", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("GMT0", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Greenwich", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Greenwich", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Hongkong", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Hongkong", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Iceland", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("Iceland", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Indian/Antananarivo", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Indian/Antananarivo", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Indian/Chagos", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Indian/Chagos", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Indian/Christmas", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Indian/Christmas", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Indian/Cocos", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Indian/Cocos", 1791244800000L)),
    "2026-10-06",
  )
}

///|
test "@date date_of 全表逐区日历日（腿 E 行，1970 与当下两档）（第 6/7 块，本块 200 条）" {
  assert_eq(cl_date_tag(@date.date_of("Indian/Comoro", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Indian/Comoro", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Indian/Kerguelen", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Indian/Kerguelen", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Indian/Mahe", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Indian/Mahe", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Indian/Maldives", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Indian/Maldives", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Indian/Mauritius", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Indian/Mauritius", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Indian/Mayotte", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Indian/Mayotte", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Indian/Reunion", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Indian/Reunion", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Iran", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("Iran", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Israel", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("Israel", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Jamaica", 0L)), "1969-12-31")
  assert_eq(cl_date_tag(@date.date_of("Jamaica", 1791244800000L)), "2026-10-05")
  assert_eq(cl_date_tag(@date.date_of("Japan", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("Japan", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Kwajalein", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Kwajalein", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Libya", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("Libya", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("MET", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("MET", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("MST7MDT", 0L)), "1969-12-31")
  assert_eq(cl_date_tag(@date.date_of("MST7MDT", 1791244800000L)), "2026-10-05")
  assert_eq(cl_date_tag(@date.date_of("Mexico/BajaNorte", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Mexico/BajaNorte", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Mexico/BajaSur", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Mexico/BajaSur", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Mexico/General", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Mexico/General", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("NZ", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("NZ", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("NZ-CHAT", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("NZ-CHAT", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Navajo", 0L)), "1969-12-31")
  assert_eq(cl_date_tag(@date.date_of("Navajo", 1791244800000L)), "2026-10-05")
  assert_eq(cl_date_tag(@date.date_of("PRC", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("PRC", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("PST8PDT", 0L)), "1969-12-31")
  assert_eq(cl_date_tag(@date.date_of("PST8PDT", 1791244800000L)), "2026-10-05")
  assert_eq(cl_date_tag(@date.date_of("Pacific/Apia", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Apia", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Auckland", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Auckland", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Bougainville", 0L)),
    "1970-01-01",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Bougainville", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Chatham", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Chatham", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Chuuk", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Chuuk", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Easter", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Easter", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Efate", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Efate", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Enderbury", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Enderbury", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Fakaofo", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Fakaofo", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Fiji", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Fiji", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Funafuti", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Funafuti", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Galapagos", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Galapagos", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Gambier", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Gambier", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Guadalcanal", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Guadalcanal", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Guam", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Guam", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Honolulu", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Honolulu", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Johnston", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Johnston", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Kanton", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Kanton", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Kiritimati", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Kiritimati", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Kosrae", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Kosrae", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Kwajalein", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Kwajalein", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Majuro", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Majuro", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Marquesas", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Marquesas", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Midway", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Midway", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Nauru", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Nauru", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Niue", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Niue", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Norfolk", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Norfolk", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Noumea", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Noumea", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Pago_Pago", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Pago_Pago", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Palau", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Palau", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Pitcairn", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Pitcairn", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Pohnpei", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Pohnpei", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Ponape", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Ponape", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Port_Moresby", 0L)),
    "1970-01-01",
  )
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Port_Moresby", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Rarotonga", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Rarotonga", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Saipan", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Saipan", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Samoa", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Samoa", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Tahiti", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Tahiti", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Tarawa", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Tarawa", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Tongatapu", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Tongatapu", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Truk", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Truk", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Wake", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Wake", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Wallis", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Wallis", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Pacific/Yap", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Yap", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("Poland", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("Poland", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Portugal", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Portugal", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("ROK", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("ROK", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Singapore", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Singapore", 1791244800000L)),
    "2026-10-06",
  )
  assert_eq(cl_date_tag(@date.date_of("SystemV/AST4", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("SystemV/AST4", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("SystemV/AST4ADT", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("SystemV/AST4ADT", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("SystemV/CST6", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("SystemV/CST6", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("SystemV/CST6CDT", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("SystemV/CST6CDT", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("SystemV/EST5", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("SystemV/EST5", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("SystemV/EST5EDT", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("SystemV/EST5EDT", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("SystemV/HST10", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("SystemV/HST10", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("SystemV/MST7", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("SystemV/MST7", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("SystemV/MST7MDT", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("SystemV/MST7MDT", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("SystemV/PST8", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("SystemV/PST8", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("SystemV/PST8PDT", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("SystemV/PST8PDT", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("SystemV/YST9", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("SystemV/YST9", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("SystemV/YST9YDT", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("SystemV/YST9YDT", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("Turkey", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("Turkey", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("UCT", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("UCT", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("US/Alaska", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("US/Alaska", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("US/Aleutian", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("US/Aleutian", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("US/Arizona", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("US/Arizona", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("US/Central", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("US/Central", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("US/East-Indiana", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("US/East-Indiana", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("US/Eastern", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("US/Eastern", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("US/Hawaii", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("US/Hawaii", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("US/Indiana-Starke", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("US/Indiana-Starke", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("US/Michigan", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("US/Michigan", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("US/Mountain", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("US/Mountain", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("US/Pacific", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("US/Pacific", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("US/Samoa", 0L)), "1969-12-31")
  assert_eq(
    cl_date_tag(@date.date_of("US/Samoa", 1791244800000L)),
    "2026-10-05",
  )
  assert_eq(cl_date_tag(@date.date_of("UTC", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("UTC", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Universal", 0L)), "1970-01-01")
  assert_eq(
    cl_date_tag(@date.date_of("Universal", 1791244800000L)),
    "2026-10-06",
  )
}

///|
test "@date date_of 全表逐区日历日（腿 E 行，1970 与当下两档）（第 7/7 块，本块 6 条）" {
  assert_eq(cl_date_tag(@date.date_of("W-SU", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("W-SU", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("WET", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("WET", 1791244800000L)), "2026-10-06")
  assert_eq(cl_date_tag(@date.date_of("Zulu", 0L)), "1970-01-01")
  assert_eq(cl_date_tag(@date.date_of("Zulu", 1791244800000L)), "2026-10-06")
}

///|
test "@date now_at 用假钟取墙上时刻（腿 W 行直读）" {
  assert_eq(
    ztag(@date.now_at("UTC", @date.clock_fixed(0L))),
    ztag(Some(dt(1970, 1, 1, 0, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("UTC", @date.clock_fixed(515556000000L))),
    ztag(Some(dt(1986, 5, 4, 2, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("UTC", @date.clock_fixed(961070400000L))),
    ztag(Some(dt(2000, 6, 15, 12, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("UTC", @date.clock_fixed(1710052200000L))),
    ztag(Some(dt(2024, 3, 10, 6, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("UTC", @date.clock_fixed(1730613600000L))),
    ztag(Some(dt(2024, 11, 3, 6, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("UTC", @date.clock_fixed(2145916799000L))),
    ztag(Some(dt(2037, 12, 31, 23, 59, 59, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Asia/Shanghai", @date.clock_fixed(0L))),
    ztag(Some(dt(1970, 1, 1, 8, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Asia/Shanghai", @date.clock_fixed(515556000000L))),
    ztag(Some(dt(1986, 5, 4, 11, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Asia/Shanghai", @date.clock_fixed(961070400000L))),
    ztag(Some(dt(2000, 6, 15, 20, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Asia/Shanghai", @date.clock_fixed(1710052200000L))),
    ztag(Some(dt(2024, 3, 10, 14, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Asia/Shanghai", @date.clock_fixed(1730613600000L))),
    ztag(Some(dt(2024, 11, 3, 14, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Asia/Shanghai", @date.clock_fixed(2145916799000L))),
    ztag(Some(dt(2038, 1, 1, 7, 59, 59, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Asia/Kathmandu", @date.clock_fixed(0L))),
    ztag(Some(dt(1970, 1, 1, 5, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Asia/Kathmandu", @date.clock_fixed(515556000000L))),
    ztag(Some(dt(1986, 5, 4, 7, 45, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Asia/Kathmandu", @date.clock_fixed(961070400000L))),
    ztag(Some(dt(2000, 6, 15, 17, 45, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Asia/Kathmandu", @date.clock_fixed(1710052200000L))),
    ztag(Some(dt(2024, 3, 10, 12, 15, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Asia/Kathmandu", @date.clock_fixed(1730613600000L))),
    ztag(Some(dt(2024, 11, 3, 11, 45, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Asia/Kathmandu", @date.clock_fixed(2145916799000L))),
    ztag(Some(dt(2038, 1, 1, 5, 44, 59, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Pacific/Chatham", @date.clock_fixed(0L))),
    ztag(Some(dt(1970, 1, 1, 12, 45, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Pacific/Chatham", @date.clock_fixed(515556000000L))),
    ztag(Some(dt(1986, 5, 4, 14, 45, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Pacific/Chatham", @date.clock_fixed(961070400000L))),
    ztag(Some(dt(2000, 6, 16, 0, 45, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Pacific/Chatham", @date.clock_fixed(1710052200000L))),
    ztag(Some(dt(2024, 3, 10, 20, 15, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Pacific/Chatham", @date.clock_fixed(1730613600000L))),
    ztag(Some(dt(2024, 11, 3, 19, 45, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Pacific/Chatham", @date.clock_fixed(2145916799000L))),
    ztag(Some(dt(2038, 1, 1, 13, 44, 59, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Australia/Lord_Howe", @date.clock_fixed(0L))),
    ztag(Some(dt(1970, 1, 1, 10, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Australia/Lord_Howe", @date.clock_fixed(515556000000L))),
    ztag(Some(dt(1986, 5, 4, 12, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Australia/Lord_Howe", @date.clock_fixed(961070400000L))),
    ztag(Some(dt(2000, 6, 15, 22, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Australia/Lord_Howe", @date.clock_fixed(1710052200000L))),
    ztag(Some(dt(2024, 3, 10, 17, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Australia/Lord_Howe", @date.clock_fixed(1730613600000L))),
    ztag(Some(dt(2024, 11, 3, 17, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Australia/Lord_Howe", @date.clock_fixed(2145916799000L))),
    ztag(Some(dt(2038, 1, 1, 10, 59, 59, 0))),
  )
  assert_eq(
    ztag(@date.now_at("America/New_York", @date.clock_fixed(0L))),
    ztag(Some(dt(1969, 12, 31, 19, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("America/New_York", @date.clock_fixed(515556000000L))),
    ztag(Some(dt(1986, 5, 3, 22, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("America/New_York", @date.clock_fixed(961070400000L))),
    ztag(Some(dt(2000, 6, 15, 8, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("America/New_York", @date.clock_fixed(1710052200000L))),
    ztag(Some(dt(2024, 3, 10, 1, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("America/New_York", @date.clock_fixed(1730613600000L))),
    ztag(Some(dt(2024, 11, 3, 1, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("America/New_York", @date.clock_fixed(2145916799000L))),
    ztag(Some(dt(2037, 12, 31, 18, 59, 59, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Etc/GMT+5", @date.clock_fixed(0L))),
    ztag(Some(dt(1969, 12, 31, 19, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Etc/GMT+5", @date.clock_fixed(515556000000L))),
    ztag(Some(dt(1986, 5, 3, 21, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Etc/GMT+5", @date.clock_fixed(961070400000L))),
    ztag(Some(dt(2000, 6, 15, 7, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Etc/GMT+5", @date.clock_fixed(1710052200000L))),
    ztag(Some(dt(2024, 3, 10, 1, 30, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Etc/GMT+5", @date.clock_fixed(1730613600000L))),
    ztag(Some(dt(2024, 11, 3, 1, 0, 0, 0))),
  )
  assert_eq(
    ztag(@date.now_at("Etc/GMT+5", @date.clock_fixed(2145916799000L))),
    ztag(Some(dt(2037, 12, 31, 18, 59, 59, 0))),
  )
}

///|
test "@date today_at 用假钟取日历日（腿 W 行的日期列直读）" {
  assert_eq(
    cl_date_tag(@date.today_at("UTC", @date.clock_fixed(0L))),
    "1970-01-01",
  )
  assert_eq(
    cl_date_tag(@date.today_at("UTC", @date.clock_fixed(515556000000L))),
    "1986-05-04",
  )
  assert_eq(
    cl_date_tag(@date.today_at("UTC", @date.clock_fixed(961070400000L))),
    "2000-06-15",
  )
  assert_eq(
    cl_date_tag(@date.today_at("UTC", @date.clock_fixed(1710052200000L))),
    "2024-03-10",
  )
  assert_eq(
    cl_date_tag(@date.today_at("UTC", @date.clock_fixed(1730613600000L))),
    "2024-11-03",
  )
  assert_eq(
    cl_date_tag(@date.today_at("UTC", @date.clock_fixed(2145916799000L))),
    "2037-12-31",
  )
  assert_eq(
    cl_date_tag(@date.today_at("Asia/Shanghai", @date.clock_fixed(0L))),
    "1970-01-01",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Asia/Shanghai", @date.clock_fixed(515556000000L)),
    ),
    "1986-05-04",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Asia/Shanghai", @date.clock_fixed(961070400000L)),
    ),
    "2000-06-15",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Asia/Shanghai", @date.clock_fixed(1710052200000L)),
    ),
    "2024-03-10",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Asia/Shanghai", @date.clock_fixed(1730613600000L)),
    ),
    "2024-11-03",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Asia/Shanghai", @date.clock_fixed(2145916799000L)),
    ),
    "2038-01-01",
  )
  assert_eq(
    cl_date_tag(@date.today_at("Asia/Kathmandu", @date.clock_fixed(0L))),
    "1970-01-01",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Asia/Kathmandu", @date.clock_fixed(515556000000L)),
    ),
    "1986-05-04",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Asia/Kathmandu", @date.clock_fixed(961070400000L)),
    ),
    "2000-06-15",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Asia/Kathmandu", @date.clock_fixed(1710052200000L)),
    ),
    "2024-03-10",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Asia/Kathmandu", @date.clock_fixed(1730613600000L)),
    ),
    "2024-11-03",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Asia/Kathmandu", @date.clock_fixed(2145916799000L)),
    ),
    "2038-01-01",
  )
  assert_eq(
    cl_date_tag(@date.today_at("Pacific/Chatham", @date.clock_fixed(0L))),
    "1970-01-01",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Pacific/Chatham", @date.clock_fixed(515556000000L)),
    ),
    "1986-05-04",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Pacific/Chatham", @date.clock_fixed(961070400000L)),
    ),
    "2000-06-16",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Pacific/Chatham", @date.clock_fixed(1710052200000L)),
    ),
    "2024-03-10",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Pacific/Chatham", @date.clock_fixed(1730613600000L)),
    ),
    "2024-11-03",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Pacific/Chatham", @date.clock_fixed(2145916799000L)),
    ),
    "2038-01-01",
  )
  assert_eq(
    cl_date_tag(@date.today_at("Australia/Lord_Howe", @date.clock_fixed(0L))),
    "1970-01-01",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Australia/Lord_Howe", @date.clock_fixed(515556000000L)),
    ),
    "1986-05-04",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Australia/Lord_Howe", @date.clock_fixed(961070400000L)),
    ),
    "2000-06-15",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Australia/Lord_Howe", @date.clock_fixed(1710052200000L)),
    ),
    "2024-03-10",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Australia/Lord_Howe", @date.clock_fixed(1730613600000L)),
    ),
    "2024-11-03",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Australia/Lord_Howe", @date.clock_fixed(2145916799000L)),
    ),
    "2038-01-01",
  )
  assert_eq(
    cl_date_tag(@date.today_at("America/New_York", @date.clock_fixed(0L))),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("America/New_York", @date.clock_fixed(515556000000L)),
    ),
    "1986-05-03",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("America/New_York", @date.clock_fixed(961070400000L)),
    ),
    "2000-06-15",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("America/New_York", @date.clock_fixed(1710052200000L)),
    ),
    "2024-03-10",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("America/New_York", @date.clock_fixed(1730613600000L)),
    ),
    "2024-11-03",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("America/New_York", @date.clock_fixed(2145916799000L)),
    ),
    "2037-12-31",
  )
  assert_eq(
    cl_date_tag(@date.today_at("Etc/GMT+5", @date.clock_fixed(0L))),
    "1969-12-31",
  )
  assert_eq(
    cl_date_tag(@date.today_at("Etc/GMT+5", @date.clock_fixed(515556000000L))),
    "1986-05-03",
  )
  assert_eq(
    cl_date_tag(@date.today_at("Etc/GMT+5", @date.clock_fixed(961070400000L))),
    "2000-06-15",
  )
  assert_eq(
    cl_date_tag(@date.today_at("Etc/GMT+5", @date.clock_fixed(1710052200000L))),
    "2024-03-10",
  )
  assert_eq(
    cl_date_tag(@date.today_at("Etc/GMT+5", @date.clock_fixed(1730613600000L))),
    "2024-11-03",
  )
  assert_eq(
    cl_date_tag(@date.today_at("Etc/GMT+5", @date.clock_fixed(2145916799000L))),
    "2037-12-31",
  )
}

///|
test "@date 坏区名与窗外：五个入口同形给 None（参照侧坏名静默回落 GMT 的那条路不跟随）" {
  // 参照读数：TimeZone=0 | ZoneId_ERR_ZoneRulesException
  assert_eq(
    cl_date_tag(@date.date_of("Nowhere/Nowhere", 1791216000000L)),
    "null",
  )
  assert_eq(
    ztag(@date.now_at("Nowhere/Nowhere", @date.clock_fixed(1791216000000L))),
    "null",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("Nowhere/Nowhere", @date.clock_fixed(1791216000000L)),
    ),
    "null",
  )
  // 参照读数：TimeZone=0 | ZoneId_ERR_DateTimeException
  assert_eq(cl_date_tag(@date.date_of("", 1791216000000L)), "null")
  assert_eq(ztag(@date.now_at("", @date.clock_fixed(1791216000000L))), "null")
  assert_eq(
    cl_date_tag(@date.today_at("", @date.clock_fixed(1791216000000L))),
    "null",
  )
  // 参照读数：TimeZone=0 | ZoneId_ERR_ZoneRulesException
  assert_eq(cl_date_tag(@date.date_of("asia/shanghai", 1791216000000L)), "null")
  assert_eq(
    ztag(@date.now_at("asia/shanghai", @date.clock_fixed(1791216000000L))),
    "null",
  )
  assert_eq(
    cl_date_tag(
      @date.today_at("asia/shanghai", @date.clock_fixed(1791216000000L)),
    ),
    "null",
  )
  // 参照读数：TimeZone=0 | ZoneId_ERR_ZoneRulesException
  assert_eq(cl_date_tag(@date.date_of("Shanghai", 1791216000000L)), "null")
  assert_eq(
    ztag(@date.now_at("Shanghai", @date.clock_fixed(1791216000000L))),
    "null",
  )
  assert_eq(
    cl_date_tag(@date.today_at("Shanghai", @date.clock_fixed(1791216000000L))),
    "null",
  )
  // 参照读数：TimeZone=480 | ZoneId_ERR_DateTimeException
  assert_eq(cl_date_tag(@date.date_of("GMT+8:00", 1791216000000L)), "null")
  assert_eq(
    ztag(@date.now_at("GMT+8:00", @date.clock_fixed(1791216000000L))),
    "null",
  )
  assert_eq(
    cl_date_tag(@date.today_at("GMT+8:00", @date.clock_fixed(1791216000000L))),
    "null",
  )
  // 窗外：假钟给什么就是什么，校验归查表那一步（§6.2 第 2 行）
  assert_eq(cl_date_tag(@date.date_of("UTC", -1L)), "null")
  assert_eq(cl_date_tag(@date.date_of("UTC", 2524608000000L)), "null")
  assert_eq(ztag(@date.now_at("UTC", @date.clock_fixed(-1L))), "null")
}

///|
test "@date clock_fixed 是恒定的假钟：同一个钟连取两次必同值" {
  let c = @date.clock_fixed(123L)
  assert_eq(c(), 123L)
  assert_eq(c(), 123L)
  let c2 = @date.clock_fixed(123L)
  assert_eq(c2(), 123L)
}

///|
test "@date 同一份底本的两个入口必同读数（date_of≡today_at、now_at≡datetime_in）" {
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Abidjan", 0L)),
    cl_date_tag(@date.today_at("Africa/Abidjan", @date.clock_fixed(0L))),
  )
  assert_eq(
    ztag(@date.datetime_in("Africa/Abidjan", 0L)),
    ztag(@date.now_at("Africa/Abidjan", @date.clock_fixed(0L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("Africa/Kinshasa", 1791244800000L)),
    cl_date_tag(
      @date.today_at("Africa/Kinshasa", @date.clock_fixed(1791244800000L)),
    ),
  )
  assert_eq(
    ztag(@date.datetime_in("Africa/Kinshasa", 1791244800000L)),
    ztag(@date.now_at("Africa/Kinshasa", @date.clock_fixed(1791244800000L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Argentina/ComodRivadavia", 0L)),
    cl_date_tag(
      @date.today_at("America/Argentina/ComodRivadavia", @date.clock_fixed(0L)),
    ),
  )
  assert_eq(
    ztag(@date.datetime_in("America/Argentina/ComodRivadavia", 0L)),
    ztag(
      @date.now_at("America/Argentina/ComodRivadavia", @date.clock_fixed(0L)),
    ),
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Cayenne", 1791244800000L)),
    cl_date_tag(
      @date.today_at("America/Cayenne", @date.clock_fixed(1791244800000L)),
    ),
  )
  assert_eq(
    ztag(@date.datetime_in("America/Cayenne", 1791244800000L)),
    ztag(@date.now_at("America/Cayenne", @date.clock_fixed(1791244800000L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Guayaquil", 0L)),
    cl_date_tag(@date.today_at("America/Guayaquil", @date.clock_fixed(0L))),
  )
  assert_eq(
    ztag(@date.datetime_in("America/Guayaquil", 0L)),
    ztag(@date.now_at("America/Guayaquil", @date.clock_fixed(0L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Manaus", 1791244800000L)),
    cl_date_tag(
      @date.today_at("America/Manaus", @date.clock_fixed(1791244800000L)),
    ),
  )
  assert_eq(
    ztag(@date.datetime_in("America/Manaus", 1791244800000L)),
    ztag(@date.now_at("America/Manaus", @date.clock_fixed(1791244800000L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Port_of_Spain", 0L)),
    cl_date_tag(@date.today_at("America/Port_of_Spain", @date.clock_fixed(0L))),
  )
  assert_eq(
    ztag(@date.datetime_in("America/Port_of_Spain", 0L)),
    ztag(@date.now_at("America/Port_of_Spain", @date.clock_fixed(0L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("America/Tijuana", 1791244800000L)),
    cl_date_tag(
      @date.today_at("America/Tijuana", @date.clock_fixed(1791244800000L)),
    ),
  )
  assert_eq(
    ztag(@date.datetime_in("America/Tijuana", 1791244800000L)),
    ztag(@date.now_at("America/Tijuana", @date.clock_fixed(1791244800000L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Baghdad", 0L)),
    cl_date_tag(@date.today_at("Asia/Baghdad", @date.clock_fixed(0L))),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Baghdad", 0L)),
    ztag(@date.now_at("Asia/Baghdad", @date.clock_fixed(0L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Jayapura", 1791244800000L)),
    cl_date_tag(
      @date.today_at("Asia/Jayapura", @date.clock_fixed(1791244800000L)),
    ),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Jayapura", 1791244800000L)),
    ztag(@date.now_at("Asia/Jayapura", @date.clock_fixed(1791244800000L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("Asia/Rangoon", 0L)),
    cl_date_tag(@date.today_at("Asia/Rangoon", @date.clock_fixed(0L))),
  )
  assert_eq(
    ztag(@date.datetime_in("Asia/Rangoon", 0L)),
    ztag(@date.now_at("Asia/Rangoon", @date.clock_fixed(0L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("Atlantic/Bermuda", 1791244800000L)),
    cl_date_tag(
      @date.today_at("Atlantic/Bermuda", @date.clock_fixed(1791244800000L)),
    ),
  )
  assert_eq(
    ztag(@date.datetime_in("Atlantic/Bermuda", 1791244800000L)),
    ztag(@date.now_at("Atlantic/Bermuda", @date.clock_fixed(1791244800000L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("Australia/Victoria", 0L)),
    cl_date_tag(@date.today_at("Australia/Victoria", @date.clock_fixed(0L))),
  )
  assert_eq(
    ztag(@date.datetime_in("Australia/Victoria", 0L)),
    ztag(@date.now_at("Australia/Victoria", @date.clock_fixed(0L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("Etc/GMT+2", 1791244800000L)),
    cl_date_tag(@date.today_at("Etc/GMT+2", @date.clock_fixed(1791244800000L))),
  )
  assert_eq(
    ztag(@date.datetime_in("Etc/GMT+2", 1791244800000L)),
    ztag(@date.now_at("Etc/GMT+2", @date.clock_fixed(1791244800000L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Astrakhan", 0L)),
    cl_date_tag(@date.today_at("Europe/Astrakhan", @date.clock_fixed(0L))),
  )
  assert_eq(
    ztag(@date.datetime_in("Europe/Astrakhan", 0L)),
    ztag(@date.now_at("Europe/Astrakhan", @date.clock_fixed(0L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Minsk", 1791244800000L)),
    cl_date_tag(
      @date.today_at("Europe/Minsk", @date.clock_fixed(1791244800000L)),
    ),
  )
  assert_eq(
    ztag(@date.datetime_in("Europe/Minsk", 1791244800000L)),
    ztag(@date.now_at("Europe/Minsk", @date.clock_fixed(1791244800000L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("Europe/Zurich", 0L)),
    cl_date_tag(@date.today_at("Europe/Zurich", @date.clock_fixed(0L))),
  )
  assert_eq(
    ztag(@date.datetime_in("Europe/Zurich", 0L)),
    ztag(@date.now_at("Europe/Zurich", @date.clock_fixed(0L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("NZ", 1791244800000L)),
    cl_date_tag(@date.today_at("NZ", @date.clock_fixed(1791244800000L))),
  )
  assert_eq(
    ztag(@date.datetime_in("NZ", 1791244800000L)),
    ztag(@date.now_at("NZ", @date.clock_fixed(1791244800000L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("Pacific/Norfolk", 0L)),
    cl_date_tag(@date.today_at("Pacific/Norfolk", @date.clock_fixed(0L))),
  )
  assert_eq(
    ztag(@date.datetime_in("Pacific/Norfolk", 0L)),
    ztag(@date.now_at("Pacific/Norfolk", @date.clock_fixed(0L))),
  )
  assert_eq(
    cl_date_tag(@date.date_of("SystemV/MST7MDT", 1791244800000L)),
    cl_date_tag(
      @date.today_at("SystemV/MST7MDT", @date.clock_fixed(1791244800000L)),
    ),
  )
  assert_eq(
    ztag(@date.datetime_in("SystemV/MST7MDT", 1791244800000L)),
    ztag(@date.now_at("SystemV/MST7MDT", @date.clock_fixed(1791244800000L))),
  )
}

///|
test "@date clock_system 只断形状与绝对下界，不断两次读数之间的关系（§6.4）" {
  let ms = @date.clock_system()()
  assert_eq(ms > 1700000000000L, true)
  // 真钟的读数必须还能查出偏移（否则等于把 OS 口子接错了地方）
  assert_eq(@date.zone_offset_minutes("Asia/Shanghai", ms) != None, true)
  assert_eq(cl_date_tag(@date.date_of("Asia/Shanghai", ms)) != "null", true)
  // 同一次读数下，两个入口必同值；**不**拿两次不同读数互比（计时依赖）
  let one = @date.clock_fixed(ms)
  assert_eq(cl_date_tag(@date.today_at("UTC", one)) != "null", true)
  assert_eq(ztag(@date.now_at("UTC", one)), ztag(@date.datetime_in("UTC", ms)))
}
