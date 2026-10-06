///|
// moon-hutool/typex —— 坐标系转换（ROADMAP 第 23 行第四批第二格，#23.97–#23.105）
// 对位 hutool `CoordinateUtil`。契约真相在 `docs/spec/23-typex.md` §17。
//
// 四条腿读数为凭、决定实现形状的事实：
// - 参照返回**可变 bean** `Coordinate`（`offset` 原地改自身），本库摊平成 `(Double, Double)`；
//   bean 的 getter/setter/`equals`/`hashCode` 都不进公开面（§17.1）。
// - 六个转换件**都不查 `outOfChina`**：国外坐标照样按火星偏移走（腿里 `-73.985428,40.748817` 有读数），
//   所以 #23.97 是独立判定件、与转换路没有调用关系，实现里不许"顺手加闸"。
// - 类内 `PI` 是字面量、墨卡托那一对用 `Math.PI`；腿的 `CONST_CHK` 现读 `PI == Math.PI` 为 `true`
//   ⇒ 两处来源在 double 上不可分辨，本库统一取一个常量。
// - 边界判据是**开区间外**：正好落在 `72.004 / 0.8293 / 137.8347 / 55.8271` 这四条线上算国内。
//
// 运算次序逐句照参照（浮点加法与乘除的结合顺序影响末位）。

///|
const COORD_PI : Double = 3.1415926535897932384626433832795

///|
let coord_x_pi : Double = COORD_PI * 3000.0 / 180.0

///|
const COORD_RADIUS : Double = 6378245.0

///|
const COORD_CORRECTION : Double = 0.00669342162296594323

///|
let coord_mercator_half : Double = 20037508.342789244

///|
fn coord_trans_lng(lng : Double, lat : Double) -> Double {
  let mut ret = 300.0 +
    lng +
    2.0 * lat +
    0.1 * lng * lng +
    0.1 * lng * lat +
    0.1 * lng.abs().sqrt()
  ret = ret +
    (
      20.0 * @math.sin(6.0 * lng * COORD_PI) +
      20.0 * @math.sin(2.0 * lng * COORD_PI)
    ) *
    2.0 /
    3.0
  ret = ret +
    (20.0 * @math.sin(lng * COORD_PI) + 40.0 * @math.sin(lng / 3.0 * COORD_PI)) *
    2.0 /
    3.0
  ret = ret +
    (
      150.0 * @math.sin(lng / 12.0 * COORD_PI) +
      300.0 * @math.sin(lng / 30.0 * COORD_PI)
    ) *
    2.0 /
    3.0
  ret
}

///|
fn coord_trans_lat(lng : Double, lat : Double) -> Double {
  let mut ret = -100.0 +
    2.0 * lng +
    3.0 * lat +
    0.2 * lat * lat +
    0.1 * lng * lat +
    0.2 * lng.abs().sqrt()
  ret = ret +
    (
      20.0 * @math.sin(6.0 * lng * COORD_PI) +
      20.0 * @math.sin(2.0 * lng * COORD_PI)
    ) *
    2.0 /
    3.0
  ret = ret +
    (20.0 * @math.sin(lat * COORD_PI) + 40.0 * @math.sin(lat / 3.0 * COORD_PI)) *
    2.0 /
    3.0
  ret = ret +
    (
      160.0 * @math.sin(lat / 12.0 * COORD_PI) +
      320.0 * @math.sin(lat * COORD_PI / 30.0)
    ) *
    2.0 /
    3.0
  ret
}

///|
fn coord_offset(lng : Double, lat : Double, is_plus : Bool) -> (Double, Double) {
  let dlng = coord_trans_lng(lng - 105.0, lat - 35.0)
  let dlat = coord_trans_lat(lng - 105.0, lat - 35.0)
  let mut magic = @math.sin(lat / 180.0 * COORD_PI)
  magic = 1.0 - COORD_CORRECTION * magic * magic
  let sqrt_magic = magic.sqrt()
  let mut dlng2 = dlng *
    180.0 /
    (COORD_RADIUS / sqrt_magic * @math.cos(lat / 180.0 * COORD_PI) * COORD_PI)
  let mut dlat2 = dlat *
    180.0 /
    (COORD_RADIUS * (1.0 - COORD_CORRECTION) / (magic * sqrt_magic) * COORD_PI)
  if !is_plus {
    dlng2 = -dlng2
    dlat2 = -dlat2
  }
  (dlng2, dlat2)
}

