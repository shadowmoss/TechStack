;编程计算一下8个数据的和,结果存在ax寄存器中
;0123 0456 0789 0abc 0def 0fed 0cba 0987
;解决方法1
;直接在代码段前定义数据
; 但是这样会造成代码段混乱，执行时，先从数据段开始
; 
assume cs:code
code segment
    dw 0123h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h ;dw(定义字型数据) db(定义一个字节) dd(定义一个双字)

    mov bx,0
    mov ax,0
    mov cx,8

    s:add ax,cs[bx]
      add bx,2
      loop segment

      mov ax,4c00h
      int 21h
code ends
end