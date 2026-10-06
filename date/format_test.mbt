// moon-hutool/date 第四批（命名时区版格式化与解析）契约用例（黑盒）。**生成件，勿手改**：
// 生成器 scripts/gen_format_test.py，期望串全部来自参照腿 scripts/FormatLeg.java 的机器读数。
// 参照代次：JDK 17.0.14 · lib/tzdb.dat 101731 bytes。腿自证 SELFCHK_BAD=0（F 行另走一条独立 JDK 路径逐字符比过）。
// helper `shape` 复用 date/date_test.mbt（同包测试共享顶层命名空间）。

///|
test "@date format_in 全表逐区两瞬间（腿 F 行）（第 1/7 块，本块 200 条）" {
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Abidjan"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Abidjan"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Accra"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Accra"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Addis_Ababa"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Addis_Ababa"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Algiers"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Algiers"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Asmara"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Asmara"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Asmera"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Asmera"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Bamako"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Bamako"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Bangui"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Bangui"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Banjul"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Banjul"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Bissau"),
    Some("1969-12-31 23:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Bissau"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Blantyre"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Blantyre"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Brazzaville"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Brazzaville"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Bujumbura"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Bujumbura"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Cairo"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Cairo"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Casablanca"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Casablanca"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Ceuta"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Ceuta"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Conakry"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Conakry"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Dakar"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Dakar"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Dar_es_Salaam"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Dar_es_Salaam",
    ),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Djibouti"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Djibouti"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Douala"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Douala"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/El_Aaiun"),
    Some("1969-12-31 23:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/El_Aaiun"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Freetown"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Freetown"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Gaborone"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Gaborone"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Harare"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Harare"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Johannesburg"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Johannesburg",
    ),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Juba"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Juba"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Kampala"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Kampala"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Khartoum"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Khartoum"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Kigali"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Kigali"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Kinshasa"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Kinshasa"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Lagos"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Lagos"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Libreville"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Libreville"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Lome"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Lome"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Luanda"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Luanda"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Lubumbashi"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Lubumbashi"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Lusaka"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Lusaka"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Malabo"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Malabo"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Maputo"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Maputo"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Maseru"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Maseru"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Mbabane"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Mbabane"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Mogadishu"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Mogadishu"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Monrovia"),
    Some("1969-12-31 23:15:30"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Monrovia"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Nairobi"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Nairobi"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Ndjamena"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Ndjamena"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Niamey"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Niamey"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Nouakchott"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Nouakchott"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Ouagadougou"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Ouagadougou"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Porto-Novo"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Porto-Novo"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Sao_Tome"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Sao_Tome"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Timbuktu"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Timbuktu"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Tripoli"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Tripoli"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Tunis"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Tunis"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Windhoek"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Africa/Windhoek"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Adak"),
    Some("1969-12-31 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Adak"),
    Some("2026-10-05 15:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Anchorage"),
    Some("1969-12-31 14:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Anchorage"),
    Some("2026-10-05 16:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Anguilla"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Anguilla"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Antigua"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Antigua"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Araguaina"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Araguaina"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Buenos_Aires"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Buenos_Aires",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Catamarca"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Catamarca",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      0L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/ComodRivadavia",
    ),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/ComodRivadavia",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Cordoba"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Cordoba",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Jujuy"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Jujuy",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/La_Rioja"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/La_Rioja",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Mendoza"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Mendoza",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Rio_Gallegos"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Rio_Gallegos",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Salta"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Salta",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/San_Juan"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/San_Juan",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/San_Luis"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/San_Luis",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Tucuman"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Tucuman",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Ushuaia"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Argentina/Ushuaia",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Aruba"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Aruba"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Asuncion"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Asuncion"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Atikokan"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Atikokan"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Atka"),
    Some("1969-12-31 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Atka"),
    Some("2026-10-05 15:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Bahia"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Bahia"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Bahia_Banderas"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Bahia_Banderas",
    ),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Barbados"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Barbados"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Belem"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Belem"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Belize"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Belize"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Blanc-Sablon"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Blanc-Sablon",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Boa_Vista"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Boa_Vista"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Bogota"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Bogota"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Boise"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Boise"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Buenos_Aires"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Buenos_Aires",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Cambridge_Bay"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Cambridge_Bay",
    ),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Campo_Grande"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Campo_Grande",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Cancun"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Cancun"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Caracas"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Caracas"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Catamarca"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Catamarca"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Cayenne"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Cayenne"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Cayman"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Cayman"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Chicago"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Chicago"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Chihuahua"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Chihuahua"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Ciudad_Juarez"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Ciudad_Juarez",
    ),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Coral_Harbour"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Coral_Harbour",
    ),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Cordoba"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Cordoba"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Costa_Rica"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Costa_Rica"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Creston"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Creston"),
    Some("2026-10-05 17:00:00"),
  )
}

///|
test "@date format_in 全表逐区两瞬间（腿 F 行）（第 2/7 块，本块 200 条）" {
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Cuiaba"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Cuiaba"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Curacao"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Curacao"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Danmarkshavn"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Danmarkshavn",
    ),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Dawson"),
    Some("1969-12-31 15:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Dawson"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Dawson_Creek"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Dawson_Creek",
    ),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Denver"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Denver"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Detroit"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Detroit"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Dominica"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Dominica"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Edmonton"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Edmonton"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Eirunepe"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Eirunepe"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/El_Salvador"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/El_Salvador",
    ),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Ensenada"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Ensenada"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Fort_Nelson"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Fort_Nelson",
    ),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Fort_Wayne"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Fort_Wayne"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Fortaleza"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Fortaleza"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Glace_Bay"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Glace_Bay"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Godthab"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Godthab"),
    Some("2026-10-05 23:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Goose_Bay"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Goose_Bay"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Grand_Turk"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Grand_Turk"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Grenada"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Grenada"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Guadeloupe"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Guadeloupe"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Guatemala"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Guatemala"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Guayaquil"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Guayaquil"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Guyana"),
    Some("1969-12-31 20:15:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Guyana"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Halifax"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Halifax"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Havana"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Havana"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Hermosillo"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Hermosillo"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Indianapolis"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Indianapolis",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Knox"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Knox",
    ),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Marengo"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Marengo",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Petersburg"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Petersburg",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Tell_City"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Tell_City",
    ),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Vevay"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Vevay",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Vincennes"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Vincennes",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Winamac"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Indiana/Winamac",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Indianapolis"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Indianapolis",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Inuvik"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Inuvik"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Iqaluit"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Iqaluit"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Jamaica"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Jamaica"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Jujuy"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Jujuy"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Juneau"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Juneau"),
    Some("2026-10-05 16:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Kentucky/Louisville"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Kentucky/Louisville",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Kentucky/Monticello"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Kentucky/Monticello",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Knox_IN"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Knox_IN"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Kralendijk"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Kralendijk"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/La_Paz"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/La_Paz"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Lima"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Lima"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Los_Angeles"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Los_Angeles",
    ),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Louisville"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Louisville"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Lower_Princes"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Lower_Princes",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Maceio"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Maceio"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Managua"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Managua"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Manaus"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Manaus"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Marigot"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Marigot"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Martinique"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Martinique"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Matamoros"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Matamoros"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Mazatlan"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Mazatlan"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Mendoza"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Mendoza"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Menominee"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Menominee"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Merida"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Merida"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Metlakatla"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Metlakatla"),
    Some("2026-10-05 16:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Mexico_City"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Mexico_City",
    ),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Miquelon"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Miquelon"),
    Some("2026-10-05 22:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Moncton"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Moncton"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Monterrey"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Monterrey"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Montevideo"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Montevideo"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Montreal"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Montreal"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Montserrat"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Montserrat"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Nassau"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Nassau"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/New_York"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/New_York"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Nipigon"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Nipigon"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Nome"),
    Some("1969-12-31 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Nome"),
    Some("2026-10-05 16:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Noronha"),
    Some("1969-12-31 22:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Noronha"),
    Some("2026-10-05 22:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/North_Dakota/Beulah"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/North_Dakota/Beulah",
    ),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/North_Dakota/Center"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/North_Dakota/Center",
    ),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/North_Dakota/New_Salem"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/North_Dakota/New_Salem",
    ),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Nuuk"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Nuuk"),
    Some("2026-10-05 23:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Ojinaga"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Ojinaga"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Panama"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Panama"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Pangnirtung"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Pangnirtung",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Paramaribo"),
    Some("1969-12-31 20:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Paramaribo"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Phoenix"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Phoenix"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Port-au-Prince"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Port-au-Prince",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Port_of_Spain"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Port_of_Spain",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Porto_Acre"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Porto_Acre"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Porto_Velho"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Porto_Velho",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Puerto_Rico"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Puerto_Rico",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Punta_Arenas"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Punta_Arenas",
    ),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Rainy_River"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Rainy_River",
    ),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Rankin_Inlet"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Rankin_Inlet",
    ),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Recife"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Recife"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Regina"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Regina"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Resolute"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Resolute"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Rio_Branco"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Rio_Branco"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Rosario"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Rosario"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Santa_Isabel"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Santa_Isabel",
    ),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Santarem"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Santarem"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Santiago"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Santiago"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Santo_Domingo"),
    Some("1969-12-31 19:30:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Santo_Domingo",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Sao_Paulo"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Sao_Paulo"),
    Some("2026-10-05 21:00:00"),
  )
}

