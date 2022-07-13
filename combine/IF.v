`ifdef DEBUG
    `include "param.v"
`else
`include "../param.v"
`endif

module IF (
           input    wire                            clk,
           input    wire                            rst_n,
           input    wire                            stop_IF,
           input    wire [`WIDTH_PCCTRL - 1 : 0]    PCCTRL,
           input    wire [`WIDTH_ALUOUT - 1 : 0]    branch_pc,
           input    wire [`WIDTH_COMPOUT - 1 : 0]   COMPOut,
           input    wire [`WIDTH_INST - 1: 0]       inst_ID,
           output   wire [`WIDTH_INST - 1: 0]       inst,
           output   wire [`WIDTH_PC - 1: 0]         pc,
           output   wire                            risk_Ctrl
       );

wire [`WIDTH_INST - 1: 0]   inst_irom;
wire [`WIDTH_PC - 1: 0]     next_pc;
wire [`WIDTH_PC - 1: 0]     current_pc;
wire [`WIDTH_PCSEL - 1 : 0] PCSel;

reg risk_Ctrl_delay;

// 当有冒险时，停顿两个时钟周期
assign pc[`WIDTH_PC - 1: 0] = (risk_Ctrl_delay) ? branch_pc :
       (risk_Ctrl) ? 0 : current_pc;

assign inst[`WIDTH_INST - 1 : 0] = (risk_Ctrl) ? 0 : inst_irom;

/***************************************************************
                        冒险信号延迟
****************************************************************/

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        risk_Ctrl_delay <= 0;
    end
    else begin
        risk_Ctrl_delay <= risk_Ctrl;
    end
end

/***************************************************************
                        设备连接
****************************************************************/

NPC IF_npc(
        .clk(clk),
        .rst_n(rst_n),
        .stop_IF(stop_IF),
        .current_pc(pc),
        .branch_pc(branch_pc),
        .inst(inst_ID),
        .PCSel(PCSel),
        .risk_Ctrl_delay(risk_Ctrl_delay),
        .npc(next_pc),
        .risk_Ctrl(risk_Ctrl)
    );

PC IF_pc(
       .clk(clk),
       .rst_n(rst_n),
       .npc(next_pc),
       .pc(current_pc)
   );

InstMem IF_irom(
            .pc(pc),
            .inst(inst_irom)
        );

BranchCTRL branchCTRL (
               .PCCTRL(PCCTRL),
               .COMPOut(COMPOut),
               .PCSel(PCSel)
           );

endmodule
