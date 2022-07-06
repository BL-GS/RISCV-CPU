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
wire [31: 0]    pc_IF, pc_ID, pc_EX, pc_MEM, pc4_MEM, pc4_WB;
wire [31: 0]    pc_IF_ID;
wire [31: 0]    pc_ID_EX;
wire [31: 0]    pc_EX_MEM;
wire [31: 0]    pc4_MEM_WB;

// 指令
wire [31: 0]    inst_IF;
wire [31: 0]    inst_ID;
wire [6: 0]     func7_ID   = inst_ID[31: 25];
wire [2: 0]     func3_ID   = inst_ID[14: 12];
wire [6: 0]     opecode_ID = inst_ID[6: 0];

// 读取写入信息
wire [4: 0]     rs1_ID, rs2_ID;
wire [31: 0]    rd1_ID;
wire [31: 0]    rd2_ID;
wire [31: 0]    DRAMRd_MEM, DRAMRd_WB;
wire [31: 0]    RegWd_WB;
wire [4: 0]     RegWr_ID, RegWr_EX, RegWr_MEM, RegWr_WB;

// 运算结果
reg  [31: 0]    Anum_ID, Anum2_ID, Bnum_ID, Bnum2_ID;
wire [31: 0]    Anum_EX, Anum2_EX, Bnum_EX, Bnum2_EX;
wire [31: 0]    ALUOut_EX, ALUOut_MEM, ALUOut_WB;
wire [1: 0]     COMPOut_EX, COMPOut_MEM, COMPOut_WB;
wire [31: 0]    COMPExOut_WB;
wire [31: 0]    immOut_ID;


// 例外信号
wire risk_Ctrl;
wire stop_IF;
wire stop_ID;

// 前递信号
wire            MUX_A_Forwarding;
wire            MUX_B_Forwarding;
wire [31: 0]    forwardingA;
wire [31: 0]    forwardingB;

// 控制信号
wire [3: 0]     PCCTRL_ID, PCCTRL_EX;
wire            RegWe_ID, RegWe_EX, RegWe_MEM, RegWe_WB;
wire            ASel_ID;
wire            BSel_ID;
wire            DRAMWE_ID, DRAMWE_EX, DRAMWE_MEM;
wire [1: 0]     RWSel_ID, RWSel_EX, RWSel_MEM, RWSel_WB;
wire [4: 0]     SextOpe_ID;
wire [2: 0]     ALUop_ID, ALUop_EX;
wire            Unsigned_ID, Unsigned_EX, Unsigned_MEM;
wire [1: 0]     DRAM_EX_TYPE_ID, DRAM_EX_TYPE_EX, DRAM_EX_TYPE_MEM;
wire [31: 0]    DRAMIn_EX, DRAMIn_MEM;

`ifdef DEBUG
// 单周期 CPU 中，wb_have_inst 始终为 1
assign wb_have_inst = (pc4_WB != 4) ? 1 : 0;
assign wb_pc        = pc4_WB - 4;
assign wb_ena       = RegWe_WB;
assign wb_reg       = RegWr_WB;
assign wb_value     = RegWd_WB;
`endif

/****************************************************************
                        取值阶段
*****************************************************************/

IF If (
       .clk(clk),
       .rst_n(rst_n),
       .stop_IF(stop_IF),
       .PCCTRL(PCCTRL_EX),
       .addOut(ALUOut_EX),
       .COMPOut(COMPOut_EX),
       .pc_ID(pc_ID),
       .inst(inst_IF),
       .pc(pc_IF),
       .risk_Ctrl(risk_Ctrl)
   );

IF_ID if_id (
          .clk(clk),
          .rst_n(rst_n),
          .stop_IF(stop_IF),
          .pc(pc_IF),
          .inst(inst_IF),
          .pc_o(pc_ID),
          .inst_o(inst_ID)
      );

/****************************************************************
                        译码阶段
*****************************************************************/

// 控制模块
CTRL ctrl (
         .rst_n(rst_n),
         .func7(func7_ID),
         .func3(func3_ID),
         .opecode(opecode_ID),
         .RegWe(RegWe_ID),
         .ASel(ASel_ID),
         .BSel(BSel_ID),
         .DRAMWE(DRAMWE_ID),
         .RWSel(RWSel_ID),
         .SextOpe(SextOpe_ID),
         .DRAM_EX_TYPE(DRAM_EX_TYPE_ID),
         .PCCTRL(PCCTRL_ID)
     );

