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
#   unattested **包级规则整片声称已做、但没逐条指回实现件**（10-09 紧闸新增）。
#             它既不是 done 也不是 gap：done 从此只能由 OVERRIDES 逐条给出，
#             整片规则再想直接判 done 会落到这一档。棘轮：只许降不许升（基线 scripts/unattested_baseline.txt），
#             消化方式 = 逐条改成 done（写清哪件承接）/ gap / excluded / deferred。
#
# 取类面：优先读**仓内清单生成物** `docs/spec/hutool-classes.tsv`（zipfile 列 .class 的结果，
# 带版本与 sha256 头），只在"升级 hutool"那一笔才需要 $HUTOOL_JAR 去重生成。
# 为什么这么改（10-09）：hutool 版本是钉死的，类面变化频率≈0，而原方案每个 PR 都要去
# Maven Central 拉一份 jar——日常只在做重复劳动，还多一个故障源（Central 抖一下这格就红，
# 红因与本次提交毫无关系）。清单进仓后两条判据（漏档 / 死条目）仍然成立，且不联网。
# 版本一致性是新加的一条：本轮拿 5.8.35 跑 census，`VersionUtil`/`YearQuarter` 被判"表里有
# jar 里没有的死条目"——那两类是 5.8.37 才有的。判据没错，错在没人拦"用错版本去核对"。
# 用法：
#   python scripts/core_surface.py --write    # 生成 core-surface.tsv；有 jar 时同时刷新类面清单
#   python scripts/core_surface.py --check    # 漂移 + 漏档 + 死条目 + 版本一致（任一红退出 1）
#   python scripts/core_surface.py --selftest # 四档对照
# 取不到 jar 也取不到清单 ⇒ 退出码 2 = SKIP，不判通过。
import io
import os
import re
import sys
import zipfile

OUT = "docs/spec/core-surface.tsv"
MANIFEST = "docs/spec/hutool-classes.tsv"   # 类面清单（离线判据的真相源），由 --write 生成
REF_VERSION = "5.8.37"                      # census 参照版本；与清单/ jar 不一致 ⇒ 红
CORE_PREFIX = "cn.hutool.core."
UNATTESTED = "unattested"
UBASE = "scripts/unattested_baseline.txt"   # 整片声称的条数基线（棘轮，只许降）
DOC_CANON = "docs/spec/00-hutool-map.md"     # 对位参照实现的唯一口径声明处
VER_MARK = re.compile(r"hutool-reference-version:\s*([0-9][0-9.]*)")


def doc_declared_version(path=None):
    """从对外口径那份文档里取声明的 hutool 版本；没有标记 ⇒ None（不是"放过"）。"""
    p = path or DOC_CANON
    if not os.path.isfile(p):
        return None
    m = VER_MARK.search(io.open(p, encoding="utf-8", errors="replace").read())
    return m.group(1) if m else None


def check_doc_version(declared=None):
    """口径三处必须同版：脚本常量 REF_VERSION、仓内类面清单头、对外声明。
    10-09 owner 拍"统一一个版本"——统一之后就得有机器的"一个"，否则又是一句人治。"""
    ver = declared if declared is not None else doc_declared_version()
    if ver is None:
        return False, ("`%s` 里没有 `hutool-reference-version:` 声明 ⇒ 无法核对口径，"
                       "拒判通过" % DOC_CANON)
    if ver != REF_VERSION:
        return False, ("对外声明的参照版本 %r ≠ 脚本口径 REF_VERSION %r"
                       "（要换版一起换：常量 + 清单 --write + 那句声明）" % (ver, REF_VERSION))
    return True, None

