// 本文件的每一条期望都由 `scripts/gen_batch1_rest.py` 从参照腿 `scripts/FileNameLeg.java` 的读数灌入，**手打零条**。
// 参照版本 hutool-all 5.8.37；判据口径见 docs/spec/15-path.md §11。
// 期望值冻结（AGENTS）：改这里任何一条都要单独一笔并给新的腿读数。

///|
test "path #11.1~#11.5 FileNameUtil 纯串档（腿 N 行）" {
  assert_eq(@path.name_of("/a/b/c.txt"), "c.txt") // N|getName|/a/b/c.txt|c.txt
  assert_eq(@path.main_name("/a/b/c.txt"), "c") // N|mainName|/a/b/c.txt|c
  assert_eq(@path.ext_name("/a/b/c.txt"), "txt") // N|extName|/a/b/c.txt|txt
  assert_eq(@path.clean_invalid("/a/b/c.txt"), "abc.txt") // N|cleanInvalid|/a/b/c.txt|abc.txt
  assert_eq(@path.contains_invalid("/a/b/c.txt"), true) // N|containsInvalid|/a/b/c.txt|true
  assert_eq(@path.name_of("C:\\a\\b.txt"), "b.txt") // N|getName|C:\a\b.txt|b.txt
  assert_eq(@path.main_name("C:\\a\\b.txt"), "b") // N|mainName|C:\a\b.txt|b
  assert_eq(@path.ext_name("C:\\a\\b.txt"), "txt") // N|extName|C:\a\b.txt|txt
  assert_eq(@path.clean_invalid("C:\\a\\b.txt"), "Cab.txt") // N|cleanInvalid|C:\a\b.txt|Cab.txt
  assert_eq(@path.contains_invalid("C:\\a\\b.txt"), true) // N|containsInvalid|C:\a\b.txt|true
  assert_eq(@path.name_of("C:/a/b.txt"), "b.txt") // N|getName|C:/a/b.txt|b.txt
  assert_eq(@path.main_name("C:/a/b.txt"), "b") // N|mainName|C:/a/b.txt|b
  assert_eq(@path.ext_name("C:/a/b.txt"), "txt") // N|extName|C:/a/b.txt|txt
  assert_eq(@path.clean_invalid("C:/a/b.txt"), "Cab.txt") // N|cleanInvalid|C:/a/b.txt|Cab.txt
  assert_eq(@path.contains_invalid("C:/a/b.txt"), true) // N|containsInvalid|C:/a/b.txt|true
  assert_eq(@path.name_of("\\\\server\\share\\f.bin"), "f.bin") // N|getName|\\server\share\f.bin|f.bin
  assert_eq(@path.main_name("\\\\server\\share\\f.bin"), "f") // N|mainName|\\server\share\f.bin|f
  assert_eq(@path.ext_name("\\\\server\\share\\f.bin"), "bin") // N|extName|\\server\share\f.bin|bin
  assert_eq(@path.clean_invalid("\\\\server\\share\\f.bin"), "serversharef.bin") // N|cleanInvalid|\\server\share\f.bin|serversharef.bin
  assert_eq(@path.contains_invalid("\\\\server\\share\\f.bin"), true) // N|containsInvalid|\\server\share\f.bin|true
  assert_eq(@path.name_of("a\\b/c.txt"), "c.txt") // N|getName|a\b/c.txt|c.txt
  assert_eq(@path.main_name("a\\b/c.txt"), "c") // N|mainName|a\b/c.txt|c
  assert_eq(@path.ext_name("a\\b/c.txt"), "txt") // N|extName|a\b/c.txt|txt
  assert_eq(@path.clean_invalid("a\\b/c.txt"), "abc.txt") // N|cleanInvalid|a\b/c.txt|abc.txt
  assert_eq(@path.contains_invalid("a\\b/c.txt"), true) // N|containsInvalid|a\b/c.txt|true
  assert_eq(@path.name_of("c.txt"), "c.txt") // N|getName|c.txt|c.txt
  assert_eq(@path.main_name("c.txt"), "c") // N|mainName|c.txt|c
  assert_eq(@path.ext_name("c.txt"), "txt") // N|extName|c.txt|txt
  assert_eq(@path.clean_invalid("c.txt"), "c.txt") // N|cleanInvalid|c.txt|c.txt
  assert_eq(@path.contains_invalid("c.txt"), false) // N|containsInvalid|c.txt|false
  assert_eq(@path.name_of("/tmp/"), "tmp") // N|getName|/tmp/|tmp
  assert_eq(@path.main_name("/tmp/"), "tmp") // N|mainName|/tmp/|tmp
  assert_eq(@path.ext_name("/tmp/"), "") // N|extName|/tmp/|
  assert_eq(@path.clean_invalid("/tmp/"), "tmp") // N|cleanInvalid|/tmp/|tmp
  assert_eq(@path.contains_invalid("/tmp/"), true) // N|containsInvalid|/tmp/|true
  assert_eq(@path.name_of("/tmp"), "tmp") // N|getName|/tmp|tmp
  assert_eq(@path.main_name("/tmp"), "tmp") // N|mainName|/tmp|tmp
  assert_eq(@path.ext_name("/tmp"), "") // N|extName|/tmp|
  assert_eq(@path.clean_invalid("/tmp"), "tmp") // N|cleanInvalid|/tmp|tmp
  assert_eq(@path.contains_invalid("/tmp"), true) // N|containsInvalid|/tmp|true
  assert_eq(@path.name_of("tmp/"), "tmp") // N|getName|tmp/|tmp
  assert_eq(@path.main_name("tmp/"), "tmp") // N|mainName|tmp/|tmp
  assert_eq(@path.ext_name("tmp/"), "") // N|extName|tmp/|
  assert_eq(@path.clean_invalid("tmp/"), "tmp") // N|cleanInvalid|tmp/|tmp
  assert_eq(@path.contains_invalid("tmp/"), true) // N|containsInvalid|tmp/|true
  assert_eq(@path.name_of("tmp"), "tmp") // N|getName|tmp|tmp
  assert_eq(@path.main_name("tmp"), "tmp") // N|mainName|tmp|tmp
  assert_eq(@path.ext_name("tmp"), "") // N|extName|tmp|
  assert_eq(@path.clean_invalid("tmp"), "tmp") // N|cleanInvalid|tmp|tmp
  assert_eq(@path.contains_invalid("tmp"), false) // N|containsInvalid|tmp|false
  assert_eq(@path.name_of("a.b.c"), "a.b.c") // N|getName|a.b.c|a.b.c
  assert_eq(@path.main_name("a.b.c"), "a.b") // N|mainName|a.b.c|a.b
  assert_eq(@path.ext_name("a.b.c"), "c") // N|extName|a.b.c|c
  assert_eq(@path.clean_invalid("a.b.c"), "a.b.c") // N|cleanInvalid|a.b.c|a.b.c
  assert_eq(@path.contains_invalid("a.b.c"), false) // N|containsInvalid|a.b.c|false
  assert_eq(@path.name_of(".bashrc"), ".bashrc") // N|getName|.bashrc|.bashrc
  assert_eq(@path.main_name(".bashrc"), "") // N|mainName|.bashrc|
  assert_eq(@path.ext_name(".bashrc"), "bashrc") // N|extName|.bashrc|bashrc
  assert_eq(@path.clean_invalid(".bashrc"), ".bashrc") // N|cleanInvalid|.bashrc|.bashrc
  assert_eq(@path.contains_invalid(".bashrc"), false) // N|containsInvalid|.bashrc|false
  assert_eq(@path.name_of("archive.tar.gz"), "archive.tar.gz") // N|getName|archive.tar.gz|archive.tar.gz
  assert_eq(@path.main_name("archive.tar.gz"), "archive") // N|mainName|archive.tar.gz|archive
  assert_eq(@path.ext_name("archive.tar.gz"), "tar.gz") // N|extName|archive.tar.gz|tar.gz
  assert_eq(@path.clean_invalid("archive.tar.gz"), "archive.tar.gz") // N|cleanInvalid|archive.tar.gz|archive.tar.gz
  assert_eq(@path.contains_invalid("archive.tar.gz"), false) // N|containsInvalid|archive.tar.gz|false
  assert_eq(@path.name_of("archive.tar.bz2"), "archive.tar.bz2") // N|getName|archive.tar.bz2|archive.tar.bz2
  assert_eq(@path.main_name("archive.tar.bz2"), "archive") // N|mainName|archive.tar.bz2|archive
  assert_eq(@path.ext_name("archive.tar.bz2"), "tar.bz2") // N|extName|archive.tar.bz2|tar.bz2
  assert_eq(@path.clean_invalid("archive.tar.bz2"), "archive.tar.bz2") // N|cleanInvalid|archive.tar.bz2|archive.tar.bz2
  assert_eq(@path.contains_invalid("archive.tar.bz2"), false) // N|containsInvalid|archive.tar.bz2|false
  assert_eq(@path.name_of("archive.tar.xz"), "archive.tar.xz") // N|getName|archive.tar.xz|archive.tar.xz
  assert_eq(@path.main_name("archive.tar.xz"), "archive") // N|mainName|archive.tar.xz|archive
  assert_eq(@path.ext_name("archive.tar.xz"), "tar.xz") // N|extName|archive.tar.xz|tar.xz
  assert_eq(@path.clean_invalid("archive.tar.xz"), "archive.tar.xz") // N|cleanInvalid|archive.tar.xz|archive.tar.xz
  assert_eq(@path.contains_invalid("archive.tar.xz"), false) // N|containsInvalid|archive.tar.xz|false
  assert_eq(@path.name_of("archive.tar"), "archive.tar") // N|getName|archive.tar|archive.tar
  assert_eq(@path.main_name("archive.tar"), "archive") // N|mainName|archive.tar|archive
  assert_eq(@path.ext_name("archive.tar"), "tar") // N|extName|archive.tar|tar
  assert_eq(@path.clean_invalid("archive.tar"), "archive.tar") // N|cleanInvalid|archive.tar|archive.tar
  assert_eq(@path.contains_invalid("archive.tar"), false) // N|containsInvalid|archive.tar|false
  assert_eq(@path.name_of("x.tar.gz.txt"), "x.tar.gz.txt") // N|getName|x.tar.gz.txt|x.tar.gz.txt
  assert_eq(@path.main_name("x.tar.gz.txt"), "x.tar.gz") // N|mainName|x.tar.gz.txt|x.tar.gz
  assert_eq(@path.ext_name("x.tar.gz.txt"), "txt") // N|extName|x.tar.gz.txt|txt
  assert_eq(@path.clean_invalid("x.tar.gz.txt"), "x.tar.gz.txt") // N|cleanInvalid|x.tar.gz.txt|x.tar.gz.txt
  assert_eq(@path.contains_invalid("x.tar.gz.txt"), false) // N|containsInvalid|x.tar.gz.txt|false
  assert_eq(@path.name_of("noext"), "noext") // N|getName|noext|noext
  assert_eq(@path.main_name("noext"), "noext") // N|mainName|noext|noext
  assert_eq(@path.ext_name("noext"), "") // N|extName|noext|
  assert_eq(@path.clean_invalid("noext"), "noext") // N|cleanInvalid|noext|noext
  assert_eq(@path.contains_invalid("noext"), false) // N|containsInvalid|noext|false
  assert_eq(@path.name_of("a."), "a.") // N|getName|a.|a.
  assert_eq(@path.main_name("a."), "a") // N|mainName|a.|a
  assert_eq(@path.ext_name("a."), "") // N|extName|a.|
  assert_eq(@path.clean_invalid("a."), "a.") // N|cleanInvalid|a.|a.
  assert_eq(@path.contains_invalid("a."), false) // N|containsInvalid|a.|false
  assert_eq(@path.name_of(".a"), ".a") // N|getName|.a|.a
  assert_eq(@path.main_name(".a"), "") // N|mainName|.a|
  assert_eq(@path.ext_name(".a"), "a") // N|extName|.a|a
  assert_eq(@path.clean_invalid(".a"), ".a") // N|cleanInvalid|.a|.a
  assert_eq(@path.contains_invalid(".a"), false) // N|containsInvalid|.a|false
  assert_eq(@path.name_of("."), ".") // N|getName|.|.
  assert_eq(@path.main_name("."), "") // N|mainName|.|
  assert_eq(@path.ext_name("."), "") // N|extName|.|
  assert_eq(@path.clean_invalid("."), ".") // N|cleanInvalid|.|.
  assert_eq(@path.contains_invalid("."), false) // N|containsInvalid|.|false
  assert_eq(@path.name_of(".."), "..") // N|getName|..|..
  assert_eq(@path.main_name(".."), ".") // N|mainName|..|.
  assert_eq(@path.ext_name(".."), "") // N|extName|..|
  assert_eq(@path.clean_invalid(".."), "..") // N|cleanInvalid|..|..
  assert_eq(@path.contains_invalid(".."), false) // N|containsInvalid|..|false
  assert_eq(@path.name_of("..."), "...") // N|getName|...|...
  assert_eq(@path.main_name("..."), "..") // N|mainName|...|..
  assert_eq(@path.ext_name("..."), "") // N|extName|...|
  assert_eq(@path.clean_invalid("..."), "...") // N|cleanInvalid|...|...
  assert_eq(@path.contains_invalid("..."), false) // N|containsInvalid|...|false
  assert_eq(@path.name_of(""), "") // N|getName||
  assert_eq(@path.main_name(""), "") // N|mainName||
  assert_eq(@path.ext_name(""), "") // N|extName||
  assert_eq(@path.clean_invalid(""), "") // N|cleanInvalid||
  assert_eq(@path.contains_invalid(""), false) // N|containsInvalid||false
  assert_eq(@path.name_of("/"), "") // N|getName|/|
  assert_eq(@path.main_name("/"), "") // N|mainName|/|
  assert_eq(@path.ext_name("/"), "") // N|extName|/|
  assert_eq(@path.clean_invalid("/"), "") // N|cleanInvalid|/|
  assert_eq(@path.contains_invalid("/"), true) // N|containsInvalid|/|true
  assert_eq(
    @path.name_of("\u{4e2d}\u{6587} \u{6587}\u{4ef6}.txt"),
    "\u{4e2d}\u{6587} \u{6587}\u{4ef6}.txt",
  ) // N|getName|{u4e2d}{u6587} {u6587}{u4ef6}.txt|{u4e2d}{u6587} {u6587}{u4ef6}.txt
  assert_eq(
    @path.main_name("\u{4e2d}\u{6587} \u{6587}\u{4ef6}.txt"),
    "\u{4e2d}\u{6587} \u{6587}\u{4ef6}",
  ) // N|mainName|{u4e2d}{u6587} {u6587}{u4ef6}.txt|{u4e2d}{u6587} {u6587}{u4ef6}
  assert_eq(@path.ext_name("\u{4e2d}\u{6587} \u{6587}\u{4ef6}.txt"), "txt") // N|extName|{u4e2d}{u6587} {u6587}{u4ef6}.txt|txt
  assert_eq(
    @path.clean_invalid("\u{4e2d}\u{6587} \u{6587}\u{4ef6}.txt"),
    "\u{4e2d}\u{6587} \u{6587}\u{4ef6}.txt",
  ) // N|cleanInvalid|{u4e2d}{u6587} {u6587}{u4ef6}.txt|{u4e2d}{u6587} {u6587}{u4ef6}.txt
  assert_eq(
    @path.contains_invalid("\u{4e2d}\u{6587} \u{6587}\u{4ef6}.txt"),
    false,
  ) // N|containsInvalid|{u4e2d}{u6587} {u6587}{u4ef6}.txt|false
  assert_eq(@path.name_of("a b.txt"), "a b.txt") // N|getName|a b.txt|a b.txt
  assert_eq(@path.main_name("a b.txt"), "a b") // N|mainName|a b.txt|a b
  assert_eq(@path.ext_name("a b.txt"), "txt") // N|extName|a b.txt|txt
  assert_eq(@path.clean_invalid("a b.txt"), "a b.txt") // N|cleanInvalid|a b.txt|a b.txt
  assert_eq(@path.contains_invalid("a b.txt"), false) // N|containsInvalid|a b.txt|false
  assert_eq(@path.name_of("bad:name?.txt"), "bad:name?.txt") // N|getName|bad:name?.txt|bad:name?.txt
  assert_eq(@path.main_name("bad:name?.txt"), "bad:name?") // N|mainName|bad:name?.txt|bad:name?
  assert_eq(@path.ext_name("bad:name?.txt"), "txt") // N|extName|bad:name?.txt|txt
  assert_eq(@path.clean_invalid("bad:name?.txt"), "badname.txt") // N|cleanInvalid|bad:name?.txt|badname.txt
  assert_eq(@path.contains_invalid("bad:name?.txt"), true) // N|containsInvalid|bad:name?.txt|true
  assert_eq(@path.name_of("a<b>c|d.txt"), "a<b>c|d.txt") // N|getName|a<b>c{u007c}d.txt|a<b>c{u007c}d.txt
  assert_eq(@path.main_name("a<b>c|d.txt"), "a<b>c|d") // N|mainName|a<b>c{u007c}d.txt|a<b>c{u007c}d
  assert_eq(@path.ext_name("a<b>c|d.txt"), "txt") // N|extName|a<b>c{u007c}d.txt|txt
  assert_eq(@path.clean_invalid("a<b>c|d.txt"), "abcd.txt") // N|cleanInvalid|a<b>c{u007c}d.txt|abcd.txt
  assert_eq(@path.contains_invalid("a<b>c|d.txt"), true) // N|containsInvalid|a<b>c{u007c}d.txt|true
  assert_eq(@path.name_of("tab\u{0009}here.txt"), "tab\u{0009}here.txt") // N|getName|tab{u0009}here.txt|tab{u0009}here.txt
  assert_eq(@path.main_name("tab\u{0009}here.txt"), "tab\u{0009}here") // N|mainName|tab{u0009}here.txt|tab{u0009}here
  assert_eq(@path.ext_name("tab\u{0009}here.txt"), "txt") // N|extName|tab{u0009}here.txt|txt
  assert_eq(@path.clean_invalid("tab\u{0009}here.txt"), "tab\u{0009}here.txt") // N|cleanInvalid|tab{u0009}here.txt|tab{u0009}here.txt
  assert_eq(@path.contains_invalid("tab\u{0009}here.txt"), false) // N|containsInvalid|tab{u0009}here.txt|false
  assert_eq(@path.name_of("line\u{000a}break.txt"), "line\u{000a}break.txt") // N|getName|line{u000a}break.txt|line{u000a}break.txt
  assert_eq(@path.main_name("line\u{000a}break.txt"), "line\u{000a}break") // N|mainName|line{u000a}break.txt|line{u000a}break
  assert_eq(@path.ext_name("line\u{000a}break.txt"), "txt") // N|extName|line{u000a}break.txt|txt
  assert_eq(@path.clean_invalid("line\u{000a}break.txt"), "linebreak.txt") // N|cleanInvalid|line{u000a}break.txt|linebreak.txt
  assert_eq(@path.contains_invalid("line\u{000a}break.txt"), true) // N|containsInvalid|line{u000a}break.txt|true
}

