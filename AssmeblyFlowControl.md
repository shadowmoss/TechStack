### 流程转移与子程序
一般情况下，指令是顺序的逐条执行的，而在实际中，常需要改变程序的执行流程。  
转移指令,  
可以控制CPU执行内存中某处代码的指令  
可以修改IP,或者同时修改CS和IP  
按转移行为  
段内转移: 只修改IP,如jmp ax  
段间转移: 同时修改CS和IP，如jmp 1000:0  
根据指令对IP修改的范围不同:  
段内短转移: IP修改范围为-128~127  
段内近转移: IP修改范围为-32768~32767  
按转移指令:  
无条件转移指令(如:jmp)  
条件转移指令(如 : jcxz)  
循环指令 (如 : loop)  
过程  
中段  
### offset操作符
用offset操作符取得标号的偏移地址  
格式:  
offset 标号  
例:  
```
assume cs:codeseg
codeseg segment
start: mov ax,offset start  ;相当于 mov ax,0
s:mov ax,offset s           ;相当于 mov ax,3
codeseg ends
end start
```
有如下程序段，填写2条指令，使该程序在运行中将s处的一条指令复制到s0处。
```
;思考
;s和s0处的指令所在的内存单元的地址是多少?cs:offset s和cs:offset s0
;将s处的指令复制到s0处，就是
;就是将cs:offset s处的数据复制到cs:offset s0处
;地址如何表示?段地址已知在cs中，偏移地址已经送入si和di中
;要复制的数据有多长?
;mov ax,bx指令的长度为两个字节，即一个字
assume cs:codesg
codesg segment
s:mov ax,bx
mov si,offset s
mov di,offset s0
mov ax,cs:[si]
mov cs:[di],ax
s0:nop  
   nop
codesg ends
ends
;nop的机器码占一个字节，起"占位"作用
```

### jmp指令--无条件转移
jmp指令功能  
无条件转移，可以只修改IP,也可以同时修改CS和IP  
jmp指令要给出两种信息:  
    转移的目的地址  
    转移的距离  
1. 段间转移(远转移):jmp 2000:1000  
2. 段内短转移: jmp short 标号 ;IP的修改范围为-128~127,8位的位移(跳转到相对位置，主要是改变IP值实现，转移)  
   (IP)=(IP)+8位位移,原理:8位位移="标号"处的地址-jmp指令后的第一个字节的地址。short 指明此处的位移为8位位移。
3. 段内近转移: jmp near ptr 标号;IP的修改范围为-32768~32767,16位的转移(跳转到相对位置，主要是改变IP值实现，转移)  
4. 远转移,jmp far ptr 标号,far ptr指明了跳转到的目的地址，即包含了标号的段地址CS和偏移地址IP.
5. 转移地址在寄存器中: 转移到IP=(16位寄存器值)的偏移地址的位置  
6. 转移地址在内存中的jmp:
   * 段内转移 jmp word ptr 内存单元地址，从内存单元地址处开始存放一个字，是转移的目的偏移地址。  
   * 段间转移 jmp dword ptr 内存单元地址,段间转移，功能:从内存单元地址处开始存放这两个字，高地址处的字是转移的目的地址，低地址处是转移的目的偏移地址。
在源程序中，不允许使用"jmp 2000:0100"的转移指令实现段间转移

### jcxz指令 条件转移
功能:如果(cx)=0,则转移到标号处,当(cx)=0时,(IP)=(IP)+8位位移  
当(cx)!=0时，什么也不做  
其机器代码代码中记录的是将要跳转到的IP的相对地址。  
1. jcxz是有条件转移指令
2. 所有的条件转移都是短转移
3. 转移距离为8位
### loop指令
功能 loop 标号  
1. (cx)=(cx)-1;  
2. 当(cx)!=0时，则转移到标号处执行  
3. 当(cx)=0时，程序向下执行  
相对转移的意义，它们对应的机器码中不包含转移的目的地址，而包含的是到目的地址的位移。  
### call指令和ret指令
调用子程序:call指令  
返回:ret指令  
实质:流程转移指令，它们都修改IP,或同时修改CS和IP  
1. call指令  
   功能调用子程序,实质:流程转移  
   格式: call 标号
   执行call指令时，进行两步操作:  
   1. 将当前IP或CS和IP压入栈中;
   2. 转移到标号处执行指令
