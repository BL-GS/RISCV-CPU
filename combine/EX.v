`ifdef DEBUG
    `include "param.v"
`else
`include "../param.v"
`endif

module EX (
           input   wire [31: 0]    rd1,
           input   wire [31: 0]    rd2,
           input   wire [31: 0]    imm,
           input   wire [31: 0]    pc,
           input   wire            ASel,
           input   wire            BSel,
           input   wire [2: 0]     ALUop,
           input   wire            Unsigned,
           output  wire [1: 0]     COMPOut,
           output  wire [31: 0]    COMPExOut,
           output  wire [31: 0]    ALUOut
       );

wire [31: 0] Ain;
wire [31: 0] Bin;
wire [31: 0] COMPAin;
wire [31: 0] COMPBin;

assign Ain     = (ASel == `ASEL_PC) ? pc : rd1;
assign COMPAin = (ASel == `ASEL_PC) ? rd1 : pc;
assign Bin     = (BSel == `BSEL_IMM) ? imm : rd2;
assign COMPBin = (BSel == `BSEL_IMM) ? rd2 : imm;

// 对比较结果进行符号扩展
assign COMPExOut[31: 0] = {31'b0, COMPOut[0]};

// (* DONT_TOUCH = "true" *) // 此处可以取消优化来康康实现
ALU alu (
        .A(Ain),
        .B(Bin),
        .ALUop(ALUop),
        .Unsigned(Unsigned),
        .out(ALUOut)
    );

// (* DONT_TOUCH = "true" *) // 此处可以取消优化来康康实现
COMP comp (
         .A(COMPAin),
         .B(COMPBin),
         .Unsigned(Unsigned),
         .out(COMPOut)
     );

endmodule
