module IF (
           input   wire            clk,
           input   wire            rst_n,
           input   wire [31: 0]    branch_pc,
           input   wire            PCSel,
           output  wire [31: 0]    inst,
           output  wire [31: 0]    pc,
           output  wire [31: 0]    pc4
       );

wire [31: 0] next_pc;
wire [31: 0] current_pc;

assign pc = current_pc;

NPC IF_npc(
        .branch_pc(branch_pc),
        .PCSel(PCSel),
        .current_pc(current_pc),
        .npc(next_pc),
        .pc4(pc4)
    );

PC IF_pc(
       .clk(clk),
       .rst_n(rst_n),
       .npc(next_pc),
       .pc(current_pc)
   );

InstMem IF_irom(
            .pc(current_pc[31: 0]),
            .inst(inst)
        );

endmodule
