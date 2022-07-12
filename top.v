`include "param.v"

module top(
           input wire clk,

`ifdef DEBUG
           input wire rst_n,
           output        wire debug_wb_have_inst,   // WB阶段是否有指令 (对单周期CPU，此flag恒为1)
           output wire [31:0]  debug_wb_pc,          // WB阶段的PC (若wb_have_inst=0，此项可为任意值)
           output         debug_wb_ena,         // WB阶段的寄存器写使能 (若wb_have_inst=0，此项可为任意值)
           output wire [4:0]   debug_wb_reg,         // WB阶段写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
           output wire [31:0]  debug_wb_value        // WB阶段写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)
`else
           input wire rst,
           // 设备线====================================================
           // 输入设备——拨码开关
           input    wire [`DEVICE_NUM_SWITCH - 1: 0]        switch,
           // 输出设备——LED灯
           output   wire [`DEVICE_NUM_LED - 1: 0]           led,
           // 输入设备——键盘
           /*
           input    wire [`DEVICE_NUM_KB_COL - 1: 0]        col_signal,
           output   wire [`DEVICE_NUM_KB_ROW - 1: 0]        row_en,
           */
           // 输出设备——LED数码管
           output   wire [`DEVICE_NUM_NUMLED_EN - 1: 0]     led_en,
           output   wire               led_ca,
           output   wire               led_cb,
           output   wire               led_cc,
           output   wire               led_cd,
           output   wire               led_ce,
           output   wire               led_cf,
           output   wire               led_cg,
           output   wire               led_dp
`endif
       );

/***************************************************************
                        时钟信号
****************************************************************/

wire clk_out;

`ifdef DEBUG
assign clk_out = clk;
`else
cpuclk cpuClk (
        .clk_in1(clk),
        .locked(locked),
        .clk_out1(clk_out)
);
`endif

/***************************************************************
                        复位信号
****************************************************************/

`ifndef DEBUG
        wire rst_n = ~rst;
`endif

/***************************************************************
                        设备连接
****************************************************************/

wire [`IO_BUS_WIDTH_DATA - 1: 0]    mem_wd;
wire [`IO_BUS_WIDTH_DATA - 1: 0]    mem_rd;
wire [`IO_BUS_WIDTH_ADDR - 1: 0]    mem_addr;
wire [`IO_BUS_WIDTH_CTRL - 1: 0]    mem_ctrl;
wire                                mem_we;
wire [`IO_BUS_WIDTH_DATA - 1: 0]    busData;

assign mem_rd  = busData;
assign busData = (mem_we) ? mem_wd : 32'hzzzzzzzz; // 写入时才接入输入

mini_rv mini_rv_u (
            .clk(clk_out),
            .rst_n(rst_n),

`ifdef DEBUG
            .wb_have_inst(debug_wb_have_inst),
            .wb_pc(debug_wb_pc),
            .wb_ena(debug_wb_ena),
            .wb_reg(debug_wb_reg),
            .wb_value(debug_wb_value),
`endif
            .mem_addr(mem_addr),
            .mem_ctrl(mem_ctrl),
            .mem_wd(mem_wd),
            .mem_rd(mem_rd),
            .mem_we(mem_we)
        );

BUS bus (
        .clk(clk_out),
        .rst_n(rst_n),

`ifndef DEBUG
        // 设备线连接
        .switch(switch),

        .led(led),
        /*
        .col_signal(col_signal),
        .row_en(row_en),
        */

        .led_en(led_en),
        .led_ca(led_ca),
        .led_cb(led_cb),
        .led_cc(led_cc),
        .led_cd(led_cd),
        .led_ce(led_ce),
        .led_cf(led_cf),
        .led_cg(led_cg),
        .led_dp(led_dp),
`endif

        .addr(mem_addr),
        .ctrl(mem_ctrl),
        .data(busData)
    );

endmodule
