/*-------------------------------------------------------
            BHT 表存储转移结果
            存储格式
            /-------1------/---------24---------/--------2--------/---------30--------/
            /    Avail     /    Tag(PC[25: 2])  /    JUMP_TAG     /       History-2   /
            /--------------/-------------------/-----------------/-------------------/
--------------------------------------------------------*/
module BHT (
    input   wire            clk,
    input   wire            rst_n,
    input   wire [31: 0]    pc,
    input   wire [31: 0]    pc_used,
    input   wire [31: 0]    pc_used_target,
    input   wire            isJump,
    output  wire            isHit,
    output  reg  [31: 0]    prePC
);

parameter NO_JUMP         = 2'b00;
parameter WEAKLY_NO_JUMP  = 2'b01;
parameter WEAKLY_JUMP     = 2'b11;
parameter JUMP            = 2'b10;

wire [31: 0] pc4 = pc + 4;
wire [31: 0] pc4_used = pc_used + 4;

/***************************************************************
                         寄存器逻辑
****************************************************************/

reg[56: 0]      BHT_reg [63: 0];

wire [56: 0]    BHT_Sel;
wire            avail;
wire [1: 0]     jump_Tag;
wire [31: 0]    history;
wire [23: 0]    tag;

assign BHT_Sel[56: 0] = BHT_reg[$unsigned(pc[31: 26])][56: 0]; // 选择对应的 BHT块
assign avail          = BHT_Sel[56];
assign jump_Tag[1: 0] = BHT_Sel[31: 30];
assign history[31: 0] = {BHT_Sel[29: 0], 2'b0};
assign tag[23: 0]     = BHT_Sel[55: 32];

assign isHit          = (pc[25: 2] == tag[23: 0]) ? 1'b1 : 1'b0;

/***************************************************************
                        状态转移逻辑
****************************************************************/
integer i;

wire [56: 0]    BHT_Sel_Judge;
wire            avail_Judge;
wire [1: 0]     jump_Tag_Judge;
wire [31: 0]    history_Judge;
wire [23: 0]    tag_Judge;

assign BHT_Sel_Judge[56: 0] = BHT_reg[$unsigned(pc[31: 26])][56: 0]; // 选择对应的 BHT块
assign avail_Judge          = BHT_Sel[56];
assign jump_Tag_Judge[1: 0] = BHT_Sel[31: 30];
assign history_Judge[31: 0] = {BHT_Sel[29: 0], 2'b0};
assign tag_Judge[23: 0]     = BHT_Sel[55: 32];

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (i = 0; i < 57; i = i + 1) begin
            BHT_reg[i][56: 0] <= 0;
        end
    end 
    else begin
        if (!isHit) begin
            BHT_reg[$unsigned(pc[31: 26])][31: 30] <= {1'b1, pc[25: 2], WEAKLY_NO_JUMP, pc4[31: 2]};
        end
        case (jump_Tag_Judge)
            NO_JUMP: begin
                BHT_reg[$unsigned(pc_used[31: 26])][31: 30] <= (isJump) ? WEAKLY_NO_JUMP : NO_JUMP;
            end
            WEAKLY_NO_JUMP: begin
                BHT_reg[$unsigned(pc_used[31: 26])][31: 30] <= (isJump) ? WEAKLY_JUMP : JUMP;
                BHT_reg[$unsigned(pc_used[31: 26])][29: 0]  <= (isJump) ? pc_used_target[31: 2] : pc4_used;
            end
            WEAKLY_JUMP: begin
                BHT_reg[$unsigned(pc_used[31: 26])][31: 30] <= (isJump) ? JUMP : WEAKLY_NO_JUMP;
                BHT_reg[$unsigned(pc_used[31: 26])][29: 0]  <= (isJump) ? pc_used_target[31: 2] : pc4_used;
            end
            JUMP: begin
                BHT_reg[$unsigned(pc_used[31: 26])][31: 30] <= (isJump) ? JUMP : WEAKLY_JUMP;
            end
            default: begin
                BHT_reg[$unsigned(pc_used[31: 26])][31: 30] <= BHT_reg[$unsigned(pc[31: 26])][31: 30];
            end
        endcase
    end
end

/***************************************************************
                        跳转逻辑
****************************************************************/
always @(*) begin
        case (jump_Tag)
        NO_JUMP: begin
            prePC <= pc4;
        end
        WEAKLY_NO_JUMP: begin
            prePC <= pc4;
        end
        WEAKLY_JUMP: begin
            prePC <= history;
        end
        JUMP: begin
            prePC <= history;
        end
        default: begin
            prePC <= pc4;
        end
        endcase
end

endmodule