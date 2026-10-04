// moon-hutool/codec 契约用例（黑盒）。
//
// 状态：**两批都已落地**（10-05）。第一批（§2~§6，24 条）与第二批（§7 form 档、§8 URL 组件，13 条）
// 全部绿，wasm / js / wasm-gc 三档读数一致，native 档由 CI 出证；第二批落地那一笔**期望串一字未改**（红线一）。
// 期望值先冻结、后实现；改任何期望串 = 门禁 G5 拦下，须单独一笔并给外部读数来源。
// 本包落地前只动过一条期望串（`MZXWE1==` 的非法字符下标 4 应为 5，逐位数就是 5），
// 另还原了一处被一次性工装改坏的 README 夹具（期望串未改，改的是夹具字节）。
//
// 读数权威（逐条见 docs/spec/05-codec.md 的「读数来源」列）：
// - Base64 / Base32：RFC 4648 §10 的官方向量表（空串、"f"、"fo"、"fob"、"foba"、"fobar"、"foo"、
//   "fooba"、"foobar" 九条），由 CPython `base64` 现算——它是同一节的公开实现，且规范正文本身给了明文-密文对。
// - MIME：RFC 2045 §6.8（76 字符一行、CRLF、最后一行后也有 CRLF）；同一批数据用「手写 76 切行」与
//   CPython `base64.encodebytes` 两条路对跑，逐字节相等。
// - Base58 / Base62 / Radix：无正式 RFC ⇒ **两套独立实现互算**（大数 `int.from_bytes` 折位 ↔
//   逐字节长除法）+ 反解恒等；表序逐字符写死在 spec 里。
// - Base58Check：双 SHA-256 取前 4 字节（Bitcoin 规则）；摘要腿复用 `digest` 已被 FIPS 向量钉住的 SHA-256。
// - 对拍腿（门禁 G8）：不含 `-`/`_` 的文本上，本包的解码与 core `encoding/base64` 同结果。
// - form 档：**HTML Living Standard** 的 `application/x-www-form-urlencoded` 序列化器（放行 `A-Za-z0-9*-._`、
//   空格出 `+`、其余 `%XX` 大写）。读数由「手写序列化器 ↔ Node `URLSearchParams` 的查询串」两条独立实现互算，
//   七个样本逐字节相等。`~` 与 `*` 两处与 Python `urllib.parse.quote_plus` **不同**（那边走 RFC 3986 的
//   unreserved 集），期望值跟 HTML 那一派——分歧写死在 spec §7，不留"以为该一样"的余地。
// - URL 组件：RFC 3986 §3 的 ABNF 逐段切，读数与 Python `urlsplit` 逐条对跑（含 `mailto`/`urn`/无 scheme 三档）；
//   `normalize` 取 §6.2.2 的语法等价对（`%7E`↔`~`、host 小写、默认端口省略）＋ §5.2.4 规范自带的两个
//   worked example，并加**幂等**断言。端口的错误下标口径由 spec §8 定死（非数字报那位、空端口报 `:`）。
// - 第二批的两条对拍腿：`form_encode` 在不含空格且不含 `+`/`*`/`~` 的输入上与 core `percent.encode` 同结果；
//   `form_decode` 在纯 `%XX`（无 `+`）输入上与 core `percent.decode` 同结果。

///|
fn bytes_of(xs : Array[Byte]) -> Bytes {
  Bytes::from_array(xs.exact_view())
}

///|
/// 16 个连续字节：既覆盖前导零，也覆盖跨组边界
let low16 : Bytes = bytes_of([
  0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d,
  0x0e, 0x0f,
])

///|
/// 58 字节：Base64 出 80 个字符 ⇒ 正好跨过 MIME 的 76 字符行宽
let bytes58 : Bytes = bytes_of([
  0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d,
  0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b,
  0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29,
  0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
  0x38, 0x39,
])

///|
/// hash160(sha256("mldong")) 的 20 字节（Python 现算，见 spec #4 的夹具说明）
let hash160 : Bytes = bytes_of([
  0x2d, 0x73, 0xf6, 0xa4, 0x88, 0x5c, 0xe6, 0x21, 0x18, 0x41, 0x7e, 0xb7, 0x3f, 0xb4,
  0x05, 0xa0, 0x53, 0x9e, 0xfa, 0x21,
])

