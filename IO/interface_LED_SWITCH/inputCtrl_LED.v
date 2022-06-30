`ifdef DEBUG
    `include "param.v"
`else
`include "../../param.v"
`endif

module InputCtrl_LED (
           input wire           light,
           input wire  [`IO_BUS_WIDTH_DATA - 1: 0]  num_in,
           output wire [`DEVICE_NUM_LED - 1: 0]     led
       );

assign  led[`DEVICE_NUM_LED - 1: 0] = (light) ?
        num_in[`DEVICE_NUM_LED - 1: 0] : `DEVICE_NUM_LED'b0;

endmodule
