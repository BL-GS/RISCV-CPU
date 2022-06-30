`ifdef DEBUG
    `include "param.v"
`else
`include "../param.v"
`endif

module WB (
           input   wire [31: 0]    pc4,
           input   wire [31: 0]    COMPExOut,
           input   wire [31: 0]    ALUOut,
           input   wire [31: 0]    DRAMRd,
           input   wire [1: 0]     RWSel,
           output  wire [31: 0]    RegWd
       );

reg [31: 0] reg_RegWd;

assign RegWd[31: 0] = reg_RegWd[31: 0];

always @(*) begin
    case (RWSel)
        `REGWD_PC:
            reg_RegWd = pc4;
        `REGWD_COMPOUT:
            reg_RegWd = COMPExOut;
        `REGWD_ALUOUT:
            reg_RegWd = ALUOut;
        default:
            reg_RegWd = DRAMRd;
    endcase
end

endmodule
