# 基于 FPGA 实现的 RISC-V CPU
## 代码分支
* `master` 单周期 CPU
* `pipeline` 流水线 CPU

## 实现的指令
| 指令类型       | 指令                             |
| -------------- | -------------------------------- |
| 算术运算指令   | add, addi, sub, lui, auipc       |
| 逻辑运算指令   | and, andi, or, ori, xor, xori    |
| 移位运算指令   | sll, slli, srl, srli, sra, srai  |
| 载入&存储指令  | lw, sw, lb, lbu, lh, lhu, sb, sh |
| 跳转指令       | beq, bne, blt, bge, bltu, bgeu   |
| 无条件跳转指令 | jal, jalr                        |
| 比较指令       | slt, slti, sltu, sltiu           |


## 开发环境

1. RARS模拟器1.4
2. WSL2 + Ubuntu22.04
3. VSCode和一系列插件
4. VIVADO 2018.3
5. Logisim

** 开发板 **： Xilinx开发板（ XC7A100T-1FGG484C）

## 文档

目前相关教程位于知乎专栏：https://www.zhihu.com/column/c_1530950608688910336

正在佛系整理 Gitbook 文档 :joy: 

> 【注】请忽略一些提交的奇怪分支和节点，因为需要再虚拟机和 Windows 环境下切换，懒得研究文件传输，所以直接拿 Gitee 当中转站的。。。专注于最后一版即可，其他部分可能会有些 BUG