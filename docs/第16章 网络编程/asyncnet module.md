##Module asyncnet

This module implements a high-level asynchronous sockets API based on the asynchronous dispatcher defined in the asyncdispatch module.

这个模块实现了高级的异步socket API，它是基于定义在 asyncdispatch 模块的异步分配器。

SSL ---

SSL can be enabled by compiling with the -d:ssl flag.

SSL能够通过编译标记 -d:ssl 来开启。

You must create a new SSL context with the newContext function defined in the net module. You may then call wrapSocket on your socket using the newly created SSL context to get an SSL socket.

你必须使用定义在 net 模块中的newContext函数创建一个新的SSL环境。你之后可能会在你的socket上调用wrapSocket用于刚刚创建的SSL环境来得到一个SSL socket。


###Examples

Chat server

The following example demonstrates a simple chat server.

下面演示一个简单的聊天服务。

```
import asyncnet, asyncdispatch

var clients {.threadvar.}: seq[AsyncSocket]

proc processClient(client: AsyncSocket) {.async.} =
  while true:
    let line = await client.recvLine()
    for c in clients:
      await c.send(line & "\c\L")

proc serve() {.async.} =
  clients = @[]
  var server = newAsyncSocket()
  server.bindAddr(Port(12345))
  server.listen()
  
  while true:
    let client = await server.accept()
    clients.add client
    
    asyncCheck processClient(client)

asyncCheck serve()
runForever()
```

###Imports

asyncdispatch, nativesockets, net, os 

###Types

AsyncSocket = ref AsyncSocketDesc
  Source 


###Procs

