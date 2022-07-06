module NPC(
           input   wire[31: 0]    current_pc,
           input   wire[31: 0]    branch_pc,
           input   wire           PCSel,
           output  wire[31: 0]    npc,
           output  wire[31: 0]    pc4
       );

assign pc4 = current_pc + 4;

/***************************************************************
                        程序计数器流向选择
****************************************************************/

assign npc = (PCSel) ? branch_pc : pc4;

endmodule