2. call far ptr 标号 实现的是段间转移  
   相当于PUSH CS,PUSH IP,jmp far ptr 标号
3. 转移地址在寄存器中的call指令  
   格式:call 16位寄存器,相当于PUSH IP,jmp 16位寄存器
4. 转移地址在内存中的call指令
   格式:call word ptr 内存单元地址，跳转的地址为一个字.
5. call dword ptr 内存单元，即转移地址在内存单位中，且存放的是段地址和偏移地址
   此时，低位地址放偏移地址，高位地址放段地址。
### ret和retf
1. retf指令
   功能:用栈中的数据，修改IP的内容，从而实现近转移  
2. retf指令
   功能:用栈中的数据，修改CS和IP的内容,从而实现远转移
### mul乘法指令
1. 8位乘法:
   被乘数在AL当中,乘数在8位寄存器或内存字节单元，结果在ax当中
2. 16位乘法:
   被乘数放在AX当中，乘数在16位寄存器或内存字单元,结果在DX(高位)和AX(低位)中。
### 汇编语言的模块化设计
使用:call指令(调用子程序),ret指令(返回)配合完成。子程序:根据提供的参数处理一定的事务，处理后,将结果(返回值)提供给调用者。  
#### 参数和结果传递问题
问题:根据提供的N,计算N的3次方  
考虑:  
1. 将参数N存储在什么位置？
2. 计算得到的值，存放在哪儿？
方案:  
1. 可以用寄存器存储参数和结果
2. 可以用内存单元进行参数传递
3. 可以用栈传递参数
用内存单元批量传递数据:  
将批量数据放到内存中，然后将它们所在内存空间的首地址放在寄存器中，传递给需要的子程序。  
对于具有批量数据的返回结果，也可以用同样的方法。  
用栈传递参数:  
由调用者将需要传递给子程序的参数，压入栈中，子程序从栈中取得参数  
任务：计算(a-b)^3,a、b为word型数据
方法:  
1. 进入子程序前，参数a,b入栈
2. 调用子程序，将使栈顶存放IP
3. 结果:(dx:ax)=(a-b)^3
ret n的含义,(平栈操作)
pop ip
add sp,n
### 寄存器的冲突解决方法
对于同一个寄存器存在了两种用法时,调用者，注意将同一寄存器的旧值入栈，待子程序执行完成时，将旧值出栈。
### 标志寄存器
PSW/FLAGS寄存器  
功能:flag寄存器是按位起作用的，也就是说，它的每一位都有专门的含义，记录特定的信息  
8086CPU中没有使用flag的1、3、5、12、13、14、15位，这些位不具有任何含义。  
作用:  
用来存储相关指令的某些执行结果  
用来为CPU执行相关指令提供行为依据  
用来控制CPU的相关工作方式  
标志寄存器中包含的位表示的寄存器:
第11号位:OF(是否溢出寄存器)  
功能:在进行有符号数运算时，如结果超过了机器所能表示的范围称为溢出  
OF记录有符号数操作指令执行之后,  
有溢出,OF=1  
无溢出,OF=0  
第10号位:DF(方向寄存器)  
1. 
第7号位:SF(符号寄存器)  
功能:SF记录指令执行后，将结果视为有符号数  
结果为负,SF=1  
结果为非负,SF=0  
第6号位:ZF(零值寄存器)  
功能:标记相关指令的计算结果是否为0，  
ZF=1,表示"结果是0"，1表示"逻辑真"  
ZF=0,表示"结果不是0",0表示"逻辑假"  
add、sub、mul、div、inc、or、and等运算指令，进行逻辑或算术运算会影响标志寄存器。  
第2号位:PF(奇偶寄存器)  
功能:PF记录指令执行之后，结果的所有二进制位中1的个数.  
1的个数为偶数时，PF=1;  
1的个数为奇数时，PF=0;  
第0号位:CF(进位寄存器)  
功能:在进行无符号数运算时，CF记录了运算结果的最高有效位向更高位的进位值，或从更高位的借位值。  
CF记录在指令执行之后,  
有进位或借位，CF=1  
无进位或借位, CF=0  
### 带进位或借位的加法减法。
adc 是带进位加法指令，它利用了CF位上记录的进位值。  
格式:adc 操作对象1，操作对象2  
功能:操作对象1=操作对象1+操作对象2+CF  
例:adc ax,bx实现的功能是:(ax)+(ax)+(bx)+CF  
adc指令应用:  
1. 大数相加  
   思路:先将低16位相加，然后将高16位和进位值相加(更大的数的思路相同。)  
   ```
      mov ax,001Eh
      mov bx,0f00h
      add bx,1000h
      adc ax,0020h
   ```
   两个128位的数据进行相加  
   功能: 
   ```
   data segment
      dw A452H,0A8F5H,78E6H,0A8EH,8B7AH,54F6H,0F04H,671EH
      DW 0E71EH,0EF04H,54F6H,8B7AH,0A8EH,78E6H,58F5H,0452H
   data ends

   code segment
   start: mov ax,data
         mov ds,ax
         mov si,0
         mov di,16
         mov cx,8
         call add123
         mov ax,4c00h
         int 21h
   add128:
      push ax
      push cx
      push si
      push di
      sub ax,ax
      s:mov ax,[si]
      adc ax,[di]
      mov [si],ax
      inc si
      inc si
      inc di
      inc di
      loop s
      pop di
      pop si
      pop cx
      pop ax
      ret
   code ends

   inc 指令不会影响CF标志位，add可能会影响标记为
   ```
