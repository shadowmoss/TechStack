;将内存ffff:0~ffff:b中的数据拷贝到0:200~0:20b单元中
assume cs:code
code segment
    mov bx,0
    mov cx,12

    s: mov ax,0ffffh
    mov ds,ax
    mov dl,[bx]

    mov ax,0020h
    mov ds,ax
    mov [bx],dl

    inc bx
    loop segment
    mov ax,4c00h

code ends
end