`ifdef DEBUG
`include "param.v"
`else
`include "../../param.v"
`endif

module BranchPredictor (
           input    wire                        clk,
           input    wire                        rst_n,
           input    wire [`WIDTH_INST - 1 : 0]  inst,
           input    wire                        risk_Ctrl_delay,
           input    wire [`WIDTH_PC - 1 : 0]    pc,
           input    wire [`WIDTH_PC - 1 : 0]    branch_pc,
           output   reg  [`WIDTH_PC - 1 : 0]    pre_pc,
           output   reg                         jump
       );

wire [6: 0]     opecode;
wire            inst_j;
wire            inst_jalr;
wire            inst_b;
wire            pc_jump_j;
wire            pc_jump_b;

reg  [31: 0]     imm;
wire [31: 0]    imm_B;
wire [31: 0]    imm_J;

/***************************************************************
                        指令译码
****************************************************************/
assign opecode   = inst[6: 0];
assign inst_j    = (opecode[6: 2] == 5'b11011) ? 1'b1 : 1'b0;
assign inst_jalr = (opecode[6: 2] == 5'b11001) ? 1'b1 : 1'b0;
assign inst_b    = (opecode[6: 2] == 5'b11000) ? 1'b1 : 1'b0;

wire inst0                  = inst[31];
wire [5: 0]     inst1       = inst[30: 25];
wire [3: 0]     inst2       = inst[24: 21];
wire inst3                  = inst[20];
wire [7: 0]     inst4       = inst[19: 12];
wire [3: 0]     inst5       = inst[11: 8];
wire inst6                  = inst[7];
wire [11: 0]    signalEX_12 = {12{inst0}};
wire [19: 0]    signalEX_20 = {{8{inst0}}, signalEX_12[11: 0]};
assign imm_J = {signalEX_12, inst4, inst3, inst1, inst2, 1'b0};

/***************************************************************
                        BHT 表连接
****************************************************************/

wire isHit_BHT;
wire isJump_BHT;
wire [`WIDTH_PC - 1 : 0] bhtPreJump;

BHT bht (
    .clk(clk),
    .rst_n(rst_n),
    .isNeeded(inst_b | inst_jalr),
    .pc(pc),
    .isWrong(risk_Ctrl_delay),
    .branch_pc(branch_pc),
    .isHit(isHit_BHT),
    .isJump(isJump_BHT),
    .pre_pc(bhtPreJump)
);

/***************************************************************
                        分支预测
****************************************************************/

always @(*) begin
    if (inst_j) begin
        // J 型指令一定跳转
        imm = imm_J;
        jump = `PCSEL_JUMP;
    end
    else begin
        imm = 4;
        jump = `PCSEL_PC4;
    end
end

/***************************************************************
                        输出预测
****************************************************************/
always @(*) begin
    if (isHit_BHT & isJump_BHT) begin
        pre_pc[`WIDTH_PC - 1 : 0] = bhtPreJump[`WIDTH_PC - 1 : 0];
    end
    else begin
        pre_pc[`WIDTH_PC - 1 : 0] = pc[`WIDTH_PC - 1 : 0] + imm[`WIDTH_OPENUM - 1 : 0];
    end
end


endmodule
