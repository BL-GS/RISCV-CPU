`ifdef DEBUG
    `include "param.v"
`else
`include "../../param.v"
`endif

module OutputCtrl_Keyboard (
           input    wire            clk,
           input    wire            rst_n,
           input    wire [`DEVICE_NUM_KB_COL - 1: 0]     col_signal,
           output   wire [`DEVICE_NUM_KB_ROW - 1: 0]     row_en,
           output   wire [`IO_BUS_WIDTH_DATA - 1: 0]     data
       );

reg [`DEVICE_NUM_KB_ROW - 1: 0]  row_en_reg;

assign row_en[`DEVICE_NUM_KB_ROW - 1: 0] = row_en_reg[`DEVICE_NUM_KB_ROW - 1: 0];
// 输出数据 TODO:
assign data[`DEVICE_NUM_KB_COL - 1: 0] = col_signal[`DEVICE_NUM_KB_COL - 1: 0];

// 扫描键盘
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        row_en_reg[`DEVICE_NUM_KB_ROW - 1: 0] <= {`DEVICE_NUM_KB_ROW{1'b1}};
    end
    else begin
        if (row_en_reg == `DEVICE_NUM_KB_ROW'b1) begin
            row_en_reg[`DEVICE_NUM_KB_ROW - 1: 0] <= {`DEVICE_NUM_KB_ROW{1'b1}};
        end
        else begin
            row_en_reg[`DEVICE_NUM_KB_ROW - 1: 0] <= {row_en_reg[`DEVICE_NUM_KB_ROW - 2: 0], row_en_reg[`DEVICE_NUM_KB_ROW - 1]};
        end
    end
end

endmodule
