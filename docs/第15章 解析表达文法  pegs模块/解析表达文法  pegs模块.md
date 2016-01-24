##Pegs 模块
简单的PEG（解析表达文法）匹配。没有使用任何记忆，而是用superoperators和符号内联来提升性能。注意：PEG匹配性能是希望与正则表达式引擎竞争的。


###PEG的语法和语义
 一个PEG（解析表达文法）是一个简单的确定性的语法，它可以直接用于解析。当前的实现已经被设计为一个更强大的来替代正则表达式。UTF-8是支持的。

用于PEG的符号与EBNF（扩展巴科斯范式）是相似的。

<table>
   <tr>
      <td>notation</td>
      <td>meaning</td>
   </tr>
   <tr>
      <td>A / ... / Z</td>
      <td>    顺序选择：应用于表达式A,...,Z，按照这种顺序，从文本的前面开始，直到其中一个成功，并且可能消耗一些文本。如果表达式中只要一个得到满足，则表明成功，否则不消耗任何文本，表明失败。</td>
   </tr>
   <tr>
      <td>A ... Z</td>
      <td>    序列：应用于表达式A,...Z，按照这个顺序，消耗文本前面连续的部分，只要它们满足。如果都能匹配表明成功，否则不消耗任何文本表明失败。这个序列的优先级要高于顺序选择的优先级：A B / C意思是(A B) / C，而不是A (B / Z)。</td>
   </tr>
   <tr>
      <td>(E)</td>
      <td>分组：圆括号用来改变运算符优先级。</td>
   </tr>
   <tr>
      <td>{E}</td>
      <td>捕获：应用于表达式E，并且存储匹配E的子串，在匹配过程后可以被调用。</td>
   </tr>
   <tr>
      <td>$i</td>
      <td>后向引用第i个捕获，i从1开始。</td>
   </tr>
   <tr>
      <td>$</td>
      <td>锚：匹配输入（字符串）的结尾，不消耗字符，与 !. 一样。</td>
   </tr>
   <tr>
      <td>^</td>
      <td>锚：匹配输入（字符串）的开始，没有字符被消耗。</td>
   </tr>
   <tr>
      <td>&E</td>
      <td>与断言：如果表达式E匹配前面的文本，则表明成功。否则表明失败。不消耗任何文本。</td>
   </tr>
   <tr>
      <td>!E</td>
      <td>非断言：如果表达式E匹配前面的文本，则表明失败。否则表明成功。不消耗任何文本。</td>
   </tr>
   <tr>
      <td>E+</td>
      <td>一个或多个：应用于表达式E多次匹配前面的文本，只要能匹配成功。消耗匹配的文本（如果有的话），并且如果至少满足一个则表明成功，否则失败。</td>
   </tr>
   <tr>
      <td>E*</td>
      <td>零个或多个：应用于表达式E多次匹配前面的文本，只要能匹配成功。消耗匹配的文本（如果有的话）。总是表明成功。</td>
   </tr>
   <tr>
      <td></td>
   </tr>
   <tr>
      <td>E?</td>
      <td>零个或一个：如果表达式E匹配前面的文本，消耗它，总是表明成功。</td>
   </tr>
   <tr>
      <td>[s]</td>
      <td>字符分类：如果前面的字符出现在字符串s中，消耗它，并且表明成功，否则失败。</td>
   </tr>
   <tr>
      <td>[a-b]</td>
      <td>字符范围：如果前面的字符是a-b范围中的，消耗它，并且表明成功，否则失败。</td>
   </tr>
   <tr>
      <td>'s'</td>
      <td>字符串：如果前面的文本是字符串s，消耗它，并且表明成功，否则失败。</td>
   </tr>
   <tr>
      <td>i's'</td>
      <td>忽略大小写的字符串匹配</td>
   </tr>
   <tr>
      <td>y's'</td>
      <td>忽略拼写风格的字符串匹配</td>
   </tr>
   <tr>
      <td>v's'</td>
      <td>逐字字符串匹配：使用这个来重载一个全局的 \i 或 \y 修饰符</td>
   </tr>
   <tr>
      <td>i$j</td>
      <td>字符串匹配忽略大小写后向引用</td>
   </tr>
   <tr>
      <td>y$j</td>
      <td>字符串匹配忽略拼写风格后向引用（忽略大小写和下划线等）</td>
   </tr>
   <tr>
      <td>v$j</td>
      <td>逐字字符串匹配后向引用</td>
   </tr>
   <tr>
      <td>.</td>
      <td>任意字符：如果有一个字符在前面，消耗它，并且表明成功，否则（也就是说，在输入的末尾）表明失败。</td>
   </tr>
   <tr>
      <td>_</td>
      <td>任何Unicode字符：如果有一个UTF-8字符在前面，消耗它，并且表明成功，否则表明失败。（下划线）</td>
   </tr>
   <tr>
      <td>@E</td>
      <td>搜索：(!E .)* E 的简写。（循环搜索模式E）</td>
   </tr>
   <tr>
      <td>{@} E</td>
      <td>捕获搜索：{(!E .)*} E。（循环搜索模式E）捕获所有直到不能匹配。</td>
   </tr>
   <tr>
      <td>@@ E</td>
      <td>与 {@} E 相同</td>
   </tr>
   <tr>
      <td>A <- E</td>
      <td>规则：绑定表达式E到非终结符A上，左递归规则是不可能的，并且会使匹配引擎崩溃。</td>
   </tr>
   <tr>
      <td>\identifier</td>
      <td>为一个长表达式内置的宏.</td>
   </tr>
   <tr>
      <td>\ddd</td>
      <td>十进制字符代码 ddd  ??????</td>
   </tr>
   <tr>
      <td>\", etc</td>
      <td>字面量,等</td>
   </tr>
