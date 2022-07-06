`ifdef DEBUG
    `include "param.v"
`else
`include "../../param.v"
`endif

module ForwardingUnit (
           input    wire [4: 0]         rs1_ID,
           input    wire [4: 0]         rs2_ID,
           input    wire [4: 0]         wr_EX,
           input    wire [4: 0]         wr_MEM,
           input    wire                we_EX,
           input    wire                we_MEM,
           input    wire [31: 0]        rd_EX,
           input    wire [31: 0]        rd_MEM,
           output   reg                 MUX_A_forwarding,
           output   reg                 MUX_B_forwarding,
           output   reg  [31: 0]        forwardingA,
           output   reg  [31: 0]        forwardingB
       );

wire risk_EX_A;
wire risk_EX_B;
wire risk_MEM_A;
wire risk_MEM_B;

wire risk_EX_zero;
wire risk_MEM_zero;

/***************************************************************
                        EX 冒险
****************************************************************/
assign risk_EX_zero = (wr_EX == 5'd0);
assign risk_EX_A = (rs1_ID == wr_EX && ~risk_EX_zero && we_EX) ? 1'b1 : 1'b0;
assign risk_EX_B = (rs2_ID == wr_EX && ~risk_EX_zero && we_EX) ? 1'b1 : 1'b0;

/***************************************************************
                        MEM 冒险 
****************************************************************/
assign risk_MEM_zero = (wr_MEM == 5'b0);
assign risk_MEM_A = (rs1_ID == wr_MEM && ~risk_MEM_zero && we_MEM) ? 1'b1 : 1'b0;
assign risk_MEM_B = (rs2_ID == wr_MEM && ~risk_MEM_zero && we_MEM) ? 1'b1 : 1'b0;

/***************************************************************
                        前递
****************************************************************/
always @(*) begin
    if (risk_EX_A) begin
        MUX_A_forwarding = `ASEL_FORWARDING;
        forwardingA[31: 0] = rd_EX[31: 0];
    end
    else if (risk_MEM_A) begin
        MUX_A_forwarding = `ASEL_FORWARDING;
        forwardingA[31: 0] = rd_MEM[31: 0];
    end
    else begin
        MUX_A_forwarding = ~(`ASEL_FORWARDING);
        forwardingA[31: 0] = 0;
    end
end

always @(*) begin
    if (risk_EX_B) begin
        MUX_B_forwarding = `BSEL_FORWARDING;
        forwardingB[31: 0] = rd_EX[31: 0];
    end
    else if (risk_MEM_B) begin
        MUX_B_forwarding = `BSEL_FORWARDING;
        forwardingB[31: 0] = rd_MEM[31: 0];
    end
    else begin
        MUX_B_forwarding = ~(`BSEL_FORWARDING);
        forwardingB[31: 0] = 0;
    end
end


endmodule
