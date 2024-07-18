### 使用代码的直接定址表解决问题
 ```
 assume cs:code
 code segment
 start:
    mov ah,2
    mvo al,5
    call setscreen
    mov ax,4c00h
    int 21h
    setscreen:
    jmp short set
    table dw sub1,sub2,sub3,sub4 ; 子程序的直接定址表
    set:
    push bx
    cmp ah,3    ;判断当前指定要执行的程序的下标号
    ja sret     ; 
    mov bl,ah   ; 
    mov bh,0    ;根据指定的子程序编号，设置基地址寄存器的值。
    add bx,bx   ;因为在table中定义的，每个子程序的标号，为实际子程序的偏移地址。所以为16位，一个字。
    call word ptr table[bx];调用标号指定的子程序。
    sret:
    pop bx
    ret
 code ends
 end start
 ```