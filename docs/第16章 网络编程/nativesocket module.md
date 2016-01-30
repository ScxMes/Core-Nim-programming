## Module nativesockets


这个模块实现了一个底层跨平台socket接口。高层版本查看net模块。

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

  Servent* = object ## information about a service
    name*: string
    aliases*: seq[string]
    port*: Port
    proto*: string

  Hostent* = object ## information about a given host
    name*: string
    aliases*: seq[string]
    addrtype*: Domain
    length*: int
    addrList*: seq[string]

```
```
proc `==`(a, b: Port): bool {.borrow.}             #通过{.borrow.}编译指示，实现基础类型int `==`
```
```
proc `$`*(p: Port): string {.borrow.}
  ## 以字符串的形式返回端口值
```
```
proc toInt*(domain: Domain): cint
  ##  将Domain的枚举值转化为平台依赖的``cint``
```
```
proc toInt*(typ: SockType): cint
  ##  将SockType的枚举值转化为平台依赖的``cint``
```
```
proc toInt*(p: Protocol): cint
  ##  将Protocol的枚举值转化为平台依赖的``cint``
```
```
proc newNativeSocket*(domain: Domain = AF_INET,
                      sockType: SockType = SOCK_STREAM,
                      protocol: Protocol = IPPROTO_TCP): SocketHandle =
  ## 创建一个新的socket,如果发生错误，返回`InvalidSocket`，
  socket(toInt(domain), toInt(sockType), toInt(protocol))
```
```
proc newNativeSocket*(domain: cint, sockType: cint,
                      protocol: cint): SocketHandle =
  ## 创建一个新的socket,如果发生错误，返回`InvalidSocket`.
  ##上面指定的其中一个枚举不包含你需要的值，可以使用这个重载
  socket(domain, sockType, protocol)
```
```
proc bindAddr*(socket: SocketHandle, name: ptr SockAddr, namelen: SockLen): cint =
  result = bindSocket(socket, name, namelen)
```
```
proc listen*(socket: SocketHandle, backlog = SOMAXCONN): cint {.tags: [ReadIOEffect].} =
  ##   标志``socket``为接收连接状态
  ##   ``Backlog``指定等待连接队列的最大长度
  
  when useWinVersion:
    result = winlean.listen(socket, cint(backlog))
  else:
    result = posix.listen(socket, cint(backlog))
```

```
proc ntohl(x: int32): int32 {.raises: [], tags: [].}
将一个32位整数从网络字节序转换为主机字节序。如果机器上的主机字节序与网络字节序一样，这个函数不做操作，否则，它执行一个4字节交换操作。
```
```
proc ntohs(x: int16): int16 {.raises: [], tags: [].}
将一个16位整数从网络字节序转换为主机字节序。如果机器上的主机字节序与网络字节序一样，这个函数不做操作，否则，它执行一个2字节交换操作。
```
```
template htonl(x: int32): expr
将一个32位的整数从主机字节序转换为网络字节序。如果机器的主机字节序与网络字节序一样，不做任何操作，否则，它执行一个4字节的交换操作
```
```
template htons(x: int16): expr
将一个16位的整数从主机字节序转换为网络字节序。如果机器的主机字节序与网络字节序一样，不做任何操作，否则，它执行一个2字节的交换操作
```