// 本文件的每一条期望都由 `scripts/gen_escape_family.py` 从参照腿灌入，**手打零条**。
// 腿：scripts/EscapeLeg.java（实体族/百分号族/UnicodeUtil 语料与闭环）、
//     scripts/EscapeLeg2.java（默认过滤器与实体表的逐码点扫、unescape 每条出口、真实文本档）、
//     scripts/EscapeLeg3.java（"谓词==行为"的 BMP 全枚举对撞 + 不转义区间表）、
//     scripts/EntityTableLeg.java（反射读四张实体表 + 数字实体/长键/别名择路）。
// 参照版本 hutool-all 5.8.37；判据口径见 docs/spec/01-text.md §1.16~§1.19。
// `show` / `cn_err` 两个 helper 在 `text/escape_err_test.mbt`（手工维护，本文件全生成）。
// 期望值冻结（AGENTS）：改这里任何一条都要单独一笔并给新的腿读数。

///|
test "text.escape #1.16 实体族逐条" {
  assert_eq(@text.escape_xml("a<b&c>d\"e'f"), "a&lt;b&amp;c&gt;d&quot;e&apos;f") // E|escapeXml|a<b&c>d"e'f|a&lt;b&amp;c&gt;d&quot;e&apos;f
  assert_eq(@text.unescape_xml("a<b&c>d\"e'f"), "a<b&c>d\"e'f") // E|unescapeXml|a<b&c>d"e'f|a<b&c>d"e'f
  assert_eq(@text.escape_html4("a<b&c>d\"e'f"), "a&lt;b&amp;c&gt;d&quot;e'f") // E|escapeHtml4|a<b&c>d"e'f|a&lt;b&amp;c&gt;d&quot;e'f
  assert_eq(@text.unescape_html4("a<b&c>d\"e'f"), "a<b&c>d\"e'f") // E|unescapeHtml4|a<b&c>d"e'f|a<b&c>d"e'f
  assert_eq(
    @text.escape_xml("<tag attr=\"v\">&amp;\u{4e2d}</tag>"),
    "&lt;tag attr=&quot;v&quot;&gt;&amp;amp;\u{4e2d}&lt;/tag&gt;",
  ) // E|escapeXml|<tag attr="v">&amp;{u4e2d}</tag>|&lt;tag attr=&quot;v&quot;&gt;&amp;amp;{u4e2d}&lt;/tag&gt;
  assert_eq(
    @text.unescape_xml("<tag attr=\"v\">&amp;\u{4e2d}</tag>"),
    "<tag attr=\"v\">&\u{4e2d}</tag>",
  ) // E|unescapeXml|<tag attr="v">&amp;{u4e2d}</tag>|<tag attr="v">&{u4e2d}</tag>
  assert_eq(
    @text.escape_html4("<tag attr=\"v\">&amp;\u{4e2d}</tag>"),
    "&lt;tag attr=&quot;v&quot;&gt;&amp;amp;\u{4e2d}&lt;/tag&gt;",
  ) // E|escapeHtml4|<tag attr="v">&amp;{u4e2d}</tag>|&lt;tag attr=&quot;v&quot;&gt;&amp;amp;{u4e2d}&lt;/tag&gt;
  assert_eq(
    @text.unescape_html4("<tag attr=\"v\">&amp;\u{4e2d}</tag>"),
    "<tag attr=\"v\">&\u{4e2d}</tag>",
  ) // E|unescapeHtml4|<tag attr="v">&amp;{u4e2d}</tag>|<tag attr="v">&{u4e2d}</tag>
  assert_eq(
    @text.escape_xml("&nbsp;&lt;&gt;&quot;&apos;&copy;&pound;"),
    "&amp;nbsp;&amp;lt;&amp;gt;&amp;quot;&amp;apos;&amp;copy;&amp;pound;",
  ) // E|escapeXml|&nbsp;&lt;&gt;&quot;&apos;&copy;&pound;|&amp;nbsp;&amp;lt;&amp;gt;&amp;quot;&amp;apos;&amp;copy;&amp;pound;
  assert_eq(
    @text.unescape_xml("&nbsp;&lt;&gt;&quot;&apos;&copy;&pound;"),
    "&nbsp;<>\"'&copy;&pound;",
  ) // E|unescapeXml|&nbsp;&lt;&gt;&quot;&apos;&copy;&pound;|&nbsp;<>"'&copy;&pound;
  assert_eq(
    @text.escape_html4("&nbsp;&lt;&gt;&quot;&apos;&copy;&pound;"),
    "&amp;nbsp;&amp;lt;&amp;gt;&amp;quot;&amp;apos;&amp;copy;&amp;pound;",
  ) // E|escapeHtml4|&nbsp;&lt;&gt;&quot;&apos;&copy;&pound;|&amp;nbsp;&amp;lt;&amp;gt;&amp;quot;&amp;apos;&amp;copy;&amp;pound;
  assert_eq(
    @text.unescape_html4("&nbsp;&lt;&gt;&quot;&apos;&copy;&pound;"),
    "\u{00a0}<>\"'\u{00a9}\u{00a3}",
  ) // E|unescapeHtml4|&nbsp;&lt;&gt;&quot;&apos;&copy;&pound;|{u00a0}<>"'{u00a9}{u00a3}
  assert_eq(
    @text.escape_xml("&#65;&#x41;&#X41;&#999;"),
    "&amp;#65;&amp;#x41;&amp;#X41;&amp;#999;",
  ) // E|escapeXml|&#65;&#x41;&#X41;&#999;|&amp;#65;&amp;#x41;&amp;#X41;&amp;#999;
  assert_eq(@text.unescape_xml("&#65;&#x41;&#X41;&#999;"), "AAA\u{03e7}") // E|unescapeXml|&#65;&#x41;&#X41;&#999;|AAA{u03e7}
  assert_eq(
    @text.escape_html4("&#65;&#x41;&#X41;&#999;"),
    "&amp;#65;&amp;#x41;&amp;#X41;&amp;#999;",
  ) // E|escapeHtml4|&#65;&#x41;&#X41;&#999;|&amp;#65;&amp;#x41;&amp;#X41;&amp;#999;
  assert_eq(@text.unescape_html4("&#65;&#x41;&#X41;&#999;"), "AAA\u{03e7}") // E|unescapeHtml4|&#65;&#x41;&#X41;&#999;|AAA{u03e7}
  assert_eq(@text.escape_xml("&amp;amp;"), "&amp;amp;amp;") // E|escapeXml|&amp;amp;|&amp;amp;amp;
  assert_eq(@text.unescape_xml("&amp;amp;"), "&amp;") // E|unescapeXml|&amp;amp;|&amp;
  assert_eq(@text.escape_html4("&amp;amp;"), "&amp;amp;amp;") // E|escapeHtml4|&amp;amp;|&amp;amp;amp;
  assert_eq(@text.unescape_html4("&amp;amp;"), "&amp;") // E|unescapeHtml4|&amp;amp;|&amp;
  assert_eq(@text.escape_xml("&notanentity;&amp"), "&amp;notanentity;&amp;amp") // E|escapeXml|&notanentity;&amp|&amp;notanentity;&amp;amp
  assert_eq(@text.unescape_xml("&notanentity;&amp"), "&notanentity;&amp") // E|unescapeXml|&notanentity;&amp|&notanentity;&amp
  assert_eq(
    @text.escape_html4("&notanentity;&amp"),
    "&amp;notanentity;&amp;amp",
  ) // E|escapeHtml4|&notanentity;&amp|&amp;notanentity;&amp;amp
  assert_eq(@text.unescape_html4("&notanentity;&amp"), "&notanentity;&amp") // E|unescapeHtml4|&notanentity;&amp|&notanentity;&amp
  assert_eq(@text.escape_xml("&#;&#xZZ;"), "&amp;#;&amp;#xZZ;") // E|escapeXml|&#;&#xZZ;|&amp;#;&amp;#xZZ;
  assert_eq(@text.unescape_xml("&#;&#xZZ;"), "&#;&#xZZ;") // E|unescapeXml|&#;&#xZZ;|&#;&#xZZ;
  assert_eq(@text.escape_html4("&#;&#xZZ;"), "&amp;#;&amp;#xZZ;") // E|escapeHtml4|&#;&#xZZ;|&amp;#;&amp;#xZZ;
  assert_eq(@text.unescape_html4("&#;&#xZZ;"), "&#;&#xZZ;") // E|unescapeHtml4|&#;&#xZZ;|&#;&#xZZ;
  assert_eq(
    @text.escape_xml("\u{4e2d}\u{6587}\u{2014}\u{2013}\u{300c}"),
    "\u{4e2d}\u{6587}\u{2014}\u{2013}\u{300c}",
  ) // E|escapeXml|{u4e2d}{u6587}{u2014}{u2013}{u300c}|{u4e2d}{u6587}{u2014}{u2013}{u300c}
  assert_eq(
    @text.unescape_xml("\u{4e2d}\u{6587}\u{2014}\u{2013}\u{300c}"),
    "\u{4e2d}\u{6587}\u{2014}\u{2013}\u{300c}",
  ) // E|unescapeXml|{u4e2d}{u6587}{u2014}{u2013}{u300c}|{u4e2d}{u6587}{u2014}{u2013}{u300c}
  assert_eq(
    @text.escape_html4("\u{4e2d}\u{6587}\u{2014}\u{2013}\u{300c}"),
    "\u{4e2d}\u{6587}&mdash;&ndash;\u{300c}",
  ) // E|escapeHtml4|{u4e2d}{u6587}{u2014}{u2013}{u300c}|{u4e2d}{u6587}&mdash;&ndash;{u300c}
  assert_eq(
    @text.unescape_html4("\u{4e2d}\u{6587}\u{2014}\u{2013}\u{300c}"),
    "\u{4e2d}\u{6587}\u{2014}\u{2013}\u{300c}",
  ) // E|unescapeHtml4|{u4e2d}{u6587}{u2014}{u2013}{u300c}|{u4e2d}{u6587}{u2014}{u2013}{u300c}
  assert_eq(@text.escape_xml("a\u{1f600}b"), "a\u{1f600}b") // E|escapeXml|a{ud83d}{ude00}b|a{ud83d}{ude00}b
  assert_eq(@text.unescape_xml("a\u{1f600}b"), "a\u{1f600}b") // E|unescapeXml|a{ud83d}{ude00}b|a{ud83d}{ude00}b
  assert_eq(@text.escape_html4("a\u{1f600}b"), "a\u{1f600}b") // E|escapeHtml4|a{ud83d}{ude00}b|a{ud83d}{ude00}b
  assert_eq(@text.unescape_html4("a\u{1f600}b"), "a\u{1f600}b") // E|unescapeHtml4|a{ud83d}{ude00}b|a{ud83d}{ude00}b
  assert_eq(@text.escape_xml(""), "") // E|escapeXml||
  assert_eq(@text.unescape_xml(""), "") // E|unescapeXml||
  assert_eq(@text.escape_html4(""), "") // E|escapeHtml4||
  assert_eq(@text.unescape_html4(""), "") // E|unescapeHtml4||
  assert_eq(
    @text.escape_xml("line1\u{000a}line2\u{0009}tab \u{000d}\u{000a}"),
    "line1\u{000a}line2\u{0009}tab \u{000d}\u{000a}",
  ) // E|escapeXml|line1{u000a}line2{u0009}tab {u000d}{u000a}|line1{u000a}line2{u0009}tab {u000d}{u000a}
  assert_eq(
    @text.unescape_xml("line1\u{000a}line2\u{0009}tab \u{000d}\u{000a}"),
    "line1\u{000a}line2\u{0009}tab \u{000d}\u{000a}",
  ) // E|unescapeXml|line1{u000a}line2{u0009}tab {u000d}{u000a}|line1{u000a}line2{u0009}tab {u000d}{u000a}
  assert_eq(
    @text.escape_html4("line1\u{000a}line2\u{0009}tab \u{000d}\u{000a}"),
    "line1\u{000a}line2\u{0009}tab \u{000d}\u{000a}",
  ) // E|escapeHtml4|line1{u000a}line2{u0009}tab {u000d}{u000a}|line1{u000a}line2{u0009}tab {u000d}{u000a}
  assert_eq(
    @text.unescape_html4("line1\u{000a}line2\u{0009}tab \u{000d}\u{000a}"),
    "line1\u{000a}line2\u{0009}tab \u{000d}\u{000a}",
  ) // E|unescapeHtml4|line1{u000a}line2{u0009}tab {u000d}{u000a}|line1{u000a}line2{u0009}tab {u000d}{u000a}
  assert_eq(
    @text.escape_xml("  leading and trailing  "),
    "  leading and trailing  ",
  ) // E|escapeXml|  leading and trailing  |  leading and trailing  
  assert_eq(
    @text.unescape_xml("  leading and trailing  "),
    "  leading and trailing  ",
  ) // E|unescapeXml|  leading and trailing  |  leading and trailing  
  assert_eq(
    @text.escape_html4("  leading and trailing  "),
    "  leading and trailing  ",
  ) // E|escapeHtml4|  leading and trailing  |  leading and trailing  
  assert_eq(
    @text.unescape_html4("  leading and trailing  "),
    "  leading and trailing  ",
  ) // E|unescapeHtml4|  leading and trailing  |  leading and trailing  
  assert_eq(@text.escape_xml("'\\\"\""), "&apos;\\&quot;&quot;") // E|escapeXml|'\""|&apos;\&quot;&quot;
  assert_eq(@text.unescape_xml("'\\\"\""), "'\\\"\"") // E|unescapeXml|'\""|'\""
  assert_eq(@text.escape_html4("'\\\"\""), "'\\&quot;&quot;") // E|escapeHtml4|'\""|'\&quot;&quot;
  assert_eq(@text.unescape_html4("'\\\"\""), "'\\\"\"") // E|unescapeHtml4|'\""|'\""
  assert_eq(@text.escape_xml("%41%E4%B8%AD"), "%41%E4%B8%AD") // E|escapeXml|%41%E4%B8%AD|%41%E4%B8%AD
  assert_eq(@text.unescape_xml("%41%E4%B8%AD"), "%41%E4%B8%AD") // E|unescapeXml|%41%E4%B8%AD|%41%E4%B8%AD
  assert_eq(@text.escape_html4("%41%E4%B8%AD"), "%41%E4%B8%AD") // E|escapeHtml4|%41%E4%B8%AD|%41%E4%B8%AD
  assert_eq(@text.unescape_html4("%41%E4%B8%AD"), "%41%E4%B8%AD") // E|unescapeHtml4|%41%E4%B8%AD|%41%E4%B8%AD
}

