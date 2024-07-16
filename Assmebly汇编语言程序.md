### 汇编语言编写程序的工作过程
汇编程序->编译器->机器码->计算机  
一个汇编程序由伪指令（由编译器执行的指令）、汇编指令(有对应机器码，可以被编译为机器指令，最终被CPU执行。)、
程序返回(套路！程序结束后，将CPU的控制权返还给使得它能够运行的程序)  
#### 程序中的三种伪指令
1. 段定义:
   一个汇编程序由多个段组成，这些段被用来存放代码、数据、或当做栈空间来使用。  
   定义程序中的段:每个段都需要有段名:  
   段名 segment --段的开始  
   段名 ends --段的结束
2. end (不是ends)
   汇编程序的结束标记。弱程序结尾处不加end,编译器在编译程序时，无法知道程序在何处结束。
3. assume(假设)
   假设某一段寄存器和程序中某一个用segment..ends定义的段相关联--assume cs:codemsg指CS段寄存器与codesg关联，将定义的codesg当做程序的代码段使用。  
源程序经编译连接后变为机器码。  
#### 汇编程序的结构  
在DosBox中，Debug直接写入指令编写的汇编程序。  
--- 注释
#### 汇编程序由写出程序到执行可执行文件的过程
1. 写出源文件.asm
   随便什么工具，文本编辑器也行，我使用vscode
2. 编译为目标文件.obj
   masm 文件名
   在DOSBox中使用masm工具进行源文件编译。
   会生成如下3种文件
   1. OBJ(目标文件)对于源程序进行编译要得到的最终结果
   2. LST(列表文件)是编译器将源程序编译为目标文件的过程中产生的中间结果
   3. CRF(交叉引用文件)交叉引用文件，同列表文件是编译器将源程序编译为目标文件过程中产生的中间结果
3. 连接为可执行文件.exe
   link 目标文件名
4. 执行可执行文件
   直接输入文件名。
#### 汇编语言[...]和(...)的区别
1. [...]汇编语法规定表示一个内存单元
   mov ax,[0] 段地址在DS中，偏移地址在[0]中。
2. (...)为学习方便做出的约定，表示一个内存单元或寄存器中的内容。
3. 再约定idata表示常量。
### LOOP指令
CPU执行Loop指令时要进行的操作  
   1. (cx) = (cx) - 1;  
   2. 判断cx 寄存器中的值,不为零则转至 loop 指定标号处，为零则向下执行。  
   s: add ax,ax  
   loop s  
cx寄存器中需要提前存放循环次数，因为(cx)影响着loop指令的执行结果  
使用loop编程的方法:  
1. 在cx寄存器中存放要循环的次数
2. 用标号指定循环开始的位置
3. 在标号和loop指令的中间，写上要循环执行的程序段(循环体)
### 段前缀的使用：一个异常现象及其对策
mov al,[0] 这种直接通过偏移地址赋值给寄存器的情况，可能导致编译为 mov al,00  
也就是编译时[0]容易被编译器编译为常数。  
解决办法，[0]前加上段寄存器名称,如ds:[0],这样向编译器明确表示这个是一个访问内存地址的操作。  

### 在代码段中存放数据
可以在代码段前面，使用dw(定义字型数据) db(定义一个字节) dd(定义一个双字)等关键字,表示其后定义的数据类型是什么  
但是这样会造成代码段混乱，执行时，先从定义的数据段开始  
``` assmebly
   assume cs:code
   code segment
    dw 0123,0456,0789,0abc,0def,0fed,0cba,0987
   code ends
   end
```
解决办法:在代码实际开始位置，加上start:标号指示代码段开始的位置

 ``` assmebly
   assume cs:code
   code segment
    dw 0123,0456,0789,0abc,0def,0fed,0cba,0987
    start : .... ;代码开始位置
   code ends
   end start ; end也可以指示程序的开始位置
```

### 在代码段中使用栈
可以在代码段的前面定义一段，数据为0的空间当做数据栈  
``` asm
   assume cs:codesg
codesg segment
    dw 0123h,0456h,0789h,0abch,0fedh,0cbah,0987h
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
```
如上dw 0,0,0定义了一段值为0的字空间。

