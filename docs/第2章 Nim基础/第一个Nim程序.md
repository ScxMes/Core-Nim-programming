##2.1 第一个Nim程序

下面我们就以一个修改过的“hello world” 开始:
    
    #这是一行注释
    echo(“What’s your name?”) 
    var name: string = readLine(stdin)
    echo(“Hi, “,name,”!”)
 
保存这段代码并命名为”greeting.nim”，现在在终端输入以下命令编译和运行它：

    nim compile --run greetings.nim 

若命令中带有 --run 开关，Nim将会在编译后自动执行这个文件。你可以在文件名后面添加想要传递给程序的参数。

    nim compile --run greetings.nim arg1 arg2

常用的命令和开关都有缩写，所以你也可以使用：

`nim c -r greetings.nim`

编译一个发布版本使用：

`nim c -d:release greetings.nim`

默认的Nim编译器会针对你的调试产生大量的运行时检查，使用 -d:release 参数这些检查将被关闭同时优化会被打开。

尽管这个程序做什么的是很明显的，但是我们来看一下它的语法：当程序开始运行时没有缩进的语句将会执行。缩进是Nim的语句分组方式，它跟Python等语言相似。缩进仅仅只能使用空格键，跳格键是不允许的。

字符串得用双引号括起来，var 语句声明了一个新的变量，名为name，类型是 string 类型，值为readLine过程的返回值。由于编译器知道readLine返回一个字符串，所以在声明时可以省略类型（这就是本地类型推断）。因此这个也将能够工作：

`var name = readLine(stdin) `

请注意，这基本上是Nim中唯一的一种类型推断形式：在简洁和可读性直接是一个很好的折衷。

这个“hello world” 程序包含了一些已经被编译器知道的标识符：echo、readLine等。这些内置的标识符在system模块里，system被隐式的导入到其他模块中，这样就不用在文件中写import system 了。



