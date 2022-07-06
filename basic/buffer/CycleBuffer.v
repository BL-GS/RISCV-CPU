`ifdef DEBUG
`include "param.v"
`else
`include "../../param.v"
`endif

module CycleBuffer
       #(parameter WIDTH = 32,
         parameter DEPTH = 3)
       (
           input wire clk,
           input wire rst_n,
           input wire [WIDTH - 1 : 0] din,
           output wire [WIDTH - 1 : 0] dout
       );
integer i;

reg [WIDTH - 1 : 0] buffer [DEPTH - 1 : 0];

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            buffer[i][WIDTH - 1 : 0] <= 0;
        end
    end
    else begin
        buffer[0][WIDTH - 1 : 0] <= din[WIDTH - 1 : 0];
        for (i = 1; i < DEPTH; i = i + 1) begin
            buffer[i][WIDTH - 1 : 0] <= buffer[i-1][WIDTH - 1 : 0]; // 数移位
        end
    end
end



endmodule
