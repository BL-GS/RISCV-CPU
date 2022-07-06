`ifdef DEBUG
    `include "param.v"
`else
`include "../../param.v"
`endif

module COMP (
           input   wire [31: 0]    A,
           input   wire [31: 0]    B,
           input   wire            Unsigned,
           output  wire [1: 0]     out
       );

wire [31: 0] Ain;
wire [31: 0] Bin;
wire equal;
wire less;

reg [1: 0] out_reg;

/***************************************************************
                        运算
****************************************************************/

// 有符号数转换为移码
assign Ain[30: 0] = A[30: 0];
assign Ain[31]    = (Unsigned == `UNSIGNED) ? A[31] : ~A[31];
assign Bin[30: 0] = B[30: 0];
assign Bin[31]    = (Unsigned == `UNSIGNED) ? B[31] : ~B[31];

// 比较运算
assign equal = ($unsigned(Ain) == $unsigned(Bin)) ? 1'b1 : 1'b0;
assign less  = ($unsigned(Ain) < $unsigned(Bin)) ? 1'b1 : 1'b0;


/***************************************************************
                        输出选择
****************************************************************/

assign out = out_reg;

always @(*) begin
    if (equal) begin
        out_reg = `COMP_EQ;
    end
    else if (less) begin
        out_reg = `COMP_LE;
    end
    else begin
        out_reg = `COMP_GE;
    end
end

endmodule