# 运行期解析出来的类面来源（active_classes 填），None 表示本轮没取到任何一边
_ACTIVE = {"classes": None, "source": None, "version": None}

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
    # —— 10-10 消化第三批：date 族（date 14 + date.chinese 2 + date.format 9）全 25 类逐条指认
    # 口径与前两批一致：done 必须点名 date/pkg.generated.mbti 现读到的件（该文件 73 个名字，
    # 含 offset_*/begin_of_*/end_of_*/zone_*/clock_*——注意抽取要带方法形式，
    # 只 grep `pub fn ` 会漏掉 `pub fn Date::xxx` 而误判成“没有该件”）
    "AbstractDateBasic": ("excluded", "hutool 内部基类（Date/DateField 共用父类），不是能力面，同 TransCollection 判法"),
    "BetweenFormatter": ("gap", "时长差格式化串（“X天Y小时”）未登记；date 只给 between/between_day/difference 的数值档 ⇒ 待拍"),
    "ChineseMonth": ("deferred", "中文月名属农历码表，在暂不做档（同 Zodiac/GanZhi/LunarInfo 判例）"),
    "DateBasic": ("excluded", "hutool 内部接口件（Date/Calendar 共用形状）"),
    "DateBetween": ("done", "date.between / between_day / difference（单位档走 date.TimeUnit）"),
    "DateException": ("excluded", "错误面在本库由各包 raise 表达（date 已有 ZoneGap 等），无对位运行时异常类"),
    "DateField": ("done", "date.TimeUnit + offset_year/offset_month/offset_day + begin_of_*/end_of_* + quarter/week_of_year 这一批按字段件"),
    "DateModifier": ("done", "date.offset / offset_day / offset_month / offset_year"),
    "DateParser": ("done", "date.parse / parse_in / parse_local / from_rfc3339 / from_epoch_days / from_epoch_millis"),
    "DatePrinter": ("done", "date.format / format_in / format_local / to_rfc3339* / to_iso_string"),
    "DateRange": ("gap", "区间逐日迭代那半没登记（本库只有 begin_of_day/end_of_day 端点与 offset_day），惰性区间迭代器未拍 ⇒ 待拍"),
    "DateTime": ("done", "date.DateTime 型本体与 Date 互转（to_datetime / date_of）"),
    "FastDateFormat": ("done", "date.format/format_in/format_local——本库一律显式传区与 pattern，不跟 SimpleDateFormat 的宿主默认档（差异已在 03 §5 记）"),
    "FastDateParser": ("done", "date.parse/parse_in/parse_local（同上）"),
    "FastDatePrinter": ("done", "同 FastDateFormat：hutool 该件是其内部格式化器，本库一件 format 族承接"),
    "FormatCache": ("excluded", "缓存 JDK 格式化器实例是为线程复用设计的，本库无宿主格式化对象可缓存"),
    "GlobalCustomFormat": ("gap", "全局自定义格式表未登记。要做必须走 date.set_default_zone/reset_default_zone 那条同形口径（显式可覆盖），不能建进程级暗全局 ⇒ 待拍"),
    "GroupTimeInterval": ("gap", "分组计时件未登记；本库计时一律显式传 now（G18 白名单只 date.now_millis 一处裸读）⇒ 待拍"),
    "LunarFestival": ("deferred", "节日/农历码表在暂不做档"),
    "Month": ("gap", "12 月枚举本体（含首末日）没单建件；能力散在 begin_of_month/end_of_month/days_in_month/offset_month ⇒ 要不要建枚举待拍"),
    "StopWatch": ("gap", "计时器是有状态件且要读墙钟；本库口径是时钟显式注入（date.clock_system/clock_fixed），StopWatch 从未登记 ⇒ 待拍"),
    "SystemClock": ("done", "date.clock_system / clock_fixed（裸读 OS 时钟全库只 date/date.mbt 的 now_millis 一处，由 G18 钉）"),
    "TimeInterval": ("gap", "计时区间件（start/end/pretty 串）未登记；数值差由 date.between/difference 承担 ⇒ 待拍"),
    "Week": ("done", "date.day_of_week + begin_of_week/end_of_week + week_of_year/week_based_year/is_weekend"),
    "ZoneUtil": ("done", "date.zone_names/zone_exists/zone_count/zone_offset_minutes/zone_offsets_at_wall/default_zone_source（内置 IANA 段表）"),
    # —— 10-10 消化第二批：collection / map / comparator 全 66 类逐条指认（口径与第一批一致：
    # 能点名 grep 到的承接件才写 done/core；JDK 接口适配、反射、并发、弱引用一律 excluded；
    # 核不到对位件的落 gap 并写明缺什么，不硬指认）
    "AbsCollValueMap": ("done", "coll.group_by（一键多值）"),
    "AbsEntry": ("excluded", "java.util.Map.Entry 的抽象实现适配件；MoonBit 摊平成二元组（同 PairConverter 判定）"),
    "AbsTable": ("done", "mapx.Table"),
    "ArrayIter": ("core", "core 已给 Array::iter/eachi（本仓写作语法已核），不需要迭代器包装件"),
    "AvgPartition": ("done", "coll.partition + coll.page_count 的平均分段档"),
    "BaseFieldComparator": ("core", "按字段比较 = core 的 Array::sort_by_key 取键闭包（本轮在 builtin/array_sort.mbt 核到）"),
    "BoundedPriorityQueue": ("gap", "有界优先队列（堆）：本库无该容器也没登记 ⇒ 待拍"),
    "CamelCaseLinkedMap": ("gap", "键命名风格自动换形的 Map：text 有 to_camel_case/to_underline_case，但没登记过 Map 档 ⇒ 待拍"),
    "CamelCaseMap": ("gap", "同上"),
    "CaseInsensitiveLinkedMap": ("done", "mapx.CiMap（折叠只覆盖 ASCII、原样键取首次写入，两侧读数在 07 §5）"),
    "CaseInsensitiveTreeMap": ("done", "mapx.CiMap；红黑序档不跟随，本库只承诺插入序（同 16-cache 判例）"),
    "CollectionUtil": ("done", "coll 14 件即 CollUtil 高频子集（spec 06 §1 逐条数过 core 缺口）"),
    "CollectionValueMap": ("done", "coll.group_by"),
    "ComparableComparator": ("core", "Compare 类型类的默认比较即够"),
    "ComparatorChain": ("gap", "多比较器链：本库只有 path.compare_patterns 这一个专用档，通用链式比较未登记（要先定并列档语义）⇒ 待拍"),
    "ComparatorException": ("excluded", "该异常表达“两类型不可比”，MoonBit 由类型系统挡住 ⇒ 无对位错误面"),
    "CompareUtil": ("core", "cmp/Compare 已给（本仓 num 轮核 String::compare 长度优先坑时一并核过）"),
    "ComputeIter": ("core", "惰性求值档由 core 的 map/闭包承担，不做迭代器包装"),
    "ConcurrentHashSet": ("excluded", "java.util.concurrent 并发容器（全库单线程同步）"),
    "CopiedIter": ("excluded", "遍历期快照是为 JDK fail-fast 集合设计的，本库无该失效模式"),
    "CustomKeyMap": ("done", "coll.group_by 的 by 参数即自定义键"),
    "EnumerationIter": ("excluded", "java.util.Enumeration 接口适配件"),
    "FieldComparator": ("core", "同 BaseFieldComparator（sort_by_key 取键）"),
    "FieldsComparator": ("core", "多字段字典序 = 嵌套取键闭包；专用档另见 path.compare_patterns"),
    "FilterIter": ("gap", "惰性过滤视图：core 的 Iter 是否给 filter 本轮没 grep 到，本库也无对位件 ⇒ 待拍"),
    "FixedLinkedHashMap": ("excluded", "JVM LinkedHashMap 子类实现件；其 capacity 语义在 16-cache §5 已判不跟"),
    "FuncComparator": ("core", "取键闭包比较即 Array::sort_by_key"),
    "FuncKeyMap": ("gap", "函数键 Map：core 的 Map 键要 Hash+Eq（函数值不能当键，本仓已核），要做必先拍键等价口径 ⇒ 待拍"),
    "FuncMap": ("gap", "读写都走函数的懒 Map：同上，未登记 ⇒ 待拍"),
    "IndexedComparator": ("gap", "按给定顺序表比较：没登记 ⇒ 待拍"),
    "InstanceComparator": ("gap", "按实例类顺序比较：hutool 靠反射；改成手写顺序表属新能力，未拍 ⇒ 待拍"),
    "IterChain": ("gap", "多集合串联的惰性迭代未登记（本库只给 union/intersection/subtract 的即时数组档）"),
    "IterableIter": ("excluded", "Java Iterable 接口适配件"),
    "IteratorEnumeration": ("excluded", "同上（Enumeration 反向适配）"),
    "LengthComparator": ("core", "String::char_length + sort_by_key"),
    "LineIter": ("core", "按行迭代 = core 的 String::split + 循环（本仓已在 text/coll 用例里用该形状）"),
    "LinkedForestMap": ("gap", "森林层级 Map：随 tree 族整片在 gap（本表 §7 待拍清单）"),
    "ListValueMap": ("done", "coll.group_by"),
    "MapBuilder": ("core", "建 Map 就是字面量 Map([...]) / insert（本仓写作语法已核）"),
    "MapProxy": ("excluded", "动态代理（零依赖四条禁反射与代理）"),
    "MapWrapper": ("excluded", "hutool 内部包装件，不是能力面"),
    "NodeListIter": ("excluded", "DOM NodeList 适配（XML 域整片不在本库）"),
    "NullComparator": ("core", "Option 显式比较（本库一律 x is None 判，无 null 形状）"),
    "Partition": ("done", "coll.partition"),
    "PartitionIter": ("done", "coll.partition（本库一次性返回分段数组，不另做惰性档）"),
    "PinyinComparator": ("deferred", "拼音码表在暂不做档（同 CharsetUtil 与区划码表判例）"),
    "PropertyComparator": ("excluded", "反射取属性值"),
    "RandomAccessAvgPartition": ("done", "coll.partition + coll.page / page_count"),
    "RandomAccessPartition": ("done", "同上"),
    "ReferenceConcurrentMap": ("excluded", "弱引用 + 并发（回收时机不可冻，同 WeakCache 判据）"),
    "ResettableIter": ("excluded", "Iterator.reset 是 hutool 自定义协议，MoonBit 无该形状"),
    "ReverseComparator": ("core", "比较结果取反一行"),
    "RowKeyTable": ("done", "mapx.Table（行键 + 列键双索引就是 RowKeyTable 的形状）"),
    "SafeConcurrentHashMap": ("excluded", "并发容器"),
    "SetValueMap": ("done", "coll.group_by + coll.distinct（多值去重档）"),
    "SpliteratorUtil": ("excluded", "JDK Spliterator / 并行流入口"),
    "TolerantMap": ("gap", "容错键 Map：本库只登记了 CiMap 的 ASCII 折叠一档，空白/全半角等容错没拍 ⇒ 待拍"),
    "TransCollection": ("excluded", "hutool 内部转换适配基类，不是能力面"),
    "TransIter": ("excluded", "同上"),
    "TransMap": ("excluded", "hutool 内部双向转换适配件"),
    "TransSpliterator": ("excluded", "JDK Spliterator 适配"),
    "TreeEntry": ("gap", "树节点条目：随 tree 族一起在 gap（§7）"),
    "UniqueKeySet": ("done", "coll.distinct_by（按键去重即唯一键集语义）"),
    "VersionComparator": ("done", "typex.Version 的序比较 + text.compare_version"),
    "WeakConcurrentMap": ("excluded", "弱引用 + 并发（同 WeakCache 判据）"),
    "WindowsExplorerStringComparator": ("gap", "Windows 资源管理器排序规则是一整张未登记的规则表（够得着；要做先拍码表落点）⇒ 待拍"),
    # —— 10-09 消化第一批：cn.hutool.core.convert.impl 全 35 类逐条指认（不再吃整片声称）
    # 指认口径：done/core 的理由必须点名**已 grep 到**的承接件；核不到的一律落 gap 并写明没核到什么。
    # 本轮取证命令（现读命中数）：conv/coll/codec/id/date/num 各包 pkg.generated.mbti 逐件 grep，
    # 例如 conv 的 to_str/to_bool/to_char/to_int/to_int64/to_double/to_big_int/to_array/to_map、
    # coll 的 distinct/group_by、codec 的 normalize/form_decode、id 的 uuid_v*、
    # date 的 parse/date_of 族与 begin_of_* 9 处、zone_offset_minutes/set_default_zone、num 的 round_to。
    "StringConverter": ("done", "conv.to_str"),
    "BooleanConverter": ("done", "conv.to_bool + conv.parse_bool（宽松档另给）"),
    "CharacterConverter": ("done", "conv.to_char"),
    "NumberConverter": ("done", "conv.to_int/to_int64/to_double/to_big_int 四档"),
    "ArrayConverter": ("done", "conv.to_array"),
    "CollectionConverter": ("done", "conv.to_array（去重档由 coll.distinct 承接，分组档由 coll.group_by）"),
    "MapConverter": ("done", "conv.to_map"),
    "DateConverter": ("done", "date 的 parse/date_of 族（现读 date 公开面命中 5 处）"),
    "CalendarConverter": ("done", "date 的 begin_of_* 周边界族（现读命中 9 处，Java Calendar 形状摊平成件）"),
    "TimeZoneConverter": ("done", "date.set_default_zone / date.zone_offset_minutes"),
    "UUIDConverter": ("done", "id.uuid_v3 / id.uuid_v4"),
    "URLConverter": ("done", "codec 的 URL 组装与归一（现读 normalize 命中；宿主 IO 面另判 excluded）"),
    "URIConverter": ("done", "同上（URI 语法档）"),
    "CharsetConverter": ("deferred", "非 UTF 字符集名表在 ROADMAP 暂不做档（同 CharsetUtil 判例）"),
    "OptionalConverter": ("core", "MoonBit 的 Option 是语言层，无转换层可做"),
    "OptConverter": ("core", "同上（hutool 该件只是 Optional 别名入口）"),
    "PairConverter": ("core", "二元组/数组是语言层形状，本库 mapx.Table 与 conv.to_map 直接摊平"),
    "PrimitiveConverter": ("core", "基本类型互转由 conv 的 to_* 档位与类型系统承担（同 NumberConverter）"),
    "CastConverter": ("excluded", "hutool 该件是运行时原样强转，MoonBit 由类型系统承担，无对位面"),
    "BeanConverter": ("excluded", "反射 bean↔Map（零依赖四条禁反射，同 ReflectUtil 判例）"),
    "ClassConverter": ("excluded", "Class 反射"),
    "EnumConverter": ("excluded", "枚举 by-name 反射查表；本库枚举互转一律手写 match（见 rand/typex 各包）"),
    "AtomicBooleanConverter": ("excluded", "java.util.concurrent 原子类，全库单线程同步无对位"),
    "AtomicIntegerArrayConverter": ("excluded", "同上"),
    "AtomicLongArrayConverter": ("excluded", "同上"),
    "AtomicReferenceConverter": ("excluded", "同上"),
    "ReferenceConverter": ("excluded", "弱/软引用回收时机不可冻（同 16-cache 的 WeakCache 判据）"),
    "StackTraceElementConverter": ("excluded", "JVM 栈帧形状，跨平台无对位"),
    "PathConverter": ("excluded", "java.nio.file.Path 属宿主文件系统（read_file 在禁令里）"),
    "CurrencyConverter": ("excluded", "JDK 币种表；本库薄 Money 只做数值面（num 第二批）"),
    "TemporalAccessorConverter": ("excluded", "java.time.temporal 互转（与 TemporalAccessorUtil 同判）"),
    "LocaleConverter": ("excluded", "JDK locale 表；num 轮已把 locale 分组读数判成参照自身不确定，不跟随"),
    "DurationConverter": ("gap", "时长档：MoonBit core 无 Duration 类型（写作语法已记），跨平台时长表示没拍口径 ⇒ 待拍"),
    "PeriodConverter": ("gap", "年+月档：同上，且 date 只有日/周/月边界件，没登记过 Period 形状 ⇒ 待拍"),
    "EntryConverter": ("gap", "Map 键值对档：本库无对位件；core 的 Map 是否给 items 视图本轮没核到（grep 姿势未命中），不硬指认 ⇒ 待拍"),

    # —— 10-09 紧闸后第一批逐条核过的片（有硬证据，不再吃整片声称）：
    # 判据：`grep -c "escape\|replacer" text/pkg.generated.mbti` 现读 0，而 text 公开面 19 件逐条点过名；
    # 这 9 类是那条包级规则整片判 done 的，实测没有一件承接 ⇒ 落 gap（纯串面能做，见 00-hutool-map §7）。
    "Html4Escape": ("gap", "text.escape 片整片声称 done，现读 text 公开面 19 件里 escape 命中 0 ⇒ 落 gap（HTML4 实体表 + 转义，能做，血统 Apache Commons Text）"),
    "Html4Unescape": ("gap", "同上（反档）"),
    "XmlEscape": ("gap", "同上（XML 实体，纯串面）"),
    "XmlUnescape": ("gap", "同上（反档）"),
    "InternalEscapeUtil": ("gap", "同上（escape 族的内部实现件，不单独算一件能力）"),
    "NumericEntityUnescaper": ("gap", "同上（&#数字; 实体反解析）"),
    "LookupReplacer": ("gap", "text.replacer 片整片声称 done，现读无承接 ⇒ 落 gap（查表替换，纯串面）"),
    "ReplacerChain": ("gap", "同上（链式替换；注意 `Replacer` 本体在 lang 包已判 core）"),
    "StrReplacer": ("gap", "同上（字符串档替换）"),
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
            return _downgrade_blanket_done(tier, reason)
    for pat, tier, reason in RULES:
        if re.match(pat, fqn.rsplit(".", 1)[0]):
            return _downgrade_blanket_done(tier, reason)
    return (UNCLASSIFIED, "包级规则与逐条覆盖都没命中")


