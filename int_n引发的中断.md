### int n引起的中断
CPU内部产生的中断信息  
1. 触发错误
2. 单步执行
3. 执行into 指令
4. 执行int指令
int格式:int n,n为中断类型码:  
功能:引发中断过程  
CPU执行int n指令,相当于引发一个n号中断的中断过程,执行过程如下:  
1. 取中断类型码n;
2. 标志寄存器入栈,IF=0,TF=0;
3. CS、IP入栈;
4. (IP)=(n*4),(CS)=(n*4+2)
5. 从此处转去执行n号中断的中断处理程序。
int 指令的最终功能和call指令相似,都是调用一段程序.  
一般情况下，系统将一些具有一定的子程序，以中断处理程序的方式提供给应用程序调用。  
技术手段:编程时，可以用int指令调用子程序。此子程序即中断处理程序，简称为中断例程。  
可以自定义中断例程，实现特定功能  

示例:中断7ch的中断例程的编写和安装  
参照中断0的中断例程。  
```
assume cs:code
code segment
start:
    ;中断程序传送
    mov ax,cs
    mov ds,ax
    mov si,offset sqr
    mov ax,0
    mov es,ax
    mov di,200h
    mov cx,offset sqrend-offset sqr

    ;设置中断向量表
    mov ax,0
    mov es,ax
    mov word ptr es:[7ch*4],200h
    mov word ptr es:[7ch*4+2],0
    
    mov ax,4c00h
    int 21h

    ;中断程序
    sqr:mul ax
    iret
    sqrend:nop
    code ends
    end start
```