// moon-hutool/codec 契约用例（黑盒）。
//
// 状态：**契约已冻结、实现未开工**——函数体是 `abort`，本包用例此刻红是设计态。
// 期望值先冻结、后实现；实现期改任何期望串 = 门禁 G5 拦下，须单独一笔并给外部读数来源。
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
