`ifdef DEBUG
    `include "param.v"
`else
`include "../../param.v"
`endif

module InputCtrl_NUMLED (
           input wire            clk,
           input wire            rst_n,
           input wire  [`IO_BUS_WIDTH_DATA - 1: 0] num_in,
           output wire [`DEVICE_NUM_NUMLED_EN - 1 : 0]  led_en,
           output wire          led_ca,
           output wire          led_cb,
           output wire          led_cc,
           output wire          led_cd,
           output wire          led_ce,
           output wire          led_cf,
           output wire          led_cg,
           output wire          led_dp
       );


// 显示的数字
reg [3 : 0] num;
// 状态: 高八位作为数码管使能信号
reg [`DEVICE_NUM_NUMLED_EN - 1 : 0] statu;

assign    led_en[`DEVICE_NUM_NUMLED_EN - 1 : 0] = statu[`DEVICE_NUM_NUMLED_EN - 1: 0];
/***************************************************************
                        显示逻辑
****************************************************************/

reg [6: 0] led;
assign {led_ca, led_cb, led_cc, led_cd, led_ce, led_cf, led_cg} = led[6: 0];

assign    led_dp = 1'b1;

always @(*) begin
    case (num)
        4'd0: begin
            led[6: 0] = 7'b0000001;
        end
        4'd1: begin
            led[6: 0] = 7'b1001111;
        end
        4'd2: begin
            led[6: 0] = 7'b0010010;
        end
        4'd3: begin
            led[6: 0] = 7'b0000110;
        end
        4'd4: begin
            led[6: 0] = 7'b1001100;
        end
        4'd5: begin
            led[6: 0] = 7'b0100100;
        end
        4'd6: begin
            led[6: 0] = 7'b0100000;
        end
        4'd7: begin
            led[6: 0] = 7'b0001111;
        end
        4'd8: begin
            led[6: 0] = 7'b0000000;
        end
        4'd9: begin
            led[6: 0] = 7'b0000100;
        end
        4'd10: begin
            led[6: 0] = 7'b0001000;
        end
        4'd11: begin
            led[6: 0] = 7'b1100000;
        end
        4'd12: begin
            led[6: 0] = 7'b0110001;
        end
        4'd13: begin
            led[6: 0] = 7'b1000010;
        end
        4'd14: begin
            led[6: 0] = 7'b0010000;
        end
        default: begin
            led[6: 0] = 7'b0111000;
        end
    endcase
end

/***************************************************************
                        数字逻辑
****************************************************************/

always @(*) begin
    case ( led_en )
        8'b11111110:
            num = num_in[3 : 0];
        8'b11111101:
            num = num_in[7 : 4];
        8'b11111011:
            num = num_in[11 : 8];
        8'b11110111:
            num = num_in[15 : 12];
        8'b11101111:
            num = num_in[19 : 16];
        8'b11011111:
            num = num_in[23 : 20];
        8'b10111111:
            num = num_in[27 : 24];
        8'b01111111:
            num = num_in[31 : 28];
        default:
            num = 4'd0;
    endcase
end

/***************************************************************
                        状态逻辑
****************************************************************/

always @( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        statu[7: 0] <= 8'b11111111;
    end
    else if (statu[7: 0] == 8'b11111111) begin
        statu[7 : 0] <= 8'b11111110;
    end
    else begin
        statu[7 : 0] <= {statu[6: 0], statu[7]};
    end
end


endmodule
