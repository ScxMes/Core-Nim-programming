# Nim Socket
## 简单一例
server向client发送字符串"123456",client接收并输出字符串及其长度
```
#Server:

import net

var server = newSocket()
var client = newSocket()

server.bindAddr(Port(9000))
server.listen()
server.accept(client)
client.send("123456")

client.close()
server.close()
```

```
#Client:

import net

var client = newSocket()
client.connect("127.0.0.1", Port(9000))
var str=""
var len=client.recv(str,6)
echo len
echo str

client.close()
```
** TCP服务器段的默认函数调用顺序 **
* socket()    创建套接字
* bing()     分配套接字地址
* listen() 等待链接请求状态
* accept() 允许链接
* read()/write()  数据交换  send()/recv()
* close()   断开链接

**TCP客户端的默认函数调用顺序**
* socket()   创建套接字
* connect()   请求连接
* read()/write()    交换数据 send()/recv()
* close()     断开连接

## net module
这个模块实现了一个高层跨平台socket接口
Socket类型
```
type
  SocketImpl* = object         ## socket type
    fd: SocketHandle
    case isBuffered: bool      # 决定这个套接字是否是缓冲套接字
    of true:
      buffer: array[0..BufferSize, char]
      currPos: int         # current index in buffer
      bufLen: int          # current length of buffer
    of false: nil
    when defined(ssl):
      case isSsl: bool
      of true:
        sslHandle: SSLPtr
        sslContext: SSLContext
        sslNoHandshake: bool # True if needs handshake.
        sslHasPeekChar: bool
        sslPeekChar: char
      of false: nil
lastError: OSErrorCode ## 存储该套接字中最后一个错误
domain: Domain
    sockType: SockType
    protocol: Protocol
```

```
proc newSocket(fd: SocketHandle; 
              domain: Domain = AF_INET;
              sockType: SockType = SOCK_STREAM; 
              protocol: Protocol = IPPROTO_TCP;
              buffered = true): Socket {.raises: [], tags: [].}

Domain:套接字中使用的协议族(protocol family)信息
PF_INET:IPv4互联网协议族
PF_INET6:IPv6互联网协议族
PF_LOCAL:本地通信的UNIX协议族
PF_PACKET：底层套接字的协议族

sockType:套接字数据传输中类型信息：
SOCK_STREAM :面向链接的套接字

Protocol:计算机通信中使用的协议类型：
IPPROTO_TCP:  IPv4协议族中面向链接的套接字
```
```
proc bindAddr(socket: Socket; port = Port(0); address = "") {.tags: [ReadIOEffect], raises: [OSError].}
给该socket绑定地址和接口
如果地址是"",将会绑定ADDR_ANY,
ADDR_ANY:采用这种方式，则可自动获取运行服务器端的计算机IP地址
```
```
proc listen(socket: Socket; backlog = SOMAXCONN) {.tags: [ReadIOEffect], raises: [OSError].}
标志socket处于接收链接状态。Backlog指定等待链接队列的最大长度
出现错误的时候引发一个EOS错误
```
```
proc acceptAddr(server: Socket; client: var Socket; address: var string; flags = {SafeDisconn}) {.tags: [ReadIOEffect], gcsafe, locks: 0, raises: [OSError].}
阻塞直到从client发出一个连接(connect).当产生一个连接时，将客户端设置为客户端套接字，将地址设置为连接的客户端地址。如果发生一个错误，这个函数将会引发EOS。
产生的客户端将继承服务器套接字的所有属性，例如:是否该套接字为缓冲套接字。
注意:client必须初始化(使用new),这个函数没有初始化client变量。
Accept调用可能会导致一个错误，如果在accept期间，连接套接字没有连接。如果指定SafeDisconn标志，则不会引发这个错误，并且将会再次调用accept.
```

