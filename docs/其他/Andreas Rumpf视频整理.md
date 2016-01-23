# Andreas Rumpf
***
## What is Nim?
1. new systems programming language
2. compiles to c
3. garbage collection + manual memory management
4. thread local garbage collection
5. design goals:efficient,expressive,elegant

## Goals
1. as fast as C
2. as expressive as ptyhon
3. as extensible as Lisp

## Uses of Nim
1. Web development
2. games
3. compilers
4. operating system development
5. scentific computing
6. scripting
7. command line applications
8. UI applications

## 例子
```
#decimalToRomain.nim
proc decimalToRomain *(number:range[1..3_999]):string=
  ## converts a number to a Roman numeral
  const romanComposites={
    "M":1000,"CM":900,
    "D":500,"CD":400,"C":100,
    "XC":90,"L":50,"XL":40,"X":10,"IX":9,
    "V":5,"IV":4,"I":1}
  result=" "
  var decVal=number.int
  echo decVal
  for key,val in items(romanComposites):
    while decVal >= val:
      decVal -= val
      result.add(key)

var x=4000
echo decimalToRomain(x)         #Error: unhandled exception: value out of range: 4000 [RangeError]
echo decimalToRomain(1009)      #MIX

#{"M":1000,"CM":900}sugar for[("M",1000),("CM",900)]
#result implicitly available
```

## Function application
** here is the suger: **
<table>
  <tr>
    <td> suger </td>
    <td> meaning </td>
    <td> Example </td>
  </tr>
  <tr>
    <td> f a </td>
    <td> f(a) </td>
    <td> spawn log("some message") </td>
  </tr>
  <tr>
    <td> a.f() </td>
    <td> f(a) </td>
    <td> db.fetchRow() </td>
  </tr>
  <tr>
    <td> a.f </td>
    <td> f(a) </td>
    <td> mystring.len </td>
  </tr>
  <tr>
    <td> f a,b </td>
    <td> f(a,b) </td>
    <td> echo"hello","world" </td>
  </tr>
  <tr>
    <td> a.f(b) </td>
    <td> f(a,b) </td>
    <td> myarray.map(f) </td>
  </tr>
  <tr>
    <td> a.f b </td>
    <td> f(a,b) </td>
    <td> db.fetchRow 1 </td>
  </tr>
  <tr>
    <td> f"\n" </td>
    <td> f(r"\n") </td>
    <td> re"\b[a-z*]\b" </td>
  </tr>
</table>

** But: f does not mean f(); myarray.map(f)passes f to map **

```
proc test(x:int):int=
 result=x

var a:int=9

discard test a
discard a.test()
discard a.test

proc test2(x,y:int):int=
  result=x+y

var
  b:int=1
  c:int=2

#discard test2 b,c   #这种操作出错了
discard c.test2(b)
discard c.test2 b

echo "hello","world"
```

## Operators
** Operators are simply sugar for functions **
** Operators in backticks is treated like an identifier **
```
`@`(x,y)
x.`@`(y)
`@`(x)
x.`@`()
x.`@`
```
of course,most of the time binary operators are simply invoked as x @ y and unary operators as @x
No explicit distinction between binary and unary operators
```
proc `++`(x:var int;y:int=1,z:int=0)=
  x=x+y+z

var g=70

++g
g++7
g.`++`(10,20)
echo g
```
** parameters are read only unless declared as `var`,`var`means "pass by reference"(implemented with a hidden pointer) **

## control flow
The usual control flow statements are avaible：
`if`,`case`,`when`,`while`,`for`,`try`,`defer`,`return`,`yield`

## statements vs expressions
** statements require indention: **
```
# no indention needed for single assignment statement:
if x:x=false

# indention needed for nested if statement:

if x:
  if y:
    y=false
else:
  y=true

# indention needed,because two statements follow the condition:
if x:
  x=false
  y=false
```
** Expression do not: **
```
if thisIsaLongCondition() and
     thisIsAnotherLongCondition(1,
       2,3,4):
  x=true
```
Rule of thumb:optional indentation after operators and `if` `case` ets also avaible as expressions

## Type system
1. strict and statically typed
2. type system weakened for the meta-programming
3. value based datatyped(like in c++)
4. subtyping via single inheritance(object of RotObj)
5. subtyping via range:** type Natural=range[0..high(int)] **
6. generics(** HashSet[string] **)
7. "concepts"constraints of generic types
8. ** no interface **,use(tuple of)** closures ** instead
9. No Hindley-milner type interface,Nim embraces overloading
10. limited amount of flow typing

