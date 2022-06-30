module OutputCtrl_RAM (
    input wire Unsigned,
    input wire TYPE_B,
    input wire TYPE_HB,
    input wire [1: 0] lowerAddr,
    input wire [31: 0] rd_RAM,
    output wire [31: 0] DRAMRd 
);

reg [31: 0] rd_reg;
reg [31: 0] DRAMRd_reg;

// 读写数据类型
assign DRAMRd  = DRAMRd_reg;

// 根据低位地址进行移位
always @(*) begin
    case(lowerAddr[1: 0])
        2'b00:
            rd_reg = rd_RAM;
        2'b01:
            rd_reg = {8'b0, rd_RAM[31: 8]};
        2'b10:
            rd_reg = {16'b0, rd_RAM[31: 16]};
        default:
            rd_reg = {24'b0, rd_RAM[31: 24]};
    endcase
end

// 对读取结果进行扩展
always @(*) begin
    DRAMRd_reg[7: 0] = rd_reg[7: 0];
    // 16 - 9 bits extend
    if (TYPE_B) begin
        DRAMRd_reg[15: 8] = (Unsigned) ?  {8'b0} : {8{DRAMRd_reg[7]}};
    end
    else begin
        DRAMRd_reg[15: 8] = rd_reg[15: 8];
    end
    // 32 - 17 bits extend
    if (TYPE_HB) begin
        DRAMRd_reg[31: 16] = (Unsigned) ? {16'b0} : {16{DRAMRd_reg[15]}};
    end
    else begin
        DRAMRd_reg[31: 16] = rd_reg[31: 16];
    end
end


endmodule