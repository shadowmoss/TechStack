### 数据的直接定址表 用查表的方法解决问题
问题:以十六进制的形式在屏幕中间显示给定的byte型数据。  
分析:先将一个byte的高4为和低4位分开，显示对应的数码字符。  
方案:建立一张表,表中一次存储字符"0"~"F",我们可以通过数值0~15直接找到对应的字符  
table db '0123456789ABCDEF' ;字符表  
最简解决方案
```
assume cs:code
code segment
start: mov al,2Bh
    call show byte
    mov ax,4c00h
    int 21h
    show byte:
        jmp short show
        table db '0123456789ABCDEF' ;定义的对应于0~15的ASCII字符表
    show: push bx
          push es
          push cx   ; 寄存器原有值入栈,等待程序执行结束再出栈到寄存器。

          mov ah,al
          mov cl,4
          shr ah,cl ;右移4位,ah中得到高4为的值.
          and al,00001111b ;al进行与操作,获得要显示数据的低4位的值

          mov bl,ah
          mov bh,0
          mov ah,table[bx]  ; 根据实际值在表中取得对应的ASCII码字符

          mov bx,0b800h
          mov es,bx
          mov es:[160*12+40*2],ah   ;将高四位在显存中的中心位置显示。

          mov bl,al
          mov bh,0
          mov al,table[bx]

          mov es:[160*12+40*2+2]   ；将低四位在显存中心位置的后两个字节显示。

          pop cx
          pop es
          pop bx
code ends
end start
```

在显存中显示sin(30) sin(60) sin(90) sin(120) sin(150) sin(180)的具体字符串  
```
assume cs:code
code segment
start:
    mov al,60
    call showsin
    mov ax,4c00h
    int 21h
showsin:
    jmp short show
    table dw ag0,ag30,ag60,ag90,ag120,ag150,ag180      ;该字符表存储各个sin(x)实际值的字符串的指针
    ag0 db '0',0
    ag30 db '0.5',0
    ag60 db '0.866',0
    ag90 db '1',0
    ag120 db '0.866',0
    ag150 db '0.5',0
    ag180 db '0',0
show:
    push bx
    push es
    push si

    mov bx,0b800h   ;初始化显存位置
    mov es,bx

    mov ah,0        ;将要查找的sin(x)的值除以30，以获取其在table表中的指针的相对位置。
    mov bl,30
    div bl
    mov bl,al
    mov bh,0
    add bx,bx       ;table表中存放的指针为dw格式，也就是一个指针一个字的大小。2字节。每次找到对应下标时，需要乘以2获得实际在table中的偏移地址。
    mov bx,table[bx]    ;根据偏移地址取得sin(x)值的指针。

    mov si,160*12+40*2  ;设置显存中心的偏移地址
    shows: mov ah,cs[bx]    ;根据数据标号，获取实际的字符串
    cmp ah,0                ;判断当前ah中的字符串值是否为0,为零则跳转至showret标号处。
    je showret
    mov es:[si],ah          ;ah不是0,则在显存中显示一个字节,
    inc bx                  ;移动至下一个字节
    add si,2                ;显存中显示一个字需要两个字节，也就是一个字的空间，每显示一个字节偏移量为2.
    jmp shows               ;回到最开始
    showret:ret

    pop si
    pop es
    pop bx

    ret

code ends
end start
```
上述程序的扩展:考虑程序的容错性，加上对提供的角度值是否超范围的检测，定位不到正确的字符串，将出现错误。  
方法扩展:直接定址表中存储子程序的地址，从而方便地实现不同子程序的调用。  