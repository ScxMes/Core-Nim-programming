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