[Hindley-milner](http://www.codecommit.com/blog/scala/what-is-hindley-milner-and-why-is-it-cool)

## Flow typing
```
proc f(p:ref int not nil)

var x:ref int

if x!=nil:
  f(x)      #Error: cannot prove 'x' is not nil
```

## Effect System
1. model effects as tuples ** (T,E) ** rather than ** E[T] **
2. every effect is inferred
3. tracks side effets
4. tracks exceptions
5. tracks "tags": `ReadIOEffect`,`WriteIoEffect`,`TimeEffect`,`ReadDirEffect`,`ExcelIOEffect`
6. tracks locking levels;deadlock prevention at compile-time
7. tracks "GC safety"

eg:
```
proc foo(){.noSideEffect.}=
  #echo "is IO a side effect?"          #Error: 'foo' can have side effects
  debugecho "is IO a side effect?"      #true
```
## Builtin types
### enums & sets
```
type
  SandboxFlag* = enum     ## what the interpreter should allow
    allowCast,           ## allow unsafe language feature:'cast'
    allowFFI,            ## allow the FFI
    allowInfiniteLoops   ## allow endless Loops
  SandboxFlags* = set[SandboxFlag]

proc runNimCode(code:string;flags:SandboxFlags={allowCast,allowFFI})=
  discard
```
** c代码 **
```
#define allowCast (1<<0)
#define allowFFI (1<<1)
#define allowInfiniteLoops (1<<1)

void runNimCode(char *code,unsigned int flags=allowCast|allowFFI);

runNimCode("4+5",700);
```

## Routines
** `proc`,`iterator`,`template`,`macro`,`method`,`converter`,`(func)` **

## Templates
```
template `??`(a,b:untyped):untyped=
  let x=a
  (if x.isNil:b else:x)

var x:string

echo x ?? "woohoo"
```
```
template html(name,body)=
  proc name():string=
    result="<html>"
    body
    result.add("<html>")

html mainPage:
  echo "colon syntax to pass statements to template"
```
Templates already suffice to implement simple DSLs:
```
html mainPage:
  head:
    title "The Nim programming Language"
  body:
    ul:
      li "efficient"
      li "expressive"
      li "elegant"

echo mainPage()


Produces:

<html>
  <head><title>The Nim progarmming Language</title></head>
  <body>
    <ul>
      <li> efficent </li>
      <li> expressive </li>
      <li> elegant </li>
    </ul>
  </body>
</html>
```

```
template html(name,body)=
  proc name():string=
    result="<html>"
    body
    result.add("<html>")

template head(body)=
  result.add("<head>")
  body
  result.add("<head>")

...

template title(x)=
  result.add("<title> $1 </title>" % x)

template li(x)=
  result.add("<li> $1 </li>" % x)
```
```
proc mainPage():string=
  result="<html>"
  result.add("<head>")
  result.add("<title> $1 </title>" % "The Nim programming Language")
  result.add("</head>")
  result.add("<body>")
  result.add("<ul>")
  result.add("<li> $1 </li>" % "efficient")
  result.add("<li> $1 </li>" % "expressive")
  result.add("<li> $1 </li>" % "elegant")
  result.add("</ul>")
  result.add("</body>")
  result.add("</html>")
```
## Macros
1. imperative AST to AST transformations
2. Turing complete
3. ** `macros` ** module provides an API for dealing with Nim ASTs

eg:
```
proc write(f:File;a:int)=
  echo a

proc write(f:File;a:bool)=
  echo a

proc write(f:File;a:float)=
  echo a

proc writeNewline(f:File)=
  echo "\n"

import macros

macro writeln(f:File;args:varargs[typed]):untyped=
  result=newStmtList()
  for a in args:
    result.add newCall(bindSym"write",f,a)
  result.add newCall(bindSym"writeNewline",f)

var f:File
writeln(f,40,40.0,false)
```
```
proc f(a,b,c:int):int=a+b+c

echo curry(f,10)(3,4)

macro curry(f:typed;args:varargs[untyped]):untyped=
  let ty=getType(f)
  assert($ty[0] == "proc","first param is not a functiong")
  let n_remaining =ty.len-2-args.len
  assert n_remaining>0,"cannot curry all the parameters"
  #echo treerepr ty

  var callExpr=newCall(f)
  args.copyChildrenTo callExpr

  var params:seq[NimNode] = @[]
  #return type
  params.add ty[1].type_to_nim
  
  for i in 0..<n_reamining:
    let param=ident("arg" & $i)
    param.add newIdentDefs(param,ty[i+2+args.len].type_to_nim2)
    callExpr.add param
  
  result = newProc(procType=nnkLambda,params=params,body=callExpr)
```
## Parallelism
```
import tables,strutils
proc countWords(filename:string):CountTableRef[string]=
  ##counts all the words in the file
  result=newCountTable[string]()
  for word in readFile(filename).split:
    result.inc word


const
  files=["data1.txt","data2.txt","data3.txt","data4.txt"]

proc main()=
  var tab=newCountTable[string]()
  for f in files:
    let tab2=countWords(f)
    tab.merge(tab2)
  tab.sort()
  echo tab.largest

main()
```
```
import threadpool

const
  files=["data1.txt","data2.txt","data3.txt","data4.txt"]


import tables,strutils

proc countWords(filename:string):CountTableRef[string]=
  ##counts all the words in the file
  result=newCountTable[string]()
  for word in readFile(filename).split:
    result.inc word

proc main()=
  var tab=newCountTable[string]()
  var results:array[files.len,FlowVar[CountTableRef[string]]]
  for f in files:
    results[i]=spawn countWords(f)
  for i in 0..high(results):
    tab.merge(^results[i])
  tab.sort()
  echo tab.largest

main()
```

```
import strutils,math,threadpool

proc term(k:float):float=
  4*math.pow(-1,k)/(2*k+1)

proc computePi(n:int):float=
  var ch=newSeq[FlowVar[float]](n+1)
  for k in 0..n:
    ch[k]=spawn term(float(k))
  for k in 0..n:
    result+= ^ch[k]


echo computePi(400)

#nim c -r --threads:on parallelismTest3
```

### Website [http://nim-lang.org](http://nim-lang.org)
### Mailling list [http://www.freelists.org/list/nim-dev]
### Forum [http://forum.nim-lang.org](http://forum.nim-lang.org)
### Github [https://github.com/Aral/Nim](https://github.com/Aral/Nim)
### IRC [irc.freenode.net/nim](irc.freenode.net/nim)