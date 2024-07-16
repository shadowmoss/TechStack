### 描述内存单元的标号
代码段中的标号可以用来标记指令、段的起始地址。  
代码断种，数据也可以使用标号  
```
code segment
    a: db 1,2,3,4,5
    b: dw 0
code ends
end start
```
去掉了冒号的数据标号
```
code segment
    a db 1,2,3,4,5
    b dw 0
    start: mov si,0
    mov cx,8
    s: mov al,al[si]
code ends
end start
;b指向单元的表示为一个字。  
;数据标号同时描述内存地址和单元长度  
```
更常见的方式:数据段中的数据标号  
```
data segment
    a db 1,2,3,4,5,6,7
    b dw 0
data ends
```
#### seg操作符
seg 操作数  
功能:去段地址的操作符