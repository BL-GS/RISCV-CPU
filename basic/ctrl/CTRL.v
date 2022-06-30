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
           input   wire[1: 0]  COMPRes,
           output  reg         PCSel,
           output  reg         RegWe,
           output  reg         ASel,
           output  reg         BSel,
           output  reg         DRAMWE,
           output  reg[1: 0]   RWSel,
           output  wire[4: 0]  SextOpe,
           output  wire[1: 0]  DRAM_EX_TYPE
       );

wire r, i, s, b, u, j;
reg  [5: 0] type_reg;

wire COMP_EQ;                   // 比较结果：等于
wire COMP_NEQ;                  // 比较结果：不等于
wire COMP_LE;                   // 比较结果：小于
wire COMP_GE_EQ;                // 比较结果：大于等于

wire TYPE_COMP_R, TYPE_COMP_I;  // 比较指令(R:与寄存器内容比较 ; I:与立即数内容比较)
wire TYPE_JUMP;                 // 无条件跳转指令
wire TYPE_PC;                   // 需要PC参与运行的指令
wire TYPE_MOVE;                 // 移位指令
wire TYPE_LOAD;                 // Load 指令

// 指令类型
assign {r, i, s, b, u, j} = type_reg[5: 0];

// 比较结果
assign COMP_EQ    = (COMPRes == 2'b00) ? 1'b1 : 1'b0;
assign COMP_NEQ   = ~COMP_EQ;
assign COMP_LE    = (COMPRes == 2'b01) ? 1'b1 : 1'b0;
assign COMP_GE_EQ = ~COMP_LE;

// 符号扩展控制
assign SextOpe     = {i, s, b, j, u};
assign TYPE_COMP_R = (opecode[6: 2] == 5'b01100 && func3[2:1] == 2'b01) ? 1'b1 : 1'b0;
assign TYPE_COMP_I = (opecode[6: 2] == 5'b00100 && func3[2:1] == 2'b01) ? 1'b1 : 1'b0;
assign TYPE_JUMP   = (j || (opecode[6: 2] == 5'b11001)) ? 1'b1 : 1'b0;
assign TYPE_PC     = ((j | b | TYPE_COMP_R | TYPE_COMP_I ) == 1'b1 || (opecode[6: 2] == 5'b00101));
assign TYPE_LOAD   = (opecode[6: 2] == 5'b00000) ? 1'b1 : 1'b0;


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
                        PC 跳转控制
****************************************************************/

always @ (*) begin
    if (b) begin
        casez (func3)
            3'b000: begin // beq
                PCSel = (COMP_EQ) ? `PCSEL_JUMP : `PCSEL_PC4;
            end
            3'b001: begin // bne
                PCSel = (COMP_NEQ) ? `PCSEL_JUMP : `PCSEL_PC4;
            end
            3'b1?0: begin // blt / bltu
                PCSel = (COMP_LE) ? `PCSEL_JUMP : `PCSEL_PC4;
            end
            3'b1?1: begin // bge / bgeu
                PCSel = (COMP_GE_EQ) ? `PCSEL_JUMP : `PCSEL_PC4;
            end
            default: begin
                PCSel = `PCSEL_PC4;
            end
        endcase
    end
    else if (TYPE_JUMP) begin
        PCSel = `PCSEL_JUMP;
    end
    else begin
        PCSel = `PCSEL_PC4;
    end
end

/***************************************************************
                        寄存器写入控制
****************************************************************/

always @(*) begin
    if (s | b | ~rst_n) begin
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
    if (TYPE_LOAD) begin
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

endmodule
