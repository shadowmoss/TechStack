;使用loop计算123x236,将结果存储在ax中,且不使用乘法计算符
;方法用加法实现乘法,将123+123执行236次
assume cs:codesg
codesg segment
    mov ax,0
    mov cx,236
    s: add ax,123
        loop s
    mov 4c00h
    int 21h
codesg ends
end