///|
/// 把 raise 的结果折成「变体名 + 携带值」——携带值同样是契约的一部分。
fn[A] err_shape(g : () -> A raise @codec.CodecError) -> String {
  try {
    let _ = g()
    "未抛错"
  } catch {
    @codec.IllegalChar(input, at) => "IllegalChar \{input}@\{at}"
    @codec.BadPadding(input, at) => "BadPadding \{input}@\{at}"
    @codec.RadixOutOfRange(v, bound) => "RadixOutOfRange \{v} bound=\{bound}"
    @codec.ValueOverflow(input) => "ValueOverflow \{input}"
    @codec.ChecksumMismatch => "ChecksumMismatch"
    @codec.BadUtf8(input) => "BadUtf8 \{input}"
  }
}

///|
test "@codec #2.1 b64_encode_url（RFC 4648 §10 向量 + url 表的两处差异）" {
  assert_eq(@codec.b64_encode_url(@utf8.encode("f")), "Zg==")
  assert_eq(@codec.b64_encode_url(@utf8.encode("fo")), "Zm8=")
  assert_eq(@codec.b64_encode_url(@utf8.encode("fob")), "Zm9i")
  assert_eq(@codec.b64_encode_url(@utf8.encode("foobar")), "Zm9vYmFy")
  assert_eq(@codec.b64_encode_url(low16), "AAECAwQFBgcICQoLDA0ODw==")
  assert_eq(@codec.b64_encode_url(@utf8.encode("中文")), "5Lit5paH")
  // 判别样本：标准表出 `////`，url 表出 `____`——这两个字符就是两张表唯一的不同
  assert_eq(@codec.b64_encode_url(bytes_of([0xff, 0xff, 0xff])), "____")
  assert_eq(@codec.b64_encode_url(@utf8.encode("fo"), padding=false), "Zm8")
  assert_eq(@codec.b64_encode_url(@utf8.encode("f"), padding=false), "Zg")
  // 0.3：空输入是合法输入
  assert_eq(@codec.b64_encode_url(bytes_of([])), "")
}

///|
test "@codec #2.2 b64_decode_url 严格档（表外字符与填充都有读数）" {
  assert_eq(@codec.b64_decode_url("Zm9vYmFy"), @utf8.encode("foobar"))
  assert_eq(@codec.b64_decode_url("____"), bytes_of([0xff, 0xff, 0xff]))
  assert_eq(@codec.b64_decode_url("AAECAwQFBgcICQoLDA0ODw=="), low16)
  assert_eq(@codec.b64_decode_url(""), bytes_of([]))
  // 标准表的 `+`/`/` 不属于 url 表：混吃是 lenient 档的活
  assert_eq(
    err_shape(() => @codec.b64_decode_url("AAECA+/=")),
    "IllegalChar AAECA+/=@5",
  )
  assert_eq(
    err_shape(() => @codec.b64_decode_url("Zm9vYmFy=")),
    "BadPadding Zm9vYmFy=@8",
  )
}

///|
test "@codec #2.3 b64_encode_mime（76 字符一行、CRLF、末行后也有 CRLF）" {
  assert_eq(@codec.b64_encode_mime(@utf8.encode("中文")), "5Lit5paH\r\n")
  // 58 字节 ⇒ 80 个 Base64 字符 ⇒ 76 + CRLF + 4 + CRLF
  assert_eq(
    @codec.b64_encode_mime(bytes58),
    "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4\r\nOQ==\r\n",
  )
  assert_eq(@codec.b64_encode_mime(bytes_of([])), "")
}