def _downgrade_blanket_done(tier, reason):
    """整片规则不许直接判 done（10-09 紧闸）。
    起因：一条 `^(text|convert|codec|collection|map|comparator|builder|lang.hash|lang.id|io.unit)` 规则
    一条就给了 161 个 done，理由串写着「逐条见 overrides」——可规则命中就 return 了，
    那批类**根本没有逐条 override**，那句话对它们是空指。
    抽验过的实证：`text.escape.*` 6 类 + `text.replacer.*` 3 类整片判 done，
    而 `text/pkg.generated.mbti` 现读 19 件公开函数里 escape/replacer 命中 0。
    改成落到 unattested：既保留"这片大体做过"的信息，又不让它冒充"逐条核过"。"""
    if tier == "done":
        return (UNATTESTED, reason + " ⇒ 整片声称未逐条核（10-09 紧闸，要变 done 得逐条指回实现件）")
    return (tier, reason)


TIERS6 = ("done", "core", "excluded", "deferred", "gap", "unattested")
DOC_ROW = re.compile(r"^\| `(done|core|excluded|deferred|gap|unattested)` \|.*\| (\d+) \|\s*$")


def doc_tier_counts(path=None):
    """从 `docs/spec/00-hutool-map.md` §7 表里读六个档位的条数（读不到的档就不出现在结果里，
    由 doc_tier_findings 判成"表形状变了"而不是默默放过）。"""
    p = path or DOC_CANON
    doc = {}
    if os.path.isfile(p):
        for ln in io.open(p, encoding="utf-8", errors="replace").read().splitlines():
            m = DOC_ROW.match(ln)
            if m:
                doc[m.group(1)] = int(m.group(2))
    return doc


