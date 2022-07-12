module OutputCtrl_RAM (
    input   wire [31: 0]    rd_RAM,
    output  wire [31: 0]    DRAMRd 
);

assign DRAMRd[31: 0] = rd_RAM[31: 0];

endmodule