`ifdef DEBUG
    `include "param.v"
`else
`include "../param.v"
`endif

module ID_IF (
    input wire clk,
    input wire rst_n,
    input wire [`WIDTH_PC - 1: 0] branch_pc,
    output reg [`WIDTH_PC - 1: 0] branch_pc_o
);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        branch_pc_o[`WIDTH_PC - 1: 0] <= 0;
    end
    else begin
        branch_pc_o[`WIDTH_PC - 1: 0] <= branch_pc[`WIDTH_PC - 1: 0];
    end
end


endmodule