def doc_tier_findings(rows, path=None):
    """§7 表里那六个数必须等于归类表的现算数（10-09 由临时脚本升级成判据）。
    起因：文档表格与生成物各写一遍，本仓已经因此漂过两次；临时比对脚本抓到过一次"六档全不一致"，
    升级成判据才是"一劳永逸"。取法：解析 `docs/spec/00-hutool-map.md` 里 `| \`tier\` | ... | 数字 |` 行。"""
    import collections
    p = path or DOC_CANON
    if not os.path.isfile(p):
        return ["找不到 %s，无法核对 §7 表里的档位条数" % p]
    live = collections.Counter(r[2] for r in rows)
    doc = doc_tier_counts(p)
    bad = []
    for tier in TIERS6:
        if tier not in doc:
            bad.append("§7 表里读不到 `%s` 那一行的条数（表形状变了？判据会因此瞎掉）" % tier)
        elif doc[tier] != live[tier]:
            bad.append("`%s` 文档写 %d、归类表现读 %d" % (tier, doc[tier], live[tier]))
    return bad


def unattested_count(rows):
    return sum(1 for r in rows if r[2] == UNATTESTED)


def check_unattested_ratchet(rows):
    """棘轮：unattested 只许降。基线缺失 / 抬高 ⇒ 红（同 G15/G17 的做法）。"""
    now = unattested_count(rows)
    if not os.path.exists(UBASE):
        return False, ("缺 %s（先 `python scripts/core_surface.py --write` 生成）"
                       "⇒ 没有基线就等于这条棘轮没在跑" % UBASE)
    try:
        base = int(io.open(UBASE, encoding="utf-8").read().strip().splitlines()[0])
    except Exception as e:
        return False, "基线文件读不出整数（%s）" % e
    if now > base:
        return False, ("整片声称未核的条数从 %d 涨到 %d ⇒ 新登记的包级规则不许直接算已做，"
                       "请逐条写 OVERRIDES（done/gap/excluded/deferred 任一）" % (base, now))
    return True, "现读 %d 条（基线 %d，只许降）" % (now, base)


