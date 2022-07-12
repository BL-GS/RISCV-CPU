`ifdef DEBUG
    `include "param.v"
`else
    `include "../../param.v"
`endif

module InstDivider (
    input wire [`WIDTH_INST - 1 : 0] inst_in,
    output wire [`WIDTH_INST - 1 : 0] inst_out
);

/***************************************************************
                        指令拆分
****************************************************************/
// 目前只有 sb 和 sh 需要进行 lw 作为前置指令

/*
    sb | sh -> [lw x0 same_addr] + (sb | sh)
*/
assign inst_out[`WIDTH_INST - 1 : 0] = {
    inst_in[31: 25], inst_in[11: 7], inst_in[19: 12], 5'b0, inst_in[6: 0]
};

endmodule