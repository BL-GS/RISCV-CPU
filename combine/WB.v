`ifdef DEBUG
    `include "param.v"
`else
`include "../param.v"
`endif

module WB (
           input   wire [`WIDTH_PC - 1: 0]    pc4,
           input   wire [`WIDTH_ALUOUT - 1: 0]    COMPExOut,
           input   wire [`WIDTH_ALUOUT - 1: 0]    ALUOut,
           input   wire [`WIDTH_DRAMRd - 1: 0]    DRAMRd,
           input   wire [`WIDTH_RWSel - 1: 0]     RWSel,
           output  wire [`WIDTH_RegWd - 1: 0]     RegWd
       );

reg [31: 0] reg_RegWd;

assign RegWd[31: 0] = reg_RegWd[31: 0];

/***************************************************************
                        写回寄存器数据多路选择
****************************************************************/

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
