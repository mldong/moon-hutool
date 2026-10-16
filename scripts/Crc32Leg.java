// CRC32 参照腿（Issues #2）：java.util.zip.CRC32 的读数，供 scripts/gen_crc32_test.py 对撞。
//
// 为什么没有 hutool 对位件可跑：本仓类面清单现读 `cn.hutool.core.io.checksum` 只有 CRC8 / CRC16
// 与十个 crc16 变体，没有 CRC32（`CRC32` 那件是 JDK 自己的 `java.util.zip.CRC32`）。
// 所以这一腿取的是**标准 IEEE 802.3 反射位序**在 JDK 上的读数，与 Python `zlib.crc32` 同族互证。
//
// 跑法（工作树外落读数，本仓惯例）：
//   javac -encoding UTF-8 -d <outdir> scripts/Crc32Leg.java
//   java -cp <outdir> Crc32Leg > <outdir>/crc32_jdk.txt
//
// 三个入口都跑到：update(byte[])、update(byte[],int,int)、update(int)，外加 reset()/getValue()。
// 非 ASCII 夹具一律 Unicode 转义（避免 javac 平台编码把字面量打坏，digest 轮那条教训的形状）。
import java.nio.charset.StandardCharsets;
import java.util.zip.CRC32;

public class Crc32Leg {

  static byte[] ascii(String s) {
    return s.getBytes(StandardCharsets.US_ASCII);
  }

  static String hex(long v) {
    return String.format("%08x", v);
  }

  // 一次性读数（update(byte[]) 档）
  static void one(String tag, byte[] b) {
    CRC32 c = new CRC32();
    c.update(b);
    System.out.println(tag + "|" + c.getValue() + "|" + hex(c.getValue()) + "|" + b.length);
  }

  // 区间档读数：update(byte[], offset, length) 与整段必须同值
  static void range(String tag, byte[] b) {
    CRC32 c = new CRC32();
    c.update(b, 0, b.length);
    System.out.println(tag + ".range|" + c.getValue() + "|" + b.length);
  }

  // 逐字节档读数：update(int) 每字节一次
  static void perByte(String tag, byte[] b) {
    CRC32 c = new CRC32();
    for (byte x : b) {
      c.update(x);
    }
    System.out.println(tag + ".perbyte|" + c.getValue() + "|" + b.length);
  }

  public static void main(String[] args) {
    one("empty", new byte[0]);
    one("a", ascii("a"));
    one("digits", ascii("123456789"));
    one("fox", ascii("The quick brown fox jumps over the lazy dog"));
    one("cn", "中文".getBytes(StandardCharsets.UTF_8));
    byte[] raw = new byte[16];
    for (int i = 0; i < 16; i++) {
      raw[i] = (byte) i;
    }
    one("raw0f", raw);
    int[] lens = { 55, 56, 63, 64, 65, 119, 120 };
    for (int n : lens) {
      byte[] b = new byte[n];
      java.util.Arrays.fill(b, (byte) 'a');
      one("rep" + n, b);
    }
    byte[] big = new byte[1_000_000];
    java.util.Arrays.fill(big, (byte) 'a');
    one("rep1m", big);
    // 带偏移的一段：从 120 字节夹具里取 [7, 7+56)，与单独喂那 56 字节同值
    byte[] src = new byte[120];
    java.util.Arrays.fill(src, (byte) 'a');
    CRC32 off = new CRC32();
    off.update(src, 7, 56);
    System.out.println("offset56|" + off.getValue() + "|0|56");
    // reset 档：先喂脏再 reset，reset 后必须回到空串读数 0
    CRC32 r = new CRC32();
    r.update(ascii("dirty-before-reset"));
    r.reset();
    System.out.println("after_reset|" + r.getValue() + "|0|0");
    for (String t : new String[] { "a", "digits", "fox", "cn", "raw0f" }) {
      byte[] b = t.equals("a") ? ascii("a")
          : t.equals("digits") ? ascii("123456789")
              : t.equals("fox") ? ascii("The quick brown fox jumps over the lazy dog")
                  : t.equals("cn") ? "中文".getBytes(StandardCharsets.UTF_8) : raw;
      range(t, b);
      perByte(t, b);
    }
  }
}
