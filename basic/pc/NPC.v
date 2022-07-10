`ifdef DEBUG
    `include "param.v"
`else
`include "../../param.v"
`endif

module NPC(
           input   wire clk,
           input   wire rst_n,
           input   wire stop_IF,
           input   wire[`WIDTH_PC - 1: 0]       current_pc,
           input   wire[`WIDTH_PC - 1: 0]       branch_pc,
           input   wire[`WIDTH_INST - 1: 0]     inst,
           input   wire                         PCSel,
           output  wire[`WIDTH_PC - 1: 0]       npc,
           output  wire                         risk_Ctrl
       );

wire [`WIDTH_PC - 1 : 0] pre_pc;

reg [1: 0] is_jump;

/***************************************************************
                        分支预测
****************************************************************/
wire pre_jump;

BranchPredictor branchPredictor (
                    .inst(inst),
                    .pc((risk_Ctrl) ? branch_pc : current_pc),
                    .pre_pc(pre_pc),
                    .jump(pre_jump)
                );

/***************************************************************
                        程序计数器流向记录
****************************************************************/

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        is_jump[1: 0] <= 0;
    end
    else if (risk_Ctrl) begin // 预测错误，清空记录
        is_jump[1: 0] <= {`PCSEL_PC4, `PCSEL_PC4};
    end
    else begin // 预测正确，更新记录
        is_jump[1: 0] <= (stop_IF) ? is_jump[1: 0] : {pre_jump, is_jump[1]};
    end
end

/***************************************************************
                        程序计数器流向选择
****************************************************************/
// 预测是否正确
assign risk_Ctrl = (PCSel == is_jump[0]) ? 1'b0 : 1'b1;
// 是否需要保持PC
assign npc = (stop_IF) ? current_pc : pre_pc;


endmodule
