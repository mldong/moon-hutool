///|
// moon-hutool/typex —— 坐标系转换（ROADMAP 第 23 行第四批第二格，#23.97–#23.105）
// 对位 hutool `CoordinateUtil`。契约真相在 `docs/spec/23-typex.md` §17。
//
// 四条腿读数为凭、决定实现形状的事实：
// - 参照返回的是**可变 bean** `Coordinate`（`setLng`/`setLat`/`offset` 会原地改），本库摊平成 `(Float, Float)`
//   二元组——bean 的四个 getter/setter 与 `equals`/`hashCode` 都不进公开面（§17.1）。
// - 六个转换件**都不查 `outOfChina`**：国外坐标照样按火星偏移走（腿里 `-73.985428,40.748817` 有读数），
//   所以 `coord_out_of_china` 是独立判定件、与转换路没有任何调用关系，实现里不许"顺手加闸"。
// - 类内 `PI` 是字面量 `3.1415926535897932384626433832795D`，而墨卡托那一对用 `Math.PI`——
//   腿的 `CONST_CHK` 现读 `PI == Math.PI` 为 `true` ⇒ 两处来源在 double 上不可分辨，实现统一取一个即可。
// - 边界判据是**开区间外**：`outOfChina` 用 `<` / `>`，所以正好落在 `72.004 / 0.8293 / 137.8347 / 55.8271`
//   这四条线上的点算**国内**（腿有边界角与越界角各一条读数）。

///|
/// #23.97 判断坐标是否在中国范围外（火星坐标系只对国内有意义，但参照的转换件并不据此短路）
/// - Returns: 经度在 `[72.004, 137.8347]`、纬度在 `[0.8293, 55.8271]` 之外给 `true`；正好在边界值上给 `false`
/// - Raises: 无
/// - Note: hutool 对位 `static boolean outOfChina(double lng, double lat)`
pub fn coord_out_of_china(lng : Float, lat : Float) -> Bool {
  abort("moon-hutool PR-B：#23.97 coord_out_of_china 待落地")
}

///|
/// #23.98 WGS84 → GCJ-02（火星坐标）
/// - Returns: `(经度, 纬度)` 二元组，浮点值与参照逐位一致（期望值按"最短可往返十进制"落字面量）
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate wgs84ToGcj02(double, double)`（`new Coordinate(lng,lat).offset(offset(…, true))`）
pub fn coord_wgs84_to_gcj02(lng : Float, lat : Float) -> (Float, Float) {
  abort("moon-hutool PR-B：#23.98 coord_wgs84_to_gcj02 待落地")
}

///|
/// #23.99 GCJ-02 → WGS84（同一偏移算法取负，参照就是这么实现的，不是逆变换）
/// - Returns: `(经度, 纬度)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate gcj02ToWgs84(double, double)`
pub fn coord_gcj02_to_wgs84(lng : Float, lat : Float) -> (Float, Float) {
  abort("moon-hutool PR-B：#23.99 coord_gcj02_to_wgs84 待落地")
}

///|
/// #23.100 GCJ-02 → BD-09（百度）
/// - Returns: `(经度, 纬度)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate gcj02ToBd09(double, double)`
pub fn coord_gcj02_to_bd09(lng : Float, lat : Float) -> (Float, Float) {
  abort("moon-hutool PR-B：#23.100 coord_gcj02_to_bd09 待落地")
}

///|
/// #23.101 BD-09 → GCJ-02
/// - Returns: `(经度, 纬度)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate bd09ToGcj02(double, double)`
pub fn coord_bd09_to_gcj02(lng : Float, lat : Float) -> (Float, Float) {
  abort("moon-hutool PR-B：#23.101 coord_bd09_to_gcj02 待落地")
}

///|
/// #23.102 WGS84 → BD-09（参照＝先 #23.98 再 #23.100 的两步复合）
/// - Returns: `(经度, 纬度)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate wgs84ToBd09(double, double)`
pub fn coord_wgs84_to_bd09(lng : Float, lat : Float) -> (Float, Float) {
  abort("moon-hutool PR-B：#23.102 coord_wgs84_to_bd09 待落地")
}

///|
/// #23.103 BD-09 → WGS84（参照＝先 #23.101 再 #23.99 的两步复合；参照的方法名是小写 `bd09toWgs84`，照抄不改齐）
/// - Returns: `(经度, 纬度)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate bd09toWgs84(double, double)`
pub fn coord_bd09_to_wgs84(lng : Float, lat : Float) -> (Float, Float) {
  abort("moon-hutool PR-B：#23.103 coord_bd09_to_wgs84 待落地")
}

///|
/// #23.104 WGS84 → 墨卡托投影
/// - Returns: `(x, y)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate wgs84ToMercator(double, double)`（这一对用 `Math.PI`）
pub fn coord_wgs84_to_mercator(lng : Float, lat : Float) -> (Float, Float) {
  abort("moon-hutool PR-B：#23.104 coord_wgs84_to_mercator 待落地")
}

///|
/// #23.105 墨卡托投影 → WGS84
/// - Returns: `(经度, 纬度)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate mercatorToWgs84(double, double)`
pub fn coord_mercator_to_wgs84(
  mercator_x : Float,
  mercator_y : Float,
) -> (Float, Float) {
  abort("moon-hutool PR-B：#23.105 coord_mercator_to_wgs84 待落地")
}