ID Id (
       .clk(clk),
       .rst_n(rst_n),
       .inst(inst_ID),
       .SextOpe(SextOpe_ID),
       .RegWe(RegWe_WB),
       .RegWd(RegWd_WB),
       .RegWr(RegWr_WB),
       .rd1(rd1_ID),
       .rd2(rd2_ID),
       .immOut(immOut_ID),
       .ALUop(ALUop_ID),
       .Unsigned(Unsigned_ID)
   );

ID_EX id_ex (
          .clk(clk),
          .rst_n(rst_n),
          .stop_ID(stop_ID),
          .pc(pc_ID),
          .Anum(Anum_ID),
          .Bnum(Bnum_ID),
          .Anum2(Anum2_ID),
          .Bnum2(Bnum2_ID),
          .ALUop(ALUop_ID),
          .Unsigned(Unsigned_ID),
          .DRAM_EX_TYPE(DRAM_EX_TYPE_ID),
          .DRAMWE(DRAMWE_ID),
          .DRAMIn(rd2_ID),
          .RWSel(RWSel_ID),
          .RegWr(inst_ID[11: 7]),
          .RegWe(RegWe_ID),
          .PCCTRL(PCCTRL_ID),

          .pc_o(pc_EX),
          .Anum_o(Anum_EX),
          .Bnum_o(Bnum_EX),
          .Anum2_o(Anum2_EX),
          .Bnum2_o(Bnum2_EX),
          .ALUop_o(ALUop_EX),
          .Unsigned_o(Unsigned_EX),
          .DRAM_EX_TYPE_o(DRAM_EX_TYPE_EX),
          .DRAMWE_o(DRAMWE_EX),
          .DRAMIn_o(DRAMIn_EX),
          .RWSel_o(RWSel_EX),
          .RegWr_o(RegWr_EX),
          .RegWe_o(RegWe_EX),
          .PCCTRL_o(PCCTRL_EX)
      );

// 操作数选择
always @(*) begin
    // A操作数选择
    if (MUX_A_Forwarding == `ASEL_FORWARDING) begin // 有前递
        Anum_ID  = (ASel_ID == `ASEL_REG) ? forwardingA : pc_ID;
        Anum2_ID = (ASel_ID == `ASEL_REG) ? pc_ID : forwardingA;
    end
    else begin  // 无前递
        Anum_ID  = (ASel_ID == `ASEL_REG) ? rd1_ID : pc_ID;
        Anum2_ID = (ASel_ID == `ASEL_REG) ? pc_ID : rd1_ID;
    end
end

always @(*) begin
    // B操作数选择
    if (MUX_B_Forwarding == `BSEL_FORWARDING) begin // 有前递
        Bnum_ID  = (BSel_ID == `BSEL_REG) ? forwardingB : immOut_ID;
        Bnum2_ID = (BSel_ID == `BSEL_REG) ? immOut_ID : forwardingB;
    end
    else begin  // 无前递
        Bnum_ID  = (BSel_ID == `BSEL_REG) ? rd2_ID : immOut_ID;
        Bnum2_ID = (BSel_ID == `BSEL_REG) ? immOut_ID : rd2_ID;
    end
end

/****************************************************************
                        执行阶段
*****************************************************************/

EX Ex (
       .Ain(Anum_EX),
       .Bin(Bnum_EX),
       .COMPAin(Anum2_EX),
       .COMPBin(Bnum2_EX),
       .ALUop(ALUop_EX),
       .Unsigned(Unsigned_EX),
       .COMPOut(COMPOut_EX),
       .ALUOut(ALUOut_EX)
   );


EX_MEM ex_mem (
           .clk(clk),
           .rst_n(rst_n),
           .pc(pc_EX),
           .DRAM_EX_TYPE(DRAM_EX_TYPE_EX),
           .DRAMWE(DRAMWE_EX),
           .RWSel(RWSel_EX),
           .RegWr(RegWr_EX),
           .RegWe(RegWe_EX),
           .COMPOut(COMPOut_EX),
           .ALUOut(ALUOut_EX),
           .DRAMIn(DRAMIn_EX),
           .Unsigned(Unsigned_EX),

           .pc_o(pc_MEM),
           .DRAM_EX_TYPE_o(DRAM_EX_TYPE_MEM),
           .DRAMWE_o(DRAMWE_MEM),
           .RWSel_o(RWSel_MEM),
           .RegWr_o(RegWr_MEM),
           .RegWe_o(RegWe_MEM),
           .COMPOut_o(COMPOut_MEM),
           .ALUOut_o(ALUOut_MEM),
           .DRAMIn_o(DRAMIn_MEM),
           .Unsigned_o(Unsigned_MEM)
       );

