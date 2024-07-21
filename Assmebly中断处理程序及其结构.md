### 中断处理程序及其结构.
CPU随时都可能检测到中断信息，所以中断处理程序必须常驻内存(一直存储在内存某段空间之中)  
中断处理程序的入口地址，即中断向量，必须存储在对应的中断向量表表项中(0000:0000~0000:03FF)。  
1. 在中断号为0的位置编置中断处理程序  
编写一个0号中断处理程序，它的功能是在屏幕中间显示"overflow!"后，然后返回到操作系统。   
2. 内存0000:0000~0000:03ff,大小为1KB的空间是系统存放终端向量表，DOS系统和其他应用程序都不会随便使用这段空间。8086支持256个中断，但实际上系统重要处理的中断事件远没有达到256个。
3. 利用中断向量表中的空闲单位来存放我们的程序。估计出，do0长度不可能超过256个字节，就选用从0000:0200至0000:02ff的256个字节的空间。  
4. 将do0程序送到内存0000:0200处。
```
assume cs:code
code segment
start:
    ;do0安装程序
    mov ax,cs
    mov ds,ax
    mov si,offset do0
    mov ax,0
    mov es,ax
    mov di,200h
    mov cx,;offset doend-offset do0                do0部分代码的长度
    cld
    rep movsb              


    ;设置中断向量表
    mov ax,0
    mov es,ax
    mov word ptr es:[0*4],200h
    mov word ptr es:[0*4+2],0

    mov ax,4c00h
    int 21h

     ;显示字符串 "overflow!"
    do0:
    jmp short do0start               
    db "overflow!"
    do0start:
    mov ax,cs
    mov ds,ax
    mov si,202h

    mov ax,0b800h
    mov es,ax
    mov di 12*160+36*2
    mov cx,9

    s:
    mov al,[si]
    mov es:[di],al
    inc si
    add di,2
    loop s

    mov ax,4c00h
    int 21h
    do0end:nop
code ends
end start 
```