///|
test "@date format_in 全表逐区两瞬间（腿 F 行）（第 3/7 块，本块 200 条）" {
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Scoresbysund"),
    Some("1969-12-31 22:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Scoresbysund",
    ),
    Some("2026-10-05 23:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Shiprock"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Shiprock"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Sitka"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Sitka"),
    Some("2026-10-05 16:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/St_Barthelemy"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/St_Barthelemy",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/St_Johns"),
    Some("1969-12-31 20:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/St_Johns"),
    Some("2026-10-05 21:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/St_Kitts"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/St_Kitts"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/St_Lucia"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/St_Lucia"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/St_Thomas"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/St_Thomas"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/St_Vincent"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/St_Vincent"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Swift_Current"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Swift_Current",
    ),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Tegucigalpa"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Tegucigalpa",
    ),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Thule"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Thule"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Thunder_Bay"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Thunder_Bay",
    ),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Tijuana"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Tijuana"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Toronto"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Toronto"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Tortola"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Tortola"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Vancouver"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Vancouver"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Virgin"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Virgin"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Whitehorse"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Whitehorse"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Winnipeg"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Winnipeg"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Yakutat"),
    Some("1969-12-31 15:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Yakutat"),
    Some("2026-10-05 16:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Yellowknife"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "America/Yellowknife",
    ),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Casey"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Casey"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Davis"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Davis"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Antarctica/DumontDUrville"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Antarctica/DumontDUrville",
    ),
    Some("2026-10-06 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Macquarie"),
    Some("1970-01-01 11:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Macquarie",
    ),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Mawson"),
    Some("1970-01-01 06:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Mawson"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Antarctica/McMurdo"),
    Some("1970-01-01 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Antarctica/McMurdo"),
    Some("2026-10-06 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Palmer"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Palmer"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Rothera"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Rothera"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Antarctica/South_Pole"),
    Some("1970-01-01 12:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Antarctica/South_Pole",
    ),
    Some("2026-10-06 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Syowa"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Syowa"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Troll"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Troll"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Vostok"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Antarctica/Vostok"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Arctic/Longyearbyen"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Arctic/Longyearbyen",
    ),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Aden"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Aden"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Almaty"),
    Some("1970-01-01 06:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Almaty"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Amman"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Amman"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Anadyr"),
    Some("1970-01-01 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Anadyr"),
    Some("2026-10-06 12:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Aqtau"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Aqtau"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Aqtobe"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Aqtobe"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Ashgabat"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Ashgabat"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Ashkhabad"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Ashkhabad"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Atyrau"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Atyrau"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Baghdad"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Baghdad"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Bahrain"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Bahrain"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Baku"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Baku"),
    Some("2026-10-06 04:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Bangkok"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Bangkok"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Barnaul"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Barnaul"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Beirut"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Beirut"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Bishkek"),
    Some("1970-01-01 06:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Bishkek"),
    Some("2026-10-06 06:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Brunei"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Brunei"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Calcutta"),
    Some("1970-01-01 05:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Calcutta"),
    Some("2026-10-06 05:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Chita"),
    Some("1970-01-01 09:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Chita"),
    Some("2026-10-06 09:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Choibalsan"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Choibalsan"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Chongqing"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Chongqing"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Chungking"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Chungking"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Colombo"),
    Some("1970-01-01 05:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Colombo"),
    Some("2026-10-06 05:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Dacca"),
    Some("1970-01-01 06:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Dacca"),
    Some("2026-10-06 06:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Damascus"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Damascus"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Dhaka"),
    Some("1970-01-01 06:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Dhaka"),
    Some("2026-10-06 06:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Dili"),
    Some("1970-01-01 09:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Dili"),
    Some("2026-10-06 09:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Dubai"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Dubai"),
    Some("2026-10-06 04:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Dushanbe"),
    Some("1970-01-01 06:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Dushanbe"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Famagusta"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Famagusta"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Gaza"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Gaza"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Harbin"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Harbin"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Hebron"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Hebron"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Ho_Chi_Minh"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Ho_Chi_Minh"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Hong_Kong"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Hong_Kong"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Hovd"),
    Some("1970-01-01 06:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Hovd"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Irkutsk"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Irkutsk"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Istanbul"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Istanbul"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Jakarta"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Jakarta"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Jayapura"),
    Some("1970-01-01 09:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Jayapura"),
    Some("2026-10-06 09:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Jerusalem"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Jerusalem"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Kabul"),
    Some("1970-01-01 04:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Kabul"),
    Some("2026-10-06 04:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Kamchatka"),
    Some("1970-01-01 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Kamchatka"),
    Some("2026-10-06 12:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Karachi"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Karachi"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Kashgar"),
    Some("1970-01-01 06:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Kashgar"),
    Some("2026-10-06 06:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Kathmandu"),
    Some("1970-01-01 05:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Kathmandu"),
    Some("2026-10-06 05:45:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Katmandu"),
    Some("1970-01-01 05:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Katmandu"),
    Some("2026-10-06 05:45:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Khandyga"),
    Some("1970-01-01 09:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Khandyga"),
    Some("2026-10-06 09:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Kolkata"),
    Some("1970-01-01 05:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Kolkata"),
    Some("2026-10-06 05:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Krasnoyarsk"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Krasnoyarsk"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Kuala_Lumpur"),
    Some("1970-01-01 07:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Kuala_Lumpur"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Kuching"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Kuching"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Kuwait"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Kuwait"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Macao"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Macao"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Macau"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Macau"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Magadan"),
    Some("1970-01-01 11:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Magadan"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Makassar"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Makassar"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Manila"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Manila"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Muscat"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Muscat"),
    Some("2026-10-06 04:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Nicosia"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Nicosia"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Novokuznetsk"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Novokuznetsk"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Novosibirsk"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Novosibirsk"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Omsk"),
    Some("1970-01-01 06:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Omsk"),
    Some("2026-10-06 06:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Oral"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Oral"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Phnom_Penh"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Phnom_Penh"),
    Some("2026-10-06 07:00:00"),
  )
}

///|
test "@date format_in 全表逐区两瞬间（腿 F 行）（第 4/7 块，本块 200 条）" {
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Pontianak"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Pontianak"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Pyongyang"),
    Some("1970-01-01 09:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Pyongyang"),
    Some("2026-10-06 09:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Qatar"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Qatar"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Qostanay"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Qostanay"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Qyzylorda"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Qyzylorda"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Rangoon"),
    Some("1970-01-01 06:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Rangoon"),
    Some("2026-10-06 06:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Riyadh"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Riyadh"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Saigon"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Saigon"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Sakhalin"),
    Some("1970-01-01 11:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Sakhalin"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Samarkand"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Samarkand"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Seoul"),
    Some("1970-01-01 09:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Seoul"),
    Some("2026-10-06 09:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Shanghai"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Shanghai"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Singapore"),
    Some("1970-01-01 07:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Singapore"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Srednekolymsk"),
    Some("1970-01-01 11:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Srednekolymsk"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Taipei"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Taipei"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Tashkent"),
    Some("1970-01-01 06:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Tashkent"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Tbilisi"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Tbilisi"),
    Some("2026-10-06 04:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Tehran"),
    Some("1970-01-01 03:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Tehran"),
    Some("2026-10-06 03:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Tel_Aviv"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Tel_Aviv"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Thimbu"),
    Some("1970-01-01 05:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Thimbu"),
    Some("2026-10-06 06:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Thimphu"),
    Some("1970-01-01 05:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Thimphu"),
    Some("2026-10-06 06:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Tokyo"),
    Some("1970-01-01 09:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Tokyo"),
    Some("2026-10-06 09:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Tomsk"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Tomsk"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Ujung_Pandang"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Ujung_Pandang"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Ulaanbaatar"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Ulaanbaatar"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Ulan_Bator"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Ulan_Bator"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Urumqi"),
    Some("1970-01-01 06:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Urumqi"),
    Some("2026-10-06 06:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Ust-Nera"),
    Some("1970-01-01 09:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Ust-Nera"),
    Some("2026-10-06 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Vientiane"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Vientiane"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Vladivostok"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Vladivostok"),
    Some("2026-10-06 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Yakutsk"),
    Some("1970-01-01 09:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Yakutsk"),
    Some("2026-10-06 09:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Yangon"),
    Some("1970-01-01 06:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Yangon"),
    Some("2026-10-06 06:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Yekaterinburg"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Yekaterinburg"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Yerevan"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Asia/Yerevan"),
    Some("2026-10-06 04:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Azores"),
    Some("1969-12-31 23:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Azores"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Bermuda"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Bermuda"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Canary"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Canary"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Cape_Verde"),
    Some("1969-12-31 22:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Cape_Verde",
    ),
    Some("2026-10-05 23:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Faeroe"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Faeroe"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Faroe"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Faroe"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Jan_Mayen"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Jan_Mayen"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Madeira"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Madeira"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Reykjavik"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Reykjavik"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Atlantic/South_Georgia"),
    Some("1969-12-31 22:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Atlantic/South_Georgia",
    ),
    Some("2026-10-05 22:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Atlantic/St_Helena"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Atlantic/St_Helena"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Stanley"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Atlantic/Stanley"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/ACT"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/ACT"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Adelaide"),
    Some("1970-01-01 09:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Adelaide"),
    Some("2026-10-06 10:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Brisbane"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Brisbane"),
    Some("2026-10-06 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Broken_Hill"),
    Some("1970-01-01 09:30:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Broken_Hill",
    ),
    Some("2026-10-06 10:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Canberra"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Canberra"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Currie"),
    Some("1970-01-01 11:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Currie"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Darwin"),
    Some("1970-01-01 09:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Darwin"),
    Some("2026-10-06 09:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Eucla"),
    Some("1970-01-01 08:45:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Eucla"),
    Some("2026-10-06 08:45:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Hobart"),
    Some("1970-01-01 11:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Hobart"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/LHI"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/LHI"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Lindeman"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Lindeman"),
    Some("2026-10-06 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Lord_Howe"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Lord_Howe",
    ),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Melbourne"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Melbourne",
    ),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/NSW"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/NSW"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/North"),
    Some("1970-01-01 09:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/North"),
    Some("2026-10-06 09:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Perth"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Perth"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Queensland"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Queensland",
    ),
    Some("2026-10-06 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/South"),
    Some("1970-01-01 09:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/South"),
    Some("2026-10-06 10:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Sydney"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Sydney"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Tasmania"),
    Some("1970-01-01 11:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Tasmania"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Victoria"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Victoria"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/West"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/West"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Yancowinna"),
    Some("1970-01-01 09:30:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Australia/Yancowinna",
    ),
    Some("2026-10-06 10:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Brazil/Acre"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Brazil/Acre"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Brazil/DeNoronha"),
    Some("1969-12-31 22:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Brazil/DeNoronha"),
    Some("2026-10-05 22:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Brazil/East"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Brazil/East"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Brazil/West"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Brazil/West"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "CET"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "CET"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "CST6CDT"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "CST6CDT"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Canada/Atlantic"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Canada/Atlantic"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Canada/Central"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Canada/Central"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Canada/Eastern"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Canada/Eastern"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Canada/Mountain"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Canada/Mountain"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Canada/Newfoundland"),
    Some("1969-12-31 20:30:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Canada/Newfoundland",
    ),
    Some("2026-10-05 21:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Canada/Pacific"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Canada/Pacific"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Canada/Saskatchewan"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Canada/Saskatchewan",
    ),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Canada/Yukon"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Canada/Yukon"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Chile/Continental"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Chile/Continental"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Chile/EasterIsland"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Chile/EasterIsland"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Cuba"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Cuba"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "EET"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "EET"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "EST5EDT"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "EST5EDT"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Egypt"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Egypt"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Eire"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Eire"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+0"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+0"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+1"),
    Some("1969-12-31 23:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+1"),
    Some("2026-10-05 23:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+10"),
    Some("1969-12-31 14:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+10"),
    Some("2026-10-05 14:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+11"),
    Some("1969-12-31 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+11"),
    Some("2026-10-05 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+12"),
    Some("1969-12-31 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+12"),
    Some("2026-10-05 12:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+2"),
    Some("1969-12-31 22:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+2"),
    Some("2026-10-05 22:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+3"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+3"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+4"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+4"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+5"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+5"),
    Some("2026-10-05 19:00:00"),
  )
}

///|
test "@date format_in 全表逐区两瞬间（腿 F 行）（第 5/7 块，本块 200 条）" {
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+6"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+6"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+7"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+7"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+8"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+8"),
    Some("2026-10-05 16:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+9"),
    Some("1969-12-31 15:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+9"),
    Some("2026-10-05 15:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-0"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-0"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-1"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-1"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-10"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-10"),
    Some("2026-10-06 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-11"),
    Some("1970-01-01 11:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-11"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-12"),
    Some("1970-01-01 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-12"),
    Some("2026-10-06 12:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-13"),
    Some("1970-01-01 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-13"),
    Some("2026-10-06 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-14"),
    Some("1970-01-01 14:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-14"),
    Some("2026-10-06 14:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-2"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-2"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-3"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-3"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-4"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-4"),
    Some("2026-10-06 04:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-5"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-5"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-6"),
    Some("1970-01-01 06:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-6"),
    Some("2026-10-06 06:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-7"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-7"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-8"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-8"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-9"),
    Some("1970-01-01 09:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT-9"),
    Some("2026-10-06 09:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT0"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT0"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/Greenwich"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/Greenwich"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/UCT"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/UCT"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/UTC"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/UTC"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/Universal"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/Universal"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/Zulu"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Etc/Zulu"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Amsterdam"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Amsterdam"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Andorra"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Andorra"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Astrakhan"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Astrakhan"),
    Some("2026-10-06 04:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Athens"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Athens"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Belfast"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Belfast"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Belgrade"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Belgrade"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Berlin"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Berlin"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Bratislava"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Bratislava"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Brussels"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Brussels"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Bucharest"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Bucharest"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Budapest"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Budapest"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Busingen"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Busingen"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Chisinau"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Chisinau"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Copenhagen"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Copenhagen"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Dublin"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Dublin"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Gibraltar"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Gibraltar"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Guernsey"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Guernsey"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Helsinki"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Helsinki"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Isle_of_Man"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Isle_of_Man"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Istanbul"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Istanbul"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Jersey"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Jersey"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Kaliningrad"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Kaliningrad"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Kiev"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Kiev"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Kirov"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Kirov"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Kyiv"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Kyiv"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Lisbon"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Lisbon"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Ljubljana"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Ljubljana"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/London"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/London"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Luxembourg"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Luxembourg"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Madrid"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Madrid"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Malta"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Malta"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Mariehamn"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Mariehamn"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Minsk"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Minsk"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Monaco"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Monaco"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Moscow"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Moscow"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Nicosia"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Nicosia"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Oslo"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Oslo"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Paris"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Paris"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Podgorica"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Podgorica"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Prague"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Prague"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Riga"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Riga"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Rome"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Rome"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Samara"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Samara"),
    Some("2026-10-06 04:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/San_Marino"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/San_Marino"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Sarajevo"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Sarajevo"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Saratov"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Saratov"),
    Some("2026-10-06 04:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Simferopol"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Simferopol"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Skopje"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Skopje"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Sofia"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Sofia"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Stockholm"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Stockholm"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Tallinn"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Tallinn"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Tirane"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Tirane"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Tiraspol"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Tiraspol"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Ulyanovsk"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Ulyanovsk"),
    Some("2026-10-06 04:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Uzhgorod"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Uzhgorod"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Vaduz"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Vaduz"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Vatican"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Vatican"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Vienna"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Vienna"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Vilnius"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Vilnius"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Volgograd"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Volgograd"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Warsaw"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Warsaw"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Zagreb"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Zagreb"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Zaporozhye"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Zaporozhye"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/Zurich"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Europe/Zurich"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "GB"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "GB"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "GB-Eire"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "GB-Eire"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "GMT"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "GMT"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "GMT0"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "GMT0"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Greenwich"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Greenwich"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Hongkong"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Hongkong"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Iceland"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Iceland"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Indian/Antananarivo"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Indian/Antananarivo",
    ),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Indian/Chagos"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Indian/Chagos"),
    Some("2026-10-06 06:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Indian/Christmas"),
    Some("1970-01-01 07:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Indian/Christmas"),
    Some("2026-10-06 07:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Indian/Cocos"),
    Some("1970-01-01 06:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Indian/Cocos"),
    Some("2026-10-06 06:30:00"),
  )
}

///|
test "@date format_in 全表逐区两瞬间（腿 F 行）（第 6/7 块，本块 200 条）" {
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Indian/Comoro"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Indian/Comoro"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Indian/Kerguelen"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Indian/Kerguelen"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Indian/Mahe"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Indian/Mahe"),
    Some("2026-10-06 04:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Indian/Maldives"),
    Some("1970-01-01 05:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Indian/Maldives"),
    Some("2026-10-06 05:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Indian/Mauritius"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Indian/Mauritius"),
    Some("2026-10-06 04:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Indian/Mayotte"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Indian/Mayotte"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Indian/Reunion"),
    Some("1970-01-01 04:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Indian/Reunion"),
    Some("2026-10-06 04:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Iran"),
    Some("1970-01-01 03:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Iran"),
    Some("2026-10-06 03:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Israel"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Israel"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Jamaica"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Jamaica"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Japan"),
    Some("1970-01-01 09:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Japan"),
    Some("2026-10-06 09:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Kwajalein"),
    Some("1969-12-31 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Kwajalein"),
    Some("2026-10-06 12:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Libya"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Libya"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "MET"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "MET"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "MST7MDT"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "MST7MDT"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Mexico/BajaNorte"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Mexico/BajaNorte"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Mexico/BajaSur"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Mexico/BajaSur"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Mexico/General"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Mexico/General"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "NZ"),
    Some("1970-01-01 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "NZ"),
    Some("2026-10-06 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "NZ-CHAT"),
    Some("1970-01-01 12:45:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "NZ-CHAT"),
    Some("2026-10-06 13:45:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Navajo"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Navajo"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "PRC"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "PRC"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "PST8PDT"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "PST8PDT"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Apia"),
    Some("1969-12-31 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Apia"),
    Some("2026-10-06 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Auckland"),
    Some("1970-01-01 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Auckland"),
    Some("2026-10-06 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Bougainville"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Bougainville",
    ),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Chatham"),
    Some("1970-01-01 12:45:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Chatham"),
    Some("2026-10-06 13:45:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Chuuk"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Chuuk"),
    Some("2026-10-06 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Easter"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Easter"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Efate"),
    Some("1970-01-01 11:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Efate"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Enderbury"),
    Some("1969-12-31 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Enderbury"),
    Some("2026-10-06 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Fakaofo"),
    Some("1969-12-31 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Fakaofo"),
    Some("2026-10-06 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Fiji"),
    Some("1970-01-01 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Fiji"),
    Some("2026-10-06 12:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Funafuti"),
    Some("1970-01-01 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Funafuti"),
    Some("2026-10-06 12:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Galapagos"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Galapagos"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Gambier"),
    Some("1969-12-31 15:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Gambier"),
    Some("2026-10-05 15:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Guadalcanal"),
    Some("1970-01-01 11:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Guadalcanal",
    ),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Guam"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Guam"),
    Some("2026-10-06 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Honolulu"),
    Some("1969-12-31 14:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Honolulu"),
    Some("2026-10-05 14:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Johnston"),
    Some("1969-12-31 14:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Johnston"),
    Some("2026-10-05 14:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Kanton"),
    Some("1969-12-31 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Kanton"),
    Some("2026-10-06 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Kiritimati"),
    Some("1969-12-31 13:20:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Kiritimati"),
    Some("2026-10-06 14:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Kosrae"),
    Some("1970-01-01 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Kosrae"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Kwajalein"),
    Some("1969-12-31 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Kwajalein"),
    Some("2026-10-06 12:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Majuro"),
    Some("1970-01-01 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Majuro"),
    Some("2026-10-06 12:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Marquesas"),
    Some("1969-12-31 14:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Marquesas"),
    Some("2026-10-05 14:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Midway"),
    Some("1969-12-31 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Midway"),
    Some("2026-10-05 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Nauru"),
    Some("1970-01-01 11:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Nauru"),
    Some("2026-10-06 12:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Niue"),
    Some("1969-12-31 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Niue"),
    Some("2026-10-05 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Norfolk"),
    Some("1970-01-01 11:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Norfolk"),
    Some("2026-10-06 12:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Noumea"),
    Some("1970-01-01 11:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Noumea"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Pago_Pago"),
    Some("1969-12-31 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Pago_Pago"),
    Some("2026-10-05 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Palau"),
    Some("1970-01-01 09:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Palau"),
    Some("2026-10-06 09:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Pitcairn"),
    Some("1969-12-31 15:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Pitcairn"),
    Some("2026-10-05 16:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Pohnpei"),
    Some("1970-01-01 11:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Pohnpei"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Ponape"),
    Some("1970-01-01 11:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Ponape"),
    Some("2026-10-06 11:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Port_Moresby"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(
      1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Port_Moresby",
    ),
    Some("2026-10-06 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Rarotonga"),
    Some("1969-12-31 13:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Rarotonga"),
    Some("2026-10-05 14:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Saipan"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Saipan"),
    Some("2026-10-06 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Samoa"),
    Some("1969-12-31 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Samoa"),
    Some("2026-10-05 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Tahiti"),
    Some("1969-12-31 14:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Tahiti"),
    Some("2026-10-05 14:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Tarawa"),
    Some("1970-01-01 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Tarawa"),
    Some("2026-10-06 12:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Tongatapu"),
    Some("1970-01-01 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Tongatapu"),
    Some("2026-10-06 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Truk"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Truk"),
    Some("2026-10-06 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Wake"),
    Some("1970-01-01 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Wake"),
    Some("2026-10-06 12:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Wallis"),
    Some("1970-01-01 12:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Wallis"),
    Some("2026-10-06 12:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Yap"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Yap"),
    Some("2026-10-06 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Poland"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Poland"),
    Some("2026-10-06 02:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Portugal"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Portugal"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "ROK"),
    Some("1970-01-01 09:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "ROK"),
    Some("2026-10-06 09:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Singapore"),
    Some("1970-01-01 07:30:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Singapore"),
    Some("2026-10-06 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "SystemV/AST4"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "SystemV/AST4"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "SystemV/AST4ADT"),
    Some("1969-12-31 20:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "SystemV/AST4ADT"),
    Some("2026-10-05 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "SystemV/CST6"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "SystemV/CST6"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "SystemV/CST6CDT"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "SystemV/CST6CDT"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "SystemV/EST5"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "SystemV/EST5"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "SystemV/EST5EDT"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "SystemV/EST5EDT"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "SystemV/HST10"),
    Some("1969-12-31 14:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "SystemV/HST10"),
    Some("2026-10-05 14:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "SystemV/MST7"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "SystemV/MST7"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "SystemV/MST7MDT"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "SystemV/MST7MDT"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "SystemV/PST8"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "SystemV/PST8"),
    Some("2026-10-05 16:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "SystemV/PST8PDT"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "SystemV/PST8PDT"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "SystemV/YST9"),
    Some("1969-12-31 15:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "SystemV/YST9"),
    Some("2026-10-05 15:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "SystemV/YST9YDT"),
    Some("1969-12-31 15:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "SystemV/YST9YDT"),
    Some("2026-10-05 16:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Turkey"),
    Some("1970-01-01 02:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Turkey"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "UCT"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "UCT"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "US/Alaska"),
    Some("1969-12-31 14:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "US/Alaska"),
    Some("2026-10-05 16:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "US/Aleutian"),
    Some("1969-12-31 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "US/Aleutian"),
    Some("2026-10-05 15:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "US/Arizona"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "US/Arizona"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "US/Central"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "US/Central"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "US/East-Indiana"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "US/East-Indiana"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "US/Eastern"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "US/Eastern"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "US/Hawaii"),
    Some("1969-12-31 14:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "US/Hawaii"),
    Some("2026-10-05 14:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "US/Indiana-Starke"),
    Some("1969-12-31 18:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "US/Indiana-Starke"),
    Some("2026-10-05 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "US/Michigan"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "US/Michigan"),
    Some("2026-10-05 20:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "US/Mountain"),
    Some("1969-12-31 17:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "US/Mountain"),
    Some("2026-10-05 18:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "US/Pacific"),
    Some("1969-12-31 16:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "US/Pacific"),
    Some("2026-10-05 17:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "US/Samoa"),
    Some("1969-12-31 13:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "US/Samoa"),
    Some("2026-10-05 13:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "UTC"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "UTC"),
    Some("2026-10-06 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Universal"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Universal"),
    Some("2026-10-06 00:00:00"),
  )
}

///|
test "@date format_in 全表逐区两瞬间（腿 F 行）（第 7/7 块，本块 6 条）" {
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "W-SU"),
    Some("1970-01-01 03:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "W-SU"),
    Some("2026-10-06 03:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "WET"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "WET"),
    Some("2026-10-06 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Zulu"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(1791244800000L, "yyyy-MM-dd HH:mm:ss", "Zulu"),
    Some("2026-10-06 00:00:00"),
  )
}

///|
test "@date format_in 特殊档小组（腿 G 行：45 分/30 分 DST/符号陷阱/窗口末）（第 1/1 块，本块 144 条）" {
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "UTC"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "UTC"),
    Some("1970-01-01T00:00:00.000"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", "UTC"),
    Some("1986-05-04 02:00:00"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "UTC"),
    Some("1986-05-04T02:00:00.000"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", "UTC"),
    Some("2000-06-15 12:00:00"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "UTC"),
    Some("2000-06-15T12:00:00.000"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", "UTC"),
    Some("2024-03-10 06:30:00"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "UTC"),
    Some("2024-03-10T06:30:00.000"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", "UTC"),
    Some("2024-11-03 06:00:00"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "UTC"),
    Some("2024-11-03T06:00:00.000"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", "UTC"),
    Some("2049-12-31 23:59:58"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "UTC"),
    Some("2049-12-31T23:59:58.000"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Shanghai"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Shanghai"),
    Some("1970-01-01T08:00:00.000"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", "Asia/Shanghai"),
    Some("1986-05-04 11:00:00"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Shanghai"),
    Some("1986-05-04T11:00:00.000"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", "Asia/Shanghai"),
    Some("2000-06-15 20:00:00"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Shanghai"),
    Some("2000-06-15T20:00:00.000"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", "Asia/Shanghai"),
    Some("2024-03-10 14:30:00"),
  )
  assert_eq(
    @date.format_in(
      1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Shanghai",
    ),
    Some("2024-03-10T14:30:00.000"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", "Asia/Shanghai"),
    Some("2024-11-03 14:00:00"),
  )
  assert_eq(
    @date.format_in(
      1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Shanghai",
    ),
    Some("2024-11-03T14:00:00.000"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", "Asia/Shanghai"),
    Some("2050-01-01 07:59:58"),
  )
  assert_eq(
    @date.format_in(
      2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Shanghai",
    ),
    Some("2050-01-01T07:59:58.000"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Kathmandu"),
    Some("1970-01-01 05:30:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Kathmandu"),
    Some("1970-01-01T05:30:00.000"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", "Asia/Kathmandu"),
    Some("1986-05-04 07:45:00"),
  )
  assert_eq(
    @date.format_in(
      515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Kathmandu",
    ),
    Some("1986-05-04T07:45:00.000"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", "Asia/Kathmandu"),
    Some("2000-06-15 17:45:00"),
  )
  assert_eq(
    @date.format_in(
      961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Kathmandu",
    ),
    Some("2000-06-15T17:45:00.000"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", "Asia/Kathmandu"),
    Some("2024-03-10 12:15:00"),
  )
  assert_eq(
    @date.format_in(
      1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Kathmandu",
    ),
    Some("2024-03-10T12:15:00.000"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", "Asia/Kathmandu"),
    Some("2024-11-03 11:45:00"),
  )
  assert_eq(
    @date.format_in(
      1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Kathmandu",
    ),
    Some("2024-11-03T11:45:00.000"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", "Asia/Kathmandu"),
    Some("2050-01-01 05:44:58"),
  )
  assert_eq(
    @date.format_in(
      2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Kathmandu",
    ),
    Some("2050-01-01T05:44:58.000"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Pacific/Chatham"),
    Some("1970-01-01 12:45:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Pacific/Chatham"),
    Some("1970-01-01T12:45:00.000"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Chatham"),
    Some("1986-05-04 14:45:00"),
  )
  assert_eq(
    @date.format_in(
      515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Pacific/Chatham",
    ),
    Some("1986-05-04T14:45:00.000"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Chatham"),
    Some("2000-06-16 00:45:00"),
  )
  assert_eq(
    @date.format_in(
      961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Pacific/Chatham",
    ),
    Some("2000-06-16T00:45:00.000"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Chatham"),
    Some("2024-03-10 20:15:00"),
  )
  assert_eq(
    @date.format_in(
      1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Pacific/Chatham",
    ),
    Some("2024-03-10T20:15:00.000"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Chatham"),
    Some("2024-11-03 19:45:00"),
  )
  assert_eq(
    @date.format_in(
      1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Pacific/Chatham",
    ),
    Some("2024-11-03T19:45:00.000"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", "Pacific/Chatham"),
    Some("2050-01-01 13:44:58"),
  )
  assert_eq(
    @date.format_in(
      2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Pacific/Chatham",
    ),
    Some("2050-01-01T13:44:58.000"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Lord_Howe"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Australia/Lord_Howe"),
    Some("1970-01-01T10:00:00.000"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", "Australia/Lord_Howe"),
    Some("1986-05-04 12:30:00"),
  )
  assert_eq(
    @date.format_in(
      515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Australia/Lord_Howe",
    ),
    Some("1986-05-04T12:30:00.000"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", "Australia/Lord_Howe"),
    Some("2000-06-15 22:30:00"),
  )
  assert_eq(
    @date.format_in(
      961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Australia/Lord_Howe",
    ),
    Some("2000-06-15T22:30:00.000"),
  )
  assert_eq(
    @date.format_in(
      1710052200000L, "yyyy-MM-dd HH:mm:ss", "Australia/Lord_Howe",
    ),
    Some("2024-03-10 17:30:00"),
  )
  assert_eq(
    @date.format_in(
      1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Australia/Lord_Howe",
    ),
    Some("2024-03-10T17:30:00.000"),
  )
  assert_eq(
    @date.format_in(
      1730613600000L, "yyyy-MM-dd HH:mm:ss", "Australia/Lord_Howe",
    ),
    Some("2024-11-03 17:00:00"),
  )
  assert_eq(
    @date.format_in(
      1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Australia/Lord_Howe",
    ),
    Some("2024-11-03T17:00:00.000"),
  )
  assert_eq(
    @date.format_in(
      2524607998000L, "yyyy-MM-dd HH:mm:ss", "Australia/Lord_Howe",
    ),
    Some("2050-01-01 10:59:58"),
  )
  assert_eq(
    @date.format_in(
      2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Australia/Lord_Howe",
    ),
    Some("2050-01-01T10:59:58.000"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/New_York"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "America/New_York"),
    Some("1969-12-31T19:00:00.000"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", "America/New_York"),
    Some("1986-05-03 22:00:00"),
  )
  assert_eq(
    @date.format_in(
      515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "America/New_York",
    ),
    Some("1986-05-03T22:00:00.000"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", "America/New_York"),
    Some("2000-06-15 08:00:00"),
  )
  assert_eq(
    @date.format_in(
      961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "America/New_York",
    ),
    Some("2000-06-15T08:00:00.000"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", "America/New_York"),
    Some("2024-03-10 01:30:00"),
  )
  assert_eq(
    @date.format_in(
      1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "America/New_York",
    ),
    Some("2024-03-10T01:30:00.000"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", "America/New_York"),
    Some("2024-11-03 01:00:00"),
  )
  assert_eq(
    @date.format_in(
      1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "America/New_York",
    ),
    Some("2024-11-03T01:00:00.000"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", "America/New_York"),
    Some("2049-12-31 18:59:58"),
  )
  assert_eq(
    @date.format_in(
      2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "America/New_York",
    ),
    Some("2049-12-31T18:59:58.000"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Europe/London"),
    Some("1970-01-01 01:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Europe/London"),
    Some("1970-01-01T01:00:00.000"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", "Europe/London"),
    Some("1986-05-04 03:00:00"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Europe/London"),
    Some("1986-05-04T03:00:00.000"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", "Europe/London"),
    Some("2000-06-15 13:00:00"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Europe/London"),
    Some("2000-06-15T13:00:00.000"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", "Europe/London"),
    Some("2024-03-10 06:30:00"),
  )
  assert_eq(
    @date.format_in(
      1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Europe/London",
    ),
    Some("2024-03-10T06:30:00.000"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", "Europe/London"),
    Some("2024-11-03 06:00:00"),
  )
  assert_eq(
    @date.format_in(
      1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Europe/London",
    ),
    Some("2024-11-03T06:00:00.000"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", "Europe/London"),
    Some("2049-12-31 23:59:58"),
  )
  assert_eq(
    @date.format_in(
      2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Europe/London",
    ),
    Some("2049-12-31T23:59:58.000"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+5"),
    Some("1969-12-31 19:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Etc/GMT+5"),
    Some("1969-12-31T19:00:00.000"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+5"),
    Some("1986-05-03 21:00:00"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Etc/GMT+5"),
    Some("1986-05-03T21:00:00.000"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+5"),
    Some("2000-06-15 07:00:00"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Etc/GMT+5"),
    Some("2000-06-15T07:00:00.000"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+5"),
    Some("2024-03-10 01:30:00"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Etc/GMT+5"),
    Some("2024-03-10T01:30:00.000"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+5"),
    Some("2024-11-03 01:00:00"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Etc/GMT+5"),
    Some("2024-11-03T01:00:00.000"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", "Etc/GMT+5"),
    Some("2049-12-31 18:59:58"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Etc/GMT+5"),
    Some("2049-12-31T18:59:58.000"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Asia/Taipei"),
    Some("1970-01-01 08:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Taipei"),
    Some("1970-01-01T08:00:00.000"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", "Asia/Taipei"),
    Some("1986-05-04 10:00:00"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Taipei"),
    Some("1986-05-04T10:00:00.000"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", "Asia/Taipei"),
    Some("2000-06-15 20:00:00"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Taipei"),
    Some("2000-06-15T20:00:00.000"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", "Asia/Taipei"),
    Some("2024-03-10 14:30:00"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Taipei"),
    Some("2024-03-10T14:30:00.000"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", "Asia/Taipei"),
    Some("2024-11-03 14:00:00"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Taipei"),
    Some("2024-11-03T14:00:00.000"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", "Asia/Taipei"),
    Some("2050-01-01 07:59:58"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Asia/Taipei"),
    Some("2050-01-01T07:59:58.000"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "America/Santiago"),
    Some("1969-12-31 21:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "America/Santiago"),
    Some("1969-12-31T21:00:00.000"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", "America/Santiago"),
    Some("1986-05-03 22:00:00"),
  )
  assert_eq(
    @date.format_in(
      515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "America/Santiago",
    ),
    Some("1986-05-03T22:00:00.000"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", "America/Santiago"),
    Some("2000-06-15 08:00:00"),
  )
  assert_eq(
    @date.format_in(
      961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "America/Santiago",
    ),
    Some("2000-06-15T08:00:00.000"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", "America/Santiago"),
    Some("2024-03-10 03:30:00"),
  )
  assert_eq(
    @date.format_in(
      1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "America/Santiago",
    ),
    Some("2024-03-10T03:30:00.000"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", "America/Santiago"),
    Some("2024-11-03 03:00:00"),
  )
  assert_eq(
    @date.format_in(
      1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "America/Santiago",
    ),
    Some("2024-11-03T03:00:00.000"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", "America/Santiago"),
    Some("2049-12-31 20:59:58"),
  )
  assert_eq(
    @date.format_in(
      2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "America/Santiago",
    ),
    Some("2049-12-31T20:59:58.000"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Australia/Sydney"),
    Some("1970-01-01 10:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Australia/Sydney"),
    Some("1970-01-01T10:00:00.000"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", "Australia/Sydney"),
    Some("1986-05-04 12:00:00"),
  )
  assert_eq(
    @date.format_in(
      515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Australia/Sydney",
    ),
    Some("1986-05-04T12:00:00.000"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", "Australia/Sydney"),
    Some("2000-06-15 22:00:00"),
  )
  assert_eq(
    @date.format_in(
      961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Australia/Sydney",
    ),
    Some("2000-06-15T22:00:00.000"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", "Australia/Sydney"),
    Some("2024-03-10 17:30:00"),
  )
  assert_eq(
    @date.format_in(
      1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Australia/Sydney",
    ),
    Some("2024-03-10T17:30:00.000"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", "Australia/Sydney"),
    Some("2024-11-03 17:00:00"),
  )
  assert_eq(
    @date.format_in(
      1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Australia/Sydney",
    ),
    Some("2024-11-03T17:00:00.000"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", "Australia/Sydney"),
    Some("2050-01-01 10:59:58"),
  )
  assert_eq(
    @date.format_in(
      2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Australia/Sydney",
    ),
    Some("2050-01-01T10:59:58.000"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd HH:mm:ss", "Africa/Ceuta"),
    Some("1970-01-01 00:00:00"),
  )
  assert_eq(
    @date.format_in(0L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Africa/Ceuta"),
    Some("1970-01-01T00:00:00.000"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd HH:mm:ss", "Africa/Ceuta"),
    Some("1986-05-04 04:00:00"),
  )
  assert_eq(
    @date.format_in(515556000000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Africa/Ceuta"),
    Some("1986-05-04T04:00:00.000"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd HH:mm:ss", "Africa/Ceuta"),
    Some("2000-06-15 14:00:00"),
  )
  assert_eq(
    @date.format_in(961070400000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Africa/Ceuta"),
    Some("2000-06-15T14:00:00.000"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd HH:mm:ss", "Africa/Ceuta"),
    Some("2024-03-10 07:30:00"),
  )
  assert_eq(
    @date.format_in(1710052200000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Africa/Ceuta"),
    Some("2024-03-10T07:30:00.000"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd HH:mm:ss", "Africa/Ceuta"),
    Some("2024-11-03 07:00:00"),
  )
  assert_eq(
    @date.format_in(1730613600000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Africa/Ceuta"),
    Some("2024-11-03T07:00:00.000"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd HH:mm:ss", "Africa/Ceuta"),
    Some("2050-01-01 00:59:58"),
  )
  assert_eq(
    @date.format_in(2524607998000L, "yyyy-MM-dd'T'HH:mm:ss.SSS", "Africa/Ceuta"),
    Some("2050-01-01T00:59:58.000"),
  )
}

///|
test "@date to_rfc3339_in 偏移随瞬间走（腿 R 行；同一区两个瞬间两个偏移）" {
  assert_eq(@date.to_rfc3339_in(0L, "UTC"), Some("1970-01-01T00:00:00Z"))
  assert_eq(
    @date.to_rfc3339_in(1791244800000L, "UTC"),
    Some("2026-10-06T00:00:00Z"),
  )
  assert_eq(
    @date.to_rfc3339_in(0L, "Asia/Shanghai"),
    Some("1970-01-01T08:00:00+08:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(1791244800000L, "Asia/Shanghai"),
    Some("2026-10-06T08:00:00+08:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(0L, "Asia/Kathmandu"),
    Some("1970-01-01T05:30:00+05:30"),
  )
  assert_eq(
    @date.to_rfc3339_in(1791244800000L, "Asia/Kathmandu"),
    Some("2026-10-06T05:45:00+05:45"),
  )
  assert_eq(
    @date.to_rfc3339_in(0L, "Pacific/Chatham"),
    Some("1970-01-01T12:45:00+12:45"),
  )
  assert_eq(
    @date.to_rfc3339_in(1791244800000L, "Pacific/Chatham"),
    Some("2026-10-06T13:45:00+13:45"),
  )
  assert_eq(
    @date.to_rfc3339_in(0L, "Australia/Lord_Howe"),
    Some("1970-01-01T10:00:00+10:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(1791244800000L, "Australia/Lord_Howe"),
    Some("2026-10-06T11:00:00+11:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(0L, "America/New_York"),
    Some("1969-12-31T19:00:00-05:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(1791244800000L, "America/New_York"),
    Some("2026-10-05T20:00:00-04:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(0L, "Europe/London"),
    Some("1970-01-01T01:00:00+01:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(1791244800000L, "Europe/London"),
    Some("2026-10-06T01:00:00+01:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(0L, "Etc/GMT+5"),
    Some("1969-12-31T19:00:00-05:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(1791244800000L, "Etc/GMT+5"),
    Some("2026-10-05T19:00:00-05:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(0L, "Asia/Taipei"),
    Some("1970-01-01T08:00:00+08:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(1791244800000L, "Asia/Taipei"),
    Some("2026-10-06T08:00:00+08:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(0L, "America/Santiago"),
    Some("1969-12-31T21:00:00-03:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(1791244800000L, "America/Santiago"),
    Some("2026-10-05T21:00:00-03:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(0L, "Australia/Sydney"),
    Some("1970-01-01T10:00:00+10:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(1791244800000L, "Australia/Sydney"),
    Some("2026-10-06T11:00:00+11:00"),
  )
  assert_eq(
    @date.to_rfc3339_in(0L, "Africa/Ceuta"),
    Some("1970-01-01T00:00:00Z"),
  )
  assert_eq(
    @date.to_rfc3339_in(1791244800000L, "Africa/Ceuta"),
    Some("2026-10-06T02:00:00+02:00"),
  )
}

///|
test "@date parse_in：1 档正常与 2 档重叠取末支（腿 S 行的瞬间读数）" {
  // 腿 S 行：America/New_York|2024-11-03 01:30:00 -> 1730615400000
  assert_eq(
    @date.parse_in(
      "2024-11-03 01:30:00", "yyyy-MM-dd HH:mm:ss", "America/New_York",
    ),
    Some(1730615400000L),
  )
  // 腿 S 行：Europe/London|2024-10-27 01:30:00 -> 1729992600000
  assert_eq(
    @date.parse_in(
      "2024-10-27 01:30:00", "yyyy-MM-dd HH:mm:ss", "Europe/London",
    ),
    Some(1729992600000L),
  )
  // 腿 S 行：Pacific/Chatham|2024-04-07 00:15:00 -> 1712399400000
  assert_eq(
    @date.parse_in(
      "2024-04-07 00:15:00", "yyyy-MM-dd HH:mm:ss", "Pacific/Chatham",
    ),
    Some(1712399400000L),
  )
  // 腿 S 行：Australia/Lord_Howe|2024-04-07 02:30:00 -> 1712419200000
  assert_eq(
    @date.parse_in(
      "2024-04-07 02:30:00", "yyyy-MM-dd HH:mm:ss", "Australia/Lord_Howe",
    ),
    Some(1712419200000L),
  )
  // 腿 S 行：UTC|2024-06-01 12:00:00 -> 1717243200000
  assert_eq(
    @date.parse_in("2024-06-01 12:00:00", "yyyy-MM-dd HH:mm:ss", "UTC"),
    Some(1717243200000L),
  )
  // 腿 S 行：Asia/Kathmandu|2024-06-01 12:00:00 -> 1717222500000
  assert_eq(
    @date.parse_in(
      "2024-06-01 12:00:00", "yyyy-MM-dd HH:mm:ss", "Asia/Kathmandu",
    ),
    Some(1717222500000L),
  )
  // 腿 S 行：Etc/GMT+5|2024-06-01 12:00:00 -> 1717261200000
  assert_eq(
    @date.parse_in("2024-06-01 12:00:00", "yyyy-MM-dd HH:mm:ss", "Etc/GMT+5"),
    Some(1717261200000L),
  )
  // 腿 S 行：No/Where|2024-06-01 12:00:00 -> 1717243200000
  assert_eq(
    @date.parse_in("2024-06-01 12:00:00", "yyyy-MM-dd HH:mm:ss", "No/Where"),
    Some(1717243200000L),
  )
}

///|
test "@date parse_in：0 档（该区不存在的墙上时刻）参照主动抛，本库 raise ZoneGap 不并 None" {
  // 腿 S 行：America/New_York|2024-03-10 02:30:00 -> ERR_ParseException（参照 setLenient(false) 下主动抛）
  assert_eq(
    shape(() => {
      @date.parse_in(
        "2024-03-10 02:30:00", "yyyy-MM-dd HH:mm:ss", "America/New_York",
      )
    }),
    "ZoneGap 2024-03-10T02:30:00.000",
  )
  // 腿 S 行：Asia/Shanghai|1986-05-04 02:30:00 -> ERR_ParseException（参照 setLenient(false) 下主动抛）
  assert_eq(
    shape(() => {
      @date.parse_in(
        "1986-05-04 02:30:00", "yyyy-MM-dd HH:mm:ss", "Asia/Shanghai",
      )
    }),
    "ZoneGap 1986-05-04T02:30:00.000",
  )
  // 腿 S 行：Asia/Shanghai|1986-05-04 02:00:00 -> ERR_ParseException（参照 setLenient(false) 下主动抛）
  assert_eq(
    shape(() => {
      @date.parse_in(
        "1986-05-04 02:00:00", "yyyy-MM-dd HH:mm:ss", "Asia/Shanghai",
      )
    }),
    "ZoneGap 1986-05-04T02:00:00.000",
  )
  // 腿 S 行：America/New_York|2024-13-45 99:99:99 -> ERR_ParseException（参照 setLenient(false) 下主动抛）
  assert_eq(
    shape(() => {
      @date.parse_in(
        "2024-13-45 99:99:99", "yyyy-MM-dd HH:mm:ss", "America/New_York",
      )
    }),
    "ZoneGap 2024-13-45T99:99:99.000",
  )
}

///|
test "@date 坏区名与窗外：三件同形给 None（参照 TimeZone 静默回落 GMT 那条不跟随）" {
  // 腿 S 行：No/Where|2024-06-01 12:00:00 参照解析成 1717243200000（= 按 GMT），本库不跟
  assert_eq(
    @date.parse_in("2024-06-01 12:00:00", "yyyy-MM-dd HH:mm:ss", "No/Where"),
    None,
  )
  assert_eq(
    @date.format_in(1717243200000L, "yyyy-MM-dd HH:mm:ss", "No/Where"),
    None,
  )
  assert_eq(@date.to_rfc3339_in(1717243200000L, "No/Where"), None)
  // 窗外：窗口下界之前、上界及其之后（§5.3 第 2 条同判据）
  assert_eq(@date.format_in(-1L, "yyyy-MM-dd HH:mm:ss", "UTC"), None)
  assert_eq(@date.to_rfc3339_in(2524608000000L, "UTC"), None)
  assert_eq(
    @date.parse_in("1969-12-31 23:59:59", "yyyy-MM-dd HH:mm:ss", "UTC"),
    None,
  )
}
