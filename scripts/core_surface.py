#!/usr/bin/env python
# hutool-core 顶层类三档归类（门禁 G16 的实现体）
#
# 立这条的起因：有人问"跟 Java hutool 差多少"，答案只能靠现场 unzip + javap 手算——
# 因为仓里只登记了**做过的**那一面，没登记的人要么当成欠账、要么当成不存在。
# 本脚本把"每个 hutool-core 顶层类必须落进一档"变成机器判据：漏档就红，判据自己坏掉也有对照。
#
# 五档（tier）：
#   done      本库有对位件（含"由本库某件复用同一判据"）
#   core      MoonBit core 已有同义能力，本库按规则不写转发层
#   excluded  结构上不属于本库：反射/动态代理/FFI/宿主能力/JVM 特性/跨栈定位
#   deferred  已登记在 ROADMAP「暂不做」档（加密、压缩、码表、流式摘要…）
#   gap       够得着、既没做也没登记 ⇒ 这一档就是要人拍板的清单，不许为空判绿
#
# 取类面：只读 jar（zipfile 列 .class，剥内部类），不依赖 javap ⇒ 快且无编码坑。
# 用法：
#   python scripts/core_surface.py --write    # 生成 docs/spec/core-surface.tsv
#   python scripts/core_surface.py --check    # 漂移 + 漏档检查（漂移或漏档退出 1）
#   python scripts/core_surface.py --selftest # 三档对照
# 参照 jar：$HUTOOL_JAR（指 hutool-all 或 hutool-core 都行）；取不到 ⇒ 退出码 2 = SKIP，不判通过。
import io
import os
import re
import sys
import zipfile

OUT = "docs/spec/core-surface.tsv"
CORE_PREFIX = "cn.hutool.core."

# 包前缀默认档（**含子包**：cn.hutool.core.bean 也吃掉 bean.copier.*）。越具体越靠前。
RULES = [
    (r"^cn\.hutool\.core\.io\.checksum", "done", "hash 包的 CRC8/CRC16 十变体对位"),
    (r"^cn\.hutool\.core\.(annotation|bean|getter|clone|compiler)", "excluded", "无运行时反射/动态代理/内联编译器"),
    (r"^cn\.hutool\.core\.(io|net|thread|img|swing|stream)", "excluded", "文件系统/网络/线程/AWT 需宿主能力（URL 语法与 io.unit 另判）"),
    (r"^cn\.hutool\.core\.lang\.mutable", "core", "Array 与 struct 本身可变"),
    (r"^cn\.hutool\.core\.(lang\.intern|lang\.loader|lang\.generator|lang\.copier|lang\.caller|lang\.reflect|lang\.func|lang\.ansi)",
     "excluded", "反射派生/JVM 内部机制/终端转义"),
    (r"^cn\.hutool\.core\.(text|convert|codec|collection|map|comparator|builder|lang\.hash|lang\.id|io\.unit)", "done", "text/conv/codec/coll/mapx/hash/id/typex 对位（逐条见 overrides）"),
    (r"^cn\.hutool\.core\.(date|math|exceptions)", "done", "date 五批 / num 四批 / 错误形状走 raise（个别档见 overrides 与 deferred）"),
    (r"^cn\.hutool\.core\.compress", "deferred", "DEFLATE/gzip/zip 在暂不做档"),
    (r"^cn\.hutool\.core\.lang\.tree", "gap", "纯数据结构却既没做也没登记（本轮新发现的档）"),
]

