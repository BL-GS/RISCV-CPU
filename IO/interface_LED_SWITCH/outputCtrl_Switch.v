`ifdef DEBUG
    `include "param.v"
`else
`include "../../param.v"
`endif

module OutputCtrl_Switch (
           input    wire [`DEVICE_NUM_SWITCH - 1: 0]     switch,
           output   wire [`IO_BUS_WIDTH_DATA - 1: 0]     data
       );

assign data[`DEVICE_NUM_SWITCH - 1: 0] = switch[`DEVICE_NUM_SWITCH - 1: 0];
assign data[`IO_BUS_WIDTH_DATA - 1: `DEVICE_NUM_SWITCH] = 0;

endmodule
