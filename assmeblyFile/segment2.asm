; 完成下面程序，利用栈，将程序中定义的数据逆序存放。
assume cs:codesg
codesg segment
    dw 0123h,0456h,0789h,0abch,0fedh,0cbah,0987h
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    start: mov ax,cs ;将代码段开始的段地址放入ax
           mov ss,ax    ; 将代码段开始的段地址放入ss
           mov sp,30h   ; 将栈的偏移地址的栈底，放入sp
           ; 入栈
           mov bx,0
           mov cx,8
           s:push cs:[bx]
           add bx,2
           loop s
           ;出栈
           mov bx,0
           mov cx,8
           s0:pop cs:[bx]
              add bx,2
              loop s0

           mov ax,4c00h
           int 21jh
codesg ends
end