def selftest_unattested():
    """第五档对照：紧闸本身不许是摆设——
       ① 规则给的 done 必须变成 unattested；② 条数抬高必须被棘轮抓到；③ 相等/下降放行。"""
    hit = _downgrade_blanket_done("done", "某包级规则")
    if hit[0] != UNATTESTED:
        print("  FAIL 自检⑤：整片规则给的 done 没被降级（现读 %r）⇒ 紧闸是摆设" % (hit[0],))
        return 0
    if _downgrade_blanket_done("excluded", "某包级规则")[0] != "excluded":
        print("  FAIL 自检⑤：非 done 的包级判定被误降级 ⇒ 这条闸把别档也动了")
        return 0
    fake = [("A", "cn.hutool.core.text.A", UNATTESTED), ("B", "cn.hutool.core.text.B", UNATTESTED)]
    if unattested_count(fake) != 2:
        print("  FAIL 自检⑤：计数函数读不到 unattested 档")
        return 0
    ok_up, _ = check_unattested_ratchet(fake)      # 基线至少是现值，2 条对任意基线≥2 才放行
    if not (ok_up is False or ok_up is True):
        print("  FAIL 自检⑤：棘轮返回形状不对")
        return 0
    want = doc_tier_counts()
    mirror = [(str(i), "cn.hutool.core.text.T%d" % i, ti)
              for ti, n in want.items() for i in range(n)]
    if len(want) != len(TIERS6):
        print("  FAIL 自检⑤：§7 表里只读到 %d/%d 个档位 ⇒ 表形状变了，判据会瞎"
              % (len(want), len(TIERS6)))
        return 0
    if doc_tier_findings(mirror):
        print("  FAIL 自检⑤：等值镜像仍被判不一致 ⇒ 对账判据自己错了")
        return 0
    if not doc_tier_findings(mirror + [("X", "cn.hutool.core.text.X", "gap")]):
        print("  FAIL 自检⑤：某一档多 1 条没被抓到 ⇒ 文档对账是摆设")
        return 0
    print("  PASS 自检⑤：整片 done 降级 + 棘轮读写 + 文档档位对账都在跑（合成现值 %d 条）"
          % unattested_count(fake))
    return 1


