module PC(
           input    wire        clk,
           input    wire        rst_n,
           input    wire        risk_Ctrl,
           input    wire[31: 0] branch_pc,
           input    wire[31: 0] npc,
           output   reg [31: 0] pc
       );

/***************************************************************
                        程序计数器变化
****************************************************************/

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        pc <= 0;
    end
    else if (risk_Ctrl) begin
        pc <= branch_pc + 4;
    end
    else begin
        pc <= npc;
    end
end

endmodule
