`ifdef DEBUG
    `include "param.v"
`else
`include "../../param.v"
`endif

module CTRL (
           input   wire        rst_n,
           input   wire[6: 0]  func7,
           input   wire[2: 0]  func3,
           input   wire[6: 0]  opecode,
           output  reg         RegWe,
           output  reg         ASel,
           output  reg         BSel,
           output  reg         DRAMWE,
           output  reg[1: 0]   RWSel,
           output  wire[4: 0]  SextOpe,
           output  wire[1: 0]  DRAM_EX_TYPE,
           output  reg [`WIDTH_PCCTRL - 1: 0]  PCCTRL
       );

/***************************************************************
                        指令译码
****************************************************************/

wire r, i, s, b, u, j;
reg  [5: 0] type_reg;

wire TYPE_LOAD;
wire TYPE_COMP_R, TYPE_COMP_I;  // 比较指令(R:与寄存器内容比较 ; I:与立即数内容比较)
wire TYPE_JUMP;                 // 无条件跳转指令
wire TYPE_PC;                   // 需要PC参与运行的指令
wire TYPE_MOVE;                 // 移位指令
wire TYPE_NOP;                  // 空指令

// 指令类型
assign {r, i, s, b, u, j} = type_reg[5: 0];

// 符号扩展控制
assign SextOpe     = {i, s, b, j, u};
assign TYPE_COMP_R = (opecode[6: 2] == 5'b01100 && func3[2:1] == 2'b01) ? 1'b1 : 1'b0;
assign TYPE_COMP_I = (opecode[6: 2] == 5'b00100 && func3[2:1] == 2'b01) ? 1'b1 : 1'b0;
assign TYPE_JUMP   = (j || (opecode[6: 2] == 5'b11001)) ? 1'b1 : 1'b0;
assign TYPE_PC     = ((j | b | TYPE_COMP_R | TYPE_COMP_I ) == 1'b1 || (opecode[6: 2] == 5'b00101));
assign TYPE_LOAD   = (opecode[6: 2] == 5'b00000) ? 1'b1 : 1'b0;

assign TYPE_NOP    = (opecode[1: 0] == 2'b00) ? 1'b1 : 1'b0;

/***************************************************************
                        指令类型判断
****************************************************************/

always @ (*) begin
    case (opecode[6:2])
        5'b01100: begin
            type_reg = 6'b100000; // R 型
        end
        5'b01101: begin
            type_reg = 6'b000010; // U 型
        end
        5'b00101: begin
            type_reg = 6'b000010; // U 型
        end
        5'b11011: begin
            type_reg = 6'b000001; // J 型
        end
        5'b01000: begin
            type_reg = 6'b001000; // S 型
        end
        5'b11000: begin
            type_reg = 6'b000100; // B 型
        end
        default: begin
            type_reg = 6'b010000; // I 型
        end
    endcase
end

/***************************************************************
                        寄存器写入控制
****************************************************************/

always @(*) begin
    if (~rst_n | s | b | TYPE_NOP) begin
        RegWe = `REGWE_READ;
    end
    else begin
        RegWe = `REGWE_WRITE;
    end
end

/***************************************************************
                        ALU中端口输入控制
****************************************************************/
// ALU中 A 端口输入控制
always @(*) begin
    if (TYPE_PC) begin
        ASel = `ASEL_PC;
    end
    else begin
        ASel = `ASEL_REG;
    end
end

// ALU中 B 端口输入控制
always @(*) begin
    if ((r == 1'b1 && TYPE_COMP_R == 1'b0) || TYPE_COMP_I == 1'b1) begin
        BSel = `BSEL_REG;
    end
    else begin
        BSel = `BSEL_IMM;
    end
end

/***************************************************************
                        写寄存器输入控制
****************************************************************/

always @(*) begin
    if (TYPE_NOP) begin
        RWSel = `REGWD_ALUOUT;
    end
    else if (TYPE_LOAD) begin
        RWSel = `REGWD_DRAMRD; // Load 指令
    end
    else if (TYPE_COMP_R | TYPE_COMP_I) begin
        RWSel = `REGWD_COMPOUT; // 比较指令
    end
    else if (TYPE_JUMP) begin
        RWSel = `REGWD_PC; // 无条件跳转指令
    end
    else begin
        RWSel = `REGWD_ALUOUT;
    end
end

/***************************************************************
                        写主存控制
****************************************************************/

always @(*) begin
    if (~rst_n) begin
        DRAMWE = `DRAM_READ;
    end
    else if (s) begin
        DRAMWE = `DRAM_WRITE;
    end
    else begin
        DRAMWE = `DRAM_READ;
    end
end

/***************************************************************
                        主存读出扩展控制
****************************************************************/

assign DRAM_EX_TYPE[1: 0] = func3[1: 0];


/***************************************************************
                        指令跳转分析
****************************************************************/

always @(*) begin
    PCCTRL[`PCCTRL_J] = TYPE_JUMP;
    PCCTRL[`PCCTRL_B] = b;
    case (func3)
        3'b000: begin // beq
            PCCTRL[1: 0] = `PCCTRL_B_EQ;
        end
        3'b001: begin // bne
            PCCTRL[1: 0] = `PCCTRL_B_NE;
        end
        3'b100: begin // blt
            PCCTRL[1: 0] = `PCCTRL_B_LT;
        end
        3'b110: begin // bltu
            PCCTRL[1: 0] = `PCCTRL_B_LT;
        end
        default: begin // bge / bgeu
            PCCTRL[1: 0] = `PCCTRL_B_GEQ;
        end
    endcase
end


endmodule
