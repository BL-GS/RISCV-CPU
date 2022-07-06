`ifdef DEBUG
    `include "param.v"
`else
`include "../../param.v"
`endif

module BUS (
           input       wire clk,
           input       wire rst_n,
           input       wire BC, // 总线查询
           input       wire [`IO_BUS_WIDTH_ADDR - 1: 0] addr,
           input       wire [`IO_BUS_WIDTH_CTRL - 1: 0] ctrl,
           inout       wire [`IO_BUS_WIDTH_DATA - 1: 0] data,

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
       );

integer i;

reg [`IO_INTERFACE_NUM - 1: 0]  BG;    // 总线同意

/***************************************************************
                        外设时钟
****************************************************************/

wire deviceClk;

// 50000 约等于 2ms 多一点 TODO: 需要调整时间
DeviceCLK  #(.EXTEND(2)) 
           deviceCLK (
               .clk(clk),
               .rst_n(rst_n),
               .clk_out(deviceClk)
           );

/***************************************************************
                        设备控制
****************************************************************/
reg [`IO_BUS_WIDTH_CTRL - 1: 0] ctrl_input [`IO_INTERFACE_NUM - 1 : 0];

// 控制线
always @(*) begin
    for (i = 0; i < `IO_INTERFACE_NUM; i = i + 1) begin
        ctrl_input[i][`IO_BUS_WIDTH_CTRL - 1: 0] =  ctrl;
    end
end

// 总线同意信号
always @(*) begin
    if (addr[`IO_BUS_WIDTH_ADDR - 1: 12] == 20'hFFFFF) begin // 外设
        case (addr[7: 4])
            4'h0: begin
                BG = 3'b010;
            end
            4'h1: begin
                BG = 3'b010;
            end
            4'h6: begin
                BG = 3'b100;
            end
            4'h7: begin
                BG = 3'b100;
            end
            default: begin
                BG = 3'b000;
            end
        endcase
    end
    else begin // 主存
        BG = 3'b001;
    end
end

/***************************************************************
                        设备连接
****************************************************************/

Interface_RAM interface_RAM (
                  .clk(clk),
                  .rst_n(rst_n),
                  .BG(BG[0]),
                  .addr(addr),
                  .ctrl(ctrl_input[0]),
                  .data(data)
              );

Interface_NUMLED_KEYBOARD interface_numled_keyboard (
                              .clk(clk),
                              .deviceClk(deviceClk),
                              .rst_n(rst_n),
                              .BG(BG[1]),
                              .addr(addr),
                              .ctrl(ctrl_input[1]),
                              .data(data),
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
                              .led_dp(led_dp)
                          );
                          
Interface_LED_SWITCH interface_led_switch (
                         .clk(clk),
                         .deviceClk(deviceClk),
                         .rst_n(rst_n),
                         .BG(BG[2]),
                         .addr(addr),
                         .ctrl(ctrl_input[2]),
                         .data(data),

                         .led(led),
                         .switch(switch)
                     );

endmodule
