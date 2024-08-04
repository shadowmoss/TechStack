### PC机键盘的处理过程
键盘输入的处理过程  
1. 键盘输入  
2. 引发9号中断  
3. 执行int 9中断例程  
键盘上的每一个键相当于一个开关，键盘中有一个芯片对键盘上的每一个键的开关状态进行扫描。  
按下一个键时的操作
开关接通，该芯片就产生一个扫描码，扫描码说明了按下的键在家盘上的位置。  
扫描码被送入主板上的相关接口芯片的寄存器中，该寄存器的端口地址为60H。  
松开按下的键时的操作  
产生一个扫描码，扫描码说明了松开的键在键盘上的位置。  
松开按键时产生的扫描码也被送入60H端口中。  
扫描码--长度为一个字节的编码  
按下一个键时产生的扫描码--通码，通码的第7位为0  
松开一个键时产生的扫描码--断码，断码的第7位为1.  
例如: g键的通码为22H,断码位a2H  
G键的通码为0010 0010  
G键的断码为1010 0010  
一个键的通码+80H=其断码  
#### PC机键盘的处理过程--引发中断  
键盘的输入到达60H端口时，相关芯片就会向CPU发出中断类型码为9的可屏蔽中断信息。  
CPU检测到该中断信息后，如果IF=1,则响应中断，引发中断过程，转去执行int 9中断例程。  
#### 输入的字符键值如何保存?  
有BIOS键盘缓冲区  
BIOS键盘缓冲区:是系统启动后，BIOS用于存放int 9中断例程所接收的键盘输入的内存区。  
BIOS键盘缓冲区:可以存放15个键盘输入,一个键盘输入用一个字单元存放，高位字节存放扫描码，低位字节存放字符码。  
#### 输入了控制键和切换键，如何处理?  
0040:17地址会存放键盘状态字节  
一个字节中:  
第7号存放:insert  
第6号存放:CapsLock  
第5号存放:NumLock  
第4号存放:ScrollLock  
第3号存放:Alt  
第2号存放:Ctrl  
第1号存放:做shift  
第0号存放:右shift  
### 执行int 9中断例程的流程  
1. 读出60H端口的扫描码  
2. 根据扫描码分情况对待。  
   如果是字符键的扫描码，将该扫描码和它所对应的字符码(即ASCII码)送入内存中的BIOS键盘缓冲区  
   如果是控制键(比如CTRL)和切换键(比如CapsLock)的扫描码，则将其转变为状态字节(用二进制位记录控制键和切换键状态的字节)写入内存中存储状态字节的单元。  
3. 对键盘系统进行相关的控制，如向相关芯片发出应答信息。  
#### PC机键盘的处理过程(int 9 中断例程)
DOS系统提供int 9中断例程  
按照需求开发定制处理键盘的输入  
编程任务: 
1. 在屏幕中间一次显示'a'~'z',并可以让人看清。
2. 在显示的过程中，按下ESC键后，改变显示的颜色。
工作策略:  
尽可能忽略硬件处理细节。充分利用BIOS提供的int 9中断例程对这些硬件细节进行处理。  
在改写后的中断例程中满足特定要求，并能调用BIOS的原int 9中断例程。  
```
   assume cs:code 
   code segment
   start:
      mov ax,0b800h
      mov es,ax
      mov ah,'a'
      s:
      mov es:[160*12-40*2],ah
      inc ah
      cmp ah,'z'
      jna s
      mov ax,4c--h
      int 21h
   code ends
   end start
```
在上述代码显示字母时，字母显示时间太快了，无法看清楚，  
需要延时一段时间。  
延时策略:  
让CPU执行一段时间的空循环  
```
mov dx,10h
mov ax,0
s:
sub ax,1
sbb dx,0
cmp ax,0
jne s
cmp dx,0
jne s
```
延时具体实现:  
```
assume cs:code 
   code segment
   start:
      mov ax,0b800h
      mov es,ax
      mov ah,'a'
      s:
      mov es:[160*12-40*2],ah
      call delay
      inc ah
      cmp ah,'z'
      jna s

      delay: 
      push ax
      push dx
      mov dx,10h
      mov ax,0
      s1:
         sub ax,1
         sbb dx,0
         cmp ax,0
      jne s1
         cmp dx,0
      jne s1
         pop dx
         pop ax
      ret

      mov ax,4c00h
      int 21h
   code ends
   end start
```

