### CPU的邻居
1. CPU内部的寄存器
2. 内存单元
3. 端口
#### 端口
端口对应各种接口卡，网卡，显卡等;  
主板上的接口芯片  
其他芯片  
1. 各种芯片工作时，都有一些寄存器由CPU读写  
2. 从CPU角度，将各寄存器当端口，并统一编址
3. CPU用统一的方法与各种设备通信  
#### 读写端口的指令
in:CPU从端口读取数据  
out:CPU往端口写入数据  
例:  
in al 60h   ;从60号端口读入一个字节
执行时与总线相关的操作  
1. CPU通过地址线将地址信息60h发出
2. CPU通过控制线发出端口读命令，选中端口所在的芯片，并通知要从中读取数据
3. 端口所在的芯片将60H端口中的数据通过数据总线送入CPU
### 端口读写指令的示例
对0~255以内的端口进行读写，端口号用立即数给出  
in al,20h  
out 21h,al  
对256~65535的端口进行读写时，端口号放在dx中:  
mov dx,3f8h ;将端口号送入dx
in al,dx ;从3f8h端口读入一个字节  
out dx,al ;向3f8h端口写入一个字节  