///|
test "@codec #2.4 b64_decode_lenient（宽在哪一步都点名）" {
  assert_eq(@codec.b64_decode_lenient("5Lit5paH"), @utf8.encode("中文"))
  assert_eq(@codec.b64_decode_lenient("5Lit5paH\r\n"), @utf8.encode("中文"))
  assert_eq(@codec.b64_decode_lenient("5Lit 5paH"), @utf8.encode("中文"))
  // 两张表的字符都收
  assert_eq(@codec.b64_decode_lenient("////"), bytes_of([0xff, 0xff, 0xff]))
  assert_eq(@codec.b64_decode_lenient("____"), bytes_of([0xff, 0xff, 0xff]))
  // 同一条输入，严格档报错、宽松档出值——这一对就是两档的分工
  assert_eq(
    err_shape(() => @codec.b64_decode_url("////")),
    "IllegalChar ////@0",
  )
  // 表外字符仍然要报，并给下标
  assert_eq(
    err_shape(() => @codec.b64_decode_lenient("Zm9v@YmFy")),
    "IllegalChar Zm9v@YmFy@4",
  )
  // 去掉空白与填充后长度 mod 4 == 1：数学上不可能是 Base64 流
  assert_eq(
    err_shape(() => @codec.b64_decode_lenient("Zm9vY")),
    "BadPadding Zm9vY@4",
  )
}

///|
test "@codec #2.5 与 core encoding/base64 的对拍腿（G8：core 改了我们先红）" {
  // 不含 `-`/`_` 的文本：url 档与标准档同解
  let core1 = @base64.decode("AAECAwQFBgcICQoLDA0ODw==") catch {
    _ => abort("对拍夹具必须是 core 能解的标准表文本")
  }
  assert_eq(core1, @codec.b64_decode_url("AAECAwQFBgcICQoLDA0ODw=="))
  let core2 = @base64.decode("Zm9vYmFy") catch {
    _ => abort("对拍夹具必须是 core 能解的标准表文本")
  }
  assert_eq(core2, @codec.b64_decode_lenient("Zm9vYmFy"))
  // MIME 那串（带换行）与 core 的 ignore_whitespace 档同解
  assert_eq(
    @base64.decode("OTo7PD0+P0BBQkNERUZH", ignore_whitespace=true) catch {
      _ => abort("对拍夹具必须是 core 能解的标准表文本")
    },
    @codec.b64_decode_lenient("OTo7PD0+P0BBQkNERUZH\r\n"),
  )
}

///|
test "@codec #3 b32_encode 的 RFC 4648 §10 九条向量（默认表与 hex 表各一遍）" {
  assert_eq(@codec.b32_encode(bytes_of([])), "")
  assert_eq(@codec.b32_encode(@utf8.encode("f")), "MY======")
  assert_eq(@codec.b32_encode(@utf8.encode("fo")), "MZXQ====")
  assert_eq(@codec.b32_encode(@utf8.encode("fob")), "MZXWE===")
  assert_eq(@codec.b32_encode(@utf8.encode("foba")), "MZXWEYI=")
  assert_eq(@codec.b32_encode(@utf8.encode("fobar")), "MZXWEYLS")
  assert_eq(@codec.b32_encode(@utf8.encode("foo")), "MZXW6===")
  assert_eq(@codec.b32_encode(@utf8.encode("fooba")), "MZXW6YTB")
  assert_eq(@codec.b32_encode(@utf8.encode("foobar")), "MZXW6YTBOI======")
  let hex : (String) -> String = s => {
    @codec.b32_encode(@utf8.encode(s), hex=true)
  }
  assert_eq(hex(""), "")
  assert_eq(hex("f"), "CO======")
  assert_eq(hex("fo"), "CPNG====")
  assert_eq(hex("fob"), "CPNM4===")
  assert_eq(hex("foba"), "CPNM4O8=")
  assert_eq(hex("fobar"), "CPNM4OBI")
  assert_eq(hex("foo"), "CPNMU===")
  assert_eq(hex("fooba"), "CPNMUOJ1")
  assert_eq(hex("foobar"), "CPNMUOJ1E8======")
  assert_eq(@codec.b32_encode(@utf8.encode("fo"), padding=false), "MZXQ")
}

