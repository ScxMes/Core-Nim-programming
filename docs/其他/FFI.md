##外部函数接口

###Foreign function interface
Nim的FFI（外部函数接口）是庞大的，只有一部分扩展其他未来的后端（像LLVM/JavaScript后端）被写在这里。


###Importc pragma
Importc编译指示提供了一种方法：从C中导入一个函数或变量。可选参数是一个C语言中的函数名，如果不提供函数名，那么这个函数在C语言中的名字就是Nim中过程名。

```
proc printf(formatstr: cstring) {.header: "<stdio.h>", varargs.}
proc printf2(formatstr: cstring) {.header: "<stdio.h>", 
                                      importc: "printf", varargs.}
var x = 3
printf("%d", x)
printf2("\n%d", x+1)
```

在上例中第一个过程由于后面编译指示没有指出函数名所以该过程名必须是printf，第二个过程就可以自己命名了。

注意这个编译指示有点用词不当：其他的后端将提供和这个名称一样的相同功能，比如，对于C++使用importCpp编译指示，对于Object-C使用importObjc编译指示。


###Exportc pragma

exportc编译指示提供一种方法：输出一个类型、变量或过程给C程序。枚举和常量不能被输出。参数exportc后面跟的是输出的函数名，如果exportc编译指示后面没有指定函数名，那么C语言中的函数名就是Nim中过程的名字。例如：
```
proc callme(formatstr: cstring) {.exportc, varargs.} =
  echo("Hi,", formatstr)
proc callme2(formatstr: cstring) {.exportc: "CallMe", varargs.} =
  echo("Hi,", formatstr)
```

###Extern pragma

像exportc或importc，extern编译指示影响名字识别编码。字符串传递给extern能够被格式化：
```
proc p(s: string) {.extern: "prefix$1".} =
  echo s
```
在这个例子中外部的p被设定为prefixp.


###Bycopy pragma

bycopy编译指示能够被用于一个对象或元组类型，它能指示编译器去传递这个类型的值传给过程：
```
type
  Vector {.bycopy, pure.} = object
    x, y, z: float
```

###Byref pragma
bycopy编译指示能够被用于一个对象或元组类型，它能指示编译器去传递这个引用类型（隐式的指针）给过程：


###Varargs pragma

varargs编译指示仅仅能够被用于过程（和过程类型），它告知Nim在最后一个指定的参数后可以接受可变数量的实参。Nim字符串值将被自动转化为C字符串。

#不能运行
```
proc printf(formatstr: cstring) {.nodecl, varargs.} 

printf("hallo %s", "world") # "world" will be passed as C string
```


###Union pragma
union编译指示可以用于任何的object类型。这意味着对象的所有的字段都能被重叠在内存中。在生成的C/C++代码中会生成union而不是struct。这个对象后不能使用继承或任何的GC内存，但是这个目前是不能检测的。

未来方向：GC的内存允许union使用，并且GC能够适当地扫描unions。


###Packed pragma
Packed编译指示能够被用于任何的object类型，它确保对象的字段是被一个接一个的装进内存中。它对于存储数据包或来自/发送到网络的消息或者是硬件驱动，以及和C进行交互是有用的。结合packed编译指示和继承是没有定义的，它不能使用GC后的内存（ref’s)。

未来方向：在packed编译指示中使用GC后的内存将会出现编译时错误，和继承结合使用的方法应该被定义和有文档说明。



###Unchecked pragma
unchecked编译指示能够用于标记一个数组类型，意味着这个数组的边界是不被检查的。这个经常用于实现自定义的灵活大小的数组，另外一个unchecked的数组被翻译成C中的未确定大小的数组。
```
type
  ArrayPart{.unchecked.} = array[0..0, int]
  MySeq = object
    len, cap: int
    data: ArrayPart

var x:ArrayPart = [0]
echo(@x)
x[1] = 1    #若没有{.unchecked.}编译指示，将会出现 Error: index out of bounds
echo x[1]   #echo 1
echo(@x)    #echo @[0]
```
Type里面的内容大致会生成下面的C代码：
```
typedef struct {
  NI len;
  NI cap;
  NI data[];
} MySeq;
```

这个在编译时期将不做边界检查，因此，访问s.data[c](c是一个常量)，数组的索引不需要包括c。

Unchecked数组的基类型不可以包含GC后的内存，但是这个当前是不能检查的。

