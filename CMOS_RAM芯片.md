### CMOS_RAM芯片
1. 包含一个实时钟和一个有128个存储单元的RAM存储器。  
2. 128个字节的RAM中存储:内部实时钟、系统配置信息、相关的程序(用于开机时配置系统信息)
3. 该芯片内部有两个端口端口地址为70h和71h,CPU通过这两个端口读写CMOS_RAM。
  70h地址端口,存放要访问的CMOS_RAM单元的地址;  
  71h数据端口,存放从选定的单元中读取的数据，或要写入到其中的数据。  
4. 读取CMOS_RAM的两个步骤
  将要读取的单元地址送入70h地址端口  
  从数据端口71h读出指定单元的内容  
#### 端口操作示例:提取CMOS_RAM中存储的时间信息
在屏幕中间显示当前的月份。  
背景知识:  
当前时间在CMOS_RAM中用6个字节存放  
第0号字节:存放秒  
第2号字节:存放分  
第4号字节:存放时  
第7号字节:存放日  
第8号字节:存放月  
第9号字节:存放年  
CMOS_RAM中的时间信息用BCD码存放:  
分析:这个程序主要做两部分工作:  
1. 从CMOS_RAM的8号单元读出当前月份的BCD码
2. 将用BCD码表示的月份以十进制的形式显示到屏幕上。
```
assume cs:code
code segment
start:
    mov al,8
    out 70h,al
    in al,71h

    mov ah,al
    mov cl,4
    shr ah,cl
    and al,00001111b

    add ah,30h
    add al,30h

    mov bx,0b800h
    mov es,bx
    mov byte ptr es:[160*12+40*2],ah
    mov byte ptr es:[160*12+40*2+2],al

    mov ax,4c00h
    int 21h
code ends
end start
```