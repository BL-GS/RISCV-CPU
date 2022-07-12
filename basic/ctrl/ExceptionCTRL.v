`ifdef DEBUG
    `include "param.v"
`else
    `include "../../param.v"
`endif

/*-----------------------------------------------
        例外处理器
        功能：负责加入气泡，如当发生分支预测错误时
            对于R-R型冒险，在有前递的情况下不需要加入气泡
            对于Load-use型冒险，在有前递的情况下需要加入一个周期的气泡
            对于控制冒险，在预测错误时需要进行一个周期的停顿
-----------------------------------------------*/

module ExceptionCTRL (
    input    wire [4: 0]         rs1_ID,
    input    wire [4: 0]         rs2_ID,
    input    wire [4: 0]         wr_EX,
    input    wire                isLoad,
    input    wire                inst_div,
    input    wire                isRiskCtrl,
    output   wire                stop_ID,
    output   wire                stop_IF
);

/***************************************************************
                        Load-Use型 冒险 
****************************************************************/
wire risk_LoadUse;

assign risk_LoadUse = (isLoad && (rs1_ID == wr_EX || rs2_ID == wr_EX) && (wr_EX != 5'b00000)) ? 1'b1 : 1'b0;

/***************************************************************
                        控制冒险
****************************************************************/
wire risk_Ctrl;

assign risk_Ctrl = isRiskCtrl;

/***************************************************************
                        插入气泡
****************************************************************/
// IF停顿即令指令不变，当Load-Use型冒险时 和 指令拆分时 可用；当控制冒险时由于需要接受新的分支PC。故不成立
// IF停顿时，！！保持！！ IF/ID 寄存器
assign stop_IF = risk_LoadUse | inst_div; 
// ID停顿即令译码内容不变，当Load-Use型冒险和控制冒险都适用，需要清空当前周期存入的所有信息
// ID停顿时，！！清空！！ ID/EX 寄存器
assign stop_ID = risk_LoadUse | risk_Ctrl; 


endmodule