### 将数据、代码、栈放入不同段
为了将数据、代码、栈分开，以便更好管理的程序空间，最好为数据，栈、代码设置不同的段。
```
   assume cs:code,ds:data,ss:stack
   data segment
   dw 0123h,0456h,0789h
   data ends
   stack segment
   stack ends
   cod segment
   start:   ;start标号的位置表示Ip初始值的位置。

   ;初始化数据段寄存器，栈段寄存器

   ；入栈
   ；出栈
   ；程序结束
   cod ends
```
### 处理字符方法
汇编程序中，用'......'的方式指明数据是以字符的形式给出的，编译器将把它们转化为相应的ASCII码。 
```asm
data segment
   db 'unIx'
   db 'foRk'
data ends
code segment
   start: mov al,'z'
          mov bl,'b'
          mov ax,4c00h
          int 21h
code ends
end start
``` 
上述程序数据段的实际起始地址为 DS:0 + 100h,这个100h是由于8086CPU在程序前段存在一个特数据的数据结构,程序段前缀,它位于程序的内存起始位置,其大小为100h。  
对于datasg中的字符串  
第一个字符串:小写字母转换为大写字母  
第二个字符串:大写字母转换为小写字母  
逻辑与指令:and dest,src  
逻辑或指令:or dest,src
```asm
   assume cs:codesg,ds:datasg
   datasg segment
      db 'BaSiC'
      db 'iNfOrMaTiOn'
   datasg

   codesg segment
   start:
      mov ax,datasg
      mov ds,ax
      ; 第一个字符串：小写字母转大写
      mov bx,0
      mov cx,5
      s: mov al,[bx]
         and al,11011111b
         mov [bx],al
         inc bx
         loop s
      ; 第二个字符串: 大写字母转小写
         mov bx,5
         mov cx,11
         s0: mov al[bx]
         or al,00100000b
         mov [bx],al
         inc bx
         loop s0

         mov ax,4c00h
         int 21h
   codesg ends
```
### [bx+idata]的寻址方式,基地址寻址方式
[bx+idata]表示一个内存单元，它的偏移地址为(bx)+idata(bx中的数值加上idata)。  
mov ax,[bx+200]/ mov ax,[200+bx]的含义  
将一个内存单元的内容送入ax  
将这个内存单元的长度为2字节(字单元),存放一个字  
内存单元的段地址在ds中，偏移地址为200加上bx中的数值  
指令mov ax,[bx+200]的其他写法(常用)  
mov ax,[200+bx]  
mov ax,200[bx]  
mov ax,[bx].200  
这种获取内存地址的方式，类似于数组线性表。  
```
; 用ds:[200+bx]的类似寻址方式将两个字符串的大小写字母进行转换
assume cs:codesg,ds:datasg
datasg segment
   db 'BaSiC'
   db 'MinIX'
datasg ends
codesg segment
start:mov ax,datasg
   mov ds,ax
   mov bx,0
   mov cx,5
   s: mov al,[bx]
   and al,11011111b
   mov [bx],al
   mov al,[5+bx]
   or al,00100000b
   mov [5+bx],al
   inc bx
   loop s
codesg ends
end
```
### SI和DI寄存器
通用寄存器:AX、BX、CX、DX  
变址寄存器:SI、DI  
指针寄存器:SP、BP  
指令指针寄存器:IP  
段寄存器:CS、SS、DS、ES  
标志寄存器:PSW  
SI和DI常执行与地址有关的操作  
SI和DI是8086CPU中和BX功能相近的寄存器  
BX:通用寄存器,在计算存储器地址时，常作为基地址寄存器用  
SI:source index,源变址寄存器  
DI:destination index,目标变址寄存器  
SI和DI不能够分成两个8位寄存器来使用  
下面三组指令实现了相同功能:  
1. mov bx,0  
   mov ax,[bx]
2. mov si,0  
   mov ax,[si]  
3. mov di,0  
   mov ax,[di]  
应用SI和DI，用寄存器SI和DI实现将字符串'welcome to masm!'复制到它后面的数据区中。
```
assume cs:codesg,ds:datasg
datasg segment
   db 'welcome to masm!'
   db '................'
datasg ends
codesg segment
start: mov ax,datasg
       mov ds,ax

       mov si,0      ; 源数据起始地址:datasg:0
       mov di,16     ; 目标数据起始地址:datasg:16
                     ; 用ds:si指向要复制的原始字符串
                     ; 用ds:di指向目标空间位置
                     ；然后用一个循环来完成复制。
       mov cx,8
       s: mov ax,[si]
       mov [di],ax
       add si,2
       add di,2
       loop s

       mov ax,4c00h
       int 21h
codesg ends
end
```