///|
test "text.escape #1.16 实体表逐位产出（S 行）" {
  assert_eq(@text.escape_xml("\u{0022}"), "&quot;") // S|escapeXml|u0022|&quot;
  assert_eq(@text.escape_html4("\u{0022}"), "&quot;") // S|escapeHtml4|u0022|&quot;
  assert_eq(@text.escape_xml("\u{0026}"), "&amp;") // S|escapeXml|u0026|&amp;
  assert_eq(@text.escape_html4("\u{0026}"), "&amp;") // S|escapeHtml4|u0026|&amp;
  assert_eq(@text.escape_xml("\u{0027}"), "&apos;") // S|escapeXml|u0027|&apos;
  assert_eq(@text.escape_xml("\u{003c}"), "&lt;") // S|escapeXml|u003c|&lt;
  assert_eq(@text.escape_html4("\u{003c}"), "&lt;") // S|escapeHtml4|u003c|&lt;
  assert_eq(@text.escape_xml("\u{003e}"), "&gt;") // S|escapeXml|u003e|&gt;
  assert_eq(@text.escape_html4("\u{003e}"), "&gt;") // S|escapeHtml4|u003e|&gt;
  assert_eq(@text.escape_html4("\u{00a0}"), "&nbsp;") // S|escapeHtml4|u00a0|&nbsp;
  assert_eq(@text.escape_html4("\u{00a1}"), "&iexcl;") // S|escapeHtml4|u00a1|&iexcl;
  assert_eq(@text.escape_html4("\u{00a2}"), "&cent;") // S|escapeHtml4|u00a2|&cent;
  assert_eq(@text.escape_html4("\u{00a3}"), "&pound;") // S|escapeHtml4|u00a3|&pound;
  assert_eq(@text.escape_html4("\u{00a4}"), "&curren;") // S|escapeHtml4|u00a4|&curren;
  assert_eq(@text.escape_html4("\u{00a5}"), "&yen;") // S|escapeHtml4|u00a5|&yen;
  assert_eq(@text.escape_html4("\u{00a6}"), "&brvbar;") // S|escapeHtml4|u00a6|&brvbar;
  assert_eq(@text.escape_html4("\u{00a7}"), "&sect;") // S|escapeHtml4|u00a7|&sect;
  assert_eq(@text.escape_html4("\u{00a8}"), "&uml;") // S|escapeHtml4|u00a8|&uml;
  assert_eq(@text.escape_html4("\u{00a9}"), "&copy;") // S|escapeHtml4|u00a9|&copy;
  assert_eq(@text.escape_html4("\u{00aa}"), "&ordf;") // S|escapeHtml4|u00aa|&ordf;
  assert_eq(@text.escape_html4("\u{00ab}"), "&laquo;") // S|escapeHtml4|u00ab|&laquo;
  assert_eq(@text.escape_html4("\u{00ac}"), "&not;") // S|escapeHtml4|u00ac|&not;
  assert_eq(@text.escape_html4("\u{00ad}"), "&shy;") // S|escapeHtml4|u00ad|&shy;
  assert_eq(@text.escape_html4("\u{00ae}"), "&reg;") // S|escapeHtml4|u00ae|&reg;
  assert_eq(@text.escape_html4("\u{00af}"), "&macr;") // S|escapeHtml4|u00af|&macr;
  assert_eq(@text.escape_html4("\u{00b0}"), "&deg;") // S|escapeHtml4|u00b0|&deg;
  assert_eq(@text.escape_html4("\u{00b1}"), "&plusmn;") // S|escapeHtml4|u00b1|&plusmn;
  assert_eq(@text.escape_html4("\u{00b2}"), "&sup2;") // S|escapeHtml4|u00b2|&sup2;
  assert_eq(@text.escape_html4("\u{00b3}"), "&sup3;") // S|escapeHtml4|u00b3|&sup3;
  assert_eq(@text.escape_html4("\u{00b4}"), "&acute;") // S|escapeHtml4|u00b4|&acute;
  assert_eq(@text.escape_html4("\u{00b5}"), "&micro;") // S|escapeHtml4|u00b5|&micro;
  assert_eq(@text.escape_html4("\u{00b6}"), "&para;") // S|escapeHtml4|u00b6|&para;
  assert_eq(@text.escape_html4("\u{00b7}"), "&middot;") // S|escapeHtml4|u00b7|&middot;
  assert_eq(@text.escape_html4("\u{00b8}"), "&cedil;") // S|escapeHtml4|u00b8|&cedil;
  assert_eq(@text.escape_html4("\u{00b9}"), "&sup1;") // S|escapeHtml4|u00b9|&sup1;
  assert_eq(@text.escape_html4("\u{00ba}"), "&ordm;") // S|escapeHtml4|u00ba|&ordm;
  assert_eq(@text.escape_html4("\u{00bb}"), "&raquo;") // S|escapeHtml4|u00bb|&raquo;
  assert_eq(@text.escape_html4("\u{00bc}"), "&frac14;") // S|escapeHtml4|u00bc|&frac14;
  assert_eq(@text.escape_html4("\u{00bd}"), "&frac12;") // S|escapeHtml4|u00bd|&frac12;
  assert_eq(@text.escape_html4("\u{00be}"), "&frac34;") // S|escapeHtml4|u00be|&frac34;
  assert_eq(@text.escape_html4("\u{00bf}"), "&iquest;") // S|escapeHtml4|u00bf|&iquest;
  assert_eq(@text.escape_html4("\u{00c0}"), "&Agrave;") // S|escapeHtml4|u00c0|&Agrave;
  assert_eq(@text.escape_html4("\u{00c1}"), "&Aacute;") // S|escapeHtml4|u00c1|&Aacute;
  assert_eq(@text.escape_html4("\u{00c2}"), "&Acirc;") // S|escapeHtml4|u00c2|&Acirc;
  assert_eq(@text.escape_html4("\u{00c3}"), "&Atilde;") // S|escapeHtml4|u00c3|&Atilde;
  assert_eq(@text.escape_html4("\u{00c4}"), "&Auml;") // S|escapeHtml4|u00c4|&Auml;
  assert_eq(@text.escape_html4("\u{00c5}"), "&Aring;") // S|escapeHtml4|u00c5|&Aring;
  assert_eq(@text.escape_html4("\u{00c6}"), "&AElig;") // S|escapeHtml4|u00c6|&AElig;
  assert_eq(@text.escape_html4("\u{00c7}"), "&Ccedil;") // S|escapeHtml4|u00c7|&Ccedil;
  assert_eq(@text.escape_html4("\u{00c8}"), "&Egrave;") // S|escapeHtml4|u00c8|&Egrave;
  assert_eq(@text.escape_html4("\u{00c9}"), "&Eacute;") // S|escapeHtml4|u00c9|&Eacute;
  assert_eq(@text.escape_html4("\u{00ca}"), "&Ecirc;") // S|escapeHtml4|u00ca|&Ecirc;
  assert_eq(@text.escape_html4("\u{00cb}"), "&Euml;") // S|escapeHtml4|u00cb|&Euml;
  assert_eq(@text.escape_html4("\u{00cc}"), "&Igrave;") // S|escapeHtml4|u00cc|&Igrave;
  assert_eq(@text.escape_html4("\u{00cd}"), "&Iacute;") // S|escapeHtml4|u00cd|&Iacute;
  assert_eq(@text.escape_html4("\u{00ce}"), "&Icirc;") // S|escapeHtml4|u00ce|&Icirc;
  assert_eq(@text.escape_html4("\u{00cf}"), "&Iuml;") // S|escapeHtml4|u00cf|&Iuml;
  assert_eq(@text.escape_html4("\u{00d0}"), "&ETH;") // S|escapeHtml4|u00d0|&ETH;
  assert_eq(@text.escape_html4("\u{00d1}"), "&Ntilde;") // S|escapeHtml4|u00d1|&Ntilde;
  assert_eq(@text.escape_html4("\u{00d2}"), "&Ograve;") // S|escapeHtml4|u00d2|&Ograve;
  assert_eq(@text.escape_html4("\u{00d3}"), "&Oacute;") // S|escapeHtml4|u00d3|&Oacute;
  assert_eq(@text.escape_html4("\u{00d4}"), "&Ocirc;") // S|escapeHtml4|u00d4|&Ocirc;
  assert_eq(@text.escape_html4("\u{00d5}"), "&Otilde;") // S|escapeHtml4|u00d5|&Otilde;
  assert_eq(@text.escape_html4("\u{00d6}"), "&Ouml;") // S|escapeHtml4|u00d6|&Ouml;
  assert_eq(@text.escape_html4("\u{00d7}"), "&times;") // S|escapeHtml4|u00d7|&times;
  assert_eq(@text.escape_html4("\u{00d8}"), "&Oslash;") // S|escapeHtml4|u00d8|&Oslash;
  assert_eq(@text.escape_html4("\u{00d9}"), "&Ugrave;") // S|escapeHtml4|u00d9|&Ugrave;
  assert_eq(@text.escape_html4("\u{00da}"), "&Uacute;") // S|escapeHtml4|u00da|&Uacute;
  assert_eq(@text.escape_html4("\u{00db}"), "&Ucirc;") // S|escapeHtml4|u00db|&Ucirc;
  assert_eq(@text.escape_html4("\u{00dc}"), "&Uuml;") // S|escapeHtml4|u00dc|&Uuml;
  assert_eq(@text.escape_html4("\u{00dd}"), "&Yacute;") // S|escapeHtml4|u00dd|&Yacute;
  assert_eq(@text.escape_html4("\u{00de}"), "&THORN;") // S|escapeHtml4|u00de|&THORN;
  assert_eq(@text.escape_html4("\u{00df}"), "&szlig;") // S|escapeHtml4|u00df|&szlig;
  assert_eq(@text.escape_html4("\u{00e0}"), "&agrave;") // S|escapeHtml4|u00e0|&agrave;
  assert_eq(@text.escape_html4("\u{00e1}"), "&aacute;") // S|escapeHtml4|u00e1|&aacute;
  assert_eq(@text.escape_html4("\u{00e2}"), "&acirc;") // S|escapeHtml4|u00e2|&acirc;
  assert_eq(@text.escape_html4("\u{00e3}"), "&atilde;") // S|escapeHtml4|u00e3|&atilde;
  assert_eq(@text.escape_html4("\u{00e4}"), "&auml;") // S|escapeHtml4|u00e4|&auml;
  assert_eq(@text.escape_html4("\u{00e5}"), "&aring;") // S|escapeHtml4|u00e5|&aring;
  assert_eq(@text.escape_html4("\u{00e6}"), "&aelig;") // S|escapeHtml4|u00e6|&aelig;
  assert_eq(@text.escape_html4("\u{00e7}"), "&ccedil;") // S|escapeHtml4|u00e7|&ccedil;
  assert_eq(@text.escape_html4("\u{00e8}"), "&egrave;") // S|escapeHtml4|u00e8|&egrave;
  assert_eq(@text.escape_html4("\u{00e9}"), "&eacute;") // S|escapeHtml4|u00e9|&eacute;
  assert_eq(@text.escape_html4("\u{00ea}"), "&ecirc;") // S|escapeHtml4|u00ea|&ecirc;
  assert_eq(@text.escape_html4("\u{00eb}"), "&euml;") // S|escapeHtml4|u00eb|&euml;
  assert_eq(@text.escape_html4("\u{00ec}"), "&igrave;") // S|escapeHtml4|u00ec|&igrave;
  assert_eq(@text.escape_html4("\u{00ed}"), "&iacute;") // S|escapeHtml4|u00ed|&iacute;
  assert_eq(@text.escape_html4("\u{00ee}"), "&icirc;") // S|escapeHtml4|u00ee|&icirc;
  assert_eq(@text.escape_html4("\u{00ef}"), "&iuml;") // S|escapeHtml4|u00ef|&iuml;
  assert_eq(@text.escape_html4("\u{00f0}"), "&eth;") // S|escapeHtml4|u00f0|&eth;
  assert_eq(@text.escape_html4("\u{00f1}"), "&ntilde;") // S|escapeHtml4|u00f1|&ntilde;
  assert_eq(@text.escape_html4("\u{00f2}"), "&ograve;") // S|escapeHtml4|u00f2|&ograve;
  assert_eq(@text.escape_html4("\u{00f3}"), "&oacute;") // S|escapeHtml4|u00f3|&oacute;
  assert_eq(@text.escape_html4("\u{00f4}"), "&ocirc;") // S|escapeHtml4|u00f4|&ocirc;
  assert_eq(@text.escape_html4("\u{00f5}"), "&otilde;") // S|escapeHtml4|u00f5|&otilde;
  assert_eq(@text.escape_html4("\u{00f6}"), "&ouml;") // S|escapeHtml4|u00f6|&ouml;
  assert_eq(@text.escape_html4("\u{00f7}"), "&divide;") // S|escapeHtml4|u00f7|&divide;
  assert_eq(@text.escape_html4("\u{00f8}"), "&oslash;") // S|escapeHtml4|u00f8|&oslash;
  assert_eq(@text.escape_html4("\u{00f9}"), "&ugrave;") // S|escapeHtml4|u00f9|&ugrave;
  assert_eq(@text.escape_html4("\u{00fa}"), "&uacute;") // S|escapeHtml4|u00fa|&uacute;
  assert_eq(@text.escape_html4("\u{00fb}"), "&ucirc;") // S|escapeHtml4|u00fb|&ucirc;
  assert_eq(@text.escape_html4("\u{00fc}"), "&uuml;") // S|escapeHtml4|u00fc|&uuml;
  assert_eq(@text.escape_html4("\u{00fd}"), "&yacute;") // S|escapeHtml4|u00fd|&yacute;
  assert_eq(@text.escape_html4("\u{00fe}"), "&thorn;") // S|escapeHtml4|u00fe|&thorn;
  assert_eq(@text.escape_html4("\u{00ff}"), "&yuml;") // S|escapeHtml4|u00ff|&yuml;
  assert_eq(@text.escape_html4("\u{0152}"), "&OElig;") // S|escapeHtml4|u0152|&OElig;
  assert_eq(@text.escape_html4("\u{0153}"), "&oelig;") // S|escapeHtml4|u0153|&oelig;
  assert_eq(@text.escape_html4("\u{0160}"), "&Scaron;") // S|escapeHtml4|u0160|&Scaron;
  assert_eq(@text.escape_html4("\u{0161}"), "&scaron;") // S|escapeHtml4|u0161|&scaron;
  assert_eq(@text.escape_html4("\u{0178}"), "&Yuml;") // S|escapeHtml4|u0178|&Yuml;
  assert_eq(@text.escape_html4("\u{0192}"), "&fnof;") // S|escapeHtml4|u0192|&fnof;
  assert_eq(@text.escape_html4("\u{02c6}"), "&circ;") // S|escapeHtml4|u02c6|&circ;
  assert_eq(@text.escape_html4("\u{02dc}"), "&tilde;") // S|escapeHtml4|u02dc|&tilde;
  assert_eq(@text.escape_html4("\u{0391}"), "&Alpha;") // S|escapeHtml4|u0391|&Alpha;
  assert_eq(@text.escape_html4("\u{0392}"), "&Beta;") // S|escapeHtml4|u0392|&Beta;
  assert_eq(@text.escape_html4("\u{0393}"), "&Gamma;") // S|escapeHtml4|u0393|&Gamma;
  assert_eq(@text.escape_html4("\u{0394}"), "&Delta;") // S|escapeHtml4|u0394|&Delta;
  assert_eq(@text.escape_html4("\u{0395}"), "&Epsilon;") // S|escapeHtml4|u0395|&Epsilon;
  assert_eq(@text.escape_html4("\u{0396}"), "&Zeta;") // S|escapeHtml4|u0396|&Zeta;
  assert_eq(@text.escape_html4("\u{0397}"), "&Eta;") // S|escapeHtml4|u0397|&Eta;
  assert_eq(@text.escape_html4("\u{0398}"), "&Theta;") // S|escapeHtml4|u0398|&Theta;
  assert_eq(@text.escape_html4("\u{0399}"), "&Iota;") // S|escapeHtml4|u0399|&Iota;
  assert_eq(@text.escape_html4("\u{039a}"), "&Kappa;") // S|escapeHtml4|u039a|&Kappa;
  assert_eq(@text.escape_html4("\u{039b}"), "&Lambda;") // S|escapeHtml4|u039b|&Lambda;
  assert_eq(@text.escape_html4("\u{039c}"), "&Mu;") // S|escapeHtml4|u039c|&Mu;
  assert_eq(@text.escape_html4("\u{039d}"), "&Nu;") // S|escapeHtml4|u039d|&Nu;
  assert_eq(@text.escape_html4("\u{039e}"), "&Xi;") // S|escapeHtml4|u039e|&Xi;
  assert_eq(@text.escape_html4("\u{039f}"), "&Omicron;") // S|escapeHtml4|u039f|&Omicron;
  assert_eq(@text.escape_html4("\u{03a0}"), "&Pi;") // S|escapeHtml4|u03a0|&Pi;
  assert_eq(@text.escape_html4("\u{03a1}"), "&Rho;") // S|escapeHtml4|u03a1|&Rho;
  assert_eq(@text.escape_html4("\u{03a3}"), "&Sigma;") // S|escapeHtml4|u03a3|&Sigma;
  assert_eq(@text.escape_html4("\u{03a4}"), "&Tau;") // S|escapeHtml4|u03a4|&Tau;
  assert_eq(@text.escape_html4("\u{03a5}"), "&Upsilon;") // S|escapeHtml4|u03a5|&Upsilon;
  assert_eq(@text.escape_html4("\u{03a6}"), "&Phi;") // S|escapeHtml4|u03a6|&Phi;
  assert_eq(@text.escape_html4("\u{03a7}"), "&Chi;") // S|escapeHtml4|u03a7|&Chi;
  assert_eq(@text.escape_html4("\u{03a8}"), "&Psi;") // S|escapeHtml4|u03a8|&Psi;
  assert_eq(@text.escape_html4("\u{03a9}"), "&Omega;") // S|escapeHtml4|u03a9|&Omega;
  assert_eq(@text.escape_html4("\u{03b1}"), "&alpha;") // S|escapeHtml4|u03b1|&alpha;
  assert_eq(@text.escape_html4("\u{03b2}"), "&beta;") // S|escapeHtml4|u03b2|&beta;
  assert_eq(@text.escape_html4("\u{03b3}"), "&gamma;") // S|escapeHtml4|u03b3|&gamma;
  assert_eq(@text.escape_html4("\u{03b4}"), "&delta;") // S|escapeHtml4|u03b4|&delta;
  assert_eq(@text.escape_html4("\u{03b5}"), "&epsilon;") // S|escapeHtml4|u03b5|&epsilon;
  assert_eq(@text.escape_html4("\u{03b6}"), "&zeta;") // S|escapeHtml4|u03b6|&zeta;
  assert_eq(@text.escape_html4("\u{03b7}"), "&eta;") // S|escapeHtml4|u03b7|&eta;
  assert_eq(@text.escape_html4("\u{03b8}"), "&theta;") // S|escapeHtml4|u03b8|&theta;
  assert_eq(@text.escape_html4("\u{03b9}"), "&iota;") // S|escapeHtml4|u03b9|&iota;
  assert_eq(@text.escape_html4("\u{03ba}"), "&kappa;") // S|escapeHtml4|u03ba|&kappa;
  assert_eq(@text.escape_html4("\u{03bb}"), "&lambda;") // S|escapeHtml4|u03bb|&lambda;
  assert_eq(@text.escape_html4("\u{03bc}"), "&mu;") // S|escapeHtml4|u03bc|&mu;
  assert_eq(@text.escape_html4("\u{03bd}"), "&nu;") // S|escapeHtml4|u03bd|&nu;
  assert_eq(@text.escape_html4("\u{03be}"), "&xi;") // S|escapeHtml4|u03be|&xi;
  assert_eq(@text.escape_html4("\u{03bf}"), "&omicron;") // S|escapeHtml4|u03bf|&omicron;
  assert_eq(@text.escape_html4("\u{03c0}"), "&pi;") // S|escapeHtml4|u03c0|&pi;
  assert_eq(@text.escape_html4("\u{03c1}"), "&rho;") // S|escapeHtml4|u03c1|&rho;
  assert_eq(@text.escape_html4("\u{03c2}"), "&sigmaf;") // S|escapeHtml4|u03c2|&sigmaf;
  assert_eq(@text.escape_html4("\u{03c3}"), "&sigma;") // S|escapeHtml4|u03c3|&sigma;
  assert_eq(@text.escape_html4("\u{03c4}"), "&tau;") // S|escapeHtml4|u03c4|&tau;
  assert_eq(@text.escape_html4("\u{03c5}"), "&upsilon;") // S|escapeHtml4|u03c5|&upsilon;
  assert_eq(@text.escape_html4("\u{03c6}"), "&phi;") // S|escapeHtml4|u03c6|&phi;
  assert_eq(@text.escape_html4("\u{03c7}"), "&chi;") // S|escapeHtml4|u03c7|&chi;
  assert_eq(@text.escape_html4("\u{03c8}"), "&psi;") // S|escapeHtml4|u03c8|&psi;
  assert_eq(@text.escape_html4("\u{03c9}"), "&omega;") // S|escapeHtml4|u03c9|&omega;
  assert_eq(@text.escape_html4("\u{03d1}"), "&thetasym;") // S|escapeHtml4|u03d1|&thetasym;
  assert_eq(@text.escape_html4("\u{03d2}"), "&upsih;") // S|escapeHtml4|u03d2|&upsih;
  assert_eq(@text.escape_html4("\u{03d6}"), "&piv;") // S|escapeHtml4|u03d6|&piv;
  assert_eq(@text.escape_html4("\u{2002}"), "&ensp;") // S|escapeHtml4|u2002|&ensp;
  assert_eq(@text.escape_html4("\u{2003}"), "&emsp;") // S|escapeHtml4|u2003|&emsp;
  assert_eq(@text.escape_html4("\u{2009}"), "&thinsp;") // S|escapeHtml4|u2009|&thinsp;
  assert_eq(@text.escape_html4("\u{200c}"), "&zwnj;") // S|escapeHtml4|u200c|&zwnj;
  assert_eq(@text.escape_html4("\u{200d}"), "&zwj;") // S|escapeHtml4|u200d|&zwj;
  assert_eq(@text.escape_html4("\u{200e}"), "&lrm;") // S|escapeHtml4|u200e|&lrm;
  assert_eq(@text.escape_html4("\u{200f}"), "&rlm;") // S|escapeHtml4|u200f|&rlm;
  assert_eq(@text.escape_html4("\u{2013}"), "&ndash;") // S|escapeHtml4|u2013|&ndash;
  assert_eq(@text.escape_html4("\u{2014}"), "&mdash;") // S|escapeHtml4|u2014|&mdash;
  assert_eq(@text.escape_html4("\u{2018}"), "&lsquo;") // S|escapeHtml4|u2018|&lsquo;
  assert_eq(@text.escape_html4("\u{2019}"), "&rsquo;") // S|escapeHtml4|u2019|&rsquo;
  assert_eq(@text.escape_html4("\u{201a}"), "&sbquo;") // S|escapeHtml4|u201a|&sbquo;
  assert_eq(@text.escape_html4("\u{201c}"), "&ldquo;") // S|escapeHtml4|u201c|&ldquo;
  assert_eq(@text.escape_html4("\u{201d}"), "&rdquo;") // S|escapeHtml4|u201d|&rdquo;
  assert_eq(@text.escape_html4("\u{201e}"), "&bdquo;") // S|escapeHtml4|u201e|&bdquo;
  assert_eq(@text.escape_html4("\u{2020}"), "&dagger;") // S|escapeHtml4|u2020|&dagger;
  assert_eq(@text.escape_html4("\u{2021}"), "&Dagger;") // S|escapeHtml4|u2021|&Dagger;
  assert_eq(@text.escape_html4("\u{2022}"), "&bull;") // S|escapeHtml4|u2022|&bull;
  assert_eq(@text.escape_html4("\u{2026}"), "&hellip;") // S|escapeHtml4|u2026|&hellip;
  assert_eq(@text.escape_html4("\u{2030}"), "&permil;") // S|escapeHtml4|u2030|&permil;
  assert_eq(@text.escape_html4("\u{2032}"), "&prime;") // S|escapeHtml4|u2032|&prime;
  assert_eq(@text.escape_html4("\u{2033}"), "&Prime;") // S|escapeHtml4|u2033|&Prime;
  assert_eq(@text.escape_html4("\u{2039}"), "&lsaquo;") // S|escapeHtml4|u2039|&lsaquo;
  assert_eq(@text.escape_html4("\u{203a}"), "&rsaquo;") // S|escapeHtml4|u203a|&rsaquo;
  assert_eq(@text.escape_html4("\u{203e}"), "&oline;") // S|escapeHtml4|u203e|&oline;
  assert_eq(@text.escape_html4("\u{2044}"), "&frasl;") // S|escapeHtml4|u2044|&frasl;
  assert_eq(@text.escape_html4("\u{20ac}"), "&euro;") // S|escapeHtml4|u20ac|&euro;
  assert_eq(@text.escape_html4("\u{2111}"), "&image;") // S|escapeHtml4|u2111|&image;
  assert_eq(@text.escape_html4("\u{2118}"), "&weierp;") // S|escapeHtml4|u2118|&weierp;
  assert_eq(@text.escape_html4("\u{211c}"), "&real;") // S|escapeHtml4|u211c|&real;
  assert_eq(@text.escape_html4("\u{2122}"), "&trade;") // S|escapeHtml4|u2122|&trade;
  assert_eq(@text.escape_html4("\u{2135}"), "&alefsym;") // S|escapeHtml4|u2135|&alefsym;
  assert_eq(@text.escape_html4("\u{2190}"), "&larr;") // S|escapeHtml4|u2190|&larr;
  assert_eq(@text.escape_html4("\u{2191}"), "&uarr;") // S|escapeHtml4|u2191|&uarr;
  assert_eq(@text.escape_html4("\u{2192}"), "&rarr;") // S|escapeHtml4|u2192|&rarr;
  assert_eq(@text.escape_html4("\u{2193}"), "&darr;") // S|escapeHtml4|u2193|&darr;
  assert_eq(@text.escape_html4("\u{2194}"), "&harr;") // S|escapeHtml4|u2194|&harr;
  assert_eq(@text.escape_html4("\u{21b5}"), "&crarr;") // S|escapeHtml4|u21b5|&crarr;
  assert_eq(@text.escape_html4("\u{21d0}"), "&lArr;") // S|escapeHtml4|u21d0|&lArr;
  assert_eq(@text.escape_html4("\u{21d1}"), "&uArr;") // S|escapeHtml4|u21d1|&uArr;
  assert_eq(@text.escape_html4("\u{21d2}"), "&rArr;") // S|escapeHtml4|u21d2|&rArr;
  assert_eq(@text.escape_html4("\u{21d3}"), "&dArr;") // S|escapeHtml4|u21d3|&dArr;
  assert_eq(@text.escape_html4("\u{21d4}"), "&hArr;") // S|escapeHtml4|u21d4|&hArr;
  assert_eq(@text.escape_html4("\u{2200}"), "&forall;") // S|escapeHtml4|u2200|&forall;
  assert_eq(@text.escape_html4("\u{2202}"), "&part;") // S|escapeHtml4|u2202|&part;
  assert_eq(@text.escape_html4("\u{2203}"), "&exist;") // S|escapeHtml4|u2203|&exist;
  assert_eq(@text.escape_html4("\u{2205}"), "&empty;") // S|escapeHtml4|u2205|&empty;
  assert_eq(@text.escape_html4("\u{2207}"), "&nabla;") // S|escapeHtml4|u2207|&nabla;
  assert_eq(@text.escape_html4("\u{2208}"), "&isin;") // S|escapeHtml4|u2208|&isin;
  assert_eq(@text.escape_html4("\u{2209}"), "&notin;") // S|escapeHtml4|u2209|&notin;
  assert_eq(@text.escape_html4("\u{220b}"), "&ni;") // S|escapeHtml4|u220b|&ni;
  assert_eq(@text.escape_html4("\u{220f}"), "&prod;") // S|escapeHtml4|u220f|&prod;
  assert_eq(@text.escape_html4("\u{2211}"), "&sum;") // S|escapeHtml4|u2211|&sum;
  assert_eq(@text.escape_html4("\u{2212}"), "&minus;") // S|escapeHtml4|u2212|&minus;
  assert_eq(@text.escape_html4("\u{2217}"), "&lowast;") // S|escapeHtml4|u2217|&lowast;
  assert_eq(@text.escape_html4("\u{221a}"), "&radic;") // S|escapeHtml4|u221a|&radic;
  assert_eq(@text.escape_html4("\u{221d}"), "&prop;") // S|escapeHtml4|u221d|&prop;
  assert_eq(@text.escape_html4("\u{221e}"), "&infin;") // S|escapeHtml4|u221e|&infin;
  assert_eq(@text.escape_html4("\u{2220}"), "&ang;") // S|escapeHtml4|u2220|&ang;
  assert_eq(@text.escape_html4("\u{2227}"), "&and;") // S|escapeHtml4|u2227|&and;
  assert_eq(@text.escape_html4("\u{2228}"), "&or;") // S|escapeHtml4|u2228|&or;
  assert_eq(@text.escape_html4("\u{2229}"), "&cap;") // S|escapeHtml4|u2229|&cap;
  assert_eq(@text.escape_html4("\u{222a}"), "&cup;") // S|escapeHtml4|u222a|&cup;
  assert_eq(@text.escape_html4("\u{222b}"), "&int;") // S|escapeHtml4|u222b|&int;
  assert_eq(@text.escape_html4("\u{2234}"), "&there4;") // S|escapeHtml4|u2234|&there4;
  assert_eq(@text.escape_html4("\u{223c}"), "&sim;") // S|escapeHtml4|u223c|&sim;
  assert_eq(@text.escape_html4("\u{2245}"), "&cong;") // S|escapeHtml4|u2245|&cong;
  assert_eq(@text.escape_html4("\u{2248}"), "&asymp;") // S|escapeHtml4|u2248|&asymp;
  assert_eq(@text.escape_html4("\u{2260}"), "&ne;") // S|escapeHtml4|u2260|&ne;
  assert_eq(@text.escape_html4("\u{2261}"), "&equiv;") // S|escapeHtml4|u2261|&equiv;
  assert_eq(@text.escape_html4("\u{2264}"), "&le;") // S|escapeHtml4|u2264|&le;
  assert_eq(@text.escape_html4("\u{2265}"), "&ge;") // S|escapeHtml4|u2265|&ge;
  assert_eq(@text.escape_html4("\u{2282}"), "&sub;") // S|escapeHtml4|u2282|&sub;
  assert_eq(@text.escape_html4("\u{2283}"), "&sup;") // S|escapeHtml4|u2283|&sup;
  assert_eq(@text.escape_html4("\u{2286}"), "&sube;") // S|escapeHtml4|u2286|&sube;
  assert_eq(@text.escape_html4("\u{2287}"), "&supe;") // S|escapeHtml4|u2287|&supe;
  assert_eq(@text.escape_html4("\u{2295}"), "&oplus;") // S|escapeHtml4|u2295|&oplus;
  assert_eq(@text.escape_html4("\u{2297}"), "&otimes;") // S|escapeHtml4|u2297|&otimes;
  assert_eq(@text.escape_html4("\u{22a5}"), "&perp;") // S|escapeHtml4|u22a5|&perp;
  assert_eq(@text.escape_html4("\u{22c5}"), "&sdot;") // S|escapeHtml4|u22c5|&sdot;
  assert_eq(@text.escape_html4("\u{2308}"), "&lceil;") // S|escapeHtml4|u2308|&lceil;
  assert_eq(@text.escape_html4("\u{2309}"), "&rceil;") // S|escapeHtml4|u2309|&rceil;
  assert_eq(@text.escape_html4("\u{230a}"), "&lfloor;") // S|escapeHtml4|u230a|&lfloor;
  assert_eq(@text.escape_html4("\u{230b}"), "&rfloor;") // S|escapeHtml4|u230b|&rfloor;
  assert_eq(@text.escape_html4("\u{2329}"), "&lang;") // S|escapeHtml4|u2329|&lang;
  assert_eq(@text.escape_html4("\u{232a}"), "&rang;") // S|escapeHtml4|u232a|&rang;
  assert_eq(@text.escape_html4("\u{25ca}"), "&loz;") // S|escapeHtml4|u25ca|&loz;
  assert_eq(@text.escape_html4("\u{2660}"), "&spades;") // S|escapeHtml4|u2660|&spades;
  assert_eq(@text.escape_html4("\u{2663}"), "&clubs;") // S|escapeHtml4|u2663|&clubs;
  assert_eq(@text.escape_html4("\u{2665}"), "&hearts;") // S|escapeHtml4|u2665|&hearts;
  assert_eq(@text.escape_html4("\u{2666}"), "&diams;") // S|escapeHtml4|u2666|&diams;
}

