`ifdef DEBUG
    `include "param.v"
`else
    `include "../../param.v"
`endif

module BHT (
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire                        isNeeded,   // 是否需要，代表是否需要跳转建议，通常表现为是否为 B 型指令
    input   wire[`WIDTH_PC - 1: 0]      pc,         // 代表当前待判断的 PC
    input   wire                        isWrong,    // 是否正确，是经过判断后的结果
    input   wire[`WIDTH_PC - 1 : 0]     branch_pc,  // 代表计算后得到的准确结果
    output  wire                        isHit,      // 是否命中，代表该预测是否有效
    output  reg                         isJump,     // 是否需要跳转
    output  wire[`WIDTH_PC - 1 : 0]     pre_pc      // 代表预测的 PC
);

integer   i;

`define   STATUS_JUMP       2'b00
`define   STATUS_WEAK_JUMP  2'b01
`define   STATUS_WEAK_NORM  2'b11
`define   STATUS_NORM       2'b10


/***************************************************************
                        BHT表连接
****************************************************************/
/*------------/-------------/-------------/--------------/
/   isAvail   /    Statu    /     Tag     /    History   /      
/-------------/-------------/-------------/-------------*/
/*---- 1 -----/----- 2 -----/----- 7 -----/ ---- 30 ----*/

`define ISAVAIL_BIT 39
`define STATUS_BIT  38
`define TAG_BIT     36
`define HISTORY_BIT 29

`define ISAVAIL_WIDTH 1
`define STATUS_WIDTH  2
`define TAG_WIDTH     7
`define HISTORY_WIDTH 30
`define BHT_WIDTH     40

// 指令范围共14位表示，用 7 位的 Tag 作判断，用 7 位选择寄存器块，共 128 块
reg [`BHT_WIDTH - 1: 0] PCtable [127: 0];

// 写入控制线
wire [6: 0] branch_blockChoice           = branch_pc[8 : 2];
wire [`TAG_WIDTH - 1: 0] branch_blockTag = branch_pc[15: 9];

/***************************************************************
                        BHT表写入
****************************************************************/
reg [1: 0] isNeededWrite;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        isNeededWrite <= 0;
    end
    else begin
        isNeededWrite[1: 0] <= {isNeededWrite[0], isNeeded};
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (i = 0; i < 128; i = i + 1) begin
            // 复位只需要将有效位置 0
            PCtable[i][`ISAVAIL_BIT -: `ISAVAIL_WIDTH] <= 0;
            PCtable[i][`STATUS_BIT -: `STATUS_WIDTH] <= `STATUS_WEAK_NORM;
        end
    end
    else if (isNeededWrite[1]) begin
        PCtable[$unsigned(branch_blockChoice[6: 0])][`ISAVAIL_BIT -: `ISAVAIL_WIDTH] <= 1'b1;
        PCtable[$unsigned(branch_blockChoice[6: 0])][`TAG_BIT -: `TAG_WIDTH]         <= branch_blockTag;
        PCtable[$unsigned(branch_blockChoice[6: 0])][`HISTORY_BIT -: `HISTORY_WIDTH] <= branch_pc[31 -: `HISTORY_WIDTH];

        // 状态转移
        case (PCtable[$unsigned(branch_blockChoice[6: 0])][`STATUS_BIT -: `STATUS_WIDTH])
            `STATUS_JUMP: begin
                PCtable[$unsigned(branch_blockChoice[6: 0])][`STATUS_BIT -: `STATUS_WIDTH] <=
                (isWrong) ? `STATUS_WEAK_JUMP : `STATUS_JUMP;
            end
            `STATUS_WEAK_JUMP: begin
                PCtable[$unsigned(branch_blockChoice[6: 0])][`STATUS_BIT -: `STATUS_WIDTH] <= 
                (isWrong) ? `STATUS_WEAK_NORM : `STATUS_JUMP;
            end
            `STATUS_WEAK_NORM: begin
                PCtable[$unsigned(branch_blockChoice[6: 0])][`STATUS_BIT -: `STATUS_WIDTH] <= 
                (isWrong) ? `STATUS_WEAK_JUMP : `STATUS_NORM;
            end
            `STATUS_NORM: begin
                PCtable[$unsigned(branch_blockChoice[6: 0])][`STATUS_BIT -: `STATUS_WIDTH] <= 
                (isWrong) ? `STATUS_WEAK_NORM : `STATUS_NORM;
            end
        endcase
    end
end

/***************************************************************
                        BHT表读出逻辑
****************************************************************/
wire [6: 0]                     blockChoice = pc[8 : 2];
wire [`TAG_WIDTH - 1: 0]        blockTag    = pc[15: 9];
wire [`BHT_WIDTH - 1: 0]        blockChoosed         = PCtable[$unsigned(blockChoice[6: 0])][`BHT_WIDTH - 1: 0];
wire [`ISAVAIL_WIDTH - 1: 0]    blockChoosed_isAvail = blockChoosed[`ISAVAIL_BIT -: `ISAVAIL_WIDTH];
wire [`TAG_WIDTH - 1: 0]        blockChoosed_Tag     = blockChoosed[`TAG_BIT -: `TAG_WIDTH];
wire [`STATUS_WIDTH - 1: 0]     blockChoosed_Status  = blockChoosed[`STATUS_BIT -: `STATUS_WIDTH];
wire [`HISTORY_WIDTH - 1: 0]    blockChoosed_History = blockChoosed[`HISTORY_BIT -: `HISTORY_WIDTH];

// 是否命中 或者 是否需要
assign isHit = (isNeeded || blockChoosed_isAvail || blockChoosed_Tag == blockTag) ? 1'b1 : 1'b0;
// 得出预测值
assign pre_pc = {blockChoosed_History, 2'b0};
// 是否需要跳转
always @(*) begin
    case (blockChoosed_Status)
        `STATUS_JUMP: begin
            isJump = 1;
        end
        `STATUS_WEAK_JUMP: begin
            isJump = 1;
        end
        `STATUS_WEAK_NORM: begin
            isJump = 0;
        end
        `STATUS_NORM: begin
            isJump = 0;
        end
    endcase
end



endmodule