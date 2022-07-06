`ifdef DEBUG
    `include "param.v"
`else
`include "../param.v"
`endif

module MEM_WB (
           input wire clk,
           input wire rst_n,
           input wire [`WIDTH_PC - 1: 0]           pc4,
           input wire [`WIDTH_RWSel - 1: 0]        RWSel,
           input wire [`WIDTH_REGMARK - 1: 0]      RegWr,
           input wire [`WIDTH_RegWE - 1: 0]        RegWe,
           input wire [`WIDTH_COMPOUT - 1: 0]      COMPOut,
           input wire [`WIDTH_ALUOUT - 1: 0]       ALUOut,
           input wire [`WIDTH_OPENUM - 1: 0]       DRAMRd,

           output reg [`WIDTH_PC - 1: 0]           pc4_o,
           output reg [`WIDTH_RWSel - 1: 0]        RWSel_o,
           output reg [`WIDTH_REGMARK - 1: 0]      RegWr_o,
           output reg [`WIDTH_RegWE - 1: 0]        RegWe_o,
           output reg [`WIDTH_COMPOUT - 1: 0]      COMPOut_o,
           output reg [`WIDTH_ALUOUT - 1: 0]       ALUOut_o,
           output reg [`WIDTH_OPENUM - 1: 0]       DRAMRd_o
       );


/****************************************************************
                        输出
*****************************************************************/
always @(posedge clk or negedge rst_n) begin

    if (~rst_n) begin
        pc4_o         [`WIDTH_PC - 1: 0]              <= 0;
        DRAMRd_o      [`WIDTH_OPENUM - 1: 0]          <= 0;
        RWSel_o       [`WIDTH_RWSel - 1: 0]           <= 0;
        RegWr_o       [`WIDTH_REGMARK - 1: 0]         <= 0;
        RegWe_o       [`WIDTH_RegWE - 1: 0]           <= 0;
        COMPOut_o     [`WIDTH_COMPOUT - 1: 0]         <= 0;
        ALUOut_o      [`WIDTH_ALUOUT - 1: 0]          <= 0;
    end
    else begin
        pc4_o         [`WIDTH_PC - 1: 0]              <= pc4;
        DRAMRd_o      [`WIDTH_OPENUM - 1: 0]          <= DRAMRd;
        RWSel_o       [`WIDTH_RWSel - 1: 0]           <= RWSel;
        RegWr_o       [`WIDTH_REGMARK - 1: 0]         <= RegWr;
        RegWe_o       [`WIDTH_RegWE - 1: 0]           <= RegWe;
        COMPOut_o     [`WIDTH_COMPOUT - 1: 0]         <= COMPOut;
        ALUOut_o      [`WIDTH_ALUOUT - 1: 0]          <= ALUOut;
    end

end

endmodule
