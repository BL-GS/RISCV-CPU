module DeviceCLK
       # (parameter EXTEND = 50000)
       (
           input wire clk,
           input wire rst_n,
           output wire clk_out
       );

reg [$clog2(EXTEND) : 0] cnt;

assign clk_out = ( cnt == EXTEND );         // 2ms

always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        cnt <= 0;
    end
    else if ( clk_out ) begin
        cnt <= 0;
    end
    else begin
        cnt <= cnt + 1;
    end
end

endmodule
