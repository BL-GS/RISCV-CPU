`ifdef DEBUG
    `include "param.v"
`else
`include "../param.v"
`endif

module EX (
           input   wire [31: 0]    Ain,
           input   wire [31: 0]    Bin,
           input   wire [31: 0]    COMPAin,
           input   wire [31: 0]    COMPBin,
           input   wire [2: 0]     ALUop,
           input   wire            Unsigned,
           output  wire [1: 0]     COMPOut,
           output  wire [31: 0]    ALUOut
       );

/***************************************************************
                        设备连接
****************************************************************/

ALU alu (
        .A(Ain),
        .B(Bin),
        .ALUop(ALUop),
        .Unsigned(Unsigned),
        .out(ALUOut)
    );

COMP comp (
         .A(COMPAin),
         .B(COMPBin),
         .Unsigned(Unsigned),
         .out(COMPOut)
     );

endmodule