///|
test "text.escape #1.16 数字实体/长键/别名择路" {
  assert_eq(@text.unescape_xml("&amp;"), "&") // A|unescapeXml|&amp;|&
  assert_eq(@text.unescape_html4("&amp;"), "&") // A|unescapeHtml4|&amp;|&
  assert_eq(@text.unescape_xml("&AMP;"), "&AMP;") // A|unescapeXml|&AMP;|&AMP;
  assert_eq(@text.unescape_html4("&AMP;"), "&AMP;") // A|unescapeHtml4|&AMP;|&AMP;
  assert_eq(@text.unescape_xml("&QUOT;"), "&QUOT;") // A|unescapeXml|&QUOT;|&QUOT;
  assert_eq(@text.unescape_html4("&QUOT;"), "&QUOT;") // A|unescapeHtml4|&QUOT;|&QUOT;
  assert_eq(@text.unescape_xml("&NewLine;"), "&NewLine;") // A|unescapeXml|&NewLine;|&NewLine;
  assert_eq(@text.unescape_html4("&NewLine;"), "&NewLine;") // A|unescapeHtml4|&NewLine;|&NewLine;
  assert_eq(@text.unescape_xml("&#x41;"), "A") // A|unescapeXml|&#x41;|A
  assert_eq(@text.unescape_html4("&#x41;"), "A") // A|unescapeHtml4|&#x41;|A
  assert_eq(@text.unescape_xml("&#X41;"), "A") // A|unescapeXml|&#X41;|A
  assert_eq(@text.unescape_html4("&#X41;"), "A") // A|unescapeHtml4|&#X41;|A
  assert_eq(@text.unescape_xml("&nbsp;"), "&nbsp;") // A|unescapeXml|&nbsp;|&nbsp;
  assert_eq(@text.unescape_html4("&nbsp;"), "\u{00a0}") // A|unescapeHtml4|&nbsp;|{u00a0}
  assert_eq(@text.unescape_xml("&NBSP;"), "&NBSP;") // A|unescapeXml|&NBSP;|&NBSP;
  assert_eq(@text.unescape_html4("&NBSP;"), "&NBSP;") // A|unescapeHtml4|&NBSP;|&NBSP;
  assert_eq(@text.unescape_xml("&copy;"), "&copy;") // A|unescapeXml|&copy;|&copy;
  assert_eq(@text.unescape_html4("&copy;"), "\u{00a9}") // A|unescapeHtml4|&copy;|{u00a9}
  assert_eq(@text.unescape_xml("&COPY;"), "&COPY;") // A|unescapeXml|&COPY;|&COPY;
  assert_eq(@text.unescape_html4("&COPY;"), "&COPY;") // A|unescapeHtml4|&COPY;|&COPY;
  assert_eq(@text.unescape_xml("&or;"), "&or;") // A|unescapeXml|&or;|&or;
  assert_eq(@text.unescape_html4("&or;"), "\u{2228}") // A|unescapeHtml4|&or;|{u2228}
  assert_eq(@text.unescape_xml("&#65;"), "A") // N|unescapeXml|&#65;|A
  assert_eq(@text.unescape_html4("&#65;"), "A") // N|unescapeHtml4|&#65;|A
  assert_eq(@text.unescape_xml("&#x41;"), "A") // N|unescapeXml|&#x41;|A
  assert_eq(@text.unescape_html4("&#x41;"), "A") // N|unescapeHtml4|&#x41;|A
  assert_eq(@text.unescape_xml("&#X41;"), "A") // N|unescapeXml|&#X41;|A
  assert_eq(@text.unescape_html4("&#X41;"), "A") // N|unescapeHtml4|&#X41;|A
  assert_eq(@text.unescape_xml("&#0;"), "\u{0000}") // N|unescapeXml|&#0;|{u0000}
  assert_eq(@text.unescape_html4("&#0;"), "\u{0000}") // N|unescapeHtml4|&#0;|{u0000}
  assert_eq(@text.unescape_xml("&#127;"), "\u{007f}") // N|unescapeXml|&#127;|{u007f}
  assert_eq(@text.unescape_html4("&#127;"), "\u{007f}") // N|unescapeHtml4|&#127;|{u007f}
  assert_eq(@text.unescape_xml("&#128;"), "\u{0080}") // N|unescapeXml|&#128;|{u0080}
  assert_eq(@text.unescape_html4("&#128;"), "\u{0080}") // N|unescapeHtml4|&#128;|{u0080}
  assert_eq(@text.unescape_xml("&#x7FF;"), "\u{07ff}") // N|unescapeXml|&#x7FF;|{u07ff}
  assert_eq(@text.unescape_html4("&#x7FF;"), "\u{07ff}") // N|unescapeHtml4|&#x7FF;|{u07ff}
  assert_eq(@text.unescape_xml("&#x800;"), "\u{0800}") // N|unescapeXml|&#x800;|{u0800}
  assert_eq(@text.unescape_html4("&#x800;"), "\u{0800}") // N|unescapeHtml4|&#x800;|{u0800}
  assert_eq(@text.unescape_xml("&#xFFFF;"), "\u{ffff}") // N|unescapeXml|&#xFFFF;|{uffff}
  assert_eq(@text.unescape_html4("&#xFFFF;"), "\u{ffff}") // N|unescapeHtml4|&#xFFFF;|{uffff}
  assert_eq(@text.unescape_xml("&#x10000;"), "\u{0000}") // N|unescapeXml|&#x10000;|{u0000}
  assert_eq(@text.unescape_html4("&#x10000;"), "\u{0000}") // N|unescapeHtml4|&#x10000;|{u0000}
  assert_eq(cn_err(() => @text.unescape_xml("&#xD800;")), "LoneSurrogate 55296") // N|unescapeXml|&#xD800;|{ud800}
  assert_eq(
    cn_err(() => @text.unescape_html4("&#xD800;")),
    "LoneSurrogate 55296",
  ) // N|unescapeHtml4|&#xD800;|{ud800}
  assert_eq(cn_err(() => @text.unescape_xml("&#xDFFF;")), "LoneSurrogate 57343") // N|unescapeXml|&#xDFFF;|{udfff}
  assert_eq(
    cn_err(() => @text.unescape_html4("&#xDFFF;")),
    "LoneSurrogate 57343",
  ) // N|unescapeHtml4|&#xDFFF;|{udfff}
  assert_eq(@text.unescape_xml("&#xD83D;&#xDE00;"), "\u{1f600}") // N|unescapeXml|&#xD83D;&#xDE00;|{ud83d}{ude00}
  assert_eq(@text.unescape_html4("&#xD83D;&#xDE00;"), "\u{1f600}") // N|unescapeHtml4|&#xD83D;&#xDE00;|{ud83d}{ude00}
  assert_eq(@text.unescape_xml("&#0065;"), "A") // N|unescapeXml|&#0065;|A
  assert_eq(@text.unescape_html4("&#0065;"), "A") // N|unescapeHtml4|&#0065;|A
  assert_eq(@text.unescape_xml("&#0x41;"), "&#0x41;") // N|unescapeXml|&#0x41;|&#0x41;
  assert_eq(@text.unescape_html4("&#0x41;"), "&#0x41;") // N|unescapeHtml4|&#0x41;|&#0x41;
  assert_eq(@text.unescape_xml("&#;"), "&#;") // N|unescapeXml|&#;|&#;
  assert_eq(@text.unescape_html4("&#;"), "&#;") // N|unescapeHtml4|&#;|&#;
  assert_eq(@text.unescape_xml("&#x;"), "&#x;") // N|unescapeXml|&#x;|&#x;
  assert_eq(@text.unescape_html4("&#x;"), "&#x;") // N|unescapeHtml4|&#x;|&#x;
  assert_eq(@text.unescape_xml("&#ZZ;"), "&#ZZ;") // N|unescapeXml|&#ZZ;|&#ZZ;
  assert_eq(@text.unescape_html4("&#ZZ;"), "&#ZZ;") // N|unescapeHtml4|&#ZZ;|&#ZZ;
  assert_eq(@text.unescape_xml("&#xGG;"), "&#xGG;") // N|unescapeXml|&#xGG;|&#xGG;
  assert_eq(@text.unescape_html4("&#xGG;"), "&#xGG;") // N|unescapeHtml4|&#xGG;|&#xGG;
  assert_eq(@text.unescape_xml("&#65"), "&#65") // N|unescapeXml|&#65|&#65
  assert_eq(@text.unescape_html4("&#65"), "&#65") // N|unescapeHtml4|&#65|&#65
  assert_eq(@text.unescape_xml("&#x41"), "&#x41") // N|unescapeXml|&#x41|&#x41
  assert_eq(@text.unescape_html4("&#x41"), "&#x41") // N|unescapeHtml4|&#x41|&#x41
  assert_eq(@text.unescape_xml("&#99999999999;"), "&#99999999999;") // N|unescapeXml|&#99999999999;|&#99999999999;
  assert_eq(@text.unescape_html4("&#99999999999;"), "&#99999999999;") // N|unescapeHtml4|&#99999999999;|&#99999999999;
  assert_eq(@text.unescape_xml("&#xFFFFFFFF;"), "&#xFFFFFFFF;") // N|unescapeXml|&#xFFFFFFFF;|&#xFFFFFFFF;
  assert_eq(@text.unescape_html4("&#xFFFFFFFF;"), "&#xFFFFFFFF;") // N|unescapeHtml4|&#xFFFFFFFF;|&#xFFFFFFFF;
  assert_eq(@text.unescape_xml("&#"), "&#") // N|unescapeXml|&#|&#
  assert_eq(@text.unescape_html4("&#"), "&#") // N|unescapeHtml4|&#|&#
  assert_eq(@text.unescape_xml("&#"), "&#") // N|unescapeXml|&#|&#
  assert_eq(@text.unescape_html4("&#"), "&#") // N|unescapeHtml4|&#|&#
  assert_eq(@text.unescape_xml("a&#65;b"), "aAb") // N|unescapeXml|a&#65;b|aAb
  assert_eq(@text.unescape_html4("a&#65;b"), "aAb") // N|unescapeHtml4|a&#65;b|aAb
  assert_eq(@text.unescape_xml("&#65;&#66;"), "AB") // N|unescapeXml|&#65;&#66;|AB
  assert_eq(@text.unescape_html4("&#65;&#66;"), "AB") // N|unescapeHtml4|&#65;&#66;|AB
  assert_eq(@text.unescape_xml("&# 65;"), "&# 65;") // N|unescapeXml|&# 65;|&# 65;
  assert_eq(@text.unescape_html4("&# 65;"), "&# 65;") // N|unescapeHtml4|&# 65;|&# 65;
  assert_eq(@text.unescape_xml("&#6 5;"), "&#6 5;") // N|unescapeXml|&#6 5;|&#6 5;
  assert_eq(@text.unescape_html4("&#6 5;"), "&#6 5;") // N|unescapeHtml4|&#6 5;|&#6 5;
  assert_eq(@text.unescape_xml("&#6;"), "\u{0006}") // N|unescapeXml|&#6;|{u0006}
  assert_eq(@text.unescape_html4("&#6;"), "\u{0006}") // N|unescapeHtml4|&#6;|{u0006}
  assert_eq(@text.unescape_xml("&#1000000;"), "\u{4240}") // N|unescapeXml|&#1000000;|{u4240}
  assert_eq(@text.unescape_html4("&#1000000;"), "\u{4240}") // N|unescapeHtml4|&#1000000;|{u4240}
  assert_eq(@text.unescape_xml("&Lt;"), "&Lt;") // M|unescapeXml|&Lt;|&Lt;
  assert_eq(@text.unescape_html4("&Lt;"), "&Lt;") // M|unescapeHtml4|&Lt;|&Lt;
  assert_eq(@text.escape_xml("&Lt;"), "&amp;Lt;") // M|escapeXml|&Lt;|&amp;Lt;
  assert_eq(@text.unescape_xml("&LT;"), "&LT;") // M|unescapeXml|&LT;|&LT;
  assert_eq(@text.unescape_html4("&LT;"), "&LT;") // M|unescapeHtml4|&LT;|&LT;
  assert_eq(@text.escape_xml("&LT;"), "&amp;LT;") // M|escapeXml|&LT;|&amp;LT;
  assert_eq(@text.unescape_xml("&lT;"), "&lT;") // M|unescapeXml|&lT;|&lT;
  assert_eq(@text.unescape_html4("&lT;"), "&lT;") // M|unescapeHtml4|&lT;|&lT;
  assert_eq(@text.escape_xml("&lT;"), "&amp;lT;") // M|escapeXml|&lT;|&amp;lT;
  assert_eq(@text.unescape_xml("&AMPamp;"), "&AMPamp;") // M|unescapeXml|&AMPamp;|&AMPamp;
  assert_eq(@text.unescape_html4("&AMPamp;"), "&AMPamp;") // M|unescapeHtml4|&AMPamp;|&AMPamp;
  assert_eq(@text.escape_xml("&AMPamp;"), "&amp;AMPamp;") // M|escapeXml|&AMPamp;|&amp;AMPamp;
  assert_eq(@text.unescape_xml("&notit;"), "&notit;") // M|unescapeXml|&notit;|&notit;
  assert_eq(@text.unescape_html4("&notit;"), "&notit;") // M|unescapeHtml4|&notit;|&notit;
  assert_eq(@text.escape_xml("&notit;"), "&amp;notit;") // M|escapeXml|&notit;|&amp;notit;
  assert_eq(@text.unescape_xml("&notin;"), "&notin;") // M|unescapeXml|&notin;|&notin;
  assert_eq(@text.unescape_html4("&notin;"), "\u{2209}") // M|unescapeHtml4|&notin;|{u2209}
  assert_eq(@text.escape_xml("&notin;"), "&amp;notin;") // M|escapeXml|&notin;|&amp;notin;
  assert_eq(@text.unescape_xml("&sup;"), "&sup;") // M|unescapeXml|&sup;|&sup;
  assert_eq(@text.unescape_html4("&sup;"), "\u{2283}") // M|unescapeHtml4|&sup;|{u2283}
  assert_eq(@text.escape_xml("&sup;"), "&amp;sup;") // M|escapeXml|&sup;|&amp;sup;
  assert_eq(@text.unescape_xml("&Sup;"), "&Sup;") // M|unescapeXml|&Sup;|&Sup;
  assert_eq(@text.unescape_html4("&Sup;"), "&Sup;") // M|unescapeHtml4|&Sup;|&Sup;
  assert_eq(@text.escape_xml("&Sup;"), "&amp;Sup;") // M|escapeXml|&Sup;|&amp;Sup;
  assert_eq(@text.unescape_xml("&forall;"), "&forall;") // M|unescapeXml|&forall;|&forall;
  assert_eq(@text.unescape_html4("&forall;"), "\u{2200}") // M|unescapeHtml4|&forall;|{u2200}
  assert_eq(@text.escape_xml("&forall;"), "&amp;forall;") // M|escapeXml|&forall;|&amp;forall;
  assert_eq(@text.unescape_xml("&ForAll;"), "&ForAll;") // M|unescapeXml|&ForAll;|&ForAll;
  assert_eq(@text.unescape_html4("&ForAll;"), "&ForAll;") // M|unescapeHtml4|&ForAll;|&ForAll;
  assert_eq(@text.escape_xml("&ForAll;"), "&amp;ForAll;") // M|escapeXml|&ForAll;|&amp;ForAll;
  assert_eq(@text.unescape_xml("&amp&;"), "&amp&;") // M|unescapeXml|&amp&;|&amp&;
  assert_eq(@text.unescape_html4("&amp&;"), "&amp&;") // M|unescapeHtml4|&amp&;|&amp&;
  assert_eq(@text.escape_xml("&amp&;"), "&amp;amp&amp;;") // M|escapeXml|&amp&;|&amp;amp&amp;;
  assert_eq(@text.unescape_xml("&&amp;"), "&&") // M|unescapeXml|&&amp;|&&
  assert_eq(@text.unescape_html4("&&amp;"), "&&") // M|unescapeHtml4|&&amp;|&&
  assert_eq(@text.escape_xml("&&amp;"), "&amp;&amp;amp;") // M|escapeXml|&&amp;|&amp;&amp;amp;
  assert_eq(@text.unescape_xml("&amp;;"), "&;") // M|unescapeXml|&amp;;|&;
  assert_eq(@text.unescape_html4("&amp;;"), "&;") // M|unescapeHtml4|&amp;;|&;
  assert_eq(@text.escape_xml("&amp;;"), "&amp;amp;;") // M|escapeXml|&amp;;|&amp;amp;;
  assert_eq(@text.unescape_xml("&nbsp&nbsp;"), "&nbsp&nbsp;") // M|unescapeXml|&nbsp&nbsp;|&nbsp&nbsp;
  assert_eq(@text.unescape_html4("&nbsp&nbsp;"), "&nbsp\u{00a0}") // M|unescapeHtml4|&nbsp&nbsp;|&nbsp{u00a0}
  assert_eq(@text.escape_xml("&nbsp&nbsp;"), "&amp;nbsp&amp;nbsp;") // M|escapeXml|&nbsp&nbsp;|&amp;nbsp&amp;nbsp;
  assert_eq(@text.unescape_xml("&lt;&gt;&amp;"), "<>&") // M|unescapeXml|&lt;&gt;&amp;|<>&
  assert_eq(@text.unescape_html4("&lt;&gt;&amp;"), "<>&") // M|unescapeHtml4|&lt;&gt;&amp;|<>&
  assert_eq(@text.escape_xml("&lt;&gt;&amp;"), "&amp;lt;&amp;gt;&amp;amp;") // M|escapeXml|&lt;&gt;&amp;|&amp;lt;&amp;gt;&amp;amp;
  assert_eq(
    @text.unescape_xml("&CounterClockwiseContourIntegral;"),
    "&CounterClockwiseContourIntegral;",
  ) // M|unescapeXml|&CounterClockwiseContourIntegral;|&CounterClockwiseContourIntegral;
  assert_eq(
    @text.unescape_html4("&CounterClockwiseContourIntegral;"),
    "&CounterClockwiseContourIntegral;",
  ) // M|unescapeHtml4|&CounterClockwiseContourIntegral;|&CounterClockwiseContourIntegral;
  assert_eq(
    @text.escape_xml("&CounterClockwiseContourIntegral;"),
    "&amp;CounterClockwiseContourIntegral;",
  ) // M|escapeXml|&CounterClockwiseContourIntegral;|&amp;CounterClockwiseContourIntegral;
  assert_eq(@text.unescape_xml("&fjlig;"), "&fjlig;") // M|unescapeXml|&fjlig;|&fjlig;
  assert_eq(@text.unescape_html4("&fjlig;"), "&fjlig;") // M|unescapeHtml4|&fjlig;|&fjlig;
  assert_eq(@text.escape_xml("&fjlig;"), "&amp;fjlig;") // M|escapeXml|&fjlig;|&amp;fjlig;
  assert_eq(
    @text.unescape_html4("&CounterClockwiseContourIntegral;"),
    "&CounterClockwiseContourIntegral;",
  ) // L|unescapeHtml4|&CounterClockwiseContourIntegral;|&CounterClockwiseContourIntegral;
  assert_eq(
    @text.unescape_xml("&CounterClockwiseContourIntegral;"),
    "&CounterClockwiseContourIntegral;",
  ) // L|unescapeXml|&CounterClockwiseContourIntegral;|&CounterClockwiseContourIntegral;
  assert_eq(
    @text.unescape_html4("&ClockwiseContourIntegral;"),
    "&ClockwiseContourIntegral;",
  ) // L|unescapeHtml4|&ClockwiseContourIntegral;|&ClockwiseContourIntegral;
  assert_eq(
    @text.unescape_xml("&ClockwiseContourIntegral;"),
    "&ClockwiseContourIntegral;",
  ) // L|unescapeXml|&ClockwiseContourIntegral;|&ClockwiseContourIntegral;
  assert_eq(@text.unescape_html4("&not;"), "\u{00ac}") // L|unescapeHtml4|&not;|{u00ac}
  assert_eq(@text.unescape_xml("&not;"), "&not;") // L|unescapeXml|&not;|&not;
  assert_eq(@text.unescape_html4("&notin;"), "\u{2209}") // L|unescapeHtml4|&notin;|{u2209}
  assert_eq(@text.unescape_xml("&notin;"), "&notin;") // L|unescapeXml|&notin;|&notin;
  assert_eq(@text.unescape_html4("&ni;"), "\u{220b}") // L|unescapeHtml4|&ni;|{u220b}
  assert_eq(@text.unescape_xml("&ni;"), "&ni;") // L|unescapeXml|&ni;|&ni;
  assert_eq(@text.unescape_html4("&ngE;"), "&ngE;") // L|unescapeHtml4|&ngE;|&ngE;
  assert_eq(@text.unescape_xml("&ngE;"), "&ngE;") // L|unescapeXml|&ngE;|&ngE;
  assert_eq(@text.unescape_html4("&nGt;"), "&nGt;") // L|unescapeHtml4|&nGt;|&nGt;
  assert_eq(@text.unescape_xml("&nGt;"), "&nGt;") // L|unescapeXml|&nGt;|&nGt;
  assert_eq(@text.unescape_html4("&gt;"), ">") // L|unescapeHtml4|&gt;|>
  assert_eq(@text.unescape_xml("&gt;"), ">") // L|unescapeXml|&gt;|>
  assert_eq(@text.unescape_html4("&Gt;"), "&Gt;") // L|unescapeHtml4|&Gt;|&Gt;
  assert_eq(@text.unescape_xml("&Gt;"), "&Gt;") // L|unescapeXml|&Gt;|&Gt;
  assert_eq(@text.unescape_html4("&Gg;"), "&Gg;") // L|unescapeHtml4|&Gg;|&Gg;
  assert_eq(@text.unescape_xml("&Gg;"), "&Gg;") // L|unescapeXml|&Gg;|&Gg;
  assert_eq(@text.unescape_html4("&gg;"), "&gg;") // L|unescapeHtml4|&gg;|&gg;
  assert_eq(@text.unescape_xml("&gg;"), "&gg;") // L|unescapeXml|&gg;|&gg;
}