未来方向：GC后的内存应该允许在unchecked数组中使用，并且应该有一个明确的注释对于GC是确定运行时数组的大小。



###Dynlib pragma for import
使用dynlib编译指示一个过程或变量表示它能够从一个动态链接库（windows下是.dll文件，Unix下是lib*.so文件）导入。dynlib参数必须是动态库的名字:
proc gtk_image_new(): PGtkWidget
  {.cdecl, dynlib: "libgtk-x11-2.0.so", importc.}

通常而言，导入一个动态库不需要任何特殊的连接器选项或与导入库链接，这也意味着不需要安装开发包。

Dynlib导入机制支持版本控制方案：
```
proc Tcl_Eval(interp: pTcl_Interp, script: cstring): int {.cdecl,
  importc, dynlib: "libtcl(|8.5|8.4|8.3).so.(1|0)".}
```

在运行时会按照下面顺序寻找动态链接库：
```
libtcl.so.1
libtcl.so.0
libtcl8.5.so.1
libtcl8.5.so.0
libtcl8.4.so.1
libtcl8.4.so.0
libtcl8.3.so.1
libtcl8.3.so.0
```
Dynlib编译指示不仅支持字符串常量作为参数，而且还支持字符串表达式：
```
when defined(windows):
  const dllname = "iup(|30|27|26|25|24).dll"
elif defined(macosx):
  const dllname = "libiup(|3.0|2.7|2.6|2.5|2.4).dylib"
else:
  const dllname = "libiup(|3.0|2.7|2.6|2.5|2.4).so(|.1)"

proc open*(argc: ptr cint, argv: ptr cstringArray): cint {.
  importc: "IupOpen", cdecl, dynlib: dllname.}

proc message*(title, msg: cstring) {.
  importc: "IupMessage", dynlib: dllname, cdecl.}
  
proc close*() {.importc: "IupClose", cdecl, dynlib: dllname.}


discard open(nil, nil)
message("Hello World","Hello world from IUP")
close()

```


```
proc getDllName: string = 
  result = "iup.dll"

proc open*(argc: ptr cint, argv: ptr cstringArray): cint {.
  importc: "IupOpen", cdecl, dynlib: getDllName().}

proc message*(title, msg: cstring) {.
  importc: "IupMessage", dynlib: getDllName(), cdecl.}
  
proc close*() {.importc: "IupClose", cdecl, dynlib: getDllName().}


discard open(nil, nil)
message("Hello World","Hello world from IUP")
close()
```
注意：像libtcl(|8.5|8.4).so这种模式只支持字符串常量，因为它们是预编译。
    
注意：传递一个变量给dynlib编译指示在运行时会失败，像上例如果是变量var dllname将会编译出错， 由于初始化顺序问题。

注意：一个dynlib导入能够被重写:使用命令行--dynlibOverride:name ，编译器的用户指南包含更多信息。



###Dynlib progma for export

Dynlib编译指示一个过程能够使其输出一个动态链接库。这个编译指示没有参数，不得不结合使用export编译指示：
```
proc summer*(x, y: float): float {.cdecl, exportc, dynlib.} =
   result = x + y
```

要使其生成动态链接库得通过命令行选项： --app:lib， 该程序用于生成动态库。编译命令为 nim c --app:lib tdll.nim 。在Windows下会生成tdll.dll，linux下生成 libtdll.so。

调用上面程序生成的动态链接库：
```
const dllname = "tdll"  #linux 下得有路径，例如在同一个目录下为  ./libtdll.so
#const dllname = "tdll.dll"
#var dllname = "tdll.dll"      #错误

proc summer*(x, y: float): float {.cdecl, importc, dynlib: dllname.}
#proc summer*(x, y: float): float {.cdecl, importc, dynlib: "tdll.dll".}

echo summer (1.0,2.0)
```

###使用C代码
在Nim程序中可以编译使用C程序，例如：

C程序，名为tc.c：
```
void hi(char* name) {
  printf("hello %s\n", name);
}

int Newadd(int a,int b) {
	printf("%d %d\n",a,b);
	return a+b;
}
```

Nim程序：
```
#改程序是导入C文件中的函数，C文件为 tc.c
{.compile: "tc.c".}
proc hi*(name: cstring) {.importc.}
hi "from Nim"

proc Newadd*(a,b:cint): cint {.importc.}
echo Newadd(0,2)
```