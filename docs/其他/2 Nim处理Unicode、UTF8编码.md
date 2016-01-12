##2 Nim处理Unicode、UTF8编码

unicode 模块提供支持处理Unicode、 utf - 8编码。
更多内容可以看unicode源文件，==》C:\Nim\lib\pure。

```
type
  RuneImpl = int
  Rune* = distinct RuneImpl                ##可以容纳任何 Unicode 字符 类型。
  Rune16* = distinct int16                   ##16位 Unicode 字符
```
#
```
procruneLen(s:string):int {.gcsafe,extern: "nuc$1", raises:[],tags: [].}
#返回UTF-8字符串s 所表示的Unicode字符个数。

procruneLenAt(s:string; i: Natural):int {.raises:[],tags: [].}
#这里的第二个参数是s[i] 所指的字节，根据utf8存储的特点，如果str[i]指向一个字符utr8码的头部，
#则返回这个字符所占字节数，否则返回1。

procvalidateUtf8(s:string):int {.raises:[],tags: [].}
#返回字符串s中第一个不是utf8码的字符位置，否则返回-1。
procruneAt(s:string; i: Natural):Rune {.raises:[],tags: [].}
#如果第二个参数是一个utf8码字符的开头索引(str[i])，则返回该字符的Unicode码。否则返回Rune(ord(str[i]))

proctoUTF8(c:Rune):string {.gcsafe,extern: "nuc$1", raises:[],tags: [].}
#将一个Unicode 字符转化为其UTF8表示

procreversed(s:string):string {.raises:[],tags: [].}
#反转字符串
```
迭代器：
iteratorrunes(s:string):Rune {.raises:[],tags: [].}

例：   
```   
import unicode,encodings

var str = "字符串"

echo len(str)                                        #返回存储字符串所用的字节数。 str[0]是指向字符串str第一个字节。
echo runeLen(str)                                    


echo runeLenAt(str,0)                                
echo runeLenAt(str,1)                               


echo validateUtf8(str)                              
var strcov = convert(str,"GB2312","UTF-8")           
echo validateUtf8(strcov)
var str2 = str & strcov 
echo validateUtf8(str2)


var index:Rune
index = runeAt(str,0)                                
echo int(index)       


var varU = Rune(0x6768)                              #杨的unicode码 0x6768
echo toUTF8(varU)                                    #将一个Rune转化为其UTF8表示
echo convert(toUTF8(varU),"GB2312","UTF-8")          #转为GB2312码


echo Rune(0x6768)                                        
#过程echo定义为proc echo(x: varargs[expr, `$`])，在unicode模块里，重载了`$`，使参数转换为utf8表示。 
var 
  yrs:seq[Rune]                                        #proc `$`(rune: Rune): string {.raises: [], tags: [].}
yrs = @[runeAt(str,0),runeAt(str,3),runeAt(str,6)]     #proc `$`(runes: seq[Rune]): string {.raises: [], tags: [].}
echo yrs,"    ", str


for i in runes str:               #runes 是一个字符串的迭代器。i是以Rune类型迭代。遍历任何 字符串s 的Unicode 字符
  echo i


echo reversed(str)

```  
  

注意：在windows下输出的可能会是乱码，因为程序处理的是UTF-8字符串，系统简体中文的编码为GB2313，所以会出现乱码，可以通过转码来解决。