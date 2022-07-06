module InstMem(
           input   wire[31: 0] pc,
           output  wire[31: 0] inst
       );

/***************************************************************
                        设备连接
****************************************************************/

inst_mem irom(
`ifdef DEBUG
             .a(pc[17: 2]),
`else
             .a(pc[15: 2]),
`endif
             .spo(inst)
         );

endmodule
