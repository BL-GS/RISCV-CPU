`ifdef DEBUG
    `include "param.v"
`else
`include "../../param.v"
`endif

module Interface_LED_SWITCH (
           input    wire            clk,
           input    wire            deviceClk,
           input    wire            rst_n,
           input    wire            BG, // 总线同意信号
           input    wire [`IO_BUS_WIDTH_ADDR - 1: 0]    addr,
           input    wire [`IO_BUS_WIDTH_CTRL - 1: 0]    ctrl,
           inout    wire [`IO_BUS_WIDTH_DATA - 1: 0]    data, // 与总线连接

           // 输入设备——拨码开关
           input    wire [`DEVICE_NUM_SWITCH - 1: 0]    switch,
           // 输出设备——LED灯
           output   wire [`DEVICE_NUM_LED - 1: 0]       led
       );

wire clk_input;
wire clk_output;

// 输入线
wire [`IO_BUS_WIDTH_DATA - 1: 0] data_input; // 数据 -> 缓冲
wire [`IO_BUS_WIDTH_DATA - 1: 0] input_data; // 缓冲 -> 数据
// 输出线
wire [`IO_BUS_WIDTH_DATA - 1: 0] data_output; // 数据 -> 缓冲
wire [`IO_BUS_WIDTH_DATA - 1: 0] output_data; // 缓冲 -> 数据


// 访问信号类型
wire ctrl_call;     // 访问控制信号
wire data_call;     // 访问输入输出
wire status_call;   // 访问状态

// 输入输出控制
wire input_call;    // 输入
wire output_call;   // 输出


/***************************************************************
                        控制逻辑
****************************************************************/

// 读写控制
assign input_call  = ((BG == 1'b1) && (ctrl[`IO_BUS_CTRL_WE] == `IO_CTRL_WRITE)) ? 1'b1 : 1'b0;
assign output_call = ((BG == 1'b1) && (ctrl[`IO_BUS_CTRL_WE] == `IO_CTRL_READ)) ? 1'b1 : 1'b0;

/***************************************************************
                        地址译码
****************************************************************/
wire [`IO_CALL_WIDTH - 1: 0] addrOut = addr[`IO_CALL_HIGHERADDR: `IO_CALL_LOWERADDR];

// 地址偏移译码
assign ctrl_call   = (addrOut == `IO_CALL_CTRL) ? 1'b1 : 1'b0;
assign data_call   = (addrOut == `IO_CALL_INOUT) ? 1'b1 : 1'b0;

/***************************************************************
                        数据交叉开关
****************************************************************/
// 地址译码和控制逻辑内部耦合，无需数据交叉开关控制
// data输出控制
assign data =  (output_call) ? data_output :            // 总线同意，数据输出
       `IO_BUS_WIDTH_DATA'dz;                   // 未定义状况
// data输入控制
assign data_input = data;

/***************************************************************
                        输入到 外设
****************************************************************/
assign clk_input = clk; // 时钟上升沿读取输入

// 输入缓冲
Buffer #(.WIDTH(32))
       input_buf (
           .clk(clk_input),
           .rst_n(rst_n),
           .din(data_input),
           .we(input_call),
           .dout(input_data)
       );
// TODO: 外设连接
InputCtrl_LED ledCtrl (
                  .light(1'b1), // TODO: 有待商榷
                  .num_in(input_data),
                  .led(led)
              );

/***************************************************************
                        输出到 CPU
****************************************************************/
assign clk_output = clk;

Buffer  #(.WIDTH(32))
        output_buf (
            .clk(clk_output),
            .rst_n(rst_n),
            .we(1'b1),
            .din(output_data),
            .dout(data_output)
        );
// TODO: 外设连接
OutputCtrl_Switch switchCtrl (
                      .switch(switch),
                      .data(output_data)
                  );

endmodule