///|
test "text.escape #1.17 escape_by 的过滤器四档" {
  assert_eq(
    @text.escape_by("abc ABC 123", _c => true),
    "%61%62%63%20%41%42%43%20%31%32%33",
  ) // P|escape(filterKeepAll)|abc ABC 123|%61%62%63%20%41%42%43%20%31%32%33
  assert_eq(@text.escape_by("abc ABC 123", _c => false), "abc ABC 123") // P|escape(filterKeepNone)|abc ABC 123|abc ABC 123
  assert_eq(
    @text.escape_by("abc ABC 123", c => c.is_ascii_alphabetic()),
    "%61%62%63 %41%42%43 123",
  ) // P|escape(filterAsciiAlpha)|abc ABC 123|%61%62%63 %41%42%43 123
  assert_eq(
    @text.escape_by("*@-_.+/ !", _c => true),
    "%2a%40%2d%5f%2e%2b%2f%20%21",
  ) // P|escape(filterKeepAll)|*@-_.+/ !|%2a%40%2d%5f%2e%2b%2f%20%21
  assert_eq(@text.escape_by("*@-_.+/ !", _c => false), "*@-_.+/ !") // P|escape(filterKeepNone)|*@-_.+/ !|*@-_.+/ !
  assert_eq(
    @text.escape_by("*@-_.+/ !", c => c.is_ascii_alphabetic()),
    "*@-_.+/ !",
  ) // P|escape(filterAsciiAlpha)|*@-_.+/ !|*@-_.+/ !
  assert_eq(
    @text.escape_by("\u{4e2d}\u{6587} a", _c => true),
    "%u4e2d%u6587%20%61",
  ) // P|escape(filterKeepAll)|{u4e2d}{u6587} a|%u4e2d%u6587%20%61
  assert_eq(
    @text.escape_by("\u{4e2d}\u{6587} a", _c => false),
    "\u{4e2d}\u{6587} a",
  ) // P|escape(filterKeepNone)|{u4e2d}{u6587} a|{u4e2d}{u6587} a
  assert_eq(
    @text.escape_by("\u{4e2d}\u{6587} a", c => c.is_ascii_alphabetic()),
    "\u{4e2d}\u{6587} %61",
  ) // P|escape(filterAsciiAlpha)|{u4e2d}{u6587} a|{u4e2d}{u6587} %61
  assert_eq(@text.escape_by("\u{1f600}", _c => true), "%ud83d%ude00") // P|escape(filterKeepAll)|{ud83d}{ude00}|%ud83d%ude00
  assert_eq(@text.escape_by("\u{1f600}", _c => false), "\u{1f600}") // P|escape(filterKeepNone)|{ud83d}{ude00}|{ud83d}{ude00}
  assert_eq(
    @text.escape_by("\u{1f600}", c => c.is_ascii_alphabetic()),
    "\u{1f600}",
  ) // P|escape(filterAsciiAlpha)|{ud83d}{ude00}|{ud83d}{ude00}
  assert_eq(@text.escape_by("", _c => true), "") // P|escape(filterKeepAll)||
  assert_eq(@text.escape_by("", _c => false), "") // P|escape(filterKeepNone)||
  assert_eq(@text.escape_by("", c => c.is_ascii_alphabetic()), "") // P|escape(filterAsciiAlpha)||
  assert_eq(@text.escape_by("%41", _c => true), "%25%34%31") // P|escape(filterKeepAll)|%41|%25%34%31
  assert_eq(@text.escape_by("%41", _c => false), "%41") // P|escape(filterKeepNone)|%41|%41
  assert_eq(@text.escape_by("%41", c => c.is_ascii_alphabetic()), "%41") // P|escape(filterAsciiAlpha)|%41|%41
  assert_eq(
    @text.escape_by("~`!@#$%^&*()_+-=[]\u{007b}\u{007d}\\|;':\",./<>?", _c => {
      true
    }),
    "%7e%60%21%40%23%24%25%5e%26%2a%28%29%5f%2b%2d%3d%5b%5d%7b%7d%5c%7c%3b%27%3a%22%2c%2e%2f%3c%3e%3f",
  ) // P|escape(filterKeepAll)|~`!@#$%^&*()_+-=[]{}\{u007c};':",./<>?|%7e%60%21%40%23%24%25%5e%26%2a%28%29%5f%2b%2d%3d%5b%5d%7b%7d%5c%7c%3b%27%3a%22%2c%2e%2f%3c%3e%3f
  assert_eq(
    @text.escape_by("~`!@#$%^&*()_+-=[]\u{007b}\u{007d}\\|;':\",./<>?", _c => {
      false
    }),
    "~`!@#$%^&*()_+-=[]\u{007b}\u{007d}\\|;':\",./<>?",
  ) // P|escape(filterKeepNone)|~`!@#$%^&*()_+-=[]{}\{u007c};':",./<>?|~`!@#$%^&*()_+-=[]{}\{u007c};':",./<>?
  assert_eq(
    @text.escape_by("~`!@#$%^&*()_+-=[]\u{007b}\u{007d}\\|;':\",./<>?", c => {
      c.is_ascii_alphabetic()
    }),
    "~`!@#$%^&*()_+-=[]\u{007b}\u{007d}\\|;':\",./<>?",
  ) // P|escape(filterAsciiAlpha)|~`!@#$%^&*()_+-=[]{}\{u007c};':",./<>?|~`!@#$%^&*()_+-=[]{}\{u007c};':",./<>?
  assert_eq(
    @text.escape_by("abc ABC 123", c => {
      !(c.is_ascii_alphabetic() || c.is_ascii_digit())
    }),
    "abc%20ABC%20123",
  ) // P|escape(filterNotAlnum)|abc ABC 123|abc%20ABC%20123
  assert_eq(
    @text.escape_by("*@-_.+/ !", c => {
      !(c.is_ascii_alphabetic() || c.is_ascii_digit())
    }),
    "%2a%40%2d%5f%2e%2b%2f%20%21",
  ) // P|escape(filterNotAlnum)|*@-_.+/ !|%2a%40%2d%5f%2e%2b%2f%20%21
  assert_eq(
    @text.escape_by("\u{4e2d}\u{6587} a", c => {
      !(c.is_ascii_alphabetic() || c.is_ascii_digit())
    }),
    "%u4e2d%u6587%20a",
  ) // P|escape(filterNotAlnum)|{u4e2d}{u6587} a|%u4e2d%u6587%20a
  assert_eq(
    @text.escape_by("\u{1f600}", c => {
      !(c.is_ascii_alphabetic() || c.is_ascii_digit())
    }),
    "%ud83d%ude00",
  ) // P|escape(filterNotAlnum)|{ud83d}{ude00}|%ud83d%ude00
  assert_eq(
    @text.escape_by("", c => !(c.is_ascii_alphabetic() || c.is_ascii_digit())),
    "",
  ) // P|escape(filterNotAlnum)||
  assert_eq(
    @text.escape_by("%41", c => !(c.is_ascii_alphabetic() || c.is_ascii_digit())),
    "%2541",
  ) // P|escape(filterNotAlnum)|%41|%2541
  assert_eq(
    @text.escape_by("~`!@#$%^&*()_+-=[]\u{007b}\u{007d}\\|;':\",./<>?", c => {
      !(c.is_ascii_alphabetic() || c.is_ascii_digit())
    }),
    "%7e%60%21%40%23%24%25%5e%26%2a%28%29%5f%2b%2d%3d%5b%5d%7b%7d%5c%7c%3b%27%3a%22%2c%2e%2f%3c%3e%3f",
  ) // P|escape(filterNotAlnum)|~`!@#$%^&*()_+-=[]{}\{u007c};':",./<>?|%7e%60%21%40%23%24%25%5e%26%2a%28%29%5f%2b%2d%3d%5b%5d%7b%7d%5c%7c%3b%27%3a%22%2c%2e%2f%3c%3e%3f
}

