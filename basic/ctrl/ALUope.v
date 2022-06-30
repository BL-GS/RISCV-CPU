`ifdef DEBUG
    `include "param.v"
`else
`include "../../param.v"
`endif

module ALUope (
           input    wire[6: 0]  func7,
           input    wire[2: 0]  func3,
           input    wire[6: 0]  opecode,
           output   reg[2: 0]   ALUop,
           output   reg         Unsigned
       );

/***************************************************************
                        运算类型控制
****************************************************************/

always @(*) begin
    casez ({func7[5], func3, opecode[6:2]})
        // 移位
        9'b11010?100:
            ALUop = `SRA;
        9'b01010?100:
            ALUop = `SRL;
        9'b00010?100:
            ALUop = `SLL;
        // 逻辑运算
        9'b?10000100:
            ALUop = `XOR;
        9'b010001100:
            ALUop = `XOR;
        9'b?11000100:
            ALUop = `OR;
        9'b011001100:
            ALUop = `OR;
        9'b?11100100:
            ALUop = `AND;
        9'b011101100:
            ALUop = `AND;
        // Lui 特殊处理
        9'b????01101:
            ALUop = `SLL;
        // 算术运算
        9'b100001100:
            ALUop = `SUB;
        default: 
            ALUop = `ADD;
    endcase
end

/***************************************************************
                        符号运算控制
****************************************************************/

always @(*) begin
    casez ({func3, opecode[6:2]})
        8'b11?11000: // bltu, bgeu
            Unsigned = `UNSIGNED;
        8'b0110?100: // sltiu, sltu // WARNING: And 操作不考虑
            Unsigned = `UNSIGNED;
        8'b1??00000: // lbu, lwu, lhu
            Unsigned = `UNSIGNED;
        8'b???01101: // Lui 特殊处理
            Unsigned = `UNSIGNED;
        default: 
            Unsigned = `SIGNED;
    endcase
end

endmodule
