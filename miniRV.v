`include "param.v"

module mini_rv (
`ifdef DEBUG
           output wire          wb_have_inst,
           output wire [31: 0]  wb_pc,
           output wire          wb_ena,
           output wire [4: 0]   wb_reg,
           output wire [31: 0]  wb_value,
`endif
           output wire [`IO_BUS_WIDTH_ADDR - 1: 0]  mem_addr,
           output wire [`IO_BUS_WIDTH_CTRL - 1: 0]  mem_ctrl,
           output wire [`IO_BUS_WIDTH_DATA - 1: 0]  mem_wd,
           output wire                              mem_we,
           input  wire [`IO_BUS_WIDTH_DATA - 1: 0]  mem_rd,
           
           input wire           clk,
           input wire           rst_n
       );

// 地址信号
wire [31: 0]    pc;
wire [31: 0]    pc4;

// 指令
wire [31: 0]    inst;
wire [6: 0]     func7   = inst[31: 25];
wire [2: 0]     func3   = inst[14: 12];
wire [6: 0]     opecode = inst[6: 0];

// 读取写入信息
wire [31: 0]    rd1;
wire [31: 0]    rd2;
wire [31: 0]    DRAMRd;
wire [31: 0]    RegWd;

// 运算结果
wire [31: 0]    ALUOut;
wire [1: 0]     COMPOut;
wire [31: 0]    immOut;
wire [31: 0]    COMPExOut;

// 控制信号
wire            PCSel;
wire            RegWe;
wire            ASel;
wire            BSel;
wire            DRAMWE;
wire [1: 0]     RWSel;
wire [4: 0]     SextOpe;
wire [2: 0]     ALUop;
wire            Unsigned;
wire [1: 0]     DRAM_EX_TYPE;

`ifdef DEBUG
// 单周期 CPU 中，wb_have_inst 始终为 1
assign wb_have_inst = 1;
assign wb_pc        = pc;
assign wb_ena       = RegWe;
assign wb_reg       = inst[11: 7];
assign wb_value     = RegWd;
`endif

// 控制模块
CTRL ctrl (
         .rst_n(rst_n),
         .func7(func7),
         .func3(func3),
         .opecode(opecode),
         .COMPRes(COMPOut),
         .PCSel(PCSel),
         .RegWe(RegWe),
         .ASel(ASel),
         .BSel(BSel),
         .DRAMWE(DRAMWE),
         .RWSel(RWSel),
         .SextOpe(SextOpe),
         .DRAM_EX_TYPE(DRAM_EX_TYPE)
     );

IF If (
       .clk(clk),
       .rst_n(rst_n),
       .branch_pc(ALUOut),
       .PCSel(PCSel),
       .inst(inst),
       .pc(pc),
       .pc4(pc4)
   );

ID Id (
       .clk(clk),
       .rst_n(rst_n),
       .inst(inst),
       .SextOpe(SextOpe),
       .RegWe(RegWe),
       .RegWd(RegWd),
       .rd1(rd1),
       .rd2(rd2),
       .immOut(immOut),
       .ALUop(ALUop),
       .Unsigned(Unsigned)
   );

EX Ex (
       .rd1(rd1),
       .rd2(rd2),
       .imm(immOut),
       .pc(pc),
       .ASel(ASel),
       .BSel(BSel),
       .ALUop(ALUop),
       .Unsigned(Unsigned),
       .COMPOut(COMPOut),
       .COMPExOut(COMPExOut),
       .ALUOut(ALUOut)
   );

assign mem_addr = ALUOut;
assign mem_ctrl = {Unsigned, DRAM_EX_TYPE[1: 0], DRAMWE};
assign mem_wd = rd2;
assign mem_we = DRAMWE;
assign DRAMRd = mem_rd;
/*
MEM_IO Mem (
        .clk(clk),
        .rst_n(rst_n),
        .DRAMWE(DRAMWE),
        .din(rd2),
        .ALUOut(ALUOut),
        .Unsigned(Unsigned),
        .DRAM_EX_TYPE(DRAM_EX_TYPE),
        .DRAMRd(DRAMRd)
    );
*/

WB Wb (
       .pc4(pc4),
       .COMPExOut(COMPExOut),
       .ALUOut(ALUOut),
       .DRAMRd(DRAMRd),
       .RWSel(RWSel),
       .RegWd(RegWd)
   );


endmodule