### [bx+si]和[bx+di]的方式寻址，基址变址寻址方式
[bx+si]表示一个内存单元，表示偏移地址为(bx)+(si)。  
内存中的数据2000:1000 BE 00 06 00 6A 22.....
```
;基址变址寻址应用案例
assume cs:code
code segment
mov ax,2000h
mov ds,ax
mov bx,1000h
mov si,0
mov ax,[bx+si]
inc si
mov cx,[bx+si]
inc si
mov di,si
mov ax,[bx+di]
code ends

```

### [bx+si+idata]和[bx+di+idata]方式寻址
[bx+si+idata]表示一个内存单元,内存地址的偏移地址为(bx)+(si)+idata的地址。  
内存中的数据2000:1000 BE 00 06 00 6A 22.....
```
;寻址应用案例
assume cs:code
code segment

code ends
end
```

### 不同寻址方式的灵活应用
[idata] 直接寻址，用常量直接寻址  
[bx] 寄存器间接寻址，用一个变量来表示内存地址  
[bx+idata] 寄存器相对寻址，用一个变量和常量表示地址，可在一个起始地址的基础上用变量间接定位一个内存单元  
[bx+si]基址变址寻址,用两个变量表示地址
[bx+si+idata]相对基址变址寻址，用两个变量和一个常量表示地址
```
;灵活应用不同的寻址方式,编程将datasg段中每个单词的头一个字母改写为大写字母。
assume cs:codesg,ds:datasg
datasg segment
   db '1.file'
   db '2.edit'
   db '3.search'
   db '4.view'
   db '5.options'
   db '6.help'
datasgends
codesg segment
start:

   mov 4c00h
   int 21h
codesg ends
end start
```
二重循环，可将外层循环数，先入栈，待每次内存循环结束时，重新将其出栈到cx，再执行外层循环。  
### 用于内存寻址的寄存器
只有bx、bp、si、di可以用于在[...]对内存单元寻址。  
cx,ax,dx,ds，这些寄存器不能用于内存寻址  
mov ax,[bp+si]  
mov ax,[bp+di]
mov ax,[bp+si+idata]  
mov ax,[bp+di+idata]  
不允许[bx+bp]和[si+di]这样的写法  
bx默认指向ds段，也就是数据段  
bp默认指向ss段，也就是栈段  
### 数据访问时，处理的数据在什么地方，处理的数据有多长
在哪里:  
1. 常数寻址，立即寻址
2. 寄存器
3. 内存
要处理的数据有多长
1. 字word操作
2. 字节操作 byte ptr  
3. mov word ptr ds:[0],1
4. inc word ptr [bx]
5. inc word ptr ds:[0]
使用word ptr或者byte ptr指明当前寻址到的数据是字数据还是字节数据  
### 寻址方式的总和应用
编程修改内存当中的过时数据
```
assume cs:code
code segment
mov ax,seg
mov ds,ax
mov bx,60h
mov word ptr [bx+0ch],11
mov word ptr [bx+0eh],13

mov si,0
mov byte ptr [bx+10h+si],'H'
inc si
mov byte ptr [bx+10h+si],'O'
inc si
mov byte ptr [bx+10h+si],'U'
code ends
end
```
### div指令
div是除法指令，使用div作除法的时候  
被除数:(默认)放在AX(16位被除数)或(dx和ax)(32位被除数,高位在dx中,低位在ax)中  
除数:8位或16位,在寄存器或内存单元中。  
结果:除数8时，在AL中存放商,在ah中存放余数，被除数在AX中存放(16位以内)。除数为16位时,在AX中存放商,在DX中存放余数,在DX和AX放被除数(32位)。  
在默认的寄存器中设置好被除数，且默认寄存器不作别的用处。  

### dup指令设置重复的内存空间。
dup  和db、dw、dd等数据定义伪指令配合使用，用来进行数据的重复。  
db 3 dup(0) 定义了3个字节，它们的值都是0 db 0,0,0  
db 3 dup(0,1,2) 定义了9个字节，由0、1、2重复3次构成 db 0,1,2,0,1,2,0,1,2  
db 3 dup('abc','ABC')定义了18个字节，构成'abcABCabcABCabcABC'  
dup的使用格式  
db 重复的次数 dup(重复的字节型数据)  
dw 重复的次数 dup(重复的字型数据)  
dd 重复的次数 dup(重复的双字型数据)  