///|
test "@codec #3 b32 的非 ASCII 档与解码往返（大小写都收）" {
  assert_eq(@codec.b32_encode(low16), "AAAQEAYEAUDAOCAJBIFQYDIOB4======")
  assert_eq(@codec.b32_encode(@utf8.encode("中文")), "4S4K3ZUWQ4======")
  assert_eq(@codec.b32_encode(bytes_of([0xff, 0xff, 0xff])), "77776===")
  assert_eq(@codec.b32_encode(bytes_of([0x00, 0x00, 0x68, 0x69])), "AAAGQ2I=")
  assert_eq(@codec.b32_decode("MZXW6YTBOI======"), @utf8.encode("foobar"))
  // 大小写都收：这张表不分大小写，而现实里小写常见
  assert_eq(@codec.b32_decode("mzxw6ytboi======"), @utf8.encode("foobar"))
  assert_eq(
    @codec.b32_decode("CPNMUOJ1E8======", hex=true),
    @utf8.encode("foobar"),
  )
  assert_eq(@codec.b32_decode(""), bytes_of([]))
}

///|
test "@codec #3 b32 的负向档（表外字符给下标、填充余数给位置）" {
  assert_eq(
    err_shape(() => @codec.b32_decode("MZXWE1==")),
    "IllegalChar MZXWE1==@5",
  )
  // 余 6 不可能（合法余数是 0/2/4/5/7）⇒ 没有「=」时报余数段起始位
  assert_eq(err_shape(() => @codec.b32_decode("MZXW6Y")), "BadPadding MZXW6Y@0")
  // 4 个数据字符该配 4 个填充，配了 6 个 ⇒ 报第一个「=」的下标
  assert_eq(
    err_shape(() => @codec.b32_decode("MZXW======")),
    "BadPadding MZXW======@4",
  )
  // 换到 hex 表就是另一个字符集：Z 不在 0-9A-V 里
  assert_eq(
    err_shape(() => @codec.b32_decode("MZXW6YTB", hex=true)),
    "IllegalChar MZXW6YTB@1",
  )
}

///|
test "@codec #4 b58_encode（Bitcoin 表 + 前导零折成前导 1）" {
  assert_eq(@codec.b58_encode(bytes_of([])), "")
  assert_eq(@codec.b58_encode(bytes_of([0x00])), "1")
  assert_eq(@codec.b58_encode(bytes_of([0x00, 0x00])), "11")
  assert_eq(@codec.b58_encode(bytes_of([0x00, 0x00, 0x68, 0x69])), "118wr")
  assert_eq(@codec.b58_encode(bytes_of([0xff, 0xff, 0xff])), "2UzHL")
  assert_eq(@codec.b58_encode(low16), "12drXXUifSrRnXLGbXg8E")
  assert_eq(@codec.b58_encode(@utf8.encode("中文")), "2xu16HBbU")
  assert_eq(
    @codec.b58_encode(@utf8.encode("Hello World!")),
    "2NEpo7TZRRrLZSi2U",
  )
  assert_eq(@codec.b58_encode(@utf8.encode("foobar")), "t1Zv2yaZ")
}

///|
test "@codec #4 b58_decode 反解恒等，且表外四个字符必须报位置" {
  assert_eq(
    @codec.b58_decode("2NEpo7TZRRrLZSi2U"),
    @utf8.encode("Hello World!"),
  )
  assert_eq(@codec.b58_decode("118wr"), bytes_of([0x00, 0x00, 0x68, 0x69]))
  assert_eq(@codec.b58_decode(""), bytes_of([]))
  // 表里没有 0、O、I、l：这四个字符一出现就报错，不当"看不见的近似"
  assert_eq(err_shape(() => @codec.b58_decode("0OIl")), "IllegalChar 0OIl@0")
  assert_eq(err_shape(() => @codec.b58_decode("l")), "IllegalChar l@0")
  assert_eq(
    err_shape(() => @codec.b58_decode("2NEpo7TZRRrLZSi2U0")),
    "IllegalChar 2NEpo7TZRRrLZSi2U0@17",
  )
}

///|
test "@codec #4 b58_check：双 SHA-256 取前 4 字节，版本 0 与 0x80 两档" {
  assert_eq(
    @codec.b58_check_encode(hash160),
    "159LKv1gGepptdXG7coMf6QhdTrgDsG7i2",
  )
  assert_eq(
    @codec.b58_check_encode(hash160, version=0x80),
    "taQYMpAZ9k8ya7NMFKS9j9FQC2qRF1Z741",
  )
  assert_eq(
    @codec.b58_check_decode("159LKv1gGepptdXG7coMf6QhdTrgDsG7i2"),
    hash160,
  )
  assert_eq(
    @codec.b58_check_decode("159LKv1gGepptdXG7coMf6QhdTrgDsG7i2", version=0),
    hash160,
  )
  assert_eq(
    err_shape(() => @codec.b58_check_encode(hash160, version=256)),
    "RadixOutOfRange 256 bound=255",
  )
}

