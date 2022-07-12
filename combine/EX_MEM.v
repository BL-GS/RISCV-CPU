`ifdef DEBUG
    `include "param.v"
`else
`include "../param.v"
`endif

module EX_MEM (
           input wire clk,
           input wire rst_n,
           input wire [`WIDTH_PC - 1: 0]           pc,
           input wire [`WIDTH_DRAM_EX_TYPE - 1: 0] DRAM_EX_TYPE,
           input wire [`WIDTH_DRAMWE - 1: 0]       DRAMWE,
           input wire [`WIDTH_RWSel - 1: 0]        RWSel,
           input wire [`WIDTH_REGMARK - 1: 0]       RegWr,
           input wire [`WIDTH_RegWE - 1: 0]         RegWe,
           input wire [`WIDTH_COMPOUT - 1: 0]      COMPOut,
           input wire [`WIDTH_ALUOUT - 1: 0]       ALUOut,
           input wire [`WIDTH_DRAMIN - 1: 0]       DRAMIn,
           input wire [`WIDTH_Unsigned - 1: 0]     Unsigned,

           output reg [`WIDTH_PC - 1: 0]              pc_o,
           output reg [`WIDTH_DRAM_EX_TYPE - 1: 0]    DRAM_EX_TYPE_o,
           output reg [`WIDTH_DRAMWE - 1: 0]          DRAMWE_o,
           output reg [`WIDTH_RWSel - 1: 0]           RWSel_o,
           output reg [`WIDTH_REGMARK - 1: 0]         RegWr_o,
           output reg [`WIDTH_RegWE - 1: 0]           RegWe_o,
           output reg [`WIDTH_COMPOUT - 1: 0]         COMPOut_o,
           (*EQUIVALENT_REGISTER_REMOVAL="NO"*) output reg [`WIDTH_ALUOUT - 1: 0]          ALUOut_o,
           (*EQUIVALENT_REGISTER_REMOVAL="NO"*) output reg [`WIDTH_ALUOUT - 1: 0]          ALUOut_mem_o,
           output reg [`WIDTH_DRAMIN - 1: 0]          DRAMIn_o,
           output reg [`WIDTH_Unsigned - 1: 0]        Unsigned_o
       );


/****************************************************************
                        输出
*****************************************************************/
always @(posedge clk or negedge rst_n) begin

    if (~rst_n) begin
        pc_o          [`WIDTH_PC - 1: 0]              <= 0;
        DRAMWE_o      [`WIDTH_DRAMWE - 1: 0]          <= 0;
        RegWe_o       [`WIDTH_RegWE - 1: 0]           <= 0;
    end
    else begin
        pc_o          [`WIDTH_PC - 1: 0]              <= pc;
        DRAM_EX_TYPE_o[`WIDTH_DRAM_EX_TYPE - 1: 0]    <= DRAM_EX_TYPE;
        DRAMWE_o      [`WIDTH_DRAMWE - 1: 0]          <= DRAMWE;
        RWSel_o       [`WIDTH_RWSel - 1: 0]           <= RWSel;
        RegWr_o       [`WIDTH_REGMARK - 1: 0]         <= RegWr;
        RegWe_o       [`WIDTH_RegWE - 1: 0]           <= RegWe;
        COMPOut_o     [`WIDTH_COMPOUT - 1: 0]         <= COMPOut;
        ALUOut_o      [`WIDTH_ALUOUT - 1: 0]          <= ALUOut;
        ALUOut_mem_o  [`WIDTH_ALUOUT - 1: 0]          <= ALUOut;
        DRAMIn_o      [`WIDTH_DRAMIN - 1: 0]          <= DRAMIn;
        Unsigned_o    [`WIDTH_Unsigned - 1: 0]        <= Unsigned;
    end

end



endmodule
