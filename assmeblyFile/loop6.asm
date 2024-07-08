;将内存ffff:0~ffff:b中的数据拷贝到0:200~0:20b单元中，改进
;但是直接在程序中写地址，危险!
; "安全位置存放数据，存在哪里?
;对策，在程序的段中存放数据，运行时由操作系统分配空间。
;段的类别:数据段、代码段栈段
;各种段中均可以有数据
;可以在单个段中安置，也可以将数据、代码、栈段放入不同的段中。
assume cs:code
code segment
    mov ax,0ffffh
    mov ds,ax
    mov ax,0020h
    mov es,ax

    mov bx,0
    mov cx,12

    s: mov dl,ds:[bx]
       mov es:[bx],dl
       inc bx
       loop s

    mov ax,4c00h
    int 21h

code ends
end