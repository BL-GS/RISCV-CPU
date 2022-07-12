`ifdef DEBUG
    `include "param.v"
`else
    `include "../../param.v"
`endif

module BHT (
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire                        isWrong,    // 是否正确，是经过判断后的结果
    input   wire[`WIDTH_PC - 1: 0]      pc,         // 代表当前待判断的 PC
    input   wire                        isNeeded,   // 是否需要，代表是否需要跳转建议，通常表现为是否为 B 型指令
    input   wire[`WIDTH_PC - 1 : 0]     branch_pc,  // 代表计算后得到的准确结果
    output  wire[`WIDTH_PC - 1 : 0]     pre_pc,     // 代表预测的 PC
    output  wire                        isHit       // 是否命中，代表该预测是否有效
);

integer   i;

parameter   STATUS_JUMP = 2'b00;
parameter   STATUS_WEAK_JUMP = 2'b01;
parameter   STATUS_WEAK_NORM = 2'b11;
parameter   STATUS_NORM = 2'b10;


/***************************************************************
                        BHT表连接
****************************************************************/
/*------------/-------------/-------------/--------------/
/   isAvail   /    Statu    /     Tag     /    History   /      
/-------------/-------------/-------------/-------------*/
/*---- 1 -----/----- 2 -----/----- 7 -----/ ---- 30 ----*/

// 指令范围共14位表示，用 7 位的 Tag 作判断，用 7 位选择寄存器块，共 128 块
reg [39: 0] PCtable [127: 0];

// 写入控制线
wire [6: 0] branch_blockChoice = branch_pc[8 : 2];
wire [6: 0] branch_blockTag    = branch_pc[15: 9];

/***************************************************************
                        BHT表写入
****************************************************************/

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (i = 0; i < 128; i = i + 1) begin
            // 复位只需要将有效位置 0
            PCtable[i][39] <= 0;
        end
    end
    else begin
        if (isWrong) begin
            PCtable[$unsigned(branch_blockChoice[6: 0])][39]
        end
    end
end






endmodule