```
proc accept(server: Socket; client: var Socket; flags = {SafeDisconn}) {. tags: [ReadIOEffect], raises: [OSError].}
等价于acceptAddr,但是不返回address，仅是socket.
注意:client必须初始化(使用new),这个函数没有初始化client变量。
Accept调用可能会导致一个错误，如果在accept期间，连接套接字没有连接。如果指定SafeDisconn标志，则不会引发这个错误，并且将会再次调用accept.
```
```
proc connect(socket: Socket; address: string; port = Port(0); timeout: int) {. tags: [ReadIOEffect, WriteIOEffect], raises: [OSError, TimeoutError].}
连接由address和port指定的server
timeout参数以毫秒为单位指定允许连接到服务器的时间
```
```
proc send(socket: Socket; data: pointer; size: int): int {.tags: [WriteIOEffect], raises: [].}
将数据发送到一个socket
注意:这个底层的send.你应该使用下面的版本。
```

```
proc send(socket: Socket; data: string; flags = {SafeDisconn}) {.tags: [WriteIOEffect], raises: [OSError].}
将数据发送到一个socket
```

```
proc trySend(socket: Socket; data: string): bool {.tags: [WriteIOEffect], raises: [].}
Send的安全替代。当一个错误发生时不会引发EOS，而是失败时返回false.
```

```
proc sendTo(socket: Socket; address: string; port: Port; data: pointer; size: int; af: Domain = AF_INET; flags = 0'i32): int {.tags: [WriteIOEffect], raises: [OSError].}
这个过程发送data到指定的address，address可能是一个IP地址或者是一个主机名，如果指定一个主机名，该函数将会尝试主机名的每个IP
注意:你可能希望使用该函数的高级版本，这将在后面定义
注意:这个过程对于SSL套接字不可用。
```

```
proc sendTo(socket: Socket; address: string; port: Port; data: string): int {. tags: [WriteIOEffect], raises: [OSError].}
这个过程发送data到指定的address，address可能是一个IP地址或者是一个主机名，如果指定一个主机名，该函数将会尝试主机名的每个IP
这个高级版本的sendTo函数
```

```
proc recv(socket: Socket; data: pointer; size: int): int {.tags: [ReadIOEffect], raises: [].}
从套接字接收数据
注意:这个低层次的函数，你可能感兴趣同样名为recv该函数的高层版本。
```

```
proc recv(socket: Socket; data: pointer; size: int; timeout: int): int {. tags: [ReadIOEffect, TimeEffect], raises: [TimeoutError, OSError].}
使用一个以毫秒为单位的timeout参数重载
```

```
proc recv(socket: Socket; data: var string; size: int; timeout = - 1; flags = {SafeDisconn}): int {.raises: [TimeoutError, OSError], tags: [ReadIOEffect, TimeEffect].}
高级版本的recv
当返回0时，socket的连接关闭
当发生一个错误时，这个函数将抛出一个EOS异常，永远不会返回一个小于0的值。
可能以毫秒为单位指定一个超时，如果在指定的时间里没有收到足够的数据，将会引发一个ETimeout异常。
注意:data必须被初始化
警告:目前仅支持SafeDisconn标志。
```

```
proc recvFrom(socket: Socket; data: var string; length: int; address: var string; port: var Port; flags = 0'i32): int {.tags: [ReadIOEffect],raises: [OSError].}
从套接字接收数据，该函数通常应用于无连接套接字(UDP套接字)
如果发生错误，引发EOS异常。否则将返回接收的值的长度。
警告:该函数还没有缓冲实现，所以当socket是缓冲套接字将会使用非缓冲实现。因此如果socket在它的buffer包含数据，该函数将不会返回它。
```

## nativesockets module
```
type
  Port* = distinct uint16  ##       端口类型

  Domain* = enum    ## domain,指定创建套接字的协议族信息。除了在这里列出的，其他域都是不支持的。
                    
    AF_UNIX,        ##   本地套接字(使用文件)，在windows上不支持 
    AF_INET = 2,    ##   IPv4网络协议中使用的地址族                              
    AF_INET6 = 23   ##   IPv6网络使用的地址族

  SockType* = enum     ## socket过程的第二个参数,套接字类型
    SOCK_STREAM = 1,   ##   可靠的面向流的服务或流套接字  
    SOCK_DGRAM = 2,    ##   数据报服务或数据报套接字
    SOCK_RAW = 3,      ##  网络层以上的原始协议   
    SOCK_SEQPACKET = 5 ##  可靠有序的分组服务

  Protocol* = enum      ##  socket过程的第三个参数，协议类型
    IPPROTO_TCP = 6,    ##  传输控制协议
    IPPROTO_UDP = 17,   ##  用户数据包协议
    IPPROTO_IP,         ##  网络协议，在windows上不支持
    IPPROTO_IPV6,       ##  IPv6的网络协议，在windows不支持   
    IPPROTO_RAW,        ##  原始IP数据报协议，在windows上不支持
    IPPROTO_ICMP        ##  控制报文协议，在windows上不支持
```