# 逐条覆盖（先于包级规则）。reason 一句话，判档依据都写在 spec 那一节。
OVERRIDES = {
    # —— 本库已交付对位
    "CharSequenceUtil": ("done", "text 首批"),
    "StrUtil": ("done", "text 首批"),
    "StrFormatter": ("done", "text.format"),
    "NamingCase": ("done", "text.to_*_case"),
    "AntPathMatcher": ("done", "path 整包"),
    "TextSimilarity": ("done", "textsim"),
    "DateUtil": ("done", "date 五批"),
    "CalendarUtil": ("done", "date"),
    "DatePattern": ("done", "date.date_pattern"),
    "DateUnit": ("done", "date.TimeUnit"),
    "LocalDateTimeUtil": ("done", "date 纯函数档"),
    "IdUtil": ("done", "id"),
    "NumberUtil": ("done", "num 一/二/三批"),
    "MathUtil": ("done", "num"),
    "NumberChineseFormatter": ("done", "num 第三批"),
    "NumberWordFormatter": ("done", "num 第三批"),
    "Calculator": ("done", "num 第四批 num_calculate"),
    "Money": ("done", "num 薄 Money 分定宽"),
    "Convert": ("done", "conv"),
    "ReUtil": ("done", "re 第一批"),
    "RegexPool": ("done", "re 第二批常量表"),
    "PatternPool": ("done", "re 第二批常量表"),
    "Validator": ("done", "valid 第一批 15 件"),
    "RandomUtil": ("done", "rand"),
    "WeightRandom": ("done", "rand 加权件"),
    "CollUtil": ("done", "coll 缺口子集"),
    "ListUtil": ("done", "coll"),
    "IterUtil": ("done", "coll"),
    "MapUtil": ("done", "mapx"),
    "Table": ("done", "mapx.Table"),
    "BiMap": ("done", "mapx.BiMap"),
    "CaseInsensitiveMap": ("done", "mapx.CiMap"),
    "HashUtil": ("done", "hash"),
    "MurmurHash": ("done", "hash"),
    "CityHash": ("done", "hash"),
    "MetroHash": ("done", "hash"),
    "CRC8": ("done", "hash 非标准表构造照搬"),
    "CRC16": ("done", "hash"),
    "Base64": ("done", "codec"),
    "Base64Decoder": ("done", "codec"),
    "Base64Encoder": ("done", "codec"),
    "Base32": ("done", "codec"),
    "Base58": ("done", "codec"),
    "Base62": ("done", "codec"),
    "RadixUtil": ("done", "codec"),
    "PercentCodec": ("done", "codec 表单档"),
    "UrlBuilder": ("done", "codec.Url"),
    "CsvReader": ("done", "csv"),
    "CsvWriter": ("done", "csv"),
    "CsvData": ("done", "csv"),
    "CsvRow": ("done", "csv"),
    "CsvConfig": ("done", "csv 选项档"),
    "Version": ("done", "typex.Version"),
    "PageUtil": ("done", "typex.page_*"),
    "Ipv4Util": ("done", "typex.ipv4_*"),
    "DataSize": ("done", "typex.DataSize 族"),
    "DataSizeUtil": ("done", "typex.data_size_format*"),
    "DesensitizedUtil": ("done", "typex.desensitize_*"),
    "IdcardUtil": ("done", "typex.idcard_*"),
    "CreditCodeUtil": ("done", "typex.credit_*"),
    "PhoneUtil": ("done", "typex.phone_*"),
    "CoordinateUtil": ("done", "typex.coord_*"),
    # —— core 已有同义能力，本库不写转发层
    "ArrayUtil": ("core", "Array/Iter 面"),
    "PrimitiveArrayUtil": ("core", "Array[T] 同义"),
    "CollStreamUtil": ("core", "Iter 组合"),
    "StrBuilder": ("core", "StringBuf/StringBuilder"),
    "StrJoiner": ("core", "Array.join"),
    "CharUtil": ("core", "Char 谓词（Unicode 档在 deferred）"),
    "BooleanUtil": ("core", "conv.to_bool 已承接文本档"),
    "ObjectUtil": ("gap", "null-safe 族在 MoonBit 是 Option 惯用法，但 default_if_null/is_all_null 这类没人登记——待拍"),
    "HexUtil": ("core", "encoding/hex；hexToInt 与颜色档另判"),
    "Dict": ("excluded", "反射式 Bean 包装"),
    "Assert": ("core", "语言自带 assert/raise；抛错类型族属 JVM 语义"),
    "TypeUtil": ("excluded", "泛型反射"),
    "ClassUtil": ("excluded", "类反射"),
    "ReflectUtil": ("excluded", "反射"),
    "ModifierUtil": ("excluded", "反射修饰位"),
    "EnumUtil": ("excluded", "反射枚举面"),
    "AnnotationUtil": ("excluded", "注解反射"),
    "Singleton": ("excluded", "反射式单例注册表"),
    "ClassScanner": ("excluded", "classpath 扫描"),
    "ClassLoaderUtil": ("excluded", "类加载器"),
    "ServiceLoaderUtil": ("excluded", "SPI"),
    "RuntimeUtil": ("excluded", "起进程"),
    "ResourceUtil": ("excluded", "classpath 资源"),
    "ExceptionUtil": ("core", "错误形状走 raise/匹配；栈深读取属宿主"),
    "CheckedUtil": ("excluded", "Java 受检异常糖"),
    "JNDIUtil": ("excluded", "JNDI"),
    "SerializeUtil": ("excluded", "Java 序列化"),
    "UnicodeUtil": ("gap", "\\uXXXX 串面转义够得着，既没做也没登记——待拍"),
    "EscapeUtil": ("gap", "HTML/XML 实体转义是纯串面，够得着却没人登记——待拍"),
    "URLUtil": ("gap", "codec 已承接 URL 组装与归一，isUrl/getSuffix/参数串那半没登记——待拍"),
    "URLEncoder": ("core", "codec.form_encode 同档"),
    "URLDecoder": ("core", "codec.form_parse 同档"),
    "URLEncodeUtil": ("core", "codec 同档"),
    "JAXBUtil": ("excluded", "JAXB"),
    "ZipUtil": ("deferred", "压缩在暂不做档"),
    "BasicType": ("excluded", "JDBC 类型映射"),
    "CastUtil": ("excluded", "泛型强转助手"),
    "FileTypeUtil": ("excluded", "要读文件魔数"),
    "BitStatusUtil": ("gap", "位状态算式，够得着没人登记——待拍"),
    "FastByteArrayOutputStream": ("excluded", "Java Stream 家族"),
    "TableMap": ("deferred", "多值 Map 已判不做（见 07-mapx §9）"),
    "ForestMap": ("deferred", "见 07-mapx §9"),
    "IoUtil": ("excluded", "流 IO"),
    "FileUtil": ("excluded", "文件 IO"),
    "FileNameUtil": ("gap", "纯路径串档（主名/扩展名/前后缀）够得着，path 包只管 Ant 匹配——待拍"),
    "PathUtil": ("excluded", "文件路径存在性需宿主"),
    "NetUtil": ("excluded", "本机 IP/端口需宿主"),
    "ThreadUtil": ("excluded", "线程池"),
    "Tuple": ("core", "元组"),
    "ConsistentHash": ("deferred", "hash 第二批排期"),
    "KetamaHash": ("deferred", "hash 第二批排期"),
    "Number128": ("deferred", "128 位族要先定返回形状"),
    "Hashids": ("deferred", "可逆编码，归属另判（见 00-hutool-map）"),
    "Snowflake": ("done", "id 生成件"),
    "ObjectId": ("done", "id"),
    "Zodiac": ("deferred", "生肖码表独立成数据件"),
    "SolarTerms": ("deferred", "节气码表独立成数据件"),
    "GanZhi": ("deferred", "干支码表独立成数据件"),
    "LunarInfo": ("deferred", "农历码表独立成数据件"),
    "ChineseDate": ("deferred", "农历码表独立成数据件"),
    "TemporalAccessorUtil": ("excluded", "java.time 互转"),
    "TemporalUtil": ("gap", "Instant/ZonedDateTime 构造助手在 MoonBit 侧对应什么，没登记——待拍"),
    "Quarter": ("core", "date.Date::quarter 同档"),
    "YearQuarter": ("gap", "年+季度复合键（含 parse/format）没登记——待拍"),
    "RingIndexUtil": ("gap", "环形下标算式，够得着没人登记——待拍"),
    "TreeUtil": ("gap", "扁平列表构树是纯算法，既没做也没登记——待拍"),
    "Tree": ("gap", "同上"),
    "CharsetUtil": ("deferred", "非 UTF 码表在暂不做档"),
    "CharsetDetector": ("deferred", "同上"),
    # —— 第二轮补齐：cn.hutool.core.util / lang 里的散件（逐条判，判据同上）
    "ByteUtil": ("deferred", "字节序族挂在 conv 第二批（见 ROADMAP conv 行）"),
    "ObjUtil": ("gap", "ObjectUtil 的新名，同档待拍"),
    "VersionUtil": ("done", "typex.Version 与 text.compare_version 承接"),
    "XmlUtil": ("excluded", "DOM/SAX 全在 JVM 侧"),
    "Pid": ("excluded", "进程号需宿主"),
    "JdkUtil": ("excluded", "JVM 内部诊断"),
    "JarClassLoader": ("excluded", "类加载器"),
    "ResourceClassLoader": ("excluded", "classpath 资源"),
    "SystemPropsUtil": ("excluded", "系统属性表（本库只按零依赖四条读 env 三件）"),
    "ReferenceUtil": ("excluded", "弱/软引用回收时机不可冻（同 16-cache 的 WeakCache 判据）"),
    "SimpleCache": ("excluded", "同上，件在 core 不在 cache"),
    "EnumItem": ("excluded", "反射枚举项"),
    "ParameterizedTypeImpl": ("excluded", "泛型反射"),
    "TypeReference": ("excluded", "泛型反射"),
    "UUID": ("done", "id.uuid_v3/uuid_v4"),
    "WeightListRandom": ("done", "rand 加权件"),
    "Console": ("excluded", "终端输出"),
    "ConsoleTable": ("excluded", "终端输出"),
    "Filter": ("core", "谓词就是一等闭包"),
    "Matcher": ("core", "re 包 + core Regex"),
    "Opt": ("core", "Option"),
    "Pair": ("core", "二元组"),
    "Chain": ("core", "闭包组合"),
    "Replacer": ("core", "re/text 已承接替换档"),
    "Editor": ("core", "Array 自带原地方法族"),
    "Range": ("core", "IntRange/Int64Range"),
    "Segment": ("core", "同上（typex 的 PageUtil.Segment 判不收另见 §1）"),
    "DefaultSegment": ("core", "同上"),
    "LambdaUtil": ("excluded", "lambda 元数据反射"),
    "MethodHandleUtil": ("excluded", "MethodHandle"),
    "ActualTypeMapperPool": ("excluded", "泛型反射"),
    "SynthesizedAnnotationProxy": ("excluded", "动态代理"),
    "DynaBean": ("excluded", "动态 Bean"),
}