///|
test "text.escape #1.17 百分号族逐条" {
  assert_eq(@text.escape("abc ABC 123"), "abc%20ABC%20123") // P|escape|abc ABC 123|abc%20ABC%20123
  assert_eq(
    @text.escape_all("abc ABC 123"),
    "%61%62%63%20%41%42%43%20%31%32%33",
  ) // P|escapeAll|abc ABC 123|%61%62%63%20%41%42%43%20%31%32%33
  assert_eq(@text.unescape("abc ABC 123"), "abc ABC 123") // P|unescape|abc ABC 123|abc ABC 123
  assert_eq(@text.safe_unescape("abc ABC 123"), "abc ABC 123") // P|safeUnescape|abc ABC 123|abc ABC 123
  assert_eq(@text.escape("*@-_.+/ !"), "*@-_.+/%20%21") // P|escape|*@-_.+/ !|*@-_.+/%20%21
  assert_eq(@text.escape_all("*@-_.+/ !"), "%2a%40%2d%5f%2e%2b%2f%20%21") // P|escapeAll|*@-_.+/ !|%2a%40%2d%5f%2e%2b%2f%20%21
  assert_eq(@text.unescape("*@-_.+/ !"), "*@-_.+/ !") // P|unescape|*@-_.+/ !|*@-_.+/ !
  assert_eq(@text.safe_unescape("*@-_.+/ !"), "*@-_.+/ !") // P|safeUnescape|*@-_.+/ !|*@-_.+/ !
  assert_eq(@text.escape("\u{4e2d}\u{6587} a"), "%u4e2d%u6587%20a") // P|escape|{u4e2d}{u6587} a|%u4e2d%u6587%20a
  assert_eq(@text.escape_all("\u{4e2d}\u{6587} a"), "%u4e2d%u6587%20%61") // P|escapeAll|{u4e2d}{u6587} a|%u4e2d%u6587%20%61
  assert_eq(@text.unescape("\u{4e2d}\u{6587} a"), "\u{4e2d}\u{6587} a") // P|unescape|{u4e2d}{u6587} a|{u4e2d}{u6587} a
  assert_eq(@text.safe_unescape("\u{4e2d}\u{6587} a"), "\u{4e2d}\u{6587} a") // P|safeUnescape|{u4e2d}{u6587} a|{u4e2d}{u6587} a
  assert_eq(@text.escape("\u{1f600}"), "%ud83d%ude00") // P|escape|{ud83d}{ude00}|%ud83d%ude00
  assert_eq(@text.escape_all("\u{1f600}"), "%ud83d%ude00") // P|escapeAll|{ud83d}{ude00}|%ud83d%ude00
  assert_eq(@text.unescape("\u{1f600}"), "\u{1f600}") // P|unescape|{ud83d}{ude00}|{ud83d}{ude00}
  assert_eq(@text.safe_unescape("\u{1f600}"), "\u{1f600}") // P|safeUnescape|{ud83d}{ude00}|{ud83d}{ude00}
  assert_eq(@text.escape(""), "") // P|escape||
  assert_eq(@text.escape_all(""), "") // P|escapeAll||
  assert_eq(@text.unescape(""), "") // P|unescape||
  assert_eq(@text.safe_unescape(""), "") // P|safeUnescape||
  assert_eq(@text.escape("%41"), "%2541") // P|escape|%41|%2541
  assert_eq(@text.escape_all("%41"), "%25%34%31") // P|escapeAll|%41|%25%34%31
  assert_eq(@text.unescape("%41"), "A") // P|unescape|%41|A
  assert_eq(@text.safe_unescape("%41"), "A") // P|safeUnescape|%41|A
  assert_eq(
    @text.escape("~`!@#$%^&*()_+-=[]\u{007b}\u{007d}\\|;':\",./<>?"),
    "%7e%60%21@%23%24%25%5e%26*%28%29_+-%3d%5b%5d%7b%7d%5c%7c%3b%27%3a%22%2c./%3c%3e%3f",
  ) // P|escape|~`!@#$%^&*()_+-=[]{}\{u007c};':",./<>?|%7e%60%21@%23%24%25%5e%26*%28%29_+-%3d%5b%5d%7b%7d%5c%7c%3b%27%3a%22%2c./%3c%3e%3f
  assert_eq(
    @text.escape_all("~`!@#$%^&*()_+-=[]\u{007b}\u{007d}\\|;':\",./<>?"),
    "%7e%60%21%40%23%24%25%5e%26%2a%28%29%5f%2b%2d%3d%5b%5d%7b%7d%5c%7c%3b%27%3a%22%2c%2e%2f%3c%3e%3f",
  ) // P|escapeAll|~`!@#$%^&*()_+-=[]{}\{u007c};':",./<>?|%7e%60%21%40%23%24%25%5e%26%2a%28%29%5f%2b%2d%3d%5b%5d%7b%7d%5c%7c%3b%27%3a%22%2c%2e%2f%3c%3e%3f
  assert_eq(
    cn_err(() => {
      @text.unescape("~`!@#$%^&*()_+-=[]\u{007b}\u{007d}\\|;':\",./<>?")
    }),
    "BadHex ^&",
  ) // P|unescape|~`!@#$%^&*()_+-=[]{}\{u007c};':",./<>?|ERR:NumberFormatException:For input string: "^&" under radix 16
  assert_eq(
    @text.safe_unescape("~`!@#$%^&*()_+-=[]\u{007b}\u{007d}\\|;':\",./<>?"),
    "~`!@#$%^&*()_+-=[]\u{007b}\u{007d}\\|;':\",./<>?",
  ) // P|safeUnescape|~`!@#$%^&*()_+-=[]{}\{u007c};':",./<>?|~`!@#$%^&*()_+-=[]{}\{u007c};':",./<>?
  assert_eq(@text.unescape("%41"), "A") // UN|unescape|%41|A
  assert_eq(@text.safe_unescape("%41"), "A") // UN|safeUnescape|%41|A
  assert_eq(@text.unescape("%41%42"), "AB") // UN|unescape|%41%42|AB
  assert_eq(@text.safe_unescape("%41%42"), "AB") // UN|safeUnescape|%41%42|AB
  assert_eq(@text.unescape("%u4e2d"), "\u{4e2d}") // UN|unescape|%u4e2d|{u4e2d}
  assert_eq(@text.safe_unescape("%u4e2d"), "\u{4e2d}") // UN|safeUnescape|%u4e2d|{u4e2d}
  assert_eq(@text.unescape("%u4E2D"), "\u{4e2d}") // UN|unescape|%u4E2D|{u4e2d}
  assert_eq(@text.safe_unescape("%u4E2D"), "\u{4e2d}") // UN|safeUnescape|%u4E2D|{u4e2d}
  assert_eq(@text.unescape("%u0041%u0042"), "AB") // UN|unescape|%u0041%u0042|AB
  assert_eq(@text.safe_unescape("%u0041%u0042"), "AB") // UN|safeUnescape|%u0041%u0042|AB
  assert_eq(@text.unescape("%4e2d"), "N2d") // UN|unescape|%4e2d|N2d
  assert_eq(@text.safe_unescape("%4e2d"), "N2d") // UN|safeUnescape|%4e2d|N2d
  assert_eq(cn_err(() => @text.unescape("%")), "ShortInput") // UN|unescape|%|ERR:StringIndexOutOfBoundsException:String index out of range: 1
  assert_eq(@text.safe_unescape("%"), "%") // UN|safeUnescape|%|%
  assert_eq(cn_err(() => @text.unescape("%2")), "ShortInput") // UN|unescape|%2|ERR:StringIndexOutOfBoundsException:begin 1, end 3, length 2
  assert_eq(@text.safe_unescape("%2"), "%2") // UN|safeUnescape|%2|%2
  assert_eq(cn_err(() => @text.unescape("%zz")), "BadHex zz") // UN|unescape|%zz|ERR:NumberFormatException:For input string: "zz" under radix 16
  assert_eq(@text.safe_unescape("%zz"), "%zz") // UN|safeUnescape|%zz|%zz
  assert_eq(cn_err(() => @text.unescape("%4")), "ShortInput") // UN|unescape|%4|ERR:StringIndexOutOfBoundsException:begin 1, end 3, length 2
  assert_eq(@text.safe_unescape("%4"), "%4") // UN|safeUnescape|%4|%4
  assert_eq(@text.unescape("abc%41def"), "abcAdef") // UN|unescape|abc%41def|abcAdef
  assert_eq(@text.safe_unescape("abc%41def"), "abcAdef") // UN|safeUnescape|abc%41def|abcAdef
  assert_eq(cn_err(() => @text.unescape("100%")), "ShortInput") // UN|unescape|100%|ERR:StringIndexOutOfBoundsException:String index out of range: 4
  assert_eq(@text.safe_unescape("100%"), "100%") // UN|safeUnescape|100%|100%
  assert_eq(@text.unescape("%25"), "%") // UN|unescape|%25|%
  assert_eq(@text.safe_unescape("%25"), "%") // UN|safeUnescape|%25|%
  assert_eq(@text.unescape("%2541"), "%41") // UN|unescape|%2541|%41
  assert_eq(@text.safe_unescape("%2541"), "%41") // UN|safeUnescape|%2541|%41
  assert_eq(@text.unescape("+"), "+") // UN|unescape|+|+
  assert_eq(@text.safe_unescape("+"), "+") // UN|safeUnescape|+|+
  assert_eq(@text.unescape("%2b"), "+") // UN|unescape|%2b|+
  assert_eq(@text.safe_unescape("%2b"), "+") // UN|safeUnescape|%2b|+
  assert_eq(@text.unescape("%0a"), "\u{000a}") // UN|unescape|%0a|{u000a}
  assert_eq(@text.safe_unescape("%0a"), "\u{000a}") // UN|safeUnescape|%0a|{u000a}
  assert_eq(@text.unescape("%0d%0a"), "\u{000d}\u{000a}") // UN|unescape|%0d%0a|{u000d}{u000a}
  assert_eq(@text.safe_unescape("%0d%0a"), "\u{000d}\u{000a}") // UN|safeUnescape|%0d%0a|{u000d}{u000a}
  assert_eq(@text.unescape("%ff"), "\u{00ff}") // UN|unescape|%ff|{u00ff}
  assert_eq(@text.safe_unescape("%ff"), "\u{00ff}") // UN|safeUnescape|%ff|{u00ff}
  assert_eq(@text.unescape("%80"), "\u{0080}") // UN|unescape|%80|{u0080}
  assert_eq(@text.safe_unescape("%80"), "\u{0080}") // UN|safeUnescape|%80|{u0080}
  assert_eq(@text.unescape("%c3%28"), "\u{00c3}(") // UN|unescape|%c3%28|{u00c3}(
  assert_eq(@text.safe_unescape("%c3%28"), "\u{00c3}(") // UN|safeUnescape|%c3%28|{u00c3}(
  assert_eq(@text.unescape("%e4%b8%ad"), "\u{00e4}\u{00b8}\u{00ad}") // UN|unescape|%e4%b8%ad|{u00e4}{u00b8}{u00ad}
  assert_eq(@text.safe_unescape("%e4%b8%ad"), "\u{00e4}\u{00b8}\u{00ad}") // UN|safeUnescape|%e4%b8%ad|{u00e4}{u00b8}{u00ad}
  assert_eq(@text.unescape("%uD83D%uDE00"), "\u{1f600}") // UN|unescape|%uD83D%uDE00|{ud83d}{ude00}
  assert_eq(@text.safe_unescape("%uD83D%uDE00"), "\u{1f600}") // UN|safeUnescape|%uD83D%uDE00|{ud83d}{ude00}
  assert_eq(@text.unescape("%3c%3e"), "<>") // UN|unescape|%3c%3e|<>
  assert_eq(@text.safe_unescape("%3c%3e"), "<>") // UN|safeUnescape|%3c%3e|<>
  assert_eq(@text.unescape("%20"), " ") // UN|unescape|%20| 
  assert_eq(@text.safe_unescape("%20"), " ") // UN|safeUnescape|%20| 
  assert_eq(@text.unescape("%25u4e2d"), "%u4e2d") // UN|unescape|%25u4e2d|%u4e2d
  assert_eq(@text.safe_unescape("%25u4e2d"), "%u4e2d") // UN|safeUnescape|%25u4e2d|%u4e2d
  assert_eq(@text.unescape(""), "") // UN|unescape||
  assert_eq(@text.safe_unescape(""), "") // UN|safeUnescape||
  assert_eq(@text.unescape("%2f"), "/") // UN|unescape|%2f|/
  assert_eq(@text.safe_unescape("%2f"), "/") // UN|safeUnescape|%2f|/
  assert_eq(@text.unescape("%2F"), "/") // UN|unescape|%2F|/
  assert_eq(@text.safe_unescape("%2F"), "/") // UN|safeUnescape|%2F|/
}

