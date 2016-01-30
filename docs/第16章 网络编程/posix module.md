## posix module

这是一个原生的POSIX接口模块。它没有提供任何方便:使用cstring而不是适当的Nim字符串，返回代码指示错误。If you want exceptions and a proper Nim-like interface, use the OS module or write a wrapper

编码约定:所有类型的命名与POSIX标准相同，例外是有些以'T'或者'P'开始(如果它们是指针)，并且不使用'_t'后缀与Nim约定保持一致。如果一个标识符是Nim的关键字，使用`identifier`符号。

该库依赖于你的C编译器的头文件。生成的C代码将仅是#include <XYZ.h>，在这里不定义声明的符号。

```
struct sockaddr_in
{
sa_family_t    sin_family;    //地址族(Address Family)
uint16_t       sin_port;      //16位TCP/UDP端口号
struct in_addr  sin_addr;     //32位IP地址
char           sin_zero[8];   //不使用
}

struct in_addr
{
    in_addr_t     s_addr;     //32位IPv4地址
}

struct sockaddr
{
  sa_family_t   sin_family;  //地址族(Address Family)
  char  sa_data[14];        //地址信息
}

此结构体成员sa_data保存的地址信息中需要包含IP地址和端口号。剩余部分应填充0，这也是bind函数要求的。而这对包含地址信息来讲非常麻烦，所以有了新的结构体sockaddr_in.先填写sockaddr_in结构体，则将生成符合bind函数要求的字节流。最后转换为sockaddr型的结构体变量，再传递给bind函数即可。
```

```
uint16_t,in_addr_t等类型可以参考POSIX(portable Operating System Interface,可移植操作系统接口)。POSIX是为UNIX系列操作系统设置的标准，它定义了一些其他数据类型

数据类型名称               数据类型说明                            声明的头文件
int8_t                   signed 8-bit int                       sys/types.h
uint8_t                  unsigned 8-bit int(unsigned char)
int16_t                  signed 16-bit int
uint16_t                 unsigned 16-bit int(unsigned char)
int32_t                  signed 32-bit int
uInt32_t                 unsigned 32-bit int(unsigned char)

sa_family_t              地址族(address family)                 sys/socket.h
socklen_t                长度(length of struct)

in_addr_t                IP地址，声明为uint32_t                  netinet/in.h
in_port_t                端口号,声明为uint16_t

为什么需要额外定义这些数据类型呢？这是考虑到拓展性的结果。如果使用int32_t类型的数据，就能保证在任何时候都占用4字节，即使将来用64位表示int类型也是如此。
```

```
结构体sockaddr_in的成员分析
成员sin_family
每中协议族适用的地址族均不同。比如，IPv4使用4字节地址族，IPv6使用16字节地址族。
地址族                                         含义
AF_INET                               IPv4网络协议中使用的地址族
AF_INET6                               IPv6 网络协议中使用的地址族
AF_LOCAL                              本地通信中采用的UNIX协议的地址族

成员sin_port
该成员保存16位端口号，重点在于，它以网络字节序保存

成员sin_addr
该成员保存32位IP地址信息，且也以网络字节序保存。

成员sin_zero
无特殊含义。只是为使结构体sockaddr_in的大小与sockaddr结构体保持一致而插入的成员。必须填充为0，否则无法得到想要的结果。
```
```
socket 通信常用的头文件:
1.sys/socket.h :
 sockaddr 结构: struct sockaddr是通用的套接字地址 是linux 网络通信的地址结构体的一种
2.netinet/in.h:
struct socketaddr_in : struct sockaddr是通用的套接字地址，而struct sockaddr_in则是internet环境下套接字的地址形式，二者长度一样，都是16个字节。二者是并列结构，指向sockaddr_in结构的指针也可以指向sockaddr。一般情况下，需要把sockaddr_in结构强制转换成sockaddr结构再传入系统调用函数中。
```
### 字节序转换(Endian Conversions)
```
在填充socket_in结构体前将数据转换成网络字节序。帮组转换字节序的函数：
unsigned short htons(unsigned short);
unsigned short ntohs(unsigned short);
unsigned long htonl(unsigned long);
Unsigned long ntohl(unsigned long);

htons中的h代表主机(host)字节序
htons中的n代表网络(network)字节序
s只short，l指long(linux中long类型占用4字节)。因此htons是h,to,n,s的组合，解释为”把short型数据从主机字节序转化为网络字节序”
通常，以s作为后缀的函数中，s代表2字节short，因此用于端口号转换；以l作为后缀的函数中，l代表4字节，因此用于IP地址转换。
```

