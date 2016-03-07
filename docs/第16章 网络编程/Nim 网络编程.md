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





