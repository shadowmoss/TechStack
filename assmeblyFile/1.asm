-- 第一个汇编程序代码计算2的3次方
assume cs:abc
abc segment
    mov ax,2
    add ax,ax
    add ax,ax

    mov ax,4c00h
    int 21h
abc ends
end