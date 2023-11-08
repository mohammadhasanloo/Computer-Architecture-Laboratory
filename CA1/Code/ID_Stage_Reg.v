module ID_Stage_Reg(
    input clk, rst,
    input [31:0] PC_in,
    input [3:0] EXE_CMD_In,
    input MEM_R_EN_In, MEM_W_EN_In, WB_En_In, B_In, S_In,
    input [31:0] reg1In, reg2In,
    input immIn,
    input [11:0] Shift_operand_In,
    input signed [23:0] imm24In,
    input [3:0] Dest_In,
    input carryIn,
    input [3:0] src1In, src2In,
    input flush, freeze,
    output [31:0] PC,
    output [3:0] EXE_CMD,
    output MEM_R_EN, MEM_W_EN, WB_EN, B, S,
    output [31:0] reg1Out, reg2Out,
    output immOut,
    output [11:0] Shift_operand,
    output signed [23:0] imm24Out,
    output [3:0] Dest,
    output [3:0] src1Out, src2Out,
    output carryOut
);
    Register #(32) pcReg(
        .clk(clk), .rst(rst),
        .in(PC_in), .ld(~freeze), .clr(flush),
        .out(PC)
    );

    Register #(4) aluCmdReg(
        .clk(clk), .rst(rst),
        .in(EXE_CMD_In), .ld(~freeze), .clr(flush),
        .out(EXE_CMD)
    );

    Register #(1) memReadReg(
        .clk(clk), .rst(rst),
        .in(MEM_R_EN_In), .ld(~freeze), .clr(flush),
        .out (MEM_R_EN)
    );
    Register #(1) memWriteReg(
        .clk(clk), .rst(rst),
        .in(MEM_W_EN_In), .ld(~freeze), .clr(flush),
        .out(MEM_W_EN)
    );
    Register #(1) wbEnReg(
        .clk(clk), .rst(rst),
        .in(WB_En_In), .ld(~freeze), .clr(flush),
        .out(WB_EN)
    );
    Register #(1) branchReg(
        .clk(clk), .rst(rst),
        .in(B_In), .ld(~freeze), .clr(flush),
        .out(B)
    );
    Register #(1) sReg(
        .clk(clk), .rst(rst),
        .in(S_In), .ld(~freeze), .clr(flush),
        .out(S)
    );

    Register #(32) reg1Reg(
        .clk(clk), .rst(rst),
        .in(reg1In), .ld(~freeze), .clr(flush),
        .out(reg1Out)
    );

    Register #(32) reg2Reg(
        .clk(clk), .rst(rst),
        .in(reg2In), .ld(~freeze), .clr(flush),
        .out(reg2Out)
    );

    Register #(1) immReg(
        .clk(clk), .rst(rst),
        .in(immIn), .ld(~freeze), .clr(flush),
        .out(immOut)
    );

    Register #(12) shiftOperandReg(
        .clk(clk), .rst(rst),
        .in(Shift_operand_In), .ld(~freeze), .clr(flush),
        .out(Shift_operand)
    );

    Register #(24) imm24Reg(
        .clk(clk), .rst(rst),
        .in(imm24In), .ld(~freeze), .clr(flush),
        .out(imm24Out)
    );

    Register #(4) destReg(
        .clk(clk), .rst(rst),
        .in(Dest_In), .ld(~freeze), .clr(flush),
        .out(Dest)
    );

    Register #(1) carryReg(
        .clk(clk), .rst(rst),
        .in(carryIn), .ld(~freeze), .clr(flush),
        .out(carryOut)
    );

    Register #(4) src1Reg(
        .clk(clk), .rst(rst),
        .in(src1In), .ld(~freeze), .clr(flush),
        .out(src1Out)
    );

    Register #(4) src2Reg(
        .clk(clk), .rst(rst),
        .in(src2In), .ld(~freeze), .clr(flush),
        .out(src2Out)
    );
endmodule
