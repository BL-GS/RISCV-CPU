module DataMem (
           input    wire        clk,
           input    wire        we,
           input    wire[31: 0] adr,
           input    wire[31: 0] din,
           output   wire[31: 0] rd
       );

data_mem RAM (
             .clk     (clk),
             .we      (we),
`ifdef DEBUG
             .a(adr[17: 2]),
`else
             .a(adr[15: 2]),
`endif
             .d       (din),
             .spo     (rd)
         );

endmodule
