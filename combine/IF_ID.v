`ifdef DEBUG
    `include "param.v"
`else
`include "../param.v"
`endif

module IF_ID (
           input   wire clk,
           input   wire rst_n,
           input   wire stop_IF,
           input   wire [`WIDTH_PC - 1: 0]      pc,
           input   wire [`WIDTH_INST - 1: 0]    inst,
           output  reg  [`WIDTH_PC - 1: 0]      pc_o,
           output  reg  [`WIDTH_INST - 1: 0]    inst_o
       );


/****************************************************************
                        输出
*****************************************************************/

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        pc_o[`WIDTH_PC - 1: 0]   <= `WIDTH_PC'b0;
        inst_o[`WIDTH_INST - 1: 0] <= `WIDTH_PC'b0;
    end
    else if (stop_IF) begin
        pc_o[`WIDTH_PC - 1: 0]   <= pc_o[`WIDTH_PC - 1: 0];
        inst_o[`WIDTH_INST - 1: 0] <= inst_o[`WIDTH_INST - 1: 0];
    end
    else begin
        pc_o[`WIDTH_PC - 1: 0]   <= pc[`WIDTH_PC - 1: 0];
        inst_o[`WIDTH_PC - 1: 0] <= inst[`WIDTH_PC - 1: 0];
    end
end


endmodule