///|
test "path #11.6 is_type 的类型表择路（腿 IT 行：大小写/带点/空表/含空串）" {
  assert_eq(@path.is_type("a.txt", ["txt"]), true) // IT|isType|a.txt|[txt,]|true
  assert_eq(@path.is_type("a.txt", ["TXT"]), true) // IT|isType|a.txt|[TXT,]|true
  assert_eq(@path.is_type("a.txt", ["txt", "jpg"]), true) // IT|isType|a.txt|[txt,jpg,]|true
  assert_eq(@path.is_type("a.txt", ["jpg", "txt"]), true) // IT|isType|a.txt|[jpg,txt,]|true
  assert_eq(@path.is_type("a.txt", [".txt"]), false) // IT|isType|a.txt|[.txt,]|false
  assert_eq(@path.is_type("a.txt", [""]), false) // IT|isType|a.txt|[,]|false
  assert_eq(@path.is_type("a.txt", []), false) // IT|isType|a.txt|[]|false
  assert_eq(@path.is_type("a.txt", ["txt", ""]), true) // IT|isType|a.txt|[txt,,]|true
  assert_eq(@path.is_type("a.txt", ["gz"]), false) // IT|isType|a.txt|[gz,]|false
  assert_eq(@path.is_type("a.txt", ["tar.gz"]), false) // IT|isType|a.txt|[tar.gz,]|false
  assert_eq(@path.is_type("a.txt", ["Tar.GZ"]), false) // IT|isType|a.txt|[Tar.GZ,]|false
  assert_eq(@path.is_type("a.txt", ["ar.gz"]), false) // IT|isType|a.txt|[ar.gz,]|false
  assert_eq(@path.is_type("a.TXT", ["txt"]), true) // IT|isType|a.TXT|[txt,]|true
  assert_eq(@path.is_type("a.TXT", ["TXT"]), true) // IT|isType|a.TXT|[TXT,]|true
  assert_eq(@path.is_type("a.TXT", ["txt", "jpg"]), true) // IT|isType|a.TXT|[txt,jpg,]|true
  assert_eq(@path.is_type("a.TXT", ["jpg", "txt"]), true) // IT|isType|a.TXT|[jpg,txt,]|true
  assert_eq(@path.is_type("a.TXT", [".txt"]), false) // IT|isType|a.TXT|[.txt,]|false
  assert_eq(@path.is_type("a.TXT", [""]), false) // IT|isType|a.TXT|[,]|false
  assert_eq(@path.is_type("a.TXT", []), false) // IT|isType|a.TXT|[]|false
  assert_eq(@path.is_type("a.TXT", ["txt", ""]), true) // IT|isType|a.TXT|[txt,,]|true
  assert_eq(@path.is_type("a.TXT", ["gz"]), false) // IT|isType|a.TXT|[gz,]|false
  assert_eq(@path.is_type("a.TXT", ["tar.gz"]), false) // IT|isType|a.TXT|[tar.gz,]|false
  assert_eq(@path.is_type("a.TXT", ["Tar.GZ"]), false) // IT|isType|a.TXT|[Tar.GZ,]|false
  assert_eq(@path.is_type("a.TXT", ["ar.gz"]), false) // IT|isType|a.TXT|[ar.gz,]|false
  assert_eq(@path.is_type("a.tar.gz", ["txt"]), false) // IT|isType|a.tar.gz|[txt,]|false
  assert_eq(@path.is_type("a.tar.gz", ["TXT"]), false) // IT|isType|a.tar.gz|[TXT,]|false
  assert_eq(@path.is_type("a.tar.gz", ["txt", "jpg"]), false) // IT|isType|a.tar.gz|[txt,jpg,]|false
  assert_eq(@path.is_type("a.tar.gz", ["jpg", "txt"]), false) // IT|isType|a.tar.gz|[jpg,txt,]|false
  assert_eq(@path.is_type("a.tar.gz", [".txt"]), false) // IT|isType|a.tar.gz|[.txt,]|false
  assert_eq(@path.is_type("a.tar.gz", [""]), false) // IT|isType|a.tar.gz|[,]|false
  assert_eq(@path.is_type("a.tar.gz", []), false) // IT|isType|a.tar.gz|[]|false
  assert_eq(@path.is_type("a.tar.gz", ["txt", ""]), false) // IT|isType|a.tar.gz|[txt,,]|false
  assert_eq(@path.is_type("a.tar.gz", ["gz"]), false) // IT|isType|a.tar.gz|[gz,]|false
  assert_eq(@path.is_type("a.tar.gz", ["tar.gz"]), true) // IT|isType|a.tar.gz|[tar.gz,]|true
  assert_eq(@path.is_type("a.tar.gz", ["Tar.GZ"]), true) // IT|isType|a.tar.gz|[Tar.GZ,]|true
  assert_eq(@path.is_type("a.tar.gz", ["ar.gz"]), false) // IT|isType|a.tar.gz|[ar.gz,]|false
  assert_eq(@path.is_type("noext", ["txt"]), false) // IT|isType|noext|[txt,]|false
  assert_eq(@path.is_type("noext", ["TXT"]), false) // IT|isType|noext|[TXT,]|false
  assert_eq(@path.is_type("noext", ["txt", "jpg"]), false) // IT|isType|noext|[txt,jpg,]|false
  assert_eq(@path.is_type("noext", ["jpg", "txt"]), false) // IT|isType|noext|[jpg,txt,]|false
  assert_eq(@path.is_type("noext", [".txt"]), false) // IT|isType|noext|[.txt,]|false
  assert_eq(@path.is_type("noext", [""]), true) // IT|isType|noext|[,]|true
  assert_eq(@path.is_type("noext", []), false) // IT|isType|noext|[]|false
  assert_eq(@path.is_type("noext", ["txt", ""]), true) // IT|isType|noext|[txt,,]|true
  assert_eq(@path.is_type("noext", ["gz"]), false) // IT|isType|noext|[gz,]|false
  assert_eq(@path.is_type("noext", ["tar.gz"]), false) // IT|isType|noext|[tar.gz,]|false
  assert_eq(@path.is_type("noext", ["Tar.GZ"]), false) // IT|isType|noext|[Tar.GZ,]|false
  assert_eq(@path.is_type("noext", ["ar.gz"]), false) // IT|isType|noext|[ar.gz,]|false
  assert_eq(@path.is_type("a.", ["txt"]), false) // IT|isType|a.|[txt,]|false
  assert_eq(@path.is_type("a.", ["TXT"]), false) // IT|isType|a.|[TXT,]|false
  assert_eq(@path.is_type("a.", ["txt", "jpg"]), false) // IT|isType|a.|[txt,jpg,]|false
  assert_eq(@path.is_type("a.", ["jpg", "txt"]), false) // IT|isType|a.|[jpg,txt,]|false
  assert_eq(@path.is_type("a.", [".txt"]), false) // IT|isType|a.|[.txt,]|false
  assert_eq(@path.is_type("a.", [""]), true) // IT|isType|a.|[,]|true
  assert_eq(@path.is_type("a.", []), false) // IT|isType|a.|[]|false
  assert_eq(@path.is_type("a.", ["txt", ""]), true) // IT|isType|a.|[txt,,]|true
  assert_eq(@path.is_type("a.", ["gz"]), false) // IT|isType|a.|[gz,]|false
  assert_eq(@path.is_type("a.", ["tar.gz"]), false) // IT|isType|a.|[tar.gz,]|false
  assert_eq(@path.is_type("a.", ["Tar.GZ"]), false) // IT|isType|a.|[Tar.GZ,]|false
  assert_eq(@path.is_type("a.", ["ar.gz"]), false) // IT|isType|a.|[ar.gz,]|false
  assert_eq(@path.is_type(".txt", ["txt"]), true) // IT|isType|.txt|[txt,]|true
  assert_eq(@path.is_type(".txt", ["TXT"]), true) // IT|isType|.txt|[TXT,]|true
  assert_eq(@path.is_type(".txt", ["txt", "jpg"]), true) // IT|isType|.txt|[txt,jpg,]|true
  assert_eq(@path.is_type(".txt", ["jpg", "txt"]), true) // IT|isType|.txt|[jpg,txt,]|true
  assert_eq(@path.is_type(".txt", [".txt"]), false) // IT|isType|.txt|[.txt,]|false
  assert_eq(@path.is_type(".txt", [""]), false) // IT|isType|.txt|[,]|false
  assert_eq(@path.is_type(".txt", []), false) // IT|isType|.txt|[]|false
  assert_eq(@path.is_type(".txt", ["txt", ""]), true) // IT|isType|.txt|[txt,,]|true
  assert_eq(@path.is_type(".txt", ["gz"]), false) // IT|isType|.txt|[gz,]|false
  assert_eq(@path.is_type(".txt", ["tar.gz"]), false) // IT|isType|.txt|[tar.gz,]|false
  assert_eq(@path.is_type(".txt", ["Tar.GZ"]), false) // IT|isType|.txt|[Tar.GZ,]|false
  assert_eq(@path.is_type(".txt", ["ar.gz"]), false) // IT|isType|.txt|[ar.gz,]|false
  assert_eq(@path.is_type("a.jpg", ["txt"]), false) // IT|isType|a.jpg|[txt,]|false
  assert_eq(@path.is_type("a.jpg", ["TXT"]), false) // IT|isType|a.jpg|[TXT,]|false
  assert_eq(@path.is_type("a.jpg", ["txt", "jpg"]), true) // IT|isType|a.jpg|[txt,jpg,]|true
  assert_eq(@path.is_type("a.jpg", ["jpg", "txt"]), true) // IT|isType|a.jpg|[jpg,txt,]|true
  assert_eq(@path.is_type("a.jpg", [".txt"]), false) // IT|isType|a.jpg|[.txt,]|false
  assert_eq(@path.is_type("a.jpg", [""]), false) // IT|isType|a.jpg|[,]|false
  assert_eq(@path.is_type("a.jpg", []), false) // IT|isType|a.jpg|[]|false
  assert_eq(@path.is_type("a.jpg", ["txt", ""]), false) // IT|isType|a.jpg|[txt,,]|false
  assert_eq(@path.is_type("a.jpg", ["gz"]), false) // IT|isType|a.jpg|[gz,]|false
  assert_eq(@path.is_type("a.jpg", ["tar.gz"]), false) // IT|isType|a.jpg|[tar.gz,]|false
  assert_eq(@path.is_type("a.jpg", ["Tar.GZ"]), false) // IT|isType|a.jpg|[Tar.GZ,]|false
  assert_eq(@path.is_type("a.jpg", ["ar.gz"]), false) // IT|isType|a.jpg|[ar.gz,]|false
  assert_eq(@path.is_type("/d/b.png", ["txt"]), false) // IT|isType|/d/b.png|[txt,]|false
  assert_eq(@path.is_type("/d/b.png", ["TXT"]), false) // IT|isType|/d/b.png|[TXT,]|false
  assert_eq(@path.is_type("/d/b.png", ["txt", "jpg"]), false) // IT|isType|/d/b.png|[txt,jpg,]|false
  assert_eq(@path.is_type("/d/b.png", ["jpg", "txt"]), false) // IT|isType|/d/b.png|[jpg,txt,]|false
  assert_eq(@path.is_type("/d/b.png", [".txt"]), false) // IT|isType|/d/b.png|[.txt,]|false
  assert_eq(@path.is_type("/d/b.png", [""]), false) // IT|isType|/d/b.png|[,]|false
  assert_eq(@path.is_type("/d/b.png", []), false) // IT|isType|/d/b.png|[]|false
  assert_eq(@path.is_type("/d/b.png", ["txt", ""]), false) // IT|isType|/d/b.png|[txt,,]|false
  assert_eq(@path.is_type("/d/b.png", ["gz"]), false) // IT|isType|/d/b.png|[gz,]|false
  assert_eq(@path.is_type("/d/b.png", ["tar.gz"]), false) // IT|isType|/d/b.png|[tar.gz,]|false
  assert_eq(@path.is_type("/d/b.png", ["Tar.GZ"]), false) // IT|isType|/d/b.png|[Tar.GZ,]|false
  assert_eq(@path.is_type("/d/b.png", ["ar.gz"]), false) // IT|isType|/d/b.png|[ar.gz,]|false
  assert_eq(@path.is_type("\u{4e2d}\u{6587}.txt", ["txt"]), true) // IT|isType|{u4e2d}{u6587}.txt|[txt,]|true
  assert_eq(@path.is_type("\u{4e2d}\u{6587}.txt", ["TXT"]), true) // IT|isType|{u4e2d}{u6587}.txt|[TXT,]|true
  assert_eq(@path.is_type("\u{4e2d}\u{6587}.txt", ["txt", "jpg"]), true) // IT|isType|{u4e2d}{u6587}.txt|[txt,jpg,]|true
  assert_eq(@path.is_type("\u{4e2d}\u{6587}.txt", ["jpg", "txt"]), true) // IT|isType|{u4e2d}{u6587}.txt|[jpg,txt,]|true
  assert_eq(@path.is_type("\u{4e2d}\u{6587}.txt", [".txt"]), false) // IT|isType|{u4e2d}{u6587}.txt|[.txt,]|false
  assert_eq(@path.is_type("\u{4e2d}\u{6587}.txt", [""]), false) // IT|isType|{u4e2d}{u6587}.txt|[,]|false
  assert_eq(@path.is_type("\u{4e2d}\u{6587}.txt", []), false) // IT|isType|{u4e2d}{u6587}.txt|[]|false
  assert_eq(@path.is_type("\u{4e2d}\u{6587}.txt", ["txt", ""]), true) // IT|isType|{u4e2d}{u6587}.txt|[txt,,]|true
  assert_eq(@path.is_type("\u{4e2d}\u{6587}.txt", ["gz"]), false) // IT|isType|{u4e2d}{u6587}.txt|[gz,]|false
  assert_eq(@path.is_type("\u{4e2d}\u{6587}.txt", ["tar.gz"]), false) // IT|isType|{u4e2d}{u6587}.txt|[tar.gz,]|false
  assert_eq(@path.is_type("\u{4e2d}\u{6587}.txt", ["Tar.GZ"]), false) // IT|isType|{u4e2d}{u6587}.txt|[Tar.GZ,]|false
  assert_eq(@path.is_type("\u{4e2d}\u{6587}.txt", ["ar.gz"]), false) // IT|isType|{u4e2d}{u6587}.txt|[ar.gz,]|false
}

// 不落断言的读数：参照 `getSuffix`/`getPrefix` 各 62 条 —— 它们是 `extName`/`mainName`
//   的委托，腿里两侧逐档同读数（并排钉在 spec），本库不出第二个同义件；
//   null 入参与 `File` 重载档共 36 条 —— 本库无对位形状（String 不收 null、零 FFI）。