```
proc newAsyncSocket(fd: AsyncFD; domain: Domain = AF_INET;
                   sockType: SockType = SOCK_STREAM;
                   protocol: Protocol = IPPROTO_TCP; buffered = true): AsyncSocket {.
    raises: [], tags: [].}

Creates a new AsyncSocket based on the supplied params.   Source 

基于提供的参数，创建一个新的AsyncSocket.



proc newAsyncSocket(domain: Domain = AF_INET; sockType: SockType = SOCK_STREAM;
                   protocol: Protocol = IPPROTO_TCP; buffered = true): AsyncSocket {.
    raises: [OSError], tags: [].}

Creates a new asynchronous socket.

创建一个新的异步socket。

This procedure will also create a brand new file descriptor for this socket.

这个过程将也将为这个socket创建一个新的文件描述符。

      Source 



proc newAsyncSocket(domain, sockType, protocol: cint; buffered = true): AsyncSocket {.
    raises: [OSError], tags: [].}

Creates a new asynchronous socket.

创建一个新的异步socket。

This procedure will also create a brand new file descriptor for this socket.

这个过程将也将为这个socket创建一个新的文件描述符。
      Source 



proc connect(socket: AsyncSocket; address: string; port: Port): Future[void] {.
    raises: [FutureError], tags: [RootEffect].}

Connects socket to server at address:port.

连接socket到在 address:port 上的服务器。

Returns a Future which will complete when the connection succeeds or an error occurs.

当这个连接成功或发生一个错误，返回一个将完成Future，
      Source 



proc recv(socket: AsyncSocket; size: int; flags = {SafeDisconn}): Future[string] {.
    raises: [FutureError], tags: [RootEffect].}

Reads up to size bytes from socket.

从socket中读取到size个字节。

For buffered sockets this function will attempt to read all the requested data. It will read this data in BufferSize chunks.

对于缓冲的sockets，这个函数将试图读取所有要求的数据。它将读取这个数据到BufferSize 块中。

For unbuffered sockets this function makes no effort to read all the data requested. It will return as much data as the operating system gives it.

对于非缓冲的sockets这个函数没有做任何操作对于所有被要求的数据。它将返回操作系统给它同样多的数据。

If socket is disconnected during the recv operation then the future may complete with only a part of the requested data.

如果socket在接收操作期间断开，那么这个future可能仅仅完成要求数据的一部分。

If socket is disconnected and no data is available to be read then the future will complete with a value of "".

如果socket断开，并且没有数据可读，那么这个future将以一个值为""完成。
      Source 



proc send(socket: AsyncSocket; data: string; flags = {SafeDisconn}): Future[void] {.
    raises: [FutureError], tags: [RootEffect].}

Sends data to socket. The returned future will complete once all data has been sent.   Source 

发送数据到socket，一旦数据发送完成，返回的future将完成。



proc acceptAddr(socket: AsyncSocket; flags = {SafeDisconn}): Future[
    tuple[address: string, client: AsyncSocket]] {.
    raises: [ValueError, OSError, Exception, FutureError], tags: [RootEffect].}

Accepts a new connection. Returns a future containing the client socket corresponding to that connection and the remote address of the client. The future will complete when the connection is successfully accepted.   Source 

接受一个新的连接。返回一个future，它包含这个连接相对应的客户端socket和这个客户端的远程地址。当这个连接成功接受，这个future将完成。



proc accept(socket: AsyncSocket; flags = {SafeDisconn}): Future[AsyncSocket] {.
    raises: [ValueError, OSError, Exception, FutureError], tags: [RootEffect].}

Accepts a new connection. Returns a future containing the client socket corresponding to that connection. The future will complete when the connection is successfully accepted.   Source 

接受一个新的连接。返回一个future，它包含这个连接相对应的客户端socket。当这个连接成功接受，这个future将完成。



proc recvLineInto(socket: AsyncSocket; resString: FutureVar[string];
                 flags = {SafeDisconn}): Future[void] {.raises: [FutureError],
    tags: [RootEffect].}

Reads a line of data from socket into resString.

从socket中读取一行数据到resString中。

If a full line is read \r\L is not added to line, however if solely \r\L is read then line will be set to it.

如果一整行被读取 \r\L 不被添加到line, 然而如果单独的 \r\L 被读那么line将被设置为它。

If the socket is disconnected, line will be set to "".

如果socket是断开的，line将被设置为""。

If the socket is disconnected in the middle of a line (before \r\L is read) then line will be set to "". The partial line will be lost.

如果这个socket在一个line（在\r\L 被读前）的中间被断开，那么line将被设置为""。这个部分line将被丢失。

Warning: The Peek flag is not yet implemented.

警告：Peek标记目前尚未实现

Warning: recvLineInto on unbuffered sockets assumes that the protocol uses \r\L to delimit a new line.

警告：recvLineInto在无缓冲的sockets上，假定协议使用 \r\L 来划定新的一行。

Warning: recvLineInto currently uses a raw pointer to a string for performance reasons. This will likely change soon to use FutureVars.

由于性能原因recvLineInto当前使用一个原生指针指向一个字符串。这个在不久后可能改变而使用FutureVars.
      Source 



proc recvLine(socket: AsyncSocket; flags = {SafeDisconn}): Future[string] {.
    raises: [FutureError], tags: [RootEffect].}

Reads a line of data from socket. Returned future will complete once a full line is read or an error occurs.

从socket中读取一行数据。一旦正行读完或者产生错误返回的future将完成。

If a full line is read \r\L is not added to line, however if solely \r\L is read then line will be set to it.

如果一整行被读取 \r\L 不被添加到line, 然而如果单独的 \r\L 被读那么line将被设置为它。
If the socket is disconnected, line will be set to "".

如果socket是断开的，line将被设置为""。

If the socket is disconnected in the middle of a line (before \r\L is read) then line will be set to "". The partial line will be lost.

如果这个socket在一个line（在\r\L 被读前）的中间被断开，那么line将被设置为""。这个部分line将被丢失。

Warning: The Peek flag is not yet implemented.

警告：Peek标记目前尚未实现

Warning: recvLine on unbuffered sockets assumes that the protocol uses \r\L to delimit a new line.

警告：recvLine在无缓冲的sockets上，假定协议使用 \r\L 来划定新的一行。
      Source 



proc listen(socket: AsyncSocket; backlog = SOMAXCONN) {.tags: [ReadIOEffect],
    raises: [OSError].}

Marks socket as accepting connections. Backlog specifies the maximum length of the queue of pending connections.

标记socket为接受连接。Backlog指定等待连接队列的最大长度。

Raises an EOS error upon failure.

在失败时引起一个EOS错误。
      Source 



proc bindAddr(socket: AsyncSocket; port = Port(0); address = "") {.tags: [ReadIOEffect],
    raises: [OSError].}

Binds address:port to the socket.

绑定 address：port 到socket

If address is "" then ADDR_ANY will be bound.

如果address是""，那么将为ADDR_ANY。
      Source 



proc close(socket: AsyncSocket) {.raises: [], tags: [].}

Closes the socket.   Source 

关闭一个socket。



proc getSockOpt(socket: AsyncSocket; opt: SOBool; level = SOL_SOCKET): bool {.
    tags: [ReadIOEffect], raises: [OSError].}

Retrieves option opt as a boolean value.   Source 

检索选项opt作为一个布尔值



proc setSockOpt(socket: AsyncSocket; opt: SOBool; value: bool; level = SOL_SOCKET) {.
    tags: [WriteIOEffect], raises: [OSError].}

Sets option opt to a boolean value specified by value.   Source 

设置选项opt为一个布尔值，该值有value指定。



proc isSsl(socket: AsyncSocket): bool {.raises: [], tags: [].}

Determines whether socket is a SSL socket.   Source 

判定socket是否是一个SSL socket。



proc getFd(socket: AsyncSocket): SocketHandle {.raises: [], tags: [].}

Returns the socket's file descriptor.   Source 

返回套接字的文件描述符。



proc isClosed(socket: AsyncSocket): bool {.raises: [], tags: [].}

Determines whether the socket has been closed.   Source 

判定这个套接字是否已经关闭。