///|
test "@codec #4 b58_check 的负向：改一位必须红，绝不返回脏 payload" {
  // 末位换掉仍是表内文本，但校验位对不上
  assert_eq(
    err_shape(() => {
      @codec.b58_check_decode("159LKv1gGepptdXG7coMf6QhdTrgDsG7i3")
    }),
    "ChecksumMismatch",
  )
  // 长度不足 4 字节：连校验位都取不出来
  assert_eq(err_shape(() => @codec.b58_check_decode("1")), "BadPadding 1@0")
  // 给了 version 而首字节不符 ⇒ 这串不属于该命名空间
  assert_eq(
    err_shape(() => {
      @codec.b58_check_decode(
        "159LKv1gGepptdXG7coMf6QhdTrgDsG7i2",
        version=0x80,
      )
    }),
    "IllegalChar 159LKv1gGepptdXG7coMf6QhdTrgDsG7i2@0",
  )
}

///|
test "@codec #5 b62 的两版表（GMP 与大小写互换）+ 往返" {
  assert_eq(@codec.b62_encode(bytes_of([])), "")
  assert_eq(@codec.b62_encode(bytes_of([0x00])), "0")
  assert_eq(@codec.b62_encode(bytes_of([0x00, 0x00, 0x68, 0x69])), "006x7")
  assert_eq(@codec.b62_encode(bytes_of([0xff, 0xff, 0xff])), "18OWF")
  assert_eq(@codec.b62_encode(low16), "0SYW7RiJxkEgOGusQGwp")
  assert_eq(@codec.b62_encode(@utf8.encode("中文")), "19PTglOr9")
  assert_eq(@codec.b62_encode(@utf8.encode("Hello World!")), "T8dgcjRGkZ3aysdN")
  // inverted 档：同一份字节、大小写互换的表
  assert_eq(
    @codec.b62_encode(bytes_of([0x00, 0x00, 0x68, 0x69]), inverted=true),
    "006X7",
  )
  assert_eq(
    @codec.b62_encode(bytes_of([0xff, 0xff, 0xff]), inverted=true),
    "18owf",
  )
  assert_eq(@codec.b62_encode(low16, inverted=true), "0syw7rIjXKeGogUSqgWP")
  assert_eq(@codec.b62_decode("T8dgcjRGkZ3aysdN"), @utf8.encode("Hello World!"))
  assert_eq(
    @codec.b62_decode("t8DGCJrgKz3AYSDn", inverted=true),
    @utf8.encode("Hello World!"),
  )
  // 两版表只差顺序不差字符集：用错版**不报错**，给出的是另一个值——所以必须点名 inverted
  assert_true(
    @codec.b62_decode("t8DGCJrgKz3AYSDn") != @utf8.encode("Hello World!"),
  )
  assert_eq(
    err_shape(() => @codec.b62_decode("T8dgcjRGkZ3aysdN+")),
    "IllegalChar T8dgcjRGkZ3aysdN+@16",
  )
}

///|
test "@codec #6 radix_encode（表序 0-9A-Za-z，负号单列）" {
  assert_eq(@codec.radix_alphabet.char_length(), 62)
  assert_eq(@codec.radix_encode(0L, 2), "0")
  assert_eq(@codec.radix_encode(1L, 2), "1")
  assert_eq(@codec.radix_encode(7L, 8), "7")
  assert_eq(@codec.radix_encode(10L, 16), "A")
  assert_eq(@codec.radix_encode(61L, 62), "z")
  assert_eq(@codec.radix_encode(62L, 62), "10")
  assert_eq(@codec.radix_encode(4096L, 36), "35S")
  assert_eq(@codec.radix_encode(4096L, 58), "1Ca")
  assert_eq(@codec.radix_encode(4096L, 62), "144")
  assert_eq(@codec.radix_encode(-4096L, 62), "-144")
  assert_eq(@codec.radix_encode(9223372036854775807L, 62), "AzL8n0Y58m7")
  assert_eq(
    @codec.radix_encode(-9223372036854775808L, 2),
    "-1000000000000000000000000000000000000000000000000000000000000000",
  )
  assert_eq(
    err_shape(() => @codec.radix_encode(1L, 1)),
    "RadixOutOfRange 1 bound=62",
  )
  assert_eq(
    err_shape(() => @codec.radix_encode(1L, 63)),
    "RadixOutOfRange 63 bound=62",
  )
}