</table>



***


###内置的宏
<table>
   <tr>
      <td>macro</td>
      <td>meaning</td>
   </tr>
   <tr>
      <td>\d</td>
      <td>任何十进制数子：[0-9]</td>
   </tr>
   <tr>
      <td>\D</td>
      <td>任何不是十进制数子的字符：[^0-9]</td>
   </tr>
   <tr>
      <td>\s</td>
      <td>任何空格字符: [ \9-\13]</td>
   </tr>
   <tr>
      <td>\S</td>
      <td>任何不是空格的字符: [^ \9-\13]</td>
   </tr>
   <tr>
      <td>\w</td>
      <td>任何”word”字符: [a-zA-Z0-9_]</td>
   </tr>
   <tr>
      <td>\W</td>
      <td>任何"non-word" 字符: [^a-zA-Z0-9_]</td>
   </tr>
   <tr>
      <td>\a</td>
      <td>和 [a-zA-Z]相同</td>
   </tr>
   <tr>
      <td>\A</td>
      <td>和 [^a-zA-Z]相同</td>
   </tr>
   <tr>
      <td>\n</td>
      <td>任何换行符组合: \10 / \13\10 / \13</td>
   </tr>
   <tr>
      <td>\i</td>
      <td>忽略大小匹配；从PEG开始使用</td>
   </tr>
   <tr>
      <td>\y</td>
      <td>忽略拼写风格的匹配; 从PEG开始使用</td>
   </tr>
   <tr>
      <td>\skip</td>
   </tr>
   <tr>
      <td>pat</td>
      <td>在试图匹配其他符号之前跳过模式pat ；这个对于跳过空格是有用的，例如： \skip(\s*) {\ident} ':' {\ident} 匹配键值对，忽略 ：旁边的空格。</td>
   </tr>
   <tr>
      <td>\ident</td>
      <td>一个标准ASCII标识符: [a-zA-Z_][a-zA-Z_0-9]*</td>
   </tr>
   <tr>
      <td>\letter</td>
      <td>任何Unicode字母</td>
   </tr>
   <tr>
      <td>\upper</td>
      <td>任何Unicode大写字母</td>
   </tr>
   <tr>
      <td>\lower</td>
      <td>任何Unicode小写字母</td>
   </tr>
   <tr>
      <td>\title</td>
      <td>任何Unicode头字母</td>
   </tr>
   <tr>
      <td>\white</td>
      <td>任何Unicode空格字符</td>
   </tr>