## posix module
```
type
  SocketHandle* = distinct cint        #   用于表示套接字描述符的类型
  
  INADDR_ANY* {.importc, header: "<netinet/in.h>".}: InAddrScalar
    ## IPv4本地主机地址.
  
  InPort* = int16 ## unsigned!
  InAddrScalar* = int32 ## unsigned!

  InAddrT* {.importc: "in_addr_t", pure, final,
             header: "<netinet/in.h>".} = int32 ## unsigned!

  InAddr* {.importc: "struct in_addr", pure, final,
             header: "<netinet/in.h>".} = object ## struct in_addr
    s_addr*: InAddrScalar
  
  Socklen* {.importc: "socklen_t", header: "<sys/socket.h>".} = cuint
  TSa_Family* {.importc: "sa_family_t", header: "<sys/socket.h>".} = cint

  SockAddr* {.importc: "struct sockaddr", header: "<sys/socket.h>",
              pure, final.} = object ## struct sockaddr
    sa_family*: TSa_Family         ## Address family.     地址族
    sa_data*: array [0..255, char] ## Socket address (variable-length data).   套接字地址
  
  Sockaddr_in* {.importc: "struct sockaddr_in", pure, final,
                  header: "<netinet/in.h>".} = object ## struct sockaddr_in
    sin_family*: TSa_Family        ## AF_INET.        IPv4网络协议中使用的地址族
    sin_port*: InPort              ## Port number.
    sin_addr*: InAddr              ## IP address.


const
  INVALID_SOCKET* = SocketHandle(-1)     #创建套接字时，成功时返回套接字描述符，失败时返回-1

var
  AF_INET* {.importc, header: "<sys/socket.h>".}: cint             
    ## Internet domain sockets for use with IPv4 addresses.  #IPv4地址中使用的网络域套接字
  AF_INET6* {.importc, header: "<sys/socket.h>".}: cint
    ## Internet domain sockets for use with IPv6 addresses.   #IPv6地址中使用的网络域套接字
  AF_UNIX* {.importc, header: "<sys/socket.h>".}: cint
    ## UNIX domain sockets.                                    #UNIX域套接字

 
  SOCK_DGRAM* {.importc, header: "<sys/socket.h>".}: cint ## Datagram socket.
  SOCK_RAW* {.importc, header: "<sys/socket.h>".}: cint
    ## Raw Protocol Interface.
  SOCK_SEQPACKET* {.importc, header: "<sys/socket.h>".}: cint
    ## Sequenced-packet socket.
  SOCK_STREAM* {.importc, header: "<sys/socket.h>".}: cint
    ## Byte-stream socket.

  IPPROTO_IP* {.importc, header: "<netinet/in.h>".}: cint
    ## Internet protocol.
  IPPROTO_IPV6* {.importc, header: "<netinet/in.h>".}: cint
    ## Internet Protocol Version 6.
  IPPROTO_ICMP* {.importc, header: "<netinet/in.h>".}: cint
    ## Control message protocol.
  IPPROTO_RAW* {.importc, header: "<netinet/in.h>".}: cint
    ## Raw IP Packets Protocol.
  IPPROTO_TCP* {.importc, header: "<netinet/in.h>".}: cint
    ## Transmission control protocol.
  IPPROTO_UDP* {.importc, header: "<netinet/in.h>".}: cint
    ## User datagram protocol.

  SOMAXCONN* {.importc, header: "<sys/socket.h>".}: cint
    ## The maximum backlog queue length.             #连接请求等待队列的最大长度
```