按下ESC键后，改变现实的颜色!  
原理:键盘输入到达60h端口后，就会引发9号中断，CPU则转去执行int 9中断例程。  
编写int 9中断例程改变现实的颜色:  
1. 从60h端口读出键盘的输入;
2. 用BIOS的int 9中断例程，处理硬件细节。
   要将中断向量表中的int 9中断例程的入口地址改为自编的中断处理程序的入口地址  
   在新中断处理程序中调用原来的int 9中断例程，还需要原来的int 9中断例程的地址。  
   解决办法:保存原来中断例程入口地址  
   将原来int 9中断例程的偏移地址和段地址保存在ds:[0],ds:[2]单元中，在需要调用原来的int 9中断例程时，到ds[0]、ds:[2]找到。  
   保存旧中断例程入口，设置新中断例程入口
   ```
      mov ax,0
      mov es,ax
      push es:[9*4]
      pop ds:[0]
      push es:[9*4+2]
      pop ds:[2]

      mov word ptr es:[9*4] offset int9
      mov es:[9*4+2],cs
   ```
   如何在新中断例程中调用旧int 9指令中断例程  
   解决办法:模拟对原中断例程的调用  
   1. 标志寄存器入栈
   2. IF=0,TF=0
      ```
      pushf
      pop ax
      and ah,11111100b  ;将IF 和TF标志位置为0
      push ax
      popf
      ```
   3. CS、IP入栈
      ```
         call dword ptr ds:[0]
      ```
   4. (IP)=((ds)*16+0)
      (CS)=((ds)*16+2)
3. 判断是否为ESC的扫描码，如果是，改变显示的颜色后返回；如果不是则直接返回。  
最终的代码:  
```
assume cs:code
stack segment
   db 128 dup (0)
stack ends
data segment
   dw 0,0
data ends
code segment
   start:
      mov ax,stack
      mov ss,ax
      mov sp,128
      mov ax,data
      mov ds,ax

      ;将旧int 9中断例程保存，新int 9中断例程替换
      mov ax,0
      mov es,ax
      push es:[9*4]
      pop ds:[0]
      push es:[9*4+2]
      pop ds:[2]
      mov word ptr es:[9*4],offset int9
      mov es:[9*4+2],cs

      ;显示a~z字符的代码
      mov ax,0b800h
      mov es,ax
      mov ah,'a'
      s:
      mov es:[160*12+40*2],ah
      call delay
      inc ah
      cmp ah,'z'
      jna s
      mov ax,0
      mov es,ax

      ;恢复原来的int 9中断地址
      push ds:[0]
      pop es:[9*4]
      push ds:[2]
      pop es:[9*4+2]

      mov ax,4c00h
      int 21h

      ;延迟程序
      delay:
      push ax
      push dx
      mov dx,10h
      mov ax,0
      s1:
         sub ax,1
         sbb dx,0
         cmp ax,0
      jne s1
         cmp dx,0
      jne s1
         pop dx
         pop ax
      ret

      ;新中断例程
      int9:
         push ax
         push bx
         push es
         in al,60h ;读取键盘扫描码，判断ESC是否按下
         pushf
         pushf
         pop bx
         and bh,11111100b
         push bx
         popf
         call dword ptr ds:[0]   ;执行原int 9中断例程

         cmp al,1 ;ESC扫描码1
         ine int9ret ;是否为ESC，如果不是则跳转int9ret

         mov ax,0b800h
         mov es,ax
         inc byte ptr es:[160*12+40*2+1]
         iret

code ends
end start
```