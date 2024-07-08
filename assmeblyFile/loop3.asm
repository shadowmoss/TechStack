;计算ffff:0006字节单元中的数乘以3，结果存储在dx中。
;方法先将内存中数据取出；该数，同自身 连加3次，即乘以3.
assume cs:code
code segment
    mov ax,0ffffh
    mov ds,ax
    mov bx,6
    mov al,[bx] ;ax的低8位字节
    mov ah,0    ;ax的高8位字节

    mov dx,0
    mov cx,3
    s: add dx,ax
    loop s

    mov ax,4c00h
    int 21h
code ends
end