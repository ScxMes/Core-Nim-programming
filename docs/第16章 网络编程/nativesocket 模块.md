##nativesockets 模块
这个模块实现了一个低级别的跨平台sockets接口。对于更高级的可以查看net模块。


##类型

`Port = distinct uint16`            #端口类型

```
Domain = enum
  AF_UNIX,     #用于本地socket（使用一个文件）。UNIX域协议（文本系统套接字），不支持           Windows操作系统
      AF_INET = 2,  #ARPA因特网协议（UNIX网络套接字），对应于网络协议IPv4
      AF_INET6 = 23  #为网络协议IPv6
```   
域，指定创造socket的协议族。其他的域是不支持的。

```
SockType = enum
  SOCK_STREAM = 1,     #可靠的面向流的服务或流套接字
  SOCK_DGRAM = 2,     #数据报服务或数据报套接字
  SOCK_RAW = 3,        #原始套接字
  SOCK_SEQPACKET = 5    #长度固定、有序、可靠的面向连接的有序分组套接字
```
这个值是过程socket的第二个参数。

```
Protocol = enum
  IPPROTO_TCP = 6,            #传输控制协议
  IPPROTO_UDP = 17,          #用户数据报协议
  IPPROTO_IP,                 #网际协议。在Windows上不支持
  IPPROTO_IPV6,             #网际协议6，在Windows上不支持
  IPPROTO_RAW,              #原始数据包协议，在Windows上不支持
  IPPROTO_ICMP             #控制消息协议， 在Windows上不支持
```
这个值是过程socket的第三个参数。

```
Servent = object
  name*: string
  aliases*: seq[string]
  port*: Port
  proto*: string
```
关于一个服务的信息。

```
Hostent = object
  name*: string
  aliases*: seq[string]
  addrtype*: Domain
  length*: int
  addrList*: seq[string]
```
关于一个给定主机的信息。



##Lets

osInvalidSocket = INVALID_SOCKET    
      
##Consts

IOCPARM_MASK = 127

IOC_IN = -2147483648

FIONBIO = -2147195266