# 规则与覆盖都没命中 ⇒ 漏档，判红（这就是 G16 的立身理由）
UNCLASSIFIED = "UNCLASSIFIED"


def classes_from_jar(jar):
    out = []
    zf = zipfile.ZipFile(jar)
    for n in zf.namelist():
        if not n.endswith(".class") or "$" in n:
            continue
        fqn = n[:-6].replace("/", ".")
        if not fqn.startswith(CORE_PREFIX):
            continue
        simple = fqn.rsplit(".", 1)[1]
        # package-info / module-info 是编译产物不是类（漏掉这条的话它们会永远落进 UNCLASSIFIED）
        if simple in ("package-info", "module-info"):
            continue
        out.append((simple, fqn))
    return sorted(set(out))


def classify(cls, fqn):
    if cls in OVERRIDES:
        return OVERRIDES[cls]
    for pat, tier, reason in RULES:
        if re.match(pat, fqn.rsplit(".", 1)[0] + "$"):
            return (tier, reason)
    for pat, tier, reason in RULES:
        if re.match(pat, fqn.rsplit(".", 1)[0]):
            return (tier, reason)
    return (UNCLASSIFIED, "包级规则与逐条覆盖都没命中")


def build(jar):
    rows = []
    for cls, fqn in classes_from_jar(jar):
        tier, reason = classify(cls, fqn)
        rows.append((cls, fqn, tier, reason))
    return rows


