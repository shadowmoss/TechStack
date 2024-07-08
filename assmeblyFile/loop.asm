;loop指令循环指令测试
assume cs:code
code segment
    mov ax,2
    mov cx,11 ; cx赋值，表示loop要执行11次循环
    s: add ax,ax
    loop s      ;s 标号实际是要跳转到的偏移地址的位置。CS中存放程序地址的段地址。
                ; loop实际是将CS:IP中的IP改变为指定的偏移地址

    mov ax,4c00h
    int 21h
code ends
end