##Procs
```
proc ioctlsocket(s: SocketHandle; cmd: clong; argptr: ptr clong): cint {.stdcall,
    importc: "ioctlsocket", dynlib: "ws2_32.dll".}
  Source


proc `==`(a, b: Port): bool {.borrow.}

== for ports.   Source


proc `$`(p: Port): string {.borrow.}

把端口号以字符串形式返回   Source


proc toInt(domain: Domain): cint {.raises: [], tags: [].}

转换Domain枚举为一个平台依赖的 cint.   Source


proc toInt(typ: SockType): cint {.raises: [], tags: [].}

转换 SockType 枚举为一个平台依赖的 cint.   Source


proc toInt(p: Protocol): cint {.raises: [], tags: [].}

转换 Protocol 枚举为一个平台依赖的 cint.   Source


proc newNativeSocket(domain: Domain = AF_INET; sockType: SockType = SOCK_STREAM;
                    protocol: Protocol = IPPROTO_TCP): SocketHandle {.raises: [],
    tags: [].}

创建一个新的socket; 如果发生一个错误将返回InvalidSocket（类型：SocketHandle（distinct int））  Source


proc newNativeSocket(domain: cint; sockType: cint; protocol: cint): SocketHandle {.
    raises: [], tags: [].}

创建一个新的socket; 如果发生一个错误将返回InvalidSocket（类型：SocketHandle（distinct int））。

你可以用枚举类型指定各个参数，来创建你需要的socket. Source


proc close(socket: SocketHandle) {.raises: [], tags: [].}

关闭一个 socket.   Source


proc bindAddr(socket: SocketHandle; name: ptr SockAddr; namelen: SockLen): cint {.
    raises: [], tags: [].}

 命名套接字，关联地址和端口号  Source


proc listen(socket: SocketHandle; backlog = SOMAXCONN): cint {.tags: [ReadIOEffect],
    raises: [].}

标记socket 作为接受链接. Backlog 指定等待链接队列的最大长度。Source


proc getAddrInfo(address: string; port: Port; domain: Domain = AF_INET;
                sockType: SockType = SOCK_STREAM; protocol: Protocol = IPPROTO_TCP): ptr AddrInfo {.
    raises: [OSError], tags: [].}

警告: 这个结果ptr TAddrInfo 必须使用dealloc释放!
  Source


proc dealloc(ai: ptr AddrInfo) {.raises: [], tags: [].}
  Source


proc ntohl(x: int32): int32 {.raises: [], tags: [].}

转换32位整数从网络字节序为主机字节序. 如果主机字节序与网络字节序是一样的，那么这个是一个空操作；否则,他执行一个4字节的交换操作。  Source


proc ntohs(x: int16): int16 {.raises: [], tags: [].}

转换16位整数从网络字节序为主机字节序. 如果主机字节序与网络字节序是一样的，那么这个是一个空操作；否则,他执行一个2字节的交换操作。   Source


proc getServByName(name, proto: string): Servent {.tags: [ReadIOEffect],
    raises: [OSError].}

从开始搜索数据库，发现由参数name匹配的s_name成员指定的服务器名和由参数proto匹配的s_proto成员指定的协议名的第一个条目。
在posix上这个将通过 /etc/services 文件查找。

Searches the database from the beginning and finds the first entry for which the service name specified by name matches the s_name member and the protocol name specified by proto matches the s_proto member.

On posix this will search through the /etc/services file.
  Source


proc getServByPort(port: Port; proto: string): Servent {.tags: [ReadIOEffect],
    raises: [OSError].}

从开始搜索数据库，发现由参数port匹配的s_port成员指定的端口和由参数proto匹配的s_proto成员指定的协议名的第一个条目。

在posix上这个将通过 /etc/services 文件查找。


Searches the database from the beginning and finds the first entry for which the port specified by portmatches the s_port member and the protocol name specified by proto matches the s_proto member.
On posix this will search through the /etc/services file.
  Source


proc getHostByAddr(ip: string): Hostent {.tags: [ReadIOEffect], raises: [OSError].}

这个函数将查找一个IP地址的主机名.   Source


proc getHostByName(name: string): Hostent {.tags: [ReadIOEffect], raises: [OSError].}

该函数将查找一个主机名的IP地址.   Source


proc getSockDomain(socket: SocketHandle): Domain {.raises: [OSError], tags: [].}

返回套接字的域 (AF_INET or AF_INET6).   Source


proc getAddrString(sockAddr: ptr SockAddr): string {.raises: [OSError], tags: [].}

返回用sockAddr表示地址的字符串表达   Source


proc getSockName(socket: SocketHandle): Port {.raises: [OSError], tags: [].}

返回套接字关联的端口号.   Source


proc getLocalAddr(socket: SocketHandle; domain: Domain): (string, Port) {.
    raises: [OSError], tags: [].}

返回套接字的本地地址和端口号.

与 POSIX的 getsockname相似.
  Source


proc getPeerAddr(socket: SocketHandle; domain: Domain): (string, Port) {.
    raises: [OSError], tags: [].}

返回远程套接字的地址和端口.

与 POSIX 中的 getpeername相似
  Source


proc getSockOptInt(socket: SocketHandle; level, optname: int): int {.
    tags: [ReadIOEffect], raises: [OSError].}

getsockopt for integer options.   Source


proc setSockOptInt(socket: SocketHandle; level, optname, optval: int) {.
    tags: [WriteIOEffect], raises: [OSError].}

setsockopt for integer options.   Source


proc setBlocking(s: SocketHandle; blocking: bool) {.raises: [OSError], tags: [].}

设置socket的阻塞模式.
Raises EOS on error.
  Source


proc select(readfds: var seq[SocketHandle]; timeout = 500): int {.raises: [], tags: [].}

传统的select函数。这个函数将返回将返回准备读、写或有错误的套接字数量。如果是空，将返回0. 参数Timeout 以毫秒为单位，对于没有超时可以指定为-1.

当一个套接字有数据正在等待被读/写或者有错误（exceptfds),那么它将被从这个指定的seq中移除。  Source


proc selectWrite(writefds: var seq[SocketHandle]; timeout = 500): int {.
    tags: [ReadIOEffect], raises: [].}

当在writefds中的一个socket准备被写时，那么一个非零值将被返回，这个值说明了能够被写的socket的数量。能够被写的socket也将从writefds中移除。

Timeout的单位是毫秒，-1可以用来指定一个无限时间。

When a socket in writefds is ready to be written to then a non-zero value will be returned specifying the count of the sockets which can be written to. The sockets which can be written to will also be removed from writefds.
timeout is specified in milliseconds and -1 can be specified for an unlimited time.
  Source


##Templates
template htonl(x: int32): expr

转换32位整数从主机字节序到网络字节序. 如果主机字节序与网络字节序是一样的，那么这个是一个空操作；否则,他执行一个4字节的交换操作。   Source


template htons(x: int16): expr

转换16位的正整数从主机字节序到网络字节序. 如果主机字节序与网络字节序是一样的，那么这个是一个空操作；否则,他执行一个2字节的交换操作。  Source