///|
test "@codec #6 radix_decode 与 encode 互逆，越界与非法字符各有读数" {
  let d : (String, Int) -> Int64 = (t, base) => {
    @codec.radix_decode(t, base) catch {
      _ => abort("夹具必须能解：\{t} base=\{base}")
    }
  }
  assert_eq(d("144", 62), 4096L)
  assert_eq(d("-144", 62), -4096L)
  assert_eq(d("Z", 36), 35L)
  assert_eq(d("0", 2), 0L)
  assert_eq(d("AzL8n0Y58m7", 62), 9223372036854775807L)
  // base36 只用表的前 36 个字符 ⇒ 大写 Z 合法、小写 z 非法
  assert_eq(err_shape(() => @codec.radix_decode("z", 36)), "IllegalChar z@0")
  assert_eq(err_shape(() => @codec.radix_decode("", 10)), "IllegalChar @0")
  assert_eq(err_shape(() => @codec.radix_decode("-", 10)), "IllegalChar -@1")
  assert_eq(
    err_shape(() => @codec.radix_decode("AzL8n0Y58m7z", 62)),
    "ValueOverflow AzL8n0Y58m7z",
  )
  assert_eq(
    err_shape(() => @codec.radix_decode("10", 1)),
    "RadixOutOfRange 1 bound=62",
  )
}

///|
/// 组件读数摆出来才看得出 `port = -1` 与 `query = None` 这两档区分对不对
fn url_of(t : String) -> @codec.Url {
  @codec.Url::parse(t) catch {
    _ => abort("夹具必须是可解析的 URL：\{t}")
  }
}

///|
test "@codec #7 form_encode（HTML 序列化器：`*` 放行而 `~` 要转义）" {
  assert_eq(@codec.form_encode(""), "")
  assert_eq(@codec.form_encode("hello world"), "hello+world")
  assert_eq(@codec.form_encode("中文"), "%E4%B8%AD%E6%96%87")
  assert_eq(@codec.form_encode("a=b&c"), "a%3Db%26c")
  assert_eq(@codec.form_encode("*-._~"), "*-._%7E")
  assert_eq(@codec.form_encode("a+b"), "a%2Bb")
  assert_eq(@codec.form_encode("100%"), "100%25")
  assert_eq(
    @codec.form_encode("~!@#$%^&*()"),
    "%7E%21%40%23%24%25%5E%26*%28%29",
  )
  // 与 core 的 percent 档不是同一件事：那边空格出 %20、`~` 放行、`*` 转义
  assert_eq(@percent.encode("a b~*"), "a%20b~%2A")
  assert_eq(@codec.form_encode("a b~*"), "a+b%7E*")
  // 对拍腿（门禁 G8）：**不含空格且不含 `+`/`*`/`~`** 的输入上两档必须同结果——
  // 重叠区间一致才证明表单档只是在四处差异上不同，不是凭空另造一套；core 改了 unreserved 集会在这里露出来
  for s in ["a=b&c", "中文", "100%", "foo.bar-baz_qux", "plain"] {
    assert_eq(@codec.form_encode(s), @percent.encode(s))
  }
}

