module InputCtrl_RAM (
    input wire [31: 0] din,
    output wire [31: 0] din_RAM
);     

assign din_RAM[31: 0] = din[31: 0];

endmodule