</table>


一个反斜杠后面跟着一个字母是一个内置的宏，否则它用于普通的转码：

<table>
   <tr>
      <td>notation</td>
      <td>meaning</td>
   </tr>
   <tr>
      <td>\\</td>
      <td>一个反斜杠</td>
   </tr>
   <tr>
      <td>\*</td>
      <td>相当于 '*'</td>
   </tr>
   <tr>
      <td>\t</td>
      <td>不是一个跳格键,而是一个（未知）内置</td>
   </tr>
</table>




###支持PEG语法
PEG解析器实现这个语法（被写入PEG语法）：

```
# Example grammar of PEG in PEG syntax.
# Comments start with '#'.
# First symbol is the start symbol.

grammar <- rule* / expr

identifier <- [A-Za-z][A-Za-z0-9_]*
charsetchar <- "\\" . / [^\]]
charset <- "[" "^"? (charsetchar ("-" charsetchar)?)+ "]"
stringlit <- identifier? ("\"" ("\\" . / [^"])* "\"" /
                          "'" ("\\" . / [^'])* "'")
builtin <- "\\" identifier / [^\13\10]

comment <- '#' @ \n
ig <- (\s / comment)* # things to ignore

rule <- identifier \s* "<-" expr ig
identNoArrow <- identifier !(\s* "<-")
prefixOpr <- ig '&' / ig '!' / ig '@' / ig '{@}' / ig '@@'
literal <- ig identifier? '$' [0-9]+ / '$' / '^' /
           ig identNoArrow /
           ig charset /
           ig stringlit /
           ig builtin /
           ig '.' /
           ig '_' /
           (ig "(" expr ig ")")
postfixOpr <- ig '?' / ig '*' / ig '+'
primary <- prefixOpr* (literal postfixOpr*)

# Concatenation has higher priority than choice:
# ``a b / c`` means ``(a b) / c``

seqExpr <- primary+
expr <- seqExpr (ig "/" expr)*
```


注意：作为一个特殊的语法扩展，如果整个PEG仅仅是一个表达式，那么标识符不是解释为一个非终结符，而是作为一个逐字的字符串：

```
import pegs

var abc = "abc"
echo abc =~ peg"abc" # is true
```

所以在上面这个例子中，是没有必要写成peg" 'abc' "的。




###例子

检查s是否匹配Nim的”while”关键字：
```
import pegs

var s = "Whi_le"
echo s =~ peg" y'while'"      #y’while’  忽略大小写和下划线等。
```

交换(key, val) 对值：
```
import pegs

var peg1 = peg"{\ident} \s* ':' \s* {\ident}"
echo "key: val; key2: val2".replacef(peg1, "$2: $1")
```

确定C文件中#inclued的文件：
C文件tc.c:
```
#include"stdio.h"
#include"math.h"
//author: yrs
/*this is a test file*/

int main() {
	printf("Hello Nim!");
	return 0;
}
```

Nim文件：
```
import pegs

for line in lines("tc.c"):
  if line =~ peg"""s <- ws '#include' ws '"' {[^"]+} '"' ws
                   comment <- '/*' @ '*/' / '//' .*
                   ws <- (comment / \s+)* """:
    echo matches[0]
```

转换一个PEG为它的字符串表达方式，tpeg.nim:
```
import pegs
var s = peg"{\ident} \s* '=' \s* {.*}"
echo($s)
```

测试过程transformFile,  ttransformFile.nim:
```
import pegs

transformFile("infile.txt", "outfile.txt",
  [(peg"""S <- {typedesc} \s* {\ident} \s* ','
         typedesc <- \ident '*'* """, r"$2: $1")])
```

过滤文件myfile.txt中的key=value对， tkeyvalue.nim:
```
# Filter key=value pairs from "myfile.txt"
import pegs

for x in lines("myfile.txt"):
  if x =~ peg"{\ident} \s* '=' \s* {.*}":
    echo "Key: ", matches[0],
         " Value: ", matches[1]
```

