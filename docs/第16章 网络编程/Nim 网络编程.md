在Nim中提供socket编程的有两个模块：nativesockets和net。 nativesockets实现的是低级的socket接口，而net则是高级的实现。

关于socket相关的知识在以前的文章：[Linux程序设计--套接字学习笔记](http://blog.csdn.net/u010657094/article/details/50781249) 中已经讲过，这里就不在赘述。

关于跟多的Nim知识你也可以看github仓库：[https://github.com/ScxMes/Core-Nim-programming/blob/master/%E7%9B%AE%E5%BD%95.md](https://github.com/ScxMes/Core-Nim-programming/blob/master/%E7%9B%AE%E5%BD%95.md)。
    
###实例：
####客户端程序：
```
import net


var 
  client: Socket
  server_mes = ""
  len: int


#创建客户socket
client = newSocket()


#请求连接服务器
client.connect("127.0.0.1", Port(7000))


#通过socket进行数据传输
#client.send("this is from Nim")
len = client.recv(server_mes, 15)
echo "from server message: ",server_mes


client.send("this is from Nim")


#关闭客户套接字：
client.close()
```

####服务器端程序：
```
import net

var 
  serverSocket, clientSocket: Socket
  IPAddr = ""
  client_mes = ""
  server_mes = "hello, welcome!"
  len: int
  
#为服务器创建套接字
serverSocket = newSocket()

#初始化为客户服务的套接字
clientSocket = newSocket()

#绑定地址和端口， 第三个参数address默认为"",表示任何IP地址
serverSocket.bindAddr(Port(7000))

#创建一个连接队列，开始等待客户进行连接
serverSocket.listen(5)

while(true):
  echo "server waitting"
  #接受一个连接
  serverSocket.acceptAddr(clientSocket, IPAddr)
  echo "client from IP: ",IPAddr
  #serverSocket.accept(clientSocket)
  
  #信息传输
  clientSocket.send(server_mes)   
  #clientSocket.send("two send")
  len = clientSocket.recv(client_mes, 16)
  echo "the received data's lenth: ", len
  echo "the message is ", client_mes
  
  #关闭套接字
  clientSocket.close()
```

上面两个程序是一个普通的socket编程实例。这里需要注意的是recv过程中的第三个参数指定的是读取socket中数据的最大值，如果socket中的数据量没有达到这个值，那么程序将会阻塞。例如你把上面的客户端程序改变语句：   len = client.recv(server_mes, 15)    ，改变recv 中的第三个参数改为 16。再运行程序将会阻塞在那。

那么我们怎么知道发送端发送了多少字节的数据，怎么设置recv的参数呢？ 这里我提供一种方法，就是在发送的数据前面用4个字节来存储数据的字节数，这样接收端就可以知道要接收多少字节的数据了。
      
###改进实例：
####客户端程序：
```
import net,strutils

var 
  client: Socket
  server_mes = ""        #存储接收服务器发送来的数据
  client_mes = ""        #客户端向服务器发送的数据
  client_mes_len: int        #客户发送数据的长度
  server_mes_len: int        #接收服务器的数据的长度，不包括开头的4个字节

#创建客户socket
client = newSocket()

#请求连接服务器
client.connect("127.0.0.1", Port(7003))

#通过socket进行数据传输
#接收数据
discard client.recv(server_mes, 4)
server_mes_len = server_mes.parseInt()
echo "message lenth: ", client.recv(server_mes, server_mes_len)
echo "from server message: ",server_mes

#发送数据
client_mes = "this is from Nim"
client_mes_len = client_mes.len()
#一个套接字缓冲数据最大长度4000字节，把数据的前4个字节设置为发送数据的长度
case ($client_mes_len).len()   
of 1:
  client_mes = "000" & $client_mes_len & client_mes
of 2:
  client_mes = "00" & $client_mes_len & client_mes
of 3:
  client_mes = "0" & $client_mes_len & client_mes
else:
  client_mes = $client_mes_len & client_mes
client.send(client_mes)

#关闭客户套接字：
client.close()
```

####服务器端程序：
```
import net, strutils

var 
  serverSocket, clientSocket: Socket
  IPAddr = ""
  client_mes = ""
  server_mes = ""   #发送的数据
  server_mes_len: int
  client_mes_len: int
  
  
  
#为服务器创建监听套接字
serverSocket = newSocket()
#初始化为客户服务的套接字
clientSocket = newSocket()

#绑定地址和端口， 第三个参数address默认为"",表示任何IP地址
serverSocket.bindAddr(Port(7003))

#创建一个连接队列，开始等待客户进行连接
serverSocket.listen(5)

while(true):
  echo "server waitting"
  #接受一个连接
  serverSocket.acceptAddr(clientSocket, IPAddr)
  echo "client from IP: ",IPAddr
  #serverSocket.accept(clientSocket)
  
  #信息传输
  #发送数据
  server_mes = "Hi, welcome!"
  server_mes_len = server_mes.len()
  #一个套接字缓冲数据最大长度4000字节，把数据的前4个字节设置为发送数据的长度
  case ($server_mes_len).len()   
  of 1:
    server_mes = "000" & $server_mes_len & server_mes
  of 2:
    server_mes = "00" & $server_mes_len & server_mes
  of 3:
    server_mes = "0" & $server_mes_len & server_mes
  else:
    server_mes = $server_mes_len & server_mes
  clientSocket.send(server_mes) 
  #接收数据  
  discard clientSocket.recv(client_mes, 4)
  client_mes_len = client_mes.parseInt()
  echo "message lenth: ", clientSocket.recv(client_mes, client_mes_len)
  echo "from client message: ",client_mes
  
  #关闭套接字
  clientSocket.close()
```  

上面改进后的程序就不会产生数据接收阻塞现象了。





###net模块更多的信息
###net模块

这个模块实现了一个高级的跨平台socket 接口。


####import
    nativesockets, os, strutils, unsigned, parseutils, times

####type
```
SocketImpl = object
  fd: SocketHandle
  case isBuffered: bool
  of true:
      buffer: array[0 .. BufferSize, char]
      currPos: int
      bufLen: int

  of false:
    nil
  when defined(ssl):
      case isSsl: bool
      of true:
          sslHandle: SSLPtr
          sslContext: SSLContext
          sslNoHandshake: bool
          sslHasPeekChar: bool
          sslPeekChar: char

      of false:
        nil
    
  lastError: OSErrorCode       ## stores the last error on this socket
  domain: Domain
  sockType: SockType
  protocol: Protocol
```
socket type   Source


    Socket = ref SocketImpl
 Source

```
SOBool = enum
  OptAcceptConn, OptBroadcast, OptDebug, OptDontRoute, OptKeepAlive, OptOOBInline,
  OptReuseAddr
```
Boolean socket options.   Source

```
ReadLineResult = enum
  ReadFullLine, ReadPartialLine, ReadDisconnected, ReadNone
```
result for readLineAsync   Source


    TimeoutError = object of Exception
Source

```
SocketFlag = enum
  Peek, SafeDisconn     
```   
Ensures disconnection exceptions (ECONNRESET, EPIPE etc) are not thrown.确保断开异常（ECONNRESET, EPIPE etc）不被抛出
Source


```
IpAddressFamily = enum
  IPv6,                       ## IPv6 address
  IPv4                        ## IPv4 address
```
描述一个IP地址的类型 Source


```
IpAddress = object
  case family*: IpAddressFamily ##IP地址类型 (IPv4 or IPv6)
  of IpAddressFamily.IPv6:
      address_v6*: array[0 .. 15, uint8]##在IPv6的情况下包含字节的IP地址
                                       
  of IpAddressFamily.IPv4:
      address_v4*: array[0 .. 3, uint8] ## 在IPv4的情况下包含字节的IP地址                                   
```    
存储一个任意的IP地址   Source



####Conts
    BufferSize: int = 4000
一个缓冲套接字的缓冲区大小   Source


####Procs
```
proc isDisconnectionError(flags: set[SocketFlag]; lastError: OSErrorCode): bool {.
    raises: [], tags: [].}

判定是否 lastError 是一个断开链接错误. Only does this if flags contains SafeDisconn.   Source


proc toOSFlags(socketFlags: set[SocketFlag]): cint {.raises: [], tags: [].}

将标志转换为底层操作系统表示.   Source


proc newSocket(fd: SocketHandle; domain: Domain = AF_INET;
              sockType: SockType = SOCK_STREAM; protocol: Protocol = IPPROTO_TCP;
              buffered = true): Socket {.raises: [], tags: [].}

由参数指定创建一个新的套接字.   Source


proc newSocket(domain, sockType, protocol: cint; buffered = true): Socket {.
    raises: [OSError], tags: [].}

创建一个新的套接字.
如果发生错误，将引起EOS异常.
  Source


proc newSocket(domain: Domain = AF_INET; sockType: SockType = SOCK_STREAM;
              protocol: Protocol = IPPROTO_TCP; buffered = true): Socket {.
    raises: [OSError], tags: [].}

创建一个新的套接字.
如果发生错误，将引起EOS异常.
  Source


proc getSocketError(socket: Socket): OSErrorCode {.raises: [OSError], tags: [].}

检查 osLastError 为一个有效的错误. 如果它被已经被重置，使用最后一个错误存储在套接字对象里.   Source


proc socketError(socket: Socket; err: int = - 1; async = false; lastError = -1.OSErrorCode): void {.
    raises: [OSError], tags: [].}

引起一个基于错误代码由SSLGetError（对于SSL sockets)和soLastError返回的OSError异常。
当错误是由没有数据被读取时造成的，如果 async 是true，将不会抛出错误。
如果err不小于0，将不会引发异常。

Raises an OSError based on the error code returned by SSLGetError (for SSL sockets) and osLastErrorotherwise.
If async is true no error will be thrown in the case when the error was caused by no data being available to be read.
If err is not lower than 0 no exception will be raised.
  Source


proc listen(socket: Socket; backlog = SOMAXCONN) {.tags: [ReadIOEffect],
    raises: [OSError].}

标记socket为接受连接. Backlog 指出等待处理连接队列的最大长度。
如果失败，将引发EOS异常。
  Source


proc bindAddr(socket: Socket; port = Port(0); address = "") {.tags: [ReadIOEffect],
    raises: [OSError].}

给socket绑定地址和端口 address:port.
如果address是 ""，那么 ADDR_ANY 将被绑定.
  Source


proc acceptAddr(server: Socket; client: var Socket; address: var string;
               flags = {SafeDisconn}) {.tags: [ReadIOEffect], gcsafe, locks: 0,
                                     raises: [OSError].}

阻塞，直到有一个来自客户的连接。那时一个连接被设置为client到客户套接字和address到连接的客户地址。如果有错误发生，会引发EOS异常。

由此产生的client将继承任何服务器套接字的属性。例如：这个套接字是否是缓冲的。

注意：client必须要被初始化（with new），这个函数没有对client变量初始化做任何操作。

如果连接套接字在accept持续时间断开，那么accept调用可能会导致一个错误。如果SafeDisconn标记被指定，那么这个错误将不会引发异常，相反accept将再次被调用。
   Source


proc accept(server: Socket; client: var Socket; flags = {SafeDisconn}) {.
    tags: [ReadIOEffect], raises: [OSError].}

与acceptAddr是等价的，但是不返回地址，仅仅是套接字。

注意：client必须要被初始化（with new），这个函数没有对client变量初始化做任何操作。

如果连接套接字在accept持续时间断开，那么accept调用可能会导致一个错误。如果SafeDisconn标记被指定，那么这个错误将不会引发异常，相反accept将再次被调用。
  Source


proc close(socket: Socket) {.raises: [], tags: [].}

关闭一个socket.   Source


proc toCInt(opt: SOBool): cint {.raises: [], tags: [].}

转换一个SOBool 为它的套接字选项cint表示.   Source


proc getSockOpt(socket: Socket; opt: SOBool; level = SOL_SOCKET): bool {.
    tags: [ReadIOEffect], raises: [OSError].}

获取选项opt为一个布尔值.   Source


proc getLocalAddr(socket: Socket): (string, Port) {.raises: [OSError], tags: [].}
  Source


proc getPeerAddr(socket: Socket): (string, Port) {.raises: [OSError], tags: [].}
  Source


proc setSockOpt(socket: Socket; opt: SOBool; value: bool; level = SOL_SOCKET) {.
    tags: [WriteIOEffect], raises: [OSError].}

设置选项opt为一个布尔值，有value指定.   Source


proc connect(socket: Socket; address: string; port = Port(0)) {.tags: [ReadIOEffect],
    raises: [OSError].}

连接socket到 address：port。Address可以是一个IP地址或着一个主机名。如果address是一个主机名，这个函数将尝试这个主机的每个IP。htons早就被执行了，因此你不必转换了。

如果socket是一个SSL套接字，一次握手将被自动执行。

If socket is an SSL socket a handshake will be automatically performed.
  Source


proc hasDataBuffered(s: Socket): bool {.raises: [], tags: [].}

判断一个套接字是否有数据缓冲.   Source


proc recv(socket: Socket; data: pointer; size: int): int {.tags: [ReadIOEffect],
    raises: [].}

从一个套接字接收数据

注意：这是一个低级的函数，你可能会对高级的版本名为recv的函数感兴趣。
  Source


proc recv(socket: Socket; data: pointer; size: int; timeout: int): int {.
    tags: [ReadIOEffect, TimeEffect], raises: [TimeoutError, OSError].}

带有以毫秒为单位的timeout参数重载   Source


proc recv(socket: Socket; data: var string; size: int; timeout = - 1; flags = {SafeDisconn}): int {.
    raises: [TimeoutError, OSError], tags: [ReadIOEffect, TimeEffect].}

高级版本函数 recv.

当返回0时，socket的连接已经关闭.

当有错误发生时，这个过程将会抛出EOS异常. 一个小于0的值从来不会返回。

Timeout可能以毫秒为单位, 如果足够多的数据没有在规定的超时时间内被接收，那么将抛出ETimeout异常。

注意：data必须被初始化

警告: 目前仅仅SafeDisconn 标记是支持的.
  Source


proc readLine(socket: Socket; line: var TaintedString; timeout = - 1;
             flags = {SafeDisconn}) {.tags: [ReadIOEffect, TimeEffect],
                                   raises: [TimeoutError, OSError].}

从socket中读一行数据.

如果一整行被读，\r\L 不被添加到line里。然而如果\r\L被单独地读，那么将被添加的line中。

If a full line is read \r\L is not added to line, however if solely \r\L is read then line will be set to it.

如果套接字是断开的，line将被设置为 "".

如果一个套接字出现错误，将会引起EOS异常.

可以指定参数timeout，以毫秒为单位,如果数据没有在规定时间内收到，那么将会抛出ETimeout异常.

警告: 目前仅仅SafeDisconn 标记是支持的.
  Source


proc recvFrom(socket: Socket; data: var string; length: int; address: var string;
             port: var Port; flags = 0'i32): int {.tags: [ReadIOEffect],
    raises: [OSError].}

从socket中接收数据。这个函数通常被用于连接少的socket（UDP sockets).

如果出现错误，将会抛出EOS异常。否则将返回实际接收数据的长度。

警告：这个函数还没有缓冲一个缓冲的实现，因此，当socket是缓冲的将会当做非缓冲的实现。那么，如果socket在它的缓冲区中含有数据，这个函数将不做任何操作返回它。

Warning: This function does not yet have a buffered implementation, so when socket is buffered the non-buffered implementation will be used. Therefore if socket contains something in its buffer this function will make no effort to return it.
  Source


proc skip(socket: Socket; size: int; timeout = - 1) {.
    raises: [Exception, TimeoutError, OSError], tags: [TimeEffect, ReadIOEffect].}

跳过size数量的字节。

Skips size amount of bytes.

可以以毫秒为单位来指定参数timeout, 如果跳过的字节所用时间超过timeout，将会引发一个ETimeout异常。

返回跳过的字节数。
  Source


proc send(socket: Socket; data: pointer; size: int): int {.tags: [WriteIOEffect],
    raises: [].}

向一个socket发送数据.

注意：这是一个低级的send，你可能应该使用下面的版本  Source


proc send(socket: Socket; data: string; flags = {SafeDisconn}) {.tags: [WriteIOEffect],
    raises: [OSError].}

向一个socket 发送数据.   Source


proc trySend(socket: Socket; data: string): bool {.tags: [WriteIOEffect], raises: [].}

对于send是安全的替换，如果发生错误将不会引发EOS异常，而是在失败时返回false。   Source


proc sendTo(socket: Socket; address: string; port: Port; data: pointer; size: int;
           af: Domain = AF_INET; flags = 0'i32): int {.tags: [WriteIOEffect],
    raises: [OSError].}

这个过程发送data到指定的address，它可能是一个IP地址或着一个主机名。如果指定的是一个主机名，那么这个函数将尝试主机名上的每一个IP。

注意：你可能愿意使用这个函数的高级版本，它在下面被定义。

注意：这个过程对于SSL套接字是无效的。
  Source


proc sendTo(socket: Socket; address: string; port: Port; data: string): int {.
    tags: [WriteIOEffect], raises: [OSError].}

这个过程发送data到指定的address，它可能是一个IP地址或着一个主机名。如果指定的是一个主机名，那么这个函数将尝试主机名上的每一个IP。

这个是上面sendTo 函数的高级版本.
  Source


proc connect(socket: Socket; address: string; port = Port(0); timeout: int) {.
    tags: [ReadIOEffect, WriteIOEffect], raises: [OSError, TimeoutError].}

连接到由addres和port指定的服务器

这个 timeout 参数指定允许连接到服务器的时间，单位是毫秒。
  Source


proc isSsl(socket: Socket): bool {.raises: [], tags: [].}

判断 socket 是否是一个SSL socket.   Source


proc getFd(socket: Socket): SocketHandle {.raises: [], tags: [].}

返回socket的文件描述符   Source


proc IPv4_any(): IpAddress {.raises: [], tags: [].}

返回IPv4 任何地址，能够被用于监听所有可用网络适配器。

Returns the IPv4 any address, which can be used to listen on all available network adapters   Source


proc IPv4_loopback(): IpAddress {.raises: [], tags: [].}

返回 IPv4 环回地址 (127.0.0.1)   Source


proc IPv4_broadcast(): IpAddress {.raises: [], tags: [].}

返回IPv4广播地址 (255.255.255.255)   Source


proc IPv6_any(): IpAddress {.raises: [], tags: [].}

返回IPv6任何地址 (::0), 能够被用于监听所有可用网络适配器  Source


proc IPv6_loopback(): IpAddress {.raises: [], tags: [].}

返回 IPv6 环回地址 (::1)   Source


proc `==`(lhs, rhs: IpAddress): bool {.raises: [], tags: [].}

比较两个 IpAddresses 是否相等. 如果相等返回true   Source


proc `$`(address: IpAddress): string {.raises: [], tags: [].}

转换一个IP地址为文本表达  Source


proc parseIpAddress(address_str: string): IpAddress {.raises: [ValueError], tags: [].}

解析一个IP地址，如果错误引发EInvalidValue异常   Source


proc isIpAddress(address_str: string): bool {.tags: [], raises: [].}

检查字符串address_str是否是一个IP地址，如果是返回true，否则返回false  Source