///|
/// #23.97 判断坐标是否在中国范围外（参照的转换件并不据此短路）
/// - Returns: 经度在 `[72.004, 137.8347]`、纬度在 `[0.8293, 55.8271]` 之外给 `true`；正好在边界值上给 `false`
/// - Raises: 无
/// - Note: hutool 对位 `static boolean outOfChina(double lng, double lat)`
pub fn coord_out_of_china(lng : Double, lat : Double) -> Bool {
  (lng < 72.004 || lng > 137.8347) || lat < 0.8293 || lat > 55.8271
}

///|
/// #23.98 WGS84 → GCJ-02（火星坐标）
/// - Returns: `(经度, 纬度)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate wgs84ToGcj02(double, double)`
pub fn coord_wgs84_to_gcj02(lng : Double, lat : Double) -> (Double, Double) {
  let (dlng, dlat) = coord_offset(lng, lat, true)
  (lng + dlng, lat + dlat)
}

///|
/// #23.99 GCJ-02 → WGS84（同一偏移取负，参照就是这么实现的，不是逆变换）
/// - Returns: `(经度, 纬度)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate gcj02ToWgs84(double, double)`
pub fn coord_gcj02_to_wgs84(lng : Double, lat : Double) -> (Double, Double) {
  let (dlng, dlat) = coord_offset(lng, lat, false)
  (lng + dlng, lat + dlat)
}

///|
/// #23.100 GCJ-02 → BD-09（百度）
/// - Returns: `(经度, 纬度)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate gcj02ToBd09(double, double)`
pub fn coord_gcj02_to_bd09(lng : Double, lat : Double) -> (Double, Double) {
  let z = (lng * lng + lat * lat).sqrt() + 0.00002 * @math.sin(lat * coord_x_pi)
  let theta = @math.atan2(lat, lng) + 0.000003 * @math.cos(lng * coord_x_pi)
  (z * @math.cos(theta) + 0.0065, z * @math.sin(theta) + 0.006)
}

///|
/// #23.101 BD-09 → GCJ-02
/// - Returns: `(经度, 纬度)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate bd09ToGcj02(double, double)`
pub fn coord_bd09_to_gcj02(lng : Double, lat : Double) -> (Double, Double) {
  let x = lng - 0.0065
  let y = lat - 0.006
  let z = (x * x + y * y).sqrt() - 0.00002 * @math.sin(y * coord_x_pi)
  let theta = @math.atan2(y, x) - 0.000003 * @math.cos(x * coord_x_pi)
  (z * @math.cos(theta), z * @math.sin(theta))
}

///|
/// #23.102 WGS84 → BD-09（参照＝先 #23.98 再 #23.100 的两步复合，不存在直达公式）
/// - Returns: `(经度, 纬度)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate wgs84ToBd09(double, double)`
pub fn coord_wgs84_to_bd09(lng : Double, lat : Double) -> (Double, Double) {
  let (glng, glat) = coord_wgs84_to_gcj02(lng, lat)
  coord_gcj02_to_bd09(glng, glat)
}

///|
/// #23.103 BD-09 → WGS84（参照＝先 #23.101 再 #23.99 的两步复合；参照原方法名是小写 `bd09toWgs84`，照抄不改齐）
/// - Returns: `(经度, 纬度)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate bd09toWgs84(double, double)`
pub fn coord_bd09_to_wgs84(lng : Double, lat : Double) -> (Double, Double) {
  let (glng, glat) = coord_bd09_to_gcj02(lng, lat)
  coord_gcj02_to_wgs84(glng, glat)
}

///|
/// #23.104 WGS84 → 墨卡托投影
/// - Returns: `(x, y)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate wgs84ToMercator(double, double)`
pub fn coord_wgs84_to_mercator(lng : Double, lat : Double) -> (Double, Double) {
  let x = lng * coord_mercator_half / 180.0
  let y = @math.ln(@math.tan((90.0 + lat) * COORD_PI / 360.0)) /
    (COORD_PI / 180.0)
  (x, y * coord_mercator_half / 180.0)
}

///|
/// #23.105 墨卡托投影 → WGS84
/// - Returns: `(经度, 纬度)`
/// - Raises: 无
/// - Note: hutool 对位 `static Coordinate mercatorToWgs84(double, double)`
pub fn coord_mercator_to_wgs84(
  mercator_x : Double,
  mercator_y : Double,
) -> (Double, Double) {
  let x = mercator_x / coord_mercator_half * 180.0
  let y = mercator_y / coord_mercator_half * 180.0
  (
    x,
    180.0 /
    COORD_PI *
    (2.0 * @math.atan(@math.exp(y * COORD_PI / 180.0)) - COORD_PI / 2.0),
  )
}