测试过程match和模板 `=~`:
```
import pegs

echo match("(a b c)", peg"'(' @ ')'")
echo match("W_HI_Le", peg"\y 'while'")       #\y 忽略格式匹配

if `=~`("((a b) c)", peg"{'(' @ ')'}"):
  echo matches[0]

if `=~`("杨汝生", peg"{_*}"):
  echo matches[0]

if `=~`("11aaadd", peg"{.*}"):
  echo matches[0]

if `=~`("yrs :a22",peg"\skip(\s*) {\ident} ':' {\ident}"):
  echo matches[0]," : ",matches[1]
```

测试过程replacef：
```
import pegs 

var peg1 = peg"{\ident} \s* ':' \s* {\ident}"
echo "key: val; key2: val2".replacef(peg1, "$2: $1")

echo "var1=key; var2=key2".replacef(peg"{\ident}'='{\ident}", "$1<-$2$2")
```

测试过程`!*`:
```
import pegs

var 
  str = "[aadd]aaa]b]qq]ba]q]ss]"#aas[lll]"
  peg1 = peg" \] "
  
for substr in findAll(str, sequence(peg"\[", `!*`(peg1))):             
  echo substr

peg1 = peg" \[ @ \] "    # @ 应该相当于运算符 `!*`
echo findAll(str, peg1)
```

```
import pegs

var 
  str = "abc123def"
  peg1 = peg"(\a)"
  peg4: Peg

peg4 = `!*`(peg1)  

for sub in findAll(str, peg4):
  echo sub
echo "*************"

for sub in findAll(str, peg"@ \a"):           # 运算符`!*` 应该相当于 @
  echo sub

```


测试过程`/`，顺序选择 A / ... / Z 
```
import pegs

var 
  str = "a 1@b"
  peg1 = peg"(\d)"
  peg2 = peg"(\s)"
  peg3 = peg"(\a)"
  peg4: Peg
  peg5 = peg"(\d)/(\a)"

peg4 = `/`(peg1,peg2,peg3)  

for sub in findAll(str, peg4):
  echo sub
echo "*************"

for sub in findAll(str, peg1 / peg3):
  echo sub
echo "*************"

for sub in findAll(str, peg5):
  echo sub
```


测试过程sequence，序列： A ... Z 
```
import pegs

var 
  str = "a 1@b"
  peg1 = peg"(\a)"
  peg2 = peg"(\s)*"
  peg3 = peg"(\d)"
  peg4: Peg
  peg5 = peg"(\a) (\s)* (\d)"

peg4 = sequence(peg1,peg2,peg3)  

for sub in findAll(str, peg4):
  echo sub
echo "*************"

for sub in findAll(str, peg5):
  echo sub
```


测试过程`!*\`
```
import pegs

var 
  str = "1abc123def"
  peg1 = peg"(\a)"
  peg4: Peg

peg4 = `!*\`(peg1)           # 运算符 `!*\` 相当于 {@}  或 @@

for sub in findAll(str, peg4):
  echo sub
echo "*************"

echo findAll(str, peg"{@} \a")
echo findAll(str, peg"{(!\a .)*} \a")
echo findAll(str, peg"@@ \a")
echo findAll(str, peg"{@ \a}")
echo findAll(str, peg4)
```



测试与断言：
```
import pegs

var 
  str = "abc123de2f"
  peg1 = peg"\d & 'd' "      #只有 模式 \d 后面跟的是字母’b'时，才会匹配 \d
  peg2: Peg

echo findAll(str, peg1)

peg2 = sequence(peg".", `&`(peg"\d\a'e'"))
#peg2 = `&`(peg"\d\a'e'")   #不能单独使用与断言，机器会崩溃，  与断言前面得有一个表达式。只有与断言后面匹配了，前面的表达式才能捕获。
echo findAll(str, peg2)
```