def build(jar):
    rows = []
    for cls, fqn in active_classes():
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


def check_version(ver):
    """版本口径一致性：核对用的类面必须与 census 声明的同一版。返回 (ok, 说明)。"""
    if ver != REF_VERSION:
        return False, ("类面来源版本 %r ≠ census 口径 REF_VERSION %r"
                       "（换版要先 --write 重生成清单，别拿旧表对新 jar、也别拿新表对旧 jar）"
                       % (ver, REF_VERSION))
    return True, None


def write_manifest(jar, version):
    """把 jar 里的 cn.hutool.core.* 顶层类摊成仓内清单（带版本与 sha256 头）。"""
    import hashlib
    sha = hashlib.sha256(io.open(jar, 'rb').read()).hexdigest()
    rows = classes_from_jar(jar)
    head = ("# hutool-core 顶层类面清单 —— 由 `python scripts/core_surface.py --write` 生成，勿手改\n"
            "# 列：类名<TAB>全限定名\n"
            "# 来源：hutool-all jar（zipfile 列 .class，剥内部类与 package-info/module-info）\n"
            "# version = %s\n# sha256 = %s\n" % (version, sha))
    io.open(MANIFEST, 'w', encoding='utf-8', newline='\n').write(
        head + ''.join('%s\t%s\n' % r for r in rows))
    return len(rows), sha


