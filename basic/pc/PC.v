`ifdef DEBUG
`include "param.v"
`else
`include "../../param.v"
`endif

module PC(
           input    wire        clk,
           input    wire        rst_n,
           input    wire[`WIDTH_PC - 1: 0] npc,
           output   reg [`WIDTH_PC - 1: 0] pc
       );

/***************************************************************
                        程序计数器变化
****************************************************************/

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        pc <= -4;
    end
    else begin
        pc <= npc;
    end
end

endmodule
