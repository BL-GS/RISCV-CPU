// `define DEBUG

`ifndef ALU_PARAM
`define ALU_PARAM

/****************************************************************
                        基本部件常量
*****************************************************************/

// 数字位宽
`define WIDTH_PC            32
`define WIDTH_INST          32
`define WIDTH_OPENUM        32
`define WIDTH_ALUOUT        32
`define WIDTH_COMPOUT       2
`define WIDTH_COMP_EX_OUT   32
`define WIDTH_DRAMRd        32
`define WIDTH_REGMARK       5

// 控制信号
`define WIDTH_ALUOpe        4
`define WIDTH_ALUOp         3
`define WIDTH_Unsigned      1     
`define WIDTH_DRAM_EX_TYPE  2
`define WIDTH_DRAMWE        1
`define WIDTH_RWSel         2
`define WIDTH_RegWE         1
`define WIDTH_DRAMIN        32
`define WIDTH_PCCTRL        4
`define WIDTH_PCSEL         1



/****************************************************************
                        基础部件（Basic）中常量
*****************************************************************/

// 符号
`define UNSIGNED    1'b1
`define SIGNED      1'b0

// 运算类型
`define ADD     3'b000
`define SUB     3'b010

`define AND     3'b110
`define OR      3'b100
`define XOR     3'b101

`define SLL     3'b001
`define SRL     3'b011
`define SRA     3'b111

// 立即数扩展类型
`define IMM_I   5'b10000
`define IMM_S   5'b01000
`define IMM_B   5'b00100
`define IMM_J   5'b00010
`define IMM_U   5'b00001

// 比较结果
`define COMP_EQ 2'b00
`define COMP_LE 2'b01
`define COMP_GE 2'b10

// 读取结果扩展
`define DRAM_EX_W   2'00
`define DRAM_EX_H   2'01
`define DRAM_EX_B   2'11


/****************************************************************
                        组合（Combine）中常量
*****************************************************************/

// PC 跳转控制
`define PCSEL_PC4           1'b0    // 顺序执行
`define PCSEL_JUMP          1'b1    // 跳转执行

// 寄存器写入控制
`define REGWE_READ      1'b0    // 不可写
`define REGWE_WRITE     1'b1    // 可写

// ALU 输入控制（COMP输入相反）
`define ASEL_REG        1'b0    // 选择寄存器输入 A
`define ASEL_PC         1'b1    // 选择 PC 输入 A
`define BSEL_REG        1'b0    // 选择寄存器输入 B
`define BSEL_IMM        1'b1    // 选择立即数输入 B
`define ASEL_FORWARDING 1'b1
`define BSEL_FORWARDING 1'b1 

// 写主存控制
`define DRAM_READ       1'b0    // 不可写
`define DRAM_WRITE      1'b1    // 可写

// 写回寄存器选择
`define REGWD_PC        2'b00   // 写回 PC + 4
`define REGWD_COMPOUT   2'b01   // 写回比较结果
`define REGWD_ALUOUT    2'b11   // 写回 ALU 运算结果
`define REGWD_DRAMRD    2'b10   // 写回主存读取结果

// PC跳转指令类型
`define PCCTRL_B_EQ     2'b00
`define PCCTRL_B_NE     2'b01
`define PCCTRL_B_LT     2'b10
`define PCCTRL_B_GEQ    2'b11
`define PCCTRL_B        2
`define PCCTRL_J        3

/****************************************************************
                        IO中常量
*****************************************************************/

// 接口
`define IO_INTERFACE_NUM    3

// 总线宽度
`define IO_BUS_WIDTH_ADDR   32  // 地址线宽度
`define IO_BUS_WIDTH_DATA   32  // 数据线宽度
`define IO_BUS_WIDTH_CTRL   4   // 控制线宽度
`define IO_BUS_WIDTH_STATU  2   // 状态总线

// 控制总线规定
`define IO_BUS_CTRL_WE          0
`define IO_BUS_CTRL_TYPE_B      1
`define IO_BUS_CTRL_TYPE_HB     2 
`define IO_BUS_CTRL_UNSIGNED    3

// 控制总线读写
`define IO_CTRL_READ       1'b0    // 不写
`define IO_CTRL_WRITE      1'b1    // 写

// 地址偏移
`define IO_CALL_HIGHERADDR 3
`define IO_CALL_LOWERADDR  2 
`define IO_CALL_WIDTH      `IO_CALL_HIGHERADDR - `IO_CALL_LOWERADDR + 1
`define IO_CALL_CTRL       2'b00    // 控制
`define IO_CALL_INOUT      2'b01    // 数据传输
`define IO_CALL_STATU      2'b10    // 状态传输

/****************************************************************
                        外设配置
*****************************************************************/

`define DEVICE_NUM_LED          24
`define DEVICE_NUM_SWITCH       24
`define DEVICE_NUM_NUMLED       8
`define DEVICE_NUM_NUMLED_EN    8
`define DEVICE_NUM_KB_ROW       4
`define DEVICE_NUM_KB_COL       4


`endif

