module OutputCtrl_RAM (
    input   wire            Unsigned,
    input   wire            TYPE_B,
    input   wire            TYPE_H,
    input   wire [1: 0]     lowerAddr,
    input   wire [31: 0]    rd_RAM,
    output  wire [31: 0]    DRAMRd 
);

reg [31: 0] rd_reg;
reg [31: 0] DRAMRd_reg;

// 读写数据类型
assign DRAMRd  = DRAMRd_reg;

/***************************************************************
                        对读出结果进行扩展
****************************************************************/

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
    if (TYPE_B) begin
        DRAMRd_reg[31: 8] = (Unsigned) ? {24'b0} : {24{DRAMRd_reg[7]}};
    end
    else if (TYPE_H) begin
        DRAMRd_reg[31: 8] = (Unsigned) ? {16'b0, rd_reg[15: 8]} : {{16{DRAMRd_reg[15]}}, rd_reg[15: 8]};
    end
    else begin
        DRAMRd_reg[31: 8] = rd_reg[31: 8];
    end
end


endmodule