///|
test "@codec #7 form_decode：+ 是空格，%2B 才是加号" {
  assert_eq(@codec.form_decode(""), "")
  assert_eq(@codec.form_decode("hello+world"), "hello world")
  assert_eq(@codec.form_decode("a%2Bb"), "a+b")
  assert_eq(@codec.form_decode("%2b"), "+") // 十六进制大小写都收
  assert_eq(@codec.form_decode("%E4%B8%AD"), "中")
  assert_eq(@codec.form_decode("plain"), "plain")
  // 对拍腿（门禁 G8）：纯 `%XX`（无 `+`）输入上与 core `percent.decode` 同结果
  for s in ["a%3Db%26c", "%E4%B8%AD%E6%96%87", "100%25", "plain"] {
    assert_eq(
      @codec.form_decode(s),
      @percent.decode(s) catch {
        _ => abort("夹具串必须是 core 那一侧的合法转义：\{s}")
      },
    )
  }
}

///|
test "@codec #7 form_decode 的坏序列：报错而不是换 U+FFFD" {
  assert_eq(err_shape(() => @codec.form_decode("%")), "IllegalChar %@0")
  assert_eq(err_shape(() => @codec.form_decode("%zz")), "IllegalChar %zz@0")
  assert_eq(err_shape(() => @codec.form_decode("a%4")), "IllegalChar a%4@1")
  // %FF%FF 不是任何合法 UTF-8 字符的开头 ⇒ 字节层坏，位置给不出有意义的文本下标
  assert_eq(err_shape(() => @codec.form_decode("%FF%FF")), "BadUtf8 %FF%FF")
  // 被截断的多字节序列同样要红（半个「中」）
  assert_eq(err_shape(() => @codec.form_decode("%E4%B8")), "BadUtf8 %E4%B8")
}

///|
test "@codec #7 form_build / form_parse：保序、重复键、无 = 的项" {
  assert_eq(@codec.form_build([]), "")
  assert_eq(@codec.form_build([("a", "1"), ("b", "2")]), "a=1&b=2")
  assert_eq(@codec.form_build([("a", "1"), ("a", "3")]), "a=1&a=3")
  assert_eq(@codec.form_build([("k", "")]), "k=")
  assert_eq(@codec.form_build([("", "")]), "=")
  assert_eq(
    @codec.form_build([("名称", "值"), ("n", "1 2")]),
    "%E5%90%8D%E7%A7%B0=%E5%80%BC&n=1+2",
  )
  assert_eq(@codec.form_build([("t", "a=b&c")]), "t=a%3Db%26c")
  let p : (String) -> Array[(String, String)] = q => {
    @codec.form_parse(q) catch {
      _ => abort("夹具必须能解：\{q}")
    }
  }
  assert_eq(p(""), [])
  assert_eq(p("a=1&b=2"), [("a", "1"), ("b", "2")])
  assert_eq(p("a=1&a=3"), [("a", "1"), ("a", "3")])
  assert_eq(p("k"), [("k", "")]) // 没有 `=` 也算一项，值为空串
  assert_eq(p("t=a%3Db%26c"), [("t", "a=b&c")]) // 只按第一个 `=` 切
  assert_eq(p("="), [("", "")])
  // 往返恒等
  let cases = [
    [],
    [("a", "1")],
    [("a", "1"), ("a", "2")],
    [("k", "")],
    [("", "")],
    [("名称", "值"), ("n", "1 2")],
    [("t", "a=b&c")],
  ]
  for cs in cases {
    assert_eq(p(@codec.form_build(cs)), cs)
  }
}

///|
test "@codec #8 Url::parse 的组件读数（含没有 authority 的那两档）" {
  let u = url_of("http://user@www.example.com:8080/a/b?q=1#frag")
  assert_eq(u.scheme, "http")
  assert_eq(u.userinfo, "user")
  assert_eq(u.host, "www.example.com")
  assert_eq(u.port, 8080)
  assert_eq(u.path, "/a/b")
  assert_eq(u.query, Some("q=1"))
  assert_eq(u.fragment, Some("frag"))
  let v = url_of("https://example.com")
  assert_eq(v.port, -1) // 未给端口 ≠ 端口 0，也不给默认值
  assert_eq(v.path, "")
  assert_eq(v.query, None) // 连 `?` 都没有
  assert_eq(v.fragment, None)
  // 不以 `//` 开头就没有 authority：`@` 不是 userinfo 分隔符，整段都是 path
  let m = url_of("mailto:t@x.com")
  assert_eq(m.userinfo, "")
  assert_eq(m.host, "")
  assert_eq(m.path, "t@x.com")
  assert_eq(url_of("urn:isbn:0451450765").path, "isbn:0451450765")
  let rel = url_of("//example.com/p")
  assert_eq(rel.scheme, "")
  assert_eq(rel.host, "example.com")
  assert_eq(url_of("/only/path").host, "")
  assert_eq(url_of("?q=1").query, Some("q=1"))
  assert_eq(url_of("http://example.com/a%2Fb?x=%7E").path, "/a%2Fb") // 解析不解码
}

