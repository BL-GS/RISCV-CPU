`include "../../param.v"


`timescale 1ns / 1ps
module cpuclk_sim();


// 时钟�?====================================================

// input
reg fpga_clk = 0;
reg fpga_rst = 0;
// output
wire clk_lock;
wire pll_clk;
wire cpu_clk;

always #5 fpga_clk = ~fpga_clk;

wire cpu_rst;

assign cpu_rst = fpga_rst;

cpuclk CLK (
           .clk_in1    (fpga_clk),
           .locked     (clk_lock),
           .clk_out1   (pll_clk)
       );

assign cpu_clk = pll_clk & clk_lock;


// 设备�?====================================================
// 输入设备—�?�拨码开�?
reg [`DEVICE_NUM_SWITCH - 1: 0]        switch;
// 输出设备—�?�LED�?
wire [`DEVICE_NUM_LED - 1: 0]           led;
// 输入设备—�?�键�?
wire [`DEVICE_NUM_KB_COL - 1: 0]        col_signal;
wire [`DEVICE_NUM_KB_ROW - 1: 0]        row_en;
// 输出设备—�?�LED数码�?
wire [`DEVICE_NUM_NUMLED_EN - 1: 0]     led_en;
wire               led_ca;
wire               led_cb;
wire               led_cc;
wire               led_cd;
wire               led_ce;
wire               led_cf;
wire               led_cg;
wire               led_dp;


//模拟过程============================================================

initial begin
    fpga_rst = 1;
    #20;
    fpga_rst = 0;
    switch = 24'b000_00000_00000000_00000000; // nop
    #5000
    switch = 24'b001_00000_00000001_00000001; // 1 + 1
    #5000;
    switch = 24'b001_00000_11111111_00000000; // -1 + 0
    #5000;
    switch = 24'b111_00000_00000010_00000011; // 2 * 3
    #5000;
    switch = 24'b001_00000_00000011_11111110; // 3 * -2

    #20000;
    $finish;
end




// 模块连接===========================================================

wire [`IO_BUS_WIDTH_DATA - 1: 0] mem_wd;
wire [`IO_BUS_WIDTH_DATA - 1: 0] mem_rd;
wire [`IO_BUS_WIDTH_ADDR - 1: 0] mem_addr;
wire [`IO_BUS_WIDTH_CTRL - 1: 0] mem_ctrl;
wire [`IO_BUS_WIDTH_DATA - 1: 0] busData;
wire mem_we;

assign mem_rd = busData;
assign busData = (mem_we) ? mem_wd : {`IO_BUS_WIDTH_DATA{1'bz}}; // 写入时才接入输入

mini_rv RV (
            .clk(cpu_clk),
            .rst_n(~cpu_rst),
            .mem_addr(mem_addr),
            .mem_ctrl(mem_ctrl),
            .mem_wd(mem_wd),
            .mem_rd(mem_rd),
            .mem_we(mem_we)
        );

BUS bus (
        .clk(cpu_clk),
        .rst_n(~cpu_rst),
        .BC(1'b1),
        .addr(mem_addr),
        .ctrl(mem_ctrl),
        .data(busData),
        // 设备线连�?
        .switch(switch),

        .led(led),

        .col_signal(col_signal),
        .row_en(row_en),

        .led_en(led_en),
        .led_ca(led_ca),
        .led_cb(led_cb),
        .led_cc(led_cc),
        .led_cd(led_cd),
        .led_ce(led_ce),
        .led_cf(led_cf),
        .led_cg(led_cg),
        .led_dp(led_dp)
    );

endmodule
