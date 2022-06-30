`ifdef DEBUG
    `include "param.v"
`else
`include "../../param.v"
`endif

module ImmGen (
           input   wire [31: 7]    imm,
           input   wire [4: 0]     SextOpe,
           output  wire [31: 0]    out
       );

reg  [31: 0] out_reg;
assign out = out_reg;

wire [31: 0] imm_I;
wire [31: 0] imm_S;
wire [31: 0] imm_B;
wire [31: 0] imm_J;
wire [31: 0] imm_U;

wire inst0               = imm[31];
wire [5: 0] inst1        = imm[30: 25];
wire [3: 0] inst2        = imm[24: 21];
wire inst3               = imm[20];
wire [7: 0] inst4        = imm[19: 12];
wire [3: 0] inst5        = imm[11: 8];
wire inst6               = imm[7];
wire [11: 0] signalEX_12 = {12{inst0}};
wire [19: 0] signalEX_20 = {{8{inst0}}, signalEX_12[11: 0]};

assign imm_I = {signalEX_20, inst0, inst1, inst2, inst3};
assign imm_S = {signalEX_20, inst0, inst1, inst5, inst6};
assign imm_B = {signalEX_20, inst6, inst1, inst5, 1'b0};
assign imm_J = {signalEX_12, inst4, inst3, inst1, inst2, 1'b0};
assign imm_U = {inst0, inst1, inst2, inst3, inst4, 12'd0};

always @(*) begin
    case (SextOpe)
        `IMM_I: begin
            // I
            out_reg[31: 0] = imm_I[31: 0];
        end
        `IMM_S: begin
            // S
            out_reg[31: 0] = imm_S[31: 0];
        end
        `IMM_B: begin
            // B
            out_reg[31: 0] = imm_B[31: 0];
        end
        `IMM_J: begin
            // J
            out_reg[31: 0] = imm_J[31: 0];
        end
        `IMM_U: begin
            // U
            out_reg[31: 0] = imm_U[31: 0];
        end
        default: begin
            out_reg[31: 0] = 32'b0;
        end
    endcase
end

endmodule