///|
test "@codec #8 Url::to_string 一个字都不加：parse 的八条读数原样往返" {
  let cases = [
    "http://user@www.example.com:8080/a/b?q=1#frag", "https://example.com", "mailto:t@x.com",
    "urn:isbn:0451450765", "//example.com/p", "/only/path", "?q=1", "http://example.com/a%2Fb?x=%7E",
    "", "http://example.com/?#", // 给了 `?`/`#` 就是给了：空 query 也要写回去
  ]
  for t in cases {
    assert_eq(url_of(t).to_string(), t)
  }
}

///|
test "@codec #8 Url::parse 的结构负向（端口与非数字各给读数）" {
  assert_eq(
    err_shape(() => @codec.Url::parse("http://example.com:99999/")),
    "RadixOutOfRange 99999 bound=65535",
  )
  // 端口从 `:` 之后第一个字符起算，遇到非数字就报那个位置
  assert_eq(
    err_shape(() => @codec.Url::parse("http://example.com:x/")),
    "IllegalChar http://example.com:x/@19",
  )
  assert_eq(
    err_shape(() => @codec.Url::parse("http://example.com:/a")),
    "IllegalChar http://example.com:/a@18",
  )
  assert_eq(
    err_shape(() => @codec.Url::parse("http://exa mple.com/")),
    "IllegalChar http://exa mple.com/@10",
  )
}

///|
test "@codec #8 Url::normalize：语法等价对与幂等（RFC 3986 §6.2.2 / §5.2.4）" {
  let n : (String) -> String = t => url_of(t).normalize().to_string()
  assert_eq(
    n("HTTP://EXAMPLE.com:80/%7Efoo/a/../b/./c?Q=1#F"),
    "http://example.com/~foo/b/c?Q=1#F",
  )
  assert_eq(n("http://example.com/a/b/../.././../x"), "http://example.com/x")
  assert_eq(n("http://example.com"), "http://example.com/")
  assert_eq(n("https://example.com:443/"), "https://example.com/")
  assert_eq(n("http://example.com:8080/"), "http://example.com:8080/")
  assert_eq(n("http://example.com/a%2fB"), "http://example.com/a%2FB")
  assert_eq(n("http://example.com/%zz/a"), "http://example.com/%zz/a") // 非法转义不猜
  // RFC 3986 §5.2.4 规范自带的两个 worked example
  assert_eq(n("http://a/x/y/../z"), "http://a/x/z")
  assert_eq(n("http://a/mid/content=5/../6"), "http://a/mid/6")
  // 幂等：归一化两次与一次同值
  for
    t in [
      "HTTP://EXAMPLE.com:80/%7Efoo/a/../b/./c?Q=1#F", "http://example.com/a/b/../x",
      "https://example.com:443",
    ] {
    assert_eq(n(n(t)), n(t))
  }
}

///|
test "@codec #8 url_of_http：只在既无 scheme 又非协议相对时补 http://" {
  assert_eq(
    @codec.url_of_http("example.com/a").to_string(),
    "http://example.com/a",
  )
  assert_eq(@codec.url_of_http("example.com").to_string(), "http://example.com")
  // 已有 scheme（大小写不敏感）不补；协议相对也不补——补了就成 `http:////`
  assert_eq(
    @codec.url_of_http("HTTPS://example.com").to_string(),
    "HTTPS://example.com",
  )
  assert_eq(
    @codec.url_of_http("//example.com/a").to_string(),
    "//example.com/a",
  )
  assert_eq(
    @codec.url_of_http("HTTP://Example.com/a/../b").normalize().to_string(),
    "http://example.com/b",
  )
}
