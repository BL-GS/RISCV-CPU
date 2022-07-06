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
           input    wire [`WIDTH_ALUOUT - 1 : 0]    addOut,
           input    wire [`WIDTH_COMPOUT - 1 : 0]   COMPOut,
           input    wire [`WIDTH_PC - 1 : 0]        pc_ID,
           output   wire [`WIDTH_INST - 1: 0]       inst,
           output   wire [`WIDTH_PC - 1: 0]         pc,
           output   wire                            risk_Ctrl 
       );

wire [31: 0] next_pc;
wire [31: 0] current_pc;
wire [31: 0] branch_pc;
wire [`WIDTH_PCSEL - 1 : 0] PCSel;

assign pc = (risk_Ctrl) ? branch_pc : current_pc;

/***************************************************************
                        设备连接
****************************************************************/

NPC IF_npc(
        .clk(clk),
        .rst_n(rst_n),
        .stop_IF(stop_IF),
        .current_pc(pc),
        .inst(inst),
        .PCSel(PCSel),
        .npc(next_pc),
        .risk_Ctrl(risk_Ctrl)
    );

PC IF_pc(
       .clk(clk),
       .rst_n(rst_n),
       .risk_Ctrl(risk_Ctrl),
       .branch_pc(branch_pc),
       .npc(next_pc),
       .pc(current_pc)
   );

InstMem IF_irom(
            .pc(pc[31: 0]),
            .inst(inst)
        );

BranchCTRL branchCTRL (
               .PCCTRL(PCCTRL),
               .addOut(addOut),
               .COMPOut(COMPOut),
               .pc_ID(pc_ID),
               .branchPC(branch_pc),
               .PCSel(PCSel)
           );

endmodule