### 网络地址的初始化与分配
```

将字符串信息转换为网络字节序的整形数
    sockaddr_in中保存地址信息的成员为32位整形数。因此，为了分配IP地址，需要将其表示为32位整形数据。
对于IP地址的表示，我们熟悉的是点分十进制表示法(Dotted Decimal Notation),而非整形数表示法。有个函数会帮我们将字符串形式的IP地址转换成32位整形数数据。此函数在转换类型的同时进行网络字节序转换。

#include<arpa/inet.h>

in_addr_t   inet_addr(const char * string);
成功时返回32位大端序整数型值，失败是返回INADDR_NONE
如果向该函数传递类型”211.214.107.99”的点分十进制格式的字符串，它会将其转换为32位整形数据并返回，当然，该整形数值满足网络字节序。另外，改函数的返回值类型in_addr_t在内部声明为32位整形数。

Inet_aton函数与inet_addr函数再功能上完全相同，也将字符串形式IP地址转换为32位网络字节序整数并返回。只不过该函数利用了in_addr结构体。
#include<arpa/inet.h>

Int inet_aton(const char * string,struct in_addr * addr);
成功时返回1(true),失败时返回0(false)
String:含有需转换的IP地址信息的字符串地址值
Addr：将保存转换结果的in_addr结构体变量的地址值。
实际编程中若要调用inet_addr函数，需将转换后的IP地址信息代入sockaddr_int结构体声明的in_addr结构体变量。而inet_aton函数则不需要此过程。原因在于，若传递in_addr结构体变量地址值，函数会自动把结果填入该结构体变量。

Inet_ntoa与inet_aton函数正好相反，此函数可以把网络字节序整形数IP地址转换成我们熟悉的字符串表示形式
#include<arpa/inet.h>
Char * inet_ntoa(struct in_addr adr);
成功时返回转换的字符串地址值，失败时返回-1
该函数将通过参数传入的整数型IP地址转换为字符串格式并返回。但调用时需小心，返回值类型是char指针。返回字符串地址意味着字符串以保存到内存空间，但该函数未向程序员要求分配内存，而是在内部申请了内存并保存了字符串。也就是说，调用完该函数后，应立即将字符串信息复制到其他内存空间。因为，若再次调用inet_ntoa函数，则有可能覆盖之前保存的字符串信息。总之，再次调用inet_ntoa函数前返回的字符串地址值是有效的。若需长期保存，则应将字符串复制到其他内存空间。 
```

```
type
  SocketHandle* = distinct cint          #  用于表示套接字描述符的类型

type
  Socklen* {.importc: "socklen_t", header: "<sys/socket.h>".} = cuint
  TSa_Family* {.importc: "sa_family_t", header: "<sys/socket.h>".} = cint

  SockAddr* {.importc: "struct sockaddr", header: "<sys/socket.h>",
              pure, final.} = object ## struct sockaddr
    sa_family*: TSa_Family         ## Address family.
    sa_data*: array [0..255, char] ## Socket address (variable-length data).

  Sockaddr_storage* {.importc: "struct sockaddr_storage",
                       header: "<sys/socket.h>",
                       pure, final.} = object ## struct sockaddr_storage
    ss_family*: TSa_Family ## Address family.

  InPort* = int16 ## unsigned!
  InAddrScalar* = int32 ## unsigned!

  InAddrT* {.importc: "in_addr_t", pure, final,
             header: "<netinet/in.h>".} = int32 ## unsigned!

  InAddr* {.importc: "struct in_addr", pure, final,
             header: "<netinet/in.h>".} = object ## struct in_addr
    s_addr*: InAddrScalar

  Sockaddr_in* {.importc: "struct sockaddr_in", pure, final,
                  header: "<netinet/in.h>".} = object ## struct sockaddr_in
    sin_family*: TSa_Family ## AF_INET.
    sin_port*: InPort      ## Port number.
    sin_addr*: InAddr      ## IP address.
```
```
# arpa/inet.h
proc htonl*(a1: int32): int32 {.importc, header: "<arpa/inet.h>".}
proc htons*(a1: int16): int16 {.importc, header: "<arpa/inet.h>".}
proc ntohl*(a1: int32): int32 {.importc, header: "<arpa/inet.h>".}
proc ntohs*(a1: int16): int16 {.importc, header: "<arpa/inet.h>".}
```
```
proc inet_addr*(a1: cstring): InAddrT {.importc, header: "<arpa/inet.h>".}
proc inet_ntoa*(a1: InAddr): cstring {.importc, header: "<arpa/inet.h>".}

proc inet_ntop*(a1: cint, a2: pointer, a3: cstring, a4: int32): cstring {.
  importc:"(char *)$1", header: "<arpa/inet.h>".}
proc inet_pton*(a1: cint, a2: cstring, a3: pointer): cint {.
  importc, header: "<arpa/inet.h>".}

```
```
const
  INVALID_SOCKET* = SocketHandle(-1)
```
```
proc `==`*(x, y: SocketHandle): bool {.borrow.}
```
```
proc accept*(a1: SocketHandle, a2: ptr SockAddr, a3: ptr Socklen): SocketHandle {.
  importc, header: "<sys/socket.h>".}
```
```
proc bindSocket*(a1: SocketHandle, a2: ptr SockAddr, a3: Socklen): cint {.
  importc: "bind", header: "<sys/socket.h>".}
  ##是Posix的``bind``,因为``bind``是一个保留字
```
```
proc connect*(a1: SocketHandle, a2: ptr SockAddr, a3: Socklen): cint {.
  importc, header: "<sys/socket.h>".}
```
```
proc listen*(a1: SocketHandle, a2: cint): cint {.
  importc, header: "<sys/socket.h>".}
```
```
proc recv*(a1: SocketHandle, a2: pointer, a3: int, a4: cint): int {.
  importc, header: "<sys/socket.h>".}
```
```
proc recvfrom*(a1: SocketHandle, a2: pointer, a3: int, a4: cint,
        a5: ptr SockAddr, a6: ptr Socklen): int {.
  importc, header: "<sys/socket.h>".}
```
```
proc recvmsg*(a1: SocketHandle, a2: ptr Tmsghdr, a3: cint): int {.
  importc, header: "<sys/socket.h>".}
```
```
proc send*(a1: SocketHandle, a2: pointer, a3: int, a4: cint): int {.
  importc, header: "<sys/socket.h>".}
```
```
proc sendmsg*(a1: SocketHandle, a2: ptr Tmsghdr, a3: cint): int {.
  importc, header: "<sys/socket.h>".}
```
```
proc sendto*(a1: SocketHandle, a2: pointer, a3: int, a4: cint, a5: ptr SockAddr,
             a6: Socklen): int {.
  importc, header: "<sys/socket.h>".}
```
```
proc socket*(a1, a2, a3: cint): SocketHandle {.
  importc, header: "<sys/socket.h>".}
```