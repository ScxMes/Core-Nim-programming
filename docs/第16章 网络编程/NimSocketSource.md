## Nim Socket Source

```
#server

import nativesockets,net

var server = newSocket(buffered=false)  #非缓冲socket
server.bindAddr(Port(8000))
server.listen()

var buf:array[1024,char]

var client=newSocket(buffered=false)     #非缓冲socket

server.accept(client)

while true:
        
        var len=client.recv(addr(buf[0]),1)    #每次从客户端接收一个字节
        if len!=0:
          echo "recv bytes"," ",len
        else:break
        
        echo "recv buf"," ",buf

client.close()
server.close()

#[
server.accept(client)
echo "recv bytes"," ",client.recv(addr(buf[0]),sizeof(buf))     #一次最大可接收sizeof(buf)个字节
echo "recv buf"," ",buf

client.close()
server.close()
]#
```

```
#client

import nativesockets,net
from os import sleep
var socket = newSocket()
socket.connect("127.0.0.1",Port(8000));
socket.send("abcdefghijk");

```