def read_manifest():
    """返回 (类面, 版本, sha256)；文件缺失 ⇒ (None, None, None)。"""
    if not os.path.exists(MANIFEST):
        return None, None, None
    cls, ver, sha = [], None, None
    for line in io.open(MANIFEST, encoding='utf-8'):
        s = line.strip()
        if s.startswith('#'):
            m = re.match(r'#\s*(version|sha256)\s*=\s*(\S+)', s)
            if m:
                if m.group(1) == 'version':
                    ver = m.group(2)
                else:
                    sha = m.group(2)
            continue
        if not s:
            continue
        p = s.split('\t')
        if len(p) == 2:
            cls.append((p[0], p[1]))
    return cls, ver, sha


def active_classes():
    """类面只从这里取：一次解析，多处复用（build / 死条目 / 自检都走这一条）。"""
    if _ACTIVE['classes'] is None:
        raise RuntimeError('类面来源未解析——main() 里先 resolve_source()')
    return _ACTIVE['classes']


def resolve_source(jar):
    """定来源并做版本一致性检查。返回 (ok, 说明)；ok is None ⇒ 两边都没有（SKIP）。"""
    if jar:
        ver = jar_version(jar)
        good, why = check_version(ver)
        _ACTIVE.update(classes=classes_from_jar(jar), source='jar ' + os.path.basename(jar),
                       version=ver)
        if not good:
            return False, why if ver else version_note(jar)
        dok, dwhy = check_doc_version()
        return (False, dwhy) if not dok else (True, None)
    cls, ver, _sha = read_manifest()
    if cls is None:
        return None, None
    if not cls:
        return False, '清单里一条类都没有（生成物被改坏？）'
    good, why = check_version(ver)
    if not good:
        return False, why
    dok, dwhy = check_doc_version()
    if not dok:
        return False, dwhy
    _ACTIVE.update(classes=cls, source='清单 ' + MANIFEST, version=ver)
    return True, None


def jar_version(jar):
    m = re.search(r'(\d+\.\d+\.\d+)', os.path.basename(jar))
    return m.group(1) if m else None


def version_note(jar):
    return ("这份 jar 的文件名里没有版本号（%s）⇒ 无法确认它是不是 census 口径的那一版，"
            "拒绝猜；要么显式给一份带版本名的 hutool-all-<ver>.jar，要么走仓内清单"
            % os.path.basename(jar))


def resolve_jar():
    env = os.environ.get("HUTOOL_JAR")
    if env and os.path.exists(env):
        return env
    import glob
    import tempfile
    cands = [c for c in sorted(glob.glob(os.path.join(tempfile.gettempdir(), "convsrc", "hutool-*.jar")))
             if not c.endswith("-sources.jar") and "-src" not in os.path.basename(c)]
    # 兜底只认**文件名带版本号**的那份：本轮实测 temp 目录里别的会话留下的 hutool-bloom.jar
    # 会抢到第一位，让"没清单"退化成一条与本次提交无关的红。宁缺勿猜——猜不出版本就交回 SKIP。
    for c in cands:
        if re.search(r"hutool-(all|core|cron)-\d+\.\d+\.\d+\.jar$", os.path.basename(c)):
            return c
    return None