def render(rows):
    head = "# hutool-core 顶层类三档归类表 —— 由 `python scripts/core_surface.py --write` 生成，勿手改\n"
    head += "# 列：类名<TAB>全限定名<TAB>档<TAB>一句话理由；档取值 done/core/excluded/deferred/gap\n"
    body = "".join("%s\t%s\t%s\t%s\n" % r for r in rows)
    return head + body


def read_committed():
    if not os.path.exists(OUT):
        return None
    rows = []
    for line in io.open(OUT, encoding="utf-8"):
        if line.startswith("#") or not line.strip():
            continue
        p = line.rstrip("\n").split("\t")
        if len(p) == 4:
            rows.append(tuple(p))
    return rows


def resolve_jar():
    env = os.environ.get("HUTOOL_JAR")
    if env and os.path.exists(env):
        return env
    import glob
    import tempfile
    for c in sorted(glob.glob(os.path.join(tempfile.gettempdir(), "convsrc", "hutool-*.jar"))):
        if not c.endswith("-sources.jar") and "-src" not in os.path.basename(c):
            return c
    return None


def main():
    os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    jar = resolve_jar()
    if not jar:
        print("  SKIP 没有参照 jar（设 HUTOOL_JAR 指 hutool-all/hutool-core）⇒ 三档归类本轮无法核对")
        return 2
    rows = build(jar)
    if not rows:
        print("  SKIP 这份 jar 里没有 cn.hutool.core.* 的类（%s）⇒ 类面无法核对，不当通过也不当红" % jar)
        return 2
    unclassified = [r for r in rows if r[2] == UNCLASSIFIED]
    if "--write" in sys.argv:
        io.open(OUT, "w", encoding="utf-8", newline="\n").write(render(rows))
        print("  OK 写入 %s：%d 个类，漏档 %d" % (OUT, len(rows), len(unclassified)))
        for r in unclassified[:20]:
            print("     漏档 %s (%s)" % (r[0], r[1]))
        return 0 if not unclassified else 1
    if "--selftest" in sys.argv:
        n = selftest(jar, rows, unclassified)
        if n == 3:
            print("  PASS 三档对照全过（现表零漏档放行 / 撤规则必掉漏档 / 假类名必被抓）")
            return 0
        print("  FAIL 自检只有 %d/3 档通过 ⇒ 这条判据不可信" % n)
        return 1
    committed = read_committed()
    if committed is None:
        print("  FAIL 缺 %s（先 --write 并单独一笔提交）" % OUT)
        return 1
    if unclassified:
        print("  FAIL %d 个 hutool-core 顶层类没落档（既没做也没登记，且规则/覆盖都没写）：" % len(unclassified))
        for r in unclassified[:20]:
            print("     %s (%s)" % (r[0], r[1]))
        return 1
    # 死条目：覆盖表里写了 jar 中不存在的类名（凭记忆建表的形状），必须显式清掉，
    # 否则下一轮会照着一条不存在的对位关系去判档。
    known2 = {c for c, _ in classes_from_jar(jar)}
    dead = sorted(c for c in OVERRIDES if c not in known2)
    if dead:
        print("  FAIL 覆盖表里有 %d 个类名在这份 jar 中不存在：%s" % (len(dead), ", ".join(dead[:12])))
        return 1
    # 类面漂移：jar 里的类集合与表里的集合必须相等
    a = sorted((r[0], r[1]) for r in rows)
    b = sorted((r[0], r[1]) for r in committed)
    if a != b:
        miss = [x for x in a if x not in b]
        extra = [x for x in b if x not in a]
        print("  FAIL 表与 jar 类面漂移：表少 %d 条 %s / 表多 %d 条 %s" % (
            len(miss), miss[:5], len(extra), extra[:5]))
        return 1
    tiers = {}
    for r in rows:
        tiers[r[2]] = tiers.get(r[2], 0) + 1
    print("  PASS 三档归类：%d 个类全部落档 %s；gap 档就是待拍清单（不许为空判绿，也不许把 gap 当失败）" % (
        len(rows), sorted(tiers.items())))
    return 0


