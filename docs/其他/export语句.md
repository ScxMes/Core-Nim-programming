## export语句

一个`export`语句可以用于符号转发，所以客户端模块不需要导入一个模块的依赖关系:

```
# module B
type 
  MyObject* = object
  MyInt* = distinct int

```
```
# module A

import B
export B.MyObject,B.MyInt  

proc `$`*(x: MyObject): string = "my object"
```
```
# module C
import A

# B.MyObject has been imported implicitly here:

var x: MyObject
echo($x)

var y:MyInt
```

## deprecated pragma

deprected编译可以用于标记一个符号为弃用(过时):

```
var x {.deprecated.}: char

x='a'
echo x

proc p():int {.deprecated.}=
  result=3

discard p()
```

它也可以作为一个语句使用，在这种情况下它表示别名列表.

```
type
  File = object
  Stream = ref object

{.deprecated: [TFile: File, PStream: Stream].}

var 
  myFile:TFile
  myFile2:File
  myStream:PStream
```
可以使用nimfix，毫不费力，自动更新你的代码，然后，通过执行这些别名重构它。
