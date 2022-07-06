`ifdef DEBUG
    `include "param.v"
`else
`include "../../param.v"
`endif

module RegFile(
           input   wire          clk,
           input   wire          rst_n,
           input   wire          we,
           input   wire[4: 0]    rs1,
           input   wire[4: 0]    rs2,
           input   wire[4: 0]    wr,
           input   wire[31: 0]   wd,
           output  wire[31: 0]   rd1,
           output  wire[31: 0]   rd2
       );

reg[31: 0] rf[31: 1]; // 寄存器

/***************************************************************
                        读寄存器
****************************************************************/

assign    rd1 = (rs1 == 0) ? 0 : rf[$unsigned(rs1)];
assign    rd2 = (rs2 == 0) ? 0 : rf[$unsigned(rs2)];

/***************************************************************
                        写寄存器(时钟上升沿)
****************************************************************/

// 时钟下降沿写入
always @ (negedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rf[1][31: 0]  <= 0;
        rf[2][31: 0]  <= 0;
        rf[3][31: 0]  <= 0;
        rf[4][31: 0]  <= 0;
        rf[5][31: 0]  <= 0;
        rf[6][31: 0]  <= 0;
        rf[7][31: 0]  <= 0;
        rf[8][31: 0]  <= 0;
        rf[9][31: 0]  <= 0;
        rf[10][31: 0] <= 0;
        rf[11][31: 0] <= 0;
        rf[12][31: 0] <= 0;
        rf[13][31: 0] <= 0;
        rf[14][31: 0] <= 0;
        rf[15][31: 0] <= 0;
        rf[16][31: 0] <= 0;
        rf[17][31: 0] <= 0;
        rf[18][31: 0] <= 0;
        rf[19][31: 0] <= 0;
        rf[20][31: 0] <= 0;
        rf[21][31: 0] <= 0;
        rf[22][31: 0] <= 0;
        rf[23][31: 0] <= 0;
        rf[24][31: 0] <= 0;
        rf[25][31: 0] <= 0;
        rf[26][31: 0] <= 0;
        rf[27][31: 0] <= 0;
        rf[28][31: 0] <= 0;
        rf[29][31: 0] <= 0;
        rf[30][31: 0] <= 0;
        rf[31][31: 0] <= 0;
    end
    else if (we == `REGWE_WRITE) begin
        rf[$unsigned(wr)] <= wd;
    end
end

endmodule
