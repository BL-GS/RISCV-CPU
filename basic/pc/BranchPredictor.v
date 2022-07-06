`ifdef DEBUG
`include "param.v"
`else
`include "../../param.v"
`endif

module BranchPredictor (
           input    wire [`WIDTH_INST - 1 : 0]  inst,
           input    wire [`WIDTH_PC - 1 : 0]    pc,
           output   wire [`WIDTH_PC - 1 : 0]    pre_pc,
           output   reg                         jump
       );

wire [6: 0]     opecode;
wire            inst_j;
wire            inst_b;
wire            pc_jump_j;
wire            pc_jump_b;

reg [31: 0]     imm;
wire [31: 0]    imm_B;
wire [31: 0]    imm_J;

/***************************************************************
                        指令译码
****************************************************************/
assign opecode = inst[6: 0];
assign inst_j = (opecode[6: 2] == 5'b11011) ? 1'b1 : 1'b0;
assign inst_b = (opecode[6: 2] == 5'b11000) ? 1'b1 : 1'b0;

wire inst0                  = inst[31];
wire [5: 0]     inst1       = inst[30: 25];
wire [3: 0]     inst2       = inst[24: 21];
wire inst3                  = inst[20];
wire [7: 0]     inst4       = inst[19: 12];
wire [3: 0]     inst5       = inst[11: 8];
wire inst6                  = inst[7];
wire [11: 0]    signalEX_12 = {12{inst0}};
wire [19: 0]    signalEX_20 = {{8{inst0}}, signalEX_12[11: 0]};
assign imm_B = {signalEX_20, inst6, inst1, inst5, 1'b0};
assign imm_J = {signalEX_12, inst4, inst3, inst1, inst2, 1'b0};


/***************************************************************
                        分支预测
****************************************************************/

always @(*) begin
    if (inst_b) begin
        // B 型指令判断是否跳转
        imm = 4; // 此处预判一定不跳转
        jump = `PCSEL_PC4;
    end
    else if (inst_j) begin
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

assign pre_pc[`WIDTH_PC - 1 : 0] = pc[`WIDTH_PC - 1 : 0] + imm[`WIDTH_OPENUM - 1 : 0];


endmodule
