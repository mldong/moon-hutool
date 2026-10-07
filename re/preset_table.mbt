// 本文件是生成物：`python scripts/gen_re2_test.py <leg.tsv> --table re/preset_table.mbt`
// 两列都从「参照腿原文 + 改写规则表」机器推导（手打零条）；规则表与逐条出处见 docs/spec/10-re.md §10。

///|
fn preset_name(p : RePreset) -> String {
  match p {
    General => "GENERAL"
    Numbers => "NUMBERS"
    Word => "WORD"
    Chinese => "CHINESE"
    Chineses => "CHINESES"
    GroupVar => "GROUP_VAR"
    Ipv4 => "IPV4"
    Ipv6 => "IPV6"
    Money => "MONEY"
    Email => "EMAIL"
    EmailWithChinese => "EMAIL_WITH_CHINESE"
    ZipCode => "ZIP_CODE"
    Birthday => "BIRTHDAY"
    Uri => "URI"
    Url => "URL"
    UrlHttp => "URL_HTTP"
    GeneralWithChinese => "GENERAL_WITH_CHINESE"
    Uuid => "UUID"
    UuidSimple => "UUID_SIMPLE"
    MacAddress => "MAC_ADDRESS"
    Hex => "HEX"
    Time => "TIME"
    ChineseName => "CHINESE_NAME"
  }
}

///|
fn preset_pattern(p : RePreset) -> String {
  match p {
    General => "^[0-9A-Za-z_]+$"
    Numbers => "[0-9]+"
    Word => "[a-zA-Z]+"
    Chinese =>
      "[⺀-⻿⼀-⿟㇀-㇯㐀-䶿一-鿿豈-﫿𠀀-𪛟𪜀-𫜿𫝀-𫠟𫠠-𬺯丽-𯨟]"
    Chineses =>
      "[⺀-⻿⼀-⿟㇀-㇯㐀-䶿一-鿿豈-﫿𠀀-𪛟𪜀-𫜿𫝀-𫠟𫠠-𬺯丽-𯨟]+"
    GroupVar => "\\$([0-9]+)"
    Ipv4 =>
      "^(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]?[0-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]?[0-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]?[0-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]?[0-9])$"
    Ipv6 =>
      "(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]+|::(ffff(:0{1,4})?:)?((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\\.){3}(25[0-5]|(2[0-4]|1?[0-9])?[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\\.){3}(25[0-5]|(2[0-4]|1?[0-9])?[0-9]))"
    Money => "^([0-9]+(?:\\.[0-9]+)?)$"
    Email =>
      "(?i:(?:[a-z0-9!#$%&'*+/=?^_`{|}~\\-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~\\-]+)*|\"(?:[\\u0001-\\u0008\\u000b\\u000c\\u000e-\\u001f\\u0021\\u0023-\\u005b\\u005d-\\u007f]|\\\\[\\u0001-\\u0009\\u000b\\u000c\\u000e-\\u007f])*\")@(?:(?:[a-z0-9](?:[a-z0-9\\-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9\\-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9\\-]*[a-z0-9]:(?:[\\u0001-\\u0008\\u000b\\u000c\\u000e-\\u001f\\u0021-\\u005a\\u0053-\\u007f]|\\\\[\\u0001-\\u0009\\u000b\\u000c\\u000e-\\u007f])+)\\]))"
    EmailWithChinese =>
      "(?i:(?:[a-z0-9\\u4e00-\\u9fa5!#$%&'*+/=?^_`{|}~\\-]+(?:\\.[a-z0-9\\u4e00-\\u9fa5!#$%&'*+/=?^_`{|}~\\-]+)*|\"(?:[\\u0001-\\u0008\\u000b\\u000c\\u000e-\\u001f\\u0021\\u0023-\\u005b\\u005d-\\u007f]|\\\\[\\u0001-\\u0009\\u000b\\u000c\\u000e-\\u007f])*\")@(?:(?:[a-z0-9\\u4e00-\\u9fa5](?:[a-z0-9\\u4e00-\\u9fa5\\-]*[a-z0-9\\u4e00-\\u9fa5])?\\.)+[a-z0-9\\u4e00-\\u9fa5](?:[a-z0-9\\u4e00-\\u9fa5\\-]*[a-z0-9\\u4e00-\\u9fa5])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9\\u4e00-\\u9fa5\\-]*[a-z0-9\\u4e00-\\u9fa5]:(?:[\\u0001-\\u0008\\u000b\\u000c\\u000e-\\u001f\\u0021-\\u005a\\u0053-\\u007f]|\\\\[\\u0001-\\u0009\\u000b\\u000c\\u000e-\\u007f])+)\\]))"
    ZipCode =>
      "^(0[1-7]|1[0-356]|2[0-7]|3[0-6]|4[0-7]|5[0-7]|6[0-7]|7[0-5]|8[0-9]|9[0-8])[0-9]{4}|99907[78]$"
    Birthday =>
      "^([0-9]{2,4})([/\\-.年]?)([0-9]{1,2})([/\\-.月]?)([0-9]{1,2})日?$"
    Uri => "^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?"
    Url =>
      "[a-zA-Z]+://[0-9A-Za-z_\\-+&@#/%?=~_|!:,.;]*[0-9A-Za-z_\\-+&@#/%=~_|]"
    UrlHttp =>
      "(?i:(https?|ftp|file)://[0-9A-Za-z_\\-+&@#/%?=~_|!:,.;]*[0-9A-Za-z_\\-+&@#/%=~_|])"
    GeneralWithChinese => "^[一-鿿0-9A-Za-z_]+$"
    Uuid =>
      "(?i:^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$)"
    UuidSimple => "^[0-9a-fA-F]{32}$"
    MacAddress =>
      "(?i:((?:[a-fA-F0-9]{1,2}[\\-:]){5}[a-fA-F0-9]{1,2})|((?:[a-fA-F0-9]{1,4}[.]){2}[a-fA-F0-9]{1,4})|[a-fA-F0-9]{12}|0x([0-9]{12}).+ETHER)"
    Hex => "^[a-fA-F0-9]+$"
    Time => "[0-9]{1,2}[时:][0-9]{1,2}([分:][0-9]{1,2})?秒?"
    ChineseName => "^[㐀-鿿·]{2,60}$"
  }
}

// 声明序＝腿 R 行的序（参照 RegexPool 的字段序），本库把它当作表全集的唯一出口

///|
let presets : Array[RePreset] = [
  RePreset::General,
  RePreset::Numbers,
  RePreset::Word,
  RePreset::Chinese,
  RePreset::Chineses,
  RePreset::GroupVar,
  RePreset::Ipv4,
  RePreset::Ipv6,
  RePreset::Money,
  RePreset::Email,
  RePreset::EmailWithChinese,
  RePreset::ZipCode,
  RePreset::Birthday,
  RePreset::Uri,
  RePreset::Url,
  RePreset::UrlHttp,
  RePreset::GeneralWithChinese,
  RePreset::Uuid,
  RePreset::UuidSimple,
  RePreset::MacAddress,
  RePreset::Hex,
  RePreset::Time,
  RePreset::ChineseName,
]
