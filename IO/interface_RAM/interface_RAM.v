`ifdef DEBUG
    `include "param.v"
`else
`include "../../param.v"
`endif

/*----------------------------------------------------------------
                主存接口
                连接方式：直接相连，无缓冲
                状态输出：无
-----------------------------------------------------------------*/

module Interface_RAM (
           input    wire            clk,
           input    wire            rst_n,
           input    wire            BG,
           input    wire [`IO_BUS_WIDTH_ADDR - 1: 0]    addr,
           input    wire [`IO_BUS_WIDTH_CTRL - 1: 0]    ctrl,
           inout    wire [`IO_BUS_WIDTH_DATA - 1: 0]    data // 与总线连接
       );

wire clk_input;
wire clk_output;

// 输入线
wire [`IO_BUS_WIDTH_DATA - 1: 0] data_input; // 数据 -> 缓冲
wire [`IO_BUS_WIDTH_DATA - 1: 0] input_data; // 缓冲 -> 数据
// 输出线
wire [`IO_BUS_WIDTH_DATA - 1: 0] data_output; // 数据 -> 缓冲
wire [`IO_BUS_WIDTH_DATA - 1: 0] output_data; // 缓冲 -> 数据



/***************************************************************
                        控制逻辑
****************************************************************/

// 输入输出控制
wire input_call;    // 输入
wire output_call;   // 输出

// 读写控制
assign input_call  = ((BG == 1'b1) && (ctrl[`IO_BUS_CTRL_WE] == `IO_CTRL_WRITE)) ? 1'b1 : 1'b0;
assign output_call = ((BG == 1'b1) && (ctrl[`IO_BUS_CTRL_WE] == `IO_CTRL_READ)) ? 1'b1 : 1'b0;

wire TYPE_B; // byte 类需要的扩展
wire TYPE_HB; // byte 和 half-word 类需要的扩展
wire Unsigned; // 符号扩展控制

assign TYPE_B    = ~(ctrl[`IO_BUS_CTRL_TYPE_B] | ctrl[`IO_BUS_CTRL_TYPE_HB]);
assign TYPE_HB   = (~ctrl[`IO_BUS_CTRL_TYPE_HB]) | TYPE_B;
assign Unsigned  = ctrl[`IO_BUS_CTRL_UNSIGNED];

/***************************************************************
                        数据交叉开关
****************************************************************/
// 地址译码和控制逻辑内部耦合，无需数据交叉开关控制
// data输出控制
assign data = (output_call) ? output_data :  // 总线同意，数据输出
       `IO_BUS_WIDTH_DATA'dz;                // 未定义状况
// data输入控制
assign data_input = data;

/***************************************************************
                        输入输出无缓冲
****************************************************************/

assign clk_input = clk; // 时钟上升沿读取

InputCtrl_RAM inputCtrl (
                  .TYPE_B(TYPE_B),
                  .TYPE_HB(TYPE_HB),
                  .lowerAddr(addr[1: 0]),
                  .rd_RAM(data_output),
                  .din(data_input),
                  .din_RAM(input_data)
              );

assign clk_output = clk; // 时钟上升沿写入

OutputCtrl_RAM outputCtrl (
                   .Unsigned(Unsigned),
                   .TYPE_B(TYPE_B),
                   .TYPE_HB(TYPE_HB),
                   .lowerAddr(addr[1: 0]),
                   .rd_RAM(data_output),
                   .DRAMRd(output_data)
               );


// 连接主存
DataMem dRAM (
            .clk(clk),
            .we(input_call),
            .adr(addr[`IO_BUS_WIDTH_ADDR - 1 :0]),
            .din(input_data),
            .rd(data_output)
        );

endmodule