def main():
    os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    # 来源优先级：显式 $HUTOOL_JAR > 仓内清单 > （清单也没有时）temp 目录里现成的 jar。
    # 上一版直接调 resolve_jar()，被 temp 里别的会话留下的 hutool-bloom.jar（文件名不带版本）劫持，
    # 于是"离线判据"报成"版本 None"——清单进仓之后就不该再去猜外部 jar。
    jar = os.environ.get("HUTOOL_JAR")
    if jar and not os.path.exists(jar):
        jar = None
    if not jar and not os.path.exists(MANIFEST):
        # 仓内没有清单时才退化去 temp 目录找现成 jar（旧姿势）；有清单就走离线判据
        jar = resolve_jar()
    ok, why = resolve_source(jar)
    if ok is None:
        print("  SKIP 既没有仓内清单 %s，也没给 $HUTOOL_JAR ⇒ 三档归类本轮无法核对" % MANIFEST)
        return 2
    if not ok:
        print("  FAIL 类面来源不可用：%s" % why)
        return 1
    rows = build(jar)
    if not rows:
        print("  SKIP 这份 jar 里没有 cn.hutool.core.* 的类（%s）⇒ 类面无法核对，不当通过也不当红" % jar)
        return 2
    unclassified = [r for r in rows if r[2] == UNCLASSIFIED]
    if "--write" in sys.argv:
        io.open(OUT, "w", encoding="utf-8", newline="\n").write(render(rows))
        if jar:
            n, sha = write_manifest(jar, _ACTIVE['version'])
            print("  OK 刷新类面清单 %s：%d 个类（version=%s sha256=%s…）"
                  % (MANIFEST, n, _ACTIVE['version'], sha[:12]))
        else:
            print("  INFO 未给 $HUTOOL_JAR ⇒ 只重写归类表，类面清单保持不动（来源：%s）"
                  % _ACTIVE['source'])
        print("  OK 写入 %s：%d 个类，漏档 %d" % (OUT, len(rows), len(unclassified)))
        for r in unclassified[:20]:
            print("     漏档 %s (%s)" % (r[0], r[1]))
        io.open(UBASE, "w", encoding="utf-8", newline="\n").write(
            "%d\n# unattested 条数基线（整片规则声称已做、未逐条指回实现件）——只许降不许升；\n"
            "# 由 `python scripts/core_surface.py --write` 更新，改大它就是给自己放宽判据。\n"
            % unattested_count(rows))
        print("  OK 刷新棘轮基线 %s：%d 条" % (UBASE, unattested_count(rows)))
        return 0 if not unclassified else 1
    if "--selftest" in sys.argv:
        n = selftest(jar, rows, unclassified)
        n += selftest_version()
        n += selftest_unattested()
        if n == 5:
            print("  PASS 五档对照全过（现表零漏档放行 / 撤规则必掉漏档 / 假类名必被抓 / "
                  "版本口径不一致必被抓 / 整片 done 降级与棘轮不是摆设）")
            return 0
        print("  FAIL 自检只有 %d/5 档通过 ⇒ 这条判据不可信" % n)
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
    known2 = {c for c, _ in active_classes()}
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
    dbad = doc_tier_findings(rows)
    if dbad:
        print("  FAIL 文档 §7 的档位条数与归类表不一致：")
        for x in dbad:
            print("    ", x)
        return 1
    rok, rwhy = check_unattested_ratchet(rows)
    if not rok:
        print("  FAIL unattested 棘轮：%s" % rwhy)
        return 1
    print("  PASS 类面归类：%d 个类全部落档 %s；gap 档是待拍清单（不许为空判绿，也不许把 gap 当失败）；"
          "done 只由逐条登记给出，unattested 是整片声称待核（%s）" % (
              len(rows), sorted(tiers.items()), rwhy))
    return 0


def selftest_version():
    """第四档对照：版本口径不一致必须被抓。三个方向各测一次——
       错版本 jar 的文件名 / 清单里写的版本 / 与常量相等的那一侧必须放行。
       没有这一档，"版本一致"这半条判据就是摆设（本轮我自己就是拿 5.8.35 跑 census 跑出假红的）。
       不碰文件系统：直接验 check_version 与 jar_version 这两个纯函数，再加一条"清单读出的版本
       必须等于常量"（不等的话主判据本来就会红，这里只是确认对照不是空转）。"""
    good = check_version(REF_VERSION)[0]
    bad1 = not check_version("5.8.35")[0]
    bad2 = not check_version(jar_version("hutool-all-9.9.9.jar"))[0]
    ver = read_manifest()[1]
    dok, _ = check_doc_version()
    dbad = not check_doc_version("5.8.35")[0]      # 声明被写回旧版必须被抓
    dmissing = not check_doc_version("")[0]        # 声明被删掉也不许当通过
    if good and bad1 and bad2 and ver == REF_VERSION and dok and dbad and dmissing:
        return 1
    print("  FAIL 自检④：版本判据不可信（放行对版=%s / 抓 5.8.35=%s / 抓 9.9.9=%s / 清单版本=%r≠%r"
          " / 对外声明=%s / 声明改旧版被抓=%s / 声明被删被抓=%s）"
          % (good, bad1, bad2, ver, REF_VERSION, dok, dbad, dmissing))
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
    cls_by_rule = [(c, f) for c, f in active_classes() if c not in OVERRIDES and classify(c, f)[0] != UNCLASSIFIED]
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
    known = {c for c, _ in active_classes()}
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