///|
test "text.unicode #1.18 UnicodeUtil 逐档" {
  assert_eq(@text.unicode_to_string("\\u4e2d\\u6587"), "\u{4e2d}\u{6587}") // U|toString|\u4e2d\u6587|{u4e2d}{u6587}
  assert_eq(@text.to_unicode("\\u4e2d\\u6587"), "\\u4e2d\\u6587") // U|toUnicode|\u4e2d\u6587|\u4e2d\u6587
  assert_eq(@text.to_unicode("\\u4e2d\\u6587"), "\\u4e2d\\u6587") // U|toUnicode(true)|\u4e2d\u6587|\u4e2d\u6587
  assert_eq(
    @text.to_unicode_all("\\u4e2d\\u6587"),
    "\\u005c\\u0075\\u0034\\u0065\\u0032\\u0064\\u005c\\u0075\\u0036\\u0035\\u0038\\u0037",
  ) // U|toUnicode(false)|\u4e2d\u6587|\u005c\u0075\u0034\u0065\u0032\u0064\u005c\u0075\u0036\u0035\u0038\u0037
  assert_eq(@text.unicode_to_string("\\uD83D\\uDE00"), "\u{1f600}") // U|toString|\uD83D\uDE00|{ud83d}{ude00}
  assert_eq(@text.to_unicode("\\uD83D\\uDE00"), "\\uD83D\\uDE00") // U|toUnicode|\uD83D\uDE00|\uD83D\uDE00
  assert_eq(@text.to_unicode("\\uD83D\\uDE00"), "\\uD83D\\uDE00") // U|toUnicode(true)|\uD83D\uDE00|\uD83D\uDE00
  assert_eq(
    @text.to_unicode_all("\\uD83D\\uDE00"),
    "\\u005c\\u0075\\u0044\\u0038\\u0033\\u0044\\u005c\\u0075\\u0044\\u0045\\u0030\\u0030",
  ) // U|toUnicode(false)|\uD83D\uDE00|\u005c\u0075\u0044\u0038\u0033\u0044\u005c\u0075\u0044\u0045\u0030\u0030
  assert_eq(@text.unicode_to_string("\\u0041\\u0042"), "AB") // U|toString|\u0041\u0042|AB
  assert_eq(@text.to_unicode("\\u0041\\u0042"), "\\u0041\\u0042") // U|toUnicode|\u0041\u0042|\u0041\u0042
  assert_eq(@text.to_unicode("\\u0041\\u0042"), "\\u0041\\u0042") // U|toUnicode(true)|\u0041\u0042|\u0041\u0042
  assert_eq(
    @text.to_unicode_all("\\u0041\\u0042"),
    "\\u005c\\u0075\\u0030\\u0030\\u0034\\u0031\\u005c\\u0075\\u0030\\u0030\\u0034\\u0032",
  ) // U|toUnicode(false)|\u0041\u0042|\u005c\u0075\u0030\u0030\u0034\u0031\u005c\u0075\u0030\u0030\u0034\u0032
  assert_eq(@text.unicode_to_string("\\uZZZZ\\u12"), "\\uZZZZ\\u12") // U|toString|\uZZZZ\u12|\uZZZZ\u12
  assert_eq(@text.to_unicode("\\uZZZZ\\u12"), "\\uZZZZ\\u12") // U|toUnicode|\uZZZZ\u12|\uZZZZ\u12
  assert_eq(@text.to_unicode("\\uZZZZ\\u12"), "\\uZZZZ\\u12") // U|toUnicode(true)|\uZZZZ\u12|\uZZZZ\u12
  assert_eq(
    @text.to_unicode_all("\\uZZZZ\\u12"),
    "\\u005c\\u0075\\u005a\\u005a\\u005a\\u005a\\u005c\\u0075\\u0031\\u0032",
  ) // U|toUnicode(false)|\uZZZZ\u12|\u005c\u0075\u005a\u005a\u005a\u005a\u005c\u0075\u0031\u0032
  assert_eq(@text.unicode_to_string("\\u"), "\\u") // U|toString|\u|\u
  assert_eq(@text.to_unicode("\\u"), "\\u") // U|toUnicode|\u|\u
  assert_eq(@text.to_unicode("\\u"), "\\u") // U|toUnicode(true)|\u|\u
  assert_eq(@text.to_unicode_all("\\u"), "\\u005c\\u0075") // U|toUnicode(false)|\u|\u005c\u0075
  assert_eq(@text.unicode_to_string("no escapes"), "no escapes") // U|toString|no escapes|no escapes
  assert_eq(@text.to_unicode("no escapes"), "no escapes") // U|toUnicode|no escapes|no escapes
  assert_eq(@text.to_unicode("no escapes"), "no escapes") // U|toUnicode(true)|no escapes|no escapes
  assert_eq(
    @text.to_unicode_all("no escapes"),
    "\\u006e\\u006f\\u0020\\u0065\\u0073\\u0063\\u0061\\u0070\\u0065\\u0073",
  ) // U|toUnicode(false)|no escapes|\u006e\u006f\u0020\u0065\u0073\u0063\u0061\u0070\u0065\u0073
  assert_eq(@text.unicode_to_string("\\\\u4e2d"), "\\\u{4e2d}") // U|toString|\\u4e2d|\{u4e2d}
  assert_eq(@text.to_unicode("\\\\u4e2d"), "\\\\u4e2d") // U|toUnicode|\\u4e2d|\\u4e2d
  assert_eq(@text.to_unicode("\\\\u4e2d"), "\\\\u4e2d") // U|toUnicode(true)|\\u4e2d|\\u4e2d
  assert_eq(
    @text.to_unicode_all("\\\\u4e2d"),
    "\\u005c\\u005c\\u0075\\u0034\\u0065\\u0032\\u0064",
  ) // U|toUnicode(false)|\\u4e2d|\u005c\u005c\u0075\u0034\u0065\u0032\u0064
  assert_eq(@text.unicode_to_string("\\"), "\\") // U|toString|\|\
  assert_eq(@text.to_unicode("\\"), "\\") // U|toUnicode|\|\
  assert_eq(@text.to_unicode("\\"), "\\") // U|toUnicode(true)|\|\
  assert_eq(@text.to_unicode_all("\\"), "\\u005c") // U|toUnicode(false)|\|\u005c
  assert_eq(@text.unicode_to_string("\\u0000\\u0009"), "\u{0000}\u{0009}") // U|toString|\u0000\u0009|{u0000}{u0009}
  assert_eq(@text.to_unicode("\\u0000\\u0009"), "\\u0000\\u0009") // U|toUnicode|\u0000\u0009|\u0000\u0009
  assert_eq(@text.to_unicode("\\u0000\\u0009"), "\\u0000\\u0009") // U|toUnicode(true)|\u0000\u0009|\u0000\u0009
  assert_eq(
    @text.to_unicode_all("\\u0000\\u0009"),
    "\\u005c\\u0075\\u0030\\u0030\\u0030\\u0030\\u005c\\u0075\\u0030\\u0030\\u0030\\u0039",
  ) // U|toUnicode(false)|\u0000\u0009|\u005c\u0075\u0030\u0030\u0030\u0030\u005c\u0075\u0030\u0030\u0030\u0039
  assert_eq(@text.unicode_to_string("\\uFFFF"), "\u{ffff}") // U|toString|\uFFFF|{uffff}
  assert_eq(@text.to_unicode("\\uFFFF"), "\\uFFFF") // U|toUnicode|\uFFFF|\uFFFF
  assert_eq(@text.to_unicode("\\uFFFF"), "\\uFFFF") // U|toUnicode(true)|\uFFFF|\uFFFF
  assert_eq(
    @text.to_unicode_all("\\uFFFF"),
    "\\u005c\\u0075\\u0046\\u0046\\u0046\\u0046",
  ) // U|toUnicode(false)|\uFFFF|\u005c\u0075\u0046\u0046\u0046\u0046
  assert_eq(@text.unicode_to_string("x\\u4e2dy"), "x\u{4e2d}y") // U|toString|x\u4e2dy|x{u4e2d}y
  assert_eq(@text.to_unicode("x\\u4e2dy"), "x\\u4e2dy") // U|toUnicode|x\u4e2dy|x\u4e2dy
  assert_eq(@text.to_unicode("x\\u4e2dy"), "x\\u4e2dy") // U|toUnicode(true)|x\u4e2dy|x\u4e2dy
  assert_eq(
    @text.to_unicode_all("x\\u4e2dy"),
    "\\u0078\\u005c\\u0075\\u0034\\u0065\\u0032\\u0064\\u0079",
  ) // U|toUnicode(false)|x\u4e2dy|\u0078\u005c\u0075\u0034\u0065\u0032\u0064\u0079
  assert_eq(@text.unicode_to_string(""), "") // U|toString||
  assert_eq(@text.to_unicode(""), "") // U|toUnicode||
  assert_eq(@text.to_unicode(""), "") // U|toUnicode(true)||
  assert_eq(@text.to_unicode_all(""), "") // U|toUnicode(false)||
  assert_eq(@text.unicode_to_string("\\u4e2d"), "\u{4e2d}") // R|toString|\u4e2d|{u4e2d}
  assert_eq(
    cn_err(() => @text.unicode_to_string("\\uD83D")),
    "LoneSurrogate 55357",
  ) // R|toString|\uD83D|{ud83d}
  assert_eq(
    cn_err(() => @text.unicode_to_string("\\uDC00")),
    "LoneSurrogate 56320",
  ) // R|toString|\uDC00|{udc00}
  assert_eq(@text.unicode_to_string("\\uD83D\\uDE00"), "\u{1f600}") // R|toString|\uD83D\uDE00|{ud83d}{ude00}
  assert_eq(@text.unicode_to_string("\\u4e2"), "\\u4e2") // R|toString|\u4e2|\u4e2
  assert_eq(@text.unicode_to_string("\\u12345"), "\u{1234}5") // R|toString|\u12345|{u1234}5
  assert_eq(@text.unicode_to_string("\\\\u4e2d"), "\\\u{4e2d}") // R|toString|\\u4e2d|\{u4e2d}
  assert_eq(@text.unicode_to_string("\\uZZZZ"), "\\uZZZZ") // R|toString|\uZZZZ|\uZZZZ
  assert_eq(@text.unicode_to_string("\\u0000"), "\u{0000}") // R|toString|\u0000|{u0000}
  assert_eq(@text.unicode_to_string("\\uffff"), "\u{ffff}") // R|toString|\uffff|{uffff}
  assert_eq(@text.unicode_to_string("\\uFFFF"), "\u{ffff}") // R|toString|\uFFFF|{uffff}
  assert_eq(@text.unicode_to_string("\\u8000"), "\u{8000}") // R|toString|\u8000|{u8000}
  assert_eq(@text.unicode_to_string("\\u8fff"), "\u{8fff}") // R|toString|\u8fff|{u8fff}
  assert_eq(@text.unicode_to_string("x\\u4e2dy"), "x\u{4e2d}y") // R|toString|x\u4e2dy|x{u4e2d}y
  assert_eq(@text.unicode_to_string("\\u4e"), "\\u4e") // R|toString|\u4e|\u4e
  assert_eq(@text.unicode_to_string("\\u4e2d\\"), "\u{4e2d}\\") // R|toString|\u4e2d\|{u4e2d}\
}