测试字符串的起始位和结束位：^  $
```
import pegs

var
  str = "sabc123"
  peg1 = peg" ^ \a"
  peg2 = peg" \d $"

echo findAll(str, peg1)
echo findAll(str, peg2)

```





###PEG vs regular expression

作为一个正则表达式 \[.*\] 匹配最长可能的文本在 '[' 和 ']'之间。作为一个PEG它不会匹配任何东西，因为一个PEG是确定的：.* 消耗输入的剩余部分，因此 \] 从来不会匹配。PEG要写成：\[ ( !\] . )* \] （或者 \[ @ \]），会匹配'[' 和 ']'之间的文本，但匹配的是最短的文本。

正则表达式：
```
import re

for x in findAll("xxx[aadd]aaa]qqq])234xdv", re"\[.*\]"):
  echo x
```

PEG：
```
import pegs

var 
  str = "[aadd]aaa]a]qq]aa]q]ss]"
  peg1 = peg"\[ @ \]"    #最短匹配
  #peg1 = peg"\[ (!(\] (!\] .)* $) . )* \]"    #最长匹配

for substr in findAll(str, peg1):
  echo substr
```

注意：正则表达式没有表现的目的之一：在这个例子中 * 不应该是贪婪的，如果想匹配最短内容则使用 \[.*?\]。





###PEG构造
在Nim中有两种方式来构造一个PEG：



1. 解析一个字符串到一个由Peg节点和Peg过程组成的AST里。


1. 直接调用过程构造AST。这种方法不支持构造规则，仅仅支持简单的表达式，并且是不方便的。它唯一的优势是不把整个PEG解析加入到你的可执行文件中。



###pegs模块 types

Peg类型： 这个类型表示一个PEG。

Captures类型： 包含捕获的子字符串。

EInvalidPeg类型：如果发现一个无效的PEG，将会引起异常。


###常量
MaxSubpatterns = 20

定义了能够捕获子模式的最大数量，更多的子模式将不能被捕获。