### sbb指令
格式: sbb操作对象1，操作对象2  
功能:操作对象1=操作对象1-操作对象2-CF  
与sub区别:利用CF位上记录的借位值  
比如:sbb ax,bx  
实现功能:(ax)=(ax)-(bx)-CF  
应用:对任意大的数据进行减法  
例如:计算003E1000H-00202000H,结果放在ax,bx中  
思路:先低位相减，高位相减时，使用sbb进行减法。  
```
   mov bx,1000h
   mov ax,003Eh
   sub bx,2000h
   sbb ax,0020h
```
### cmp指令
格式: cmp 操作对象1，操作对象2  
功能: 计算操作对象1，操作对象2  
应用: 其他相关指令通过识别这些被影响的标志寄存器位来得知比较结果。  
cmp ax,ax  
功能:做(ax)-(ax)的运算，结果为0，但并不保存在ax中，仅影响flag的相关各个位。  
标志寄存器:ZF=1 PF=1 SF=0 CF=0 OF=0  
无符号数比较与标志位取值:  
思路:通过cmp指令执行后相关标志位的值，可以看出比较结果  
指令: cmp ax,bx  
无符号数比较关系:
等于 (ax)=(bx) (ax)-(bx)=0 ZF=1  
不等于 (ax)!=(bx) (ax)-(bx)!=0 ZF=0  
小于 (ax)<(bx) (ax)-(bx)将产生借位，CF=1  
大于等于 (ax)>=(bx) (ax)-(bx)不必借位，CF=0  
大于 (ax)>(bx) (ax)-(bx)既不借位，结果又不为0 CF=0且ZF=0  
小于等于 (ax)<=(bx) (ax)-(bx)或者借位，或者结果为0 CF=1或ZF=1  
有符号数比较与标志位取值  
用cmp来进行有符号数比较时，CPU用哪些标志位对比较结果进行记录?  
等于 (ah)=(bh) (ah)-(bh)=0 ZF=1  
不等于 (ah)!=(bh) (ah)-(bh)!=0 ZF=0  
小于 (ax)<(bx) (ax)-(bx)为负，且不溢出 SF=1且OF=0  
大于 (ax)>(bx) (ax)-(bx)为负，且溢出, SF=1且OF=1  
大于等于 (ax)>=(bx) (ax)-(bx)为非负，且无溢出 SF=0且OF=0  
小于等于 (ax)<=(bx) (ax)-(bx)为非负，且有溢出 SF=0或OF=1  
#### 条件转移指令
cmp oper1,oper2 或者其他影响标志寄存器的指令  
jxxx 标号  
根据单个标志位转移的指令:  
je/jz  相等/结果为0 ZF=1  
jne/jnz 不等/结果不为0 ZF=0  
js 结果为负 SF=1  
jns 结果为非负 SF=0  
jo 结果溢出 OF=1  
jno 结果没有溢出 OF=0  
jp 奇偶位为1 PF=1  
jnp 奇偶位不为1 PF=0  
jb/jnae/jc 低于/不高于等于/有借位 CF=1  
jnb/jae/jnc 不低于/高于等于/无借位 CF=0  
根据无符号数比较结果进行转移的指令:  
jb/jnae/jc 低于则转移 CF=1  
jnb/jae/jnc 低于则转移 CF=0  
jna/jbe 不高于则转移 CF=1或ZF=1  
ja/jnbe 高于则转移 CF=0且ZF=0  
根据有符号数比较结果进行转移的指令:  
jl/jnge 小于则转移 SF=1且OF=0  
jnl/jge 不小于转移 SF=0且OF=0  
jle/jng 小于等于则转移 SF=0或OF=1  
jnle/jg 不小于等与则转移 SF=1且OF=1  
### 条件转移指令的应用
条件转移指令可以根据"条件"，决定是否"转移"程序执行流程。  
"转移"=修改IP  
条件转移指令通常都和cmp相配合使用，cmp指令改变标志位  
双分支结构的实现:  
```
   cmp ah,bh
   je s  ;若果ah和bh相等，则跳转到s
   add ah,bh
   jmp short ok
   s:add ah,ah
   ok:ret
```
注意:条件转移指令不一定非得要和jmp配合。只要标志位改变了，都能进行条件转移。  
给出下面一组数据  
```
   data segment
      db 8,11,8,1,8,5,63,38
   data ends
```
统计数值为9的字节的个数,  
统计数值大于8的字节的个数,  
统计数值小于8的字节的个数  
```
code segment
start:
   mov ax,data
   mov ds,ax
   mov ax,0
   mov cx,8
   s: cmp byte ptr [bx],8
   jne next
   inc ax
   next:
   inc bx
   loop s
   mov ax,4c00h
   int 21h
code ends
```
### DF方向标志位,串传送指令
将data 段中的第一个字符复制到它后面的空间中。
```
   data segment
   db 'Welcome to masm!'
   db 16 dup(0)
   data ends
```
DF-方向标志位(Direction Flag)  
功能:在串处理指令中，控制每次si，di的增减。  
DF=0:每次操作后si,di递增.  
DF=1:每次操作后si,di递减。  
#### 串传送指令movsb和movsw
movsb:  
功能:(以字节为单位传送)  
1. ((ex)x16+(di))= ((ds)x16+(si))  
2. 如果DF=0则:(si)=(si)+1 (di)=(di)+1  
   如果DF=1则:(si)=(si)-1 (di)=(di)-1  
movsw:
功能:(以字为单位传送)
1. ((es)x16+(di))=((ds)x16+(si))
2. 如果DF=0则:(si)=(si)+2 (di)=(di)+2
   如果DF=1则:(si)=(si)-2 (di)=(di)-2
#### 对DF位进行设置的指令:
   cld指令:将标志寄存器DF位设为0(clear)  
   std指令:将标志寄存器的DF位设置为1(setup)  
#### rep指令
rep指令常和串传送指令搭配使用  
功能:根据cx的值，重复执行后面的指令  
用法: rep movsb 等同于s:movsb loop s  

应用：用串传送指令，将F000H段中的最后16个字符复制到data段中。  
```
   data segment
   db 16 dup (0)
   data ends
   code segment
   start:
      mov ax,0f000h
      mov ds,ax
      mov si,0ffffh
      mov ax,data
      mov es,ax
      mov di,15
      mov cx,16
      std
      rep movsb
      mov ax,4c00h
      int 21h
   code ends
   end start
```
### 