///|
test "text.unicode #1.18 unicode_of 逐码点（char/int 两侧同读数）" {
  assert_eq(@text.unicode_of(0), "\\u0000") // N|toUnicode(int)|int:0|\u0000
  assert_eq(@text.unicode_of(0), "\\u0000") // N|toUnicode(char)|char:0|\u0000
  assert_eq(@text.unicode_of(9), "\\u0009") // N|toUnicode(int)|int:9|\u0009
  assert_eq(@text.unicode_of(9), "\\u0009") // N|toUnicode(char)|char:9|\u0009
  assert_eq(@text.unicode_of(32), "\\u0020") // N|toUnicode(int)|int:32|\u0020
  assert_eq(@text.unicode_of(32), "\\u0020") // N|toUnicode(char)|char:32|\u0020
  assert_eq(@text.unicode_of(65), "\\u0041") // N|toUnicode(int)|int:65|\u0041
  assert_eq(@text.unicode_of(65), "\\u0041") // N|toUnicode(char)|char:65|\u0041
  assert_eq(@text.unicode_of(127), "\\u007f") // N|toUnicode(int)|int:127|\u007f
  assert_eq(@text.unicode_of(127), "\\u007f") // N|toUnicode(char)|char:127|\u007f
  assert_eq(@text.unicode_of(128), "\\u0080") // N|toUnicode(int)|int:128|\u0080
  assert_eq(@text.unicode_of(128), "\\u0080") // N|toUnicode(char)|char:128|\u0080
  assert_eq(@text.unicode_of(255), "\\u00ff") // N|toUnicode(int)|int:255|\u00ff
  assert_eq(@text.unicode_of(255), "\\u00ff") // N|toUnicode(char)|char:255|\u00ff
  assert_eq(@text.unicode_of(8192), "\\u2000") // N|toUnicode(int)|int:8192|\u2000
  assert_eq(@text.unicode_of(8192), "\\u2000") // N|toUnicode(char)|char:8192|\u2000
  assert_eq(@text.unicode_of(20013), "\\u4e2d") // N|toUnicode(int)|int:20013|\u4e2d
  assert_eq(@text.unicode_of(20013), "\\u4e2d") // N|toUnicode(char)|char:20013|\u4e2d
  assert_eq(@text.unicode_of(55296), "\\ud800") // N|toUnicode(int)|int:55296|\ud800
  assert_eq(@text.unicode_of(55296), "\\ud800") // N|toUnicode(char)|char:55296|\ud800
  assert_eq(@text.unicode_of(57343), "\\udfff") // N|toUnicode(int)|int:57343|\udfff
  assert_eq(@text.unicode_of(57343), "\\udfff") // N|toUnicode(char)|char:57343|\udfff
  assert_eq(@text.unicode_of(65535), "\\uffff") // N|toUnicode(int)|int:65535|\uffff
  assert_eq(@text.unicode_of(65535), "\\uffff") // N|toUnicode(char)|char:65535|\uffff
  assert_eq(@text.unicode_of(65536), "\\u10000") // N|toUnicode(int)|int:65536|\u10000
  assert_eq(@text.unicode_of(128512), "\\u1f600") // N|toUnicode(int)|int:128512|\u1f600
  assert_eq(@text.unicode_of(-1), "\\uffffffff") // N|toUnicode(int)|int:-1|\uffffffff
  assert_eq(@text.unicode_of(2147483647), "\\u7fffffff") // N|toUnicode(int)|int:2147483647|\u7fffffff
}