/****************************************************************
                        执行阶段
*****************************************************************/

assign mem_addr   = ALUOut_MEM;
assign mem_ctrl   = {Unsigned_MEM, DRAM_EX_TYPE_MEM[1: 0], DRAMWE_MEM};
assign mem_wd     = DRAMIn_MEM;
assign mem_we     = DRAMWE_MEM;
assign DRAMRd_MEM = mem_rd;

assign pc4_MEM = pc_MEM + 4;

MEM_WB mem_wb (
           .clk(clk),
           .rst_n(rst_n),
           .pc4(pc4_MEM),
           .RWSel(RWSel_MEM),
           .RegWr(RegWr_MEM),
           .RegWe(RegWe_MEM),
           .COMPOut(COMPOut_MEM),
           .ALUOut(ALUOut_MEM),
           .DRAMRd(DRAMRd_MEM),

           .pc4_o(pc4_WB),
           .RWSel_o(RWSel_WB),
           .RegWr_o(RegWr_WB),
           .RegWe_o(RegWe_WB),
           .COMPOut_o(COMPOut_WB),
           .ALUOut_o(ALUOut_WB),
           .DRAMRd_o(DRAMRd_WB)
       );

/****************************************************************
                        写回阶段
*****************************************************************/

assign COMPExOut_WB = {31'b0, COMPOut_WB[0]};// 对比较结果进行符号扩展

WB Wb (
       .pc4(pc4_WB),
       .COMPExOut(COMPExOut_WB),
       .ALUOut(ALUOut_WB),
       .DRAMRd(DRAMRd_WB),
       .RWSel(RWSel_WB),
       .RegWd(RegWd_WB)
   );


/****************************************************************
                        前递和例外处理
*****************************************************************/
wire TYPE_COMP_R = (opecode_ID[6: 2] == 5'b01100 && func3_ID[2:1] == 2'b01) ? 1'b1 : 1'b0;
wire TYPE_COMP_I = (opecode_ID[6: 2] == 5'b00100 && func3_ID[2:1] == 2'b01) ? 1'b1 : 1'b0;

reg isLoad; // 需要代表 EX 阶段的载入判断
reg isLoad_MEM;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        isLoad <= 1'b0;
        isLoad_MEM <= 1'b0;
    end
    else begin
        isLoad <= (opecode_ID[6: 2] == 5'b00000) ? 1'b1 : 1'b0;
        isLoad_MEM <= isLoad;
    end
end

reg rd_Type_EX;
reg rd_Type_MEM;
wire [31: 0] rd_EX = (rd_Type_EX) ? {31'b0, COMPOut_EX[0]} : ALUOut_EX;
wire [31: 0] rd_MEM = (isLoad_MEM) ? DRAMRd_MEM :
     (rd_Type_MEM) ? {31'b0, COMPOut_MEM[0]} : ALUOut_MEM; // TODO:

assign rs1_ID = inst_ID[19: 15];
assign rs2_ID = inst_ID[24: 20];

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rd_Type_EX <= 0;
        rd_Type_MEM <= 0;
    end
    else begin
        rd_Type_EX <= (TYPE_COMP_I | TYPE_COMP_R);
        rd_Type_MEM <= rd_Type_EX;
    end
end

ForwardingUnit forwardingUnit (
                   .rs1_ID(rs1_ID),
                   .rs2_ID(rs2_ID),
                   .wr_EX(RegWr_EX),
                   .wr_MEM(RegWr_MEM),
                   .we_EX(RegWe_EX),
                   .we_MEM(RegWe_MEM),
                   .rd_EX(rd_EX),
                   .rd_MEM(rd_MEM),
                   .MUX_A_forwarding(MUX_A_Forwarding),
                   .MUX_B_forwarding(MUX_B_Forwarding),
                   .forwardingA(forwardingA),
                   .forwardingB(forwardingB)
               );


ExceptionCTRL exceptionCTRL (
                  .rs1_ID(rs1_ID),
                  .rs2_ID(rs2_ID),
                  .wr_EX(RegWr_EX),
                  .isLoad(isLoad),
                  .isRiskCtrl(risk_Ctrl),
                  .stop_IF(stop_IF),
                  .stop_ID(stop_ID)
              );


endmodule