def selftest(jar, rows, unclassified):
    ok = 0
    # ① 现表必须放行（且零漏档）
    if not unclassified and read_committed() is not None:
        ok += 1
    else:
        print("  FAIL 自检①：现表之下就有 %d 个漏档，或表文件缺失" % len(unclassified))
    # ② 抽一个"由包级规则落档"的类（不是逐条覆盖来的），撤掉那条规则 ⇒ 它必须掉进漏档。
    #    这一档对照的存在理由：没有它，"全部落档"可能是规则表里某条永远为真在兜底（永真判据）。
    cls_by_rule = [(c, f) for c, f in classes_from_jar(jar) if c not in OVERRIDES and classify(c, f)[0] != UNCLASSIFIED]
    if cls_by_rule:
        c, f = cls_by_rule[0]
        pkg = f.rsplit(".", 1)[0]
        hit = [i for i, (pat, t, r) in enumerate(RULES) if re.match(pat, pkg)]
        if hit:
            saved = RULES.pop(hit[0])
            try:
                if classify(c, f)[0] == UNCLASSIFIED:
                    ok += 1
                else:
                    print("  FAIL 自检②：撤掉规则 %s 之后 %s 仍落 %s ⇒ 有别的规则在兜底，漏档判据不认这一条"
                          % (saved[0], c, classify(c, f)[0]))
            finally:
                RULES.insert(hit[0], saved)
        else:
            print("  FAIL 自检②：取不到「由规则落档」的样本类")
    else:
        print("  FAIL 自检②：全部类都走逐条覆盖，包级规则一格没被走过 ⇒ 对照取不到样本")
    # ③ 覆盖表里写了 jar 中不存在的类名 ⇒ 必须点名（防"凭记忆建表"，本仓犯过三次）
    known = {c for c, _ in classes_from_jar(jar)}
    ghosts = [c for c in OVERRIDES if c not in known]
    planted = "NoSuchClassForSelftestZzz"
    OVERRIDES[planted] = ("gap", "对照样本")
    try:
        caught = [c for c in OVERRIDES if c not in known]
        real = sorted(c for c in caught if c != planted)
        if planted not in caught:
            print("  FAIL 自检③：注入的假类名没被抓到 ⇒ ghost 判据失效")
        elif real:
            print("  FAIL 自检③：表里留有 %d 个死条目（jar 中不存在）：%s" % (len(real), ", ".join(real[:10])))
        else:
            ok += 1
    finally:
        OVERRIDES.pop(planted, None)
    return ok


if __name__ == "__main__":
    sys.exit(main())