///|
test "text.unicode #1.18 闭环（to_unicode ∘ unicode_to_string）" {
  assert_eq(
    @text.unicode_to_string(@text.to_unicode("\\u4e2d\\u6587")),
    "\u{4e2d}\u{6587}",
  ) // I|roundtrip|\u4e2d\u6587|{u4e2d}{u6587}
  assert_eq(
    @text.unicode_to_string(@text.to_unicode("\\u4e2d\\u6587")),
    "\u{4e2d}\u{6587}",
  ) // I|roundtrip(true)|\u4e2d\u6587|{u4e2d}{u6587}
  assert_eq(
    @text.unicode_to_string(@text.to_unicode("\\uD83D\\uDE00")),
    "\u{1f600}",
  ) // I|roundtrip|\uD83D\uDE00|{ud83d}{ude00}
  assert_eq(
    @text.unicode_to_string(@text.to_unicode("\\uD83D\\uDE00")),
    "\u{1f600}",
  ) // I|roundtrip(true)|\uD83D\uDE00|{ud83d}{ude00}
  assert_eq(@text.unicode_to_string(@text.to_unicode("\\u0041\\u0042")), "AB") // I|roundtrip|\u0041\u0042|AB
  assert_eq(@text.unicode_to_string(@text.to_unicode("\\u0041\\u0042")), "AB") // I|roundtrip(true)|\u0041\u0042|AB
  assert_eq(
    @text.unicode_to_string(@text.to_unicode("\\uZZZZ\\u12")),
    "\\uZZZZ\\u12",
  ) // I|roundtrip|\uZZZZ\u12|\uZZZZ\u12
  assert_eq(
    @text.unicode_to_string(@text.to_unicode("\\uZZZZ\\u12")),
    "\\uZZZZ\\u12",
  ) // I|roundtrip(true)|\uZZZZ\u12|\uZZZZ\u12
  assert_eq(@text.unicode_to_string(@text.to_unicode("\\u")), "\\u") // I|roundtrip|\u|\u
  assert_eq(@text.unicode_to_string(@text.to_unicode("\\u")), "\\u") // I|roundtrip(true)|\u|\u
  assert_eq(
    @text.unicode_to_string(@text.to_unicode("no escapes")),
    "no escapes",
  ) // I|roundtrip|no escapes|no escapes
  assert_eq(
    @text.unicode_to_string(@text.to_unicode("no escapes")),
    "no escapes",
  ) // I|roundtrip(true)|no escapes|no escapes
  assert_eq(
    @text.unicode_to_string(@text.to_unicode("\\\\u4e2d")),
    "\\\u{4e2d}",
  ) // I|roundtrip|\\u4e2d|\{u4e2d}
  assert_eq(
    @text.unicode_to_string(@text.to_unicode("\\\\u4e2d")),
    "\\\u{4e2d}",
  ) // I|roundtrip(true)|\\u4e2d|\{u4e2d}
  assert_eq(@text.unicode_to_string(@text.to_unicode("\\")), "\\") // I|roundtrip|\|\
  assert_eq(@text.unicode_to_string(@text.to_unicode("\\")), "\\") // I|roundtrip(true)|\|\
  assert_eq(
    @text.unicode_to_string(@text.to_unicode("\\u0000\\u0009")),
    "\u{0000}\u{0009}",
  ) // I|roundtrip|\u0000\u0009|{u0000}{u0009}
  assert_eq(
    @text.unicode_to_string(@text.to_unicode("\\u0000\\u0009")),
    "\u{0000}\u{0009}",
  ) // I|roundtrip(true)|\u0000\u0009|{u0000}{u0009}
  assert_eq(@text.unicode_to_string(@text.to_unicode("\\uFFFF")), "\u{ffff}") // I|roundtrip|\uFFFF|{uffff}
  assert_eq(@text.unicode_to_string(@text.to_unicode("\\uFFFF")), "\u{ffff}") // I|roundtrip(true)|\uFFFF|{uffff}
  assert_eq(
    @text.unicode_to_string(@text.to_unicode("x\\u4e2dy")),
    "x\u{4e2d}y",
  ) // I|roundtrip|x\u4e2dy|x{u4e2d}y
  assert_eq(
    @text.unicode_to_string(@text.to_unicode("x\\u4e2dy")),
    "x\u{4e2d}y",
  ) // I|roundtrip(true)|x\u4e2dy|x{u4e2d}y
  assert_eq(@text.unicode_to_string(@text.to_unicode("")), "") // I|roundtrip||
  assert_eq(@text.unicode_to_string(@text.to_unicode("")), "") // I|roundtrip(true)||
}
