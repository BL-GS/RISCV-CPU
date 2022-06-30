module InputCtrl_RAM (
    input wire TYPE_B,
    input wire TYPE_HB,
    input wire [1: 0] lowerAddr,
    input wire [31: 0] rd_RAM,
    input wire [31: 0] din,
    output wire [31: 0] din_RAM
);     

reg [31: 0] din_reg;

assign din_RAM[31: 0] = din_reg[31: 0];

// 根据低位地址对写入结果进行移位
always @(*) begin
    din_reg = rd_RAM;
    case (lowerAddr[1: 0])
        2'b00: begin
            din_reg[7: 0]   = din[7: 0];
            din_reg[15: 8]  = (TYPE_B) ? rd_RAM [15: 8] : din[15: 8];
            din_reg[31: 16] = (TYPE_HB) ? rd_RAM [31: 16] : din[31: 16];
        end
        2'b01: begin
            din_reg[7: 0]   = rd_RAM[7: 0];
            din_reg[15: 8]  = din[7: 0];
            din_reg[23: 16] = (TYPE_B) ? rd_RAM [23: 16] : din[15: 8];
            din_reg[31: 24] = (TYPE_HB) ? rd_RAM [31: 24] : din[23: 16];
        end
        2'b10: begin
            din_reg[15: 0]  = rd_RAM[15: 0];
            din_reg[23: 16] = din[7: 0];
            din_reg[31: 24] = (TYPE_B) ? rd_RAM [31: 24] : din[15: 8];
        end
        default: begin
            din_reg[23: 0]  = rd_RAM[23: 0];
            din_reg[31: 24] = din[7: 0];
        end
    endcase
end

endmodule