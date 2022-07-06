/*----------------------------------------------------------------
        缓冲器
        WIDTH 为缓冲器位宽
----------------------------------------------------------------*/

module Buffer
       # (parameter WIDTH = 32)
       (
           input   wire                 clk,
           input   wire                 rst_n,
           input   wire                 we,
           input   wire [WIDTH-1: 0]    din,
           output  wire [WIDTH-1: 0]    dout
       );

reg [WIDTH-1: 0] buff;

/***************************************************************
                        输出
****************************************************************/

assign dout = buff;

/***************************************************************
                        写缓冲
****************************************************************/

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        buff[WIDTH-1: 0] <= 0;
    end
    else if (we) begin
        buff[WIDTH-1: 0] <= din[WIDTH-1: 0];
    end
end

endmodule