###过程
```
proc term(t: string): Peg {.nosideEffect, gcsafe, extern: "npegs$1Str", raises: [],
                        tags: [].}
从一个终端字符串构造一个PEG   Source
proc termIgnoreCase(t: string): Peg {.nosideEffect, gcsafe, extern: "npegs$1",
                                  raises: [], tags: [].}
从一个终端字符串构造一个PEG，忽略大小写匹配   Source
proc termIgnoreStyle(t: string): Peg {.nosideEffect, gcsafe, extern: "npegs$1",
                                   raises: [], tags: [].}
从一个终端字符串构造一个PEG，忽略拼写风格匹配（大小写，下划线等）   Source
proc term(t: char): Peg {.nosideEffect, gcsafe, extern: "npegs$1Char", raises: [],
                      tags: [].}
从一个终端字符构造一个PEG   Source
proc charSet(s: set[char]): Peg {.nosideEffect, gcsafe, extern: "npegs$1", raises: [],
                              tags: [].}
从一个终端字符集合s构造一个PEG   Source
proc `/`(a: varargs[Peg]): Peg {.nosideEffect, gcsafe, extern: "npegsOrderedChoice",
                             raises: [], tags: [].}
构造一个顺序选择的PEG，只要满足其中一个则表明成功  Source
proc sequence(a: varargs[Peg]): Peg {.nosideEffect, gcsafe, extern: "npegs$1",
                                  raises: [], tags: [].}
由多个PEGs a 来构造一个序列。对应与 A ... Z   Source
proc `?`(a: Peg): Peg {.nosideEffect, gcsafe, extern: "npegsOptional", raises: [],
                    tags: [].}
构造一个可选的 PEG a，对应于 a?   Source
proc `*`(a: Peg): Peg {.nosideEffect, gcsafe, extern: "npegsGreedyRep", raises: [],
                    tags: [].}
构造一个贪婪的重复的 PEG a，对应于a*   Source
proc `!*`(a: Peg): Peg {.nosideEffect, gcsafe, extern: "npegsSearch", raises: [], tags: [].}
构造一个"search" PEG a ，应该相当于 @a   Source
proc `!*\`(a: Peg): Peg {.noSideEffect, gcsafe, extern: "npgegsCapturedSearch",
                      raises: [], tags: [].}
构造一个捕获搜索的PEG a( "captured search" for the PEG a), 应该相当于 {@} a  或 @@ a。   Source
proc `+`(a: Peg): Peg {.nosideEffect, gcsafe, extern: "npegsGreedyPosRep", raises: [],
                    tags: [].}
构造一个正向贪婪重复的PEG a，相当于 a+   Source
proc `&`(a: Peg): Peg {.nosideEffect, gcsafe, extern: "npegsAndPredicate", raises: [],
                    tags: [].}
构造一个与断言的 PEG a，相当于&a   Source
proc `!`(a: Peg): Peg {.nosideEffect, gcsafe, extern: "npegsNotPredicate", raises: [],
                    tags: [].}
构造一个非断言的 PEG a，相当于 !a   Source
proc any(): Peg {.inline, raises: [], tags: [].}
构造匹配任何字符的PEG： (.)   Source
proc anyRune(): Peg {.inline, raises: [], tags: [].}
构造匹配任何Unicode字符： (_)   Source
proc newLine(): Peg {.inline, raises: [], tags: [].}
构造换行符 PEG：(\n)   Source
proc unicodeLetter(): Peg {.inline, raises: [], tags: [].}
构造匹配任何Unicode字母的 PEG： \letter  Source
proc unicodeLower(): Peg {.inline, raises: [], tags: [].}
构造匹配任何Unicode小写字母的 PEG：\lower   Source
proc unicodeUpper(): Peg {.inline, raises: [], tags: [].}
构造匹配任何Unicode大写字母的 PEG： \upper   Source
proc unicodeTitle(): Peg {.inline, raises: [], tags: [].}
构造匹配任何Unicode title letter（？？？）的 PEG：\title   Source
proc unicodeWhitespace(): Peg {.inline, raises: [], tags: [].}
构造匹配任何Unicode空格符的 PEG： \white    Source
proc startAnchor(): Peg {.inline, raises: [], tags: [].}
构造匹配输入开始位的PEG ^    Source
proc endAnchor(): Peg {.inline, raises: [], tags: [].}
构造匹配输入结尾的PEG：$    Source
proc capture(a: Peg): Peg {.nosideEffect, gcsafe, extern: "npegsCapture", raises: [],
                        tags: [].}
构造一个PEG a的捕获，相当与{a}   Source
proc backref(index: range[1 .. MaxSubpatterns]): Peg {.nosideEffect, gcsafe,
    extern: "npegs$1", raises: [], tags: [].}
构造一个后向引用的PEG，索引是index，其值从1开始，最大值是MaxSubpatterns(常量20），相当与 $i   Source
proc backrefIgnoreCase(index: range[1 .. MaxSubpatterns]): Peg {.nosideEffect,
    gcsafe, extern: "npegs$1", raises: [], tags: [].}
构造一个后向引用的PEG，索引是index，其值从1开始，最大值是MaxSubpatterns(常量20），匹配忽略大小写，相当与 i$j   Source
proc backrefIgnoreStyle(index: range[1 .. MaxSubpatterns]): Peg {.nosideEffect,
    gcsafe, extern: "npegs$1", raises: [], tags: [].}
构造一个后向引用的PEG，索引是index，其值从1开始，最大值是MaxSubpatterns(常量20），匹配忽略拼写风格（大小写，下划线等），相当与 y$j   Source
proc nonterminal(n: NonTerminal): Peg {.nosideEffect, gcsafe, extern: "npegs$1",
                                    raises: [], tags: [].}
构造一个由非终结符组成的PEG   Source
proc newNonTerminal(name: string; line, column: int): NonTerminal {.nosideEffect,
    gcsafe, extern: "npegs$1", raises: [], tags: [].}
构造一个非终结符号   Source
proc `$`(r: Peg): string {.nosideEffect, gcsafe, extern: "npegsToString", raises: [],
                       tags: [].}
转化一个PEG为它的字符串表示形式   Source
proc bounds(c: Captures; i: range[0 .. 20 - 1]): tuple[first, last: int] {.raises: [],
    tags: [].}
返回第i个捕获的边界 [first..last]    Source
proc rawMatch(s: string; p: Peg; start: int; c: var Captures): int {.nosideEffect,
    gcsafe, extern: "npegs$1", raises: [], tags: [].}
底层匹配过程，实现PEG解释器。使用这个来达到最高效率（每一个其他的PEG操作都以调用这个过程结束），如果没有匹配将返回-1，否则返回匹配的长度。   Source
proc matchLen(s: string; pattern: Peg; matches: var openArray[string]; start = 0): int {.
    nosideEffect, gcsafe, extern: "npegs$1Capture", raises: [], tags: [].}
和match一样，不过它返回匹配的长度，如果没有匹配，将返回-1。注意一个匹配的长度可能是0. s 的下标可能不属于这个匹配（？？？）   Source
proc matchLen(s: string; pattern: Peg; start = 0): int {.nosideEffect, gcsafe,
    extern: "npegs$1", raises: [], tags: [].}
和match一样，不过它返回匹配的长度，如果没有匹配，将返回-1。注意一个匹配的长度可能是0. s 的下标可能不属于这个匹配（？？？）   Source
proc match(s: string; pattern: Peg; matches: var openArray[string]; start = 0): bool {.
    nosideEffect, gcsafe, extern: "npegs$1Capture", raises: [], tags: [].}
如果s[start..]匹配 pattern，并且捕获子字符串到数组matches里，那么将返回true。如果没有匹配，不会向数组中写数据，并且返回false   Source
proc match(s: string; pattern: Peg; start = 0): bool {.nosideEffect, gcsafe,
    extern: "npegs$1", raises: [], tags: [].}
如果s从start出开始匹配pattern，则返回true   Source
proc find(s: string; pattern: Peg; matches: var openArray[string]; start = 0): int {.
    nosideEffect, gcsafe, extern: "npegs$1Capture", raises: [], tags: [].}
返回s匹配pattern的开始位置，并且捕获子字符串到数组matches中。如果没有匹配，不写入matches任何数据，并且返回-1   Source
proc findBounds(s: string; pattern: Peg; matches: var openArray[string]; start = 0): tuple[
    first, last: int] {.nosideEffect, gcsafe, extern: "npegs$1Capture", raises: [],
                     tags: [].}
返回字符串s匹配pattern的开始和结束位置，并且捕获子字符串到数组matches中，如果没有匹配，数组不写入任何数据，并且返回（-1,0）  Source
proc find(s: string; pattern: Peg; start = 0): int {.nosideEffect, gcsafe,
    extern: "npegs$1", raises: [], tags: [].}
返回s匹配pattern的开始位置，如果没有匹配，将返回-1   Source
proc findAll(s: string; pattern: Peg; start = 0): seq[string] {.nosideEffect, gcsafe,
    extern: "npegs$1", raises: [], tags: [].}
返回s匹配pattern的所有子字符串，如果没有匹配，将返回@[]   Source
proc contains(s: string; pattern: Peg; start = 0): bool {.nosideEffect, gcsafe,
    extern: "npegs$1", raises: [], tags: [].}
相当于 find(s, pattern, start) >= 0   Source
proc contains(s: string; pattern: Peg; matches: var openArray[string]; start = 0): bool {.
    nosideEffect, gcsafe, extern: "npegs$1Capture", raises: [], tags: [].}
相当于 find(s, pattern, matches, start) >= 0   Source
proc startsWith(s: string; prefix: Peg; start = 0): bool {.nosideEffect, gcsafe,
    extern: "npegs$1", raises: [], tags: [].}
如果s以pattern为前缀开始，那么返回true   Source
proc endsWith(s: string; suffix: Peg; start = 0): bool {.nosideEffect, gcsafe,
    extern: "npegs$1", raises: [], tags: [].}
如果s以pattern为后缀结束，那么返回true   Source
proc replacef(s: string; sub: Peg; by: string): string {.nosideEffect, gcsafe,
    extern: "npegs$1", raises: [ValueError], tags: [].}
用字符串by来替代s中的sub部分。匹配捕获的可以通过符号$i和$#访问（看strutils.`%`),例如：
"var1=key; var2=key2".replacef(peg"{\ident}'='{\ident}", "$1<-$2$2")
Results in:
"var1<-keykey; val2<-key2key2"
  Source
proc replace(s: string; sub: Peg; by = ""): string {.nosideEffect, gcsafe,
    extern: "npegs$1", raises: [], tags: [].}
用字符串by来替代s中的sub部分，捕获的数据不能访问   Source
proc parallelReplace(s: string; subs: varargs[tuple[pattern: Peg, repl: string]]): string {.
    nosideEffect, gcsafe, extern: "npegs$1", raises: [ValueError], tags: [].}
返回s被subs并行代替改变后的复制   Source
proc transformFile(infile, outfile: string;
                  subs: varargs[tuple[pattern: Peg, repl: string]]) {.gcsafe,
    extern: "npegs$1", raises: [Exception, IOError, ValueError],
    tags: [ReadIOEffect, WriteIOEffect].}
读infile文件，执行一个并行性替换（调用parallelReplace),并且写入outfile文件。如果发生一个错误将会引起EIO异常，这个应该用于快速脚本   Source
proc split(s: string; sep: Peg): seq[string] {.nosideEffect, gcsafe, extern: "npegs$1",
    raises: [], tags: [].}
切割字符串为子字符串   Source
proc parsePeg(pattern: string; filename = "pattern"; line = 1; col = 0): Peg {.
    raises: [ValueError, EInvalidPeg, Exception], tags: [RootEffect].}
以pattern构造一个Peg对象，filename、line、col被用于错误信息，但是它们仅仅提供开始偏移量。parsePeg保持值对pattern内部的line和column数的追踪   Source
proc peg(pattern: string): Peg {.raises: [ValueError, EInvalidPeg, Exception],
                             tags: [RootEffect].}
以pattern构造一个Peg对象，简写已经被推荐使用原始字符串修饰符，例如:
peg"{\ident} \s* '=' \s* {.*}"
  Source
proc escapePeg(s: string): string {.raises: [], tags: [].}
转义s,以至于它被逐字匹配当被用于一个peg时   Source
Iterators
iterator findAll(s: string; pattern: Peg; start = 0): string {.raises: [], tags: [].}
产生所有的s中匹配pattern的子字符串   Source
iterator split(s: string; sep: Peg): string {.raises: [], tags: [].}
切割字符串s为子字符串，
子串被 PEG sep分割. Examples:
for word in split("00232this02939is39an22example111", peg"\d+"):
  writeLine(stdout, word)
Results in:
"this"
"is"
"an"
"example"
  Source
Templates
template letters(): expr
扩大到 charset({'A'..'Z', 'a'..'z'})   Source
template digits(): expr
扩大到 charset({'0'..'9'})   Source
template whitespace(): expr
扩大到 charset({' ', '\9'..'\13'})   Source
template identChars(): expr
扩大到 charset({'a'..'z', 'A'..'Z', '0'..'9', '_'})   Source
template identStartChars(): expr
扩大到 charset({'A'..'Z', 'a'..'z', '_'})   Source
template ident(): expr
same as [a-zA-Z_][a-zA-z_0-9]*; standard identifier   Source
template natural(): expr
same as \d+   Source
template `=~`(s: string; pattern: Peg): bool
这个调用过程match，并且隐式的声明一个matches数组，这个数组能够在 =~ 作用域内调用:
if line =~ peg"\s* {\w+} \s* '=' \s* {\w+}":
  # matches a key=value pair:
  echo("Key: ", matches[0])
  echo("Value: ", matches[1])
elif line =~ peg"\s*{'#'.*}":
  # matches a comment
  # note that the implicit ``matches`` array is different from the
  # ``matches`` array of the first branch
  echo("comment: ", matches[0])
else:
  echo("syntax error")
  Source

```

































































