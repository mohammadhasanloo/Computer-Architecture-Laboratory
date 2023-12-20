module ID_Stage_Reg(
    input clk, rst, Flush, carryIn, MEM_R_EN_In, MEM_W_EN_In, WB_EN_In, B_In, S_In,
    input [31:0] PC_in,
    input [3:0] EXE_CMD_In,
    input [31:0] reg1In, reg2In,
    input [3:0] src1In, src2In,
    input imm_In,
    input [11:0] Shift_operand_In,
    input signed [23:0] Signed_imm_24_In,
    input [3:0] Dest_In,

    output MEM_R_EN_Out, MEM_W_EN_Out, WB_EN_Out, B_Out, S_Out,imm_Out, carryOut,
    output [31:0] PC,
    output [3:0] EXE_CMD_Out,Dest_Out,
    output [31:0] reg1Out, reg2Out,
    output [11:0] Shift_operand_Out,
    output [3:0] src1Out, src2Out,
    output signed [23:0] Signed_imm_24_Out
);
    Register #(32) pcReg(
        .clk(clk), .rst(rst),
        .in(PC_in), .ld(1'b1), .clr(Flush),
        .out(PC)
    );

    Register #(4) aluCmdReg(
        .clk(clk), .rst(rst),
        .in(EXE_CMD_In), .ld(1'b1), .clr(Flush),
        .out(EXE_CMD_Out)
    );

    Register #(1) memReadReg(
        .clk(clk), .rst(rst),
        .in(MEM_R_EN_In), .ld(1'b1), .clr(Flush),
        .out(MEM_R_EN_Out)
    );
    Register #(1) memWriteReg(
        .clk(clk), .rst(rst),
        .in(MEM_W_EN_In), .ld(1'b1), .clr(Flush),
        .out(MEM_W_EN_Out)
    );
    Register #(1) Wb_En_Reg(
        .clk(clk), .rst(rst),
        .in(WB_EN_In), .ld(1'b1), .clr(Flush),
        .out(WB_EN_Out)
    );
    Register #(1) branchReg(
        .clk(clk), .rst(rst),
        .in(B_In), .ld(1'b1), .clr(Flush),
        .out(B_Out)
    );
    Register #(1) sReg(
        .clk(clk), .rst(rst),
        .in(S_In), .ld(1'b1), .clr(Flush),
        .out(S_Out)
    );

    Register #(32) reg1Reg(
        .clk(clk), .rst(rst),
        .in(reg1In), .ld(1'b1), .clr(Flush),
        .out(reg1Out)
    );

    Register #(32) reg2Reg(
        .clk(clk), .rst(rst),
        .in(reg2In), .ld(1'b1), .clr(Flush),
        .out(reg2Out)
    );

    Register #(1) immReg(
        .clk(clk), .rst(rst),
        .in(imm_In), .ld(1'b1), .clr(Flush),
        .out(imm_Out)
    );

    Register #(12) shiftOperandReg(
        .clk(clk), .rst(rst),
        .in(Shift_operand_In), .ld(1'b1), .clr(Flush),
        .out(Shift_operand_Out)
    );

    Register #(24) imm24Reg(
        .clk(clk), .rst(rst),
        .in(Signed_imm_24_In), .ld(1'b1), .clr(Flush),
        .out(Signed_imm_24_Out)
    );

    Register #(4) Dest_Reg(
        .clk(clk), .rst(rst),
        .in(Dest_In), .ld(1'b1), .clr(Flush),
        .out(Dest_Out)
    );

    Register #(1) flushReg(
        .clk(clk), .rst(rst),
        .in(flushIn), .ld(1'b1), .clr(Flush),
        .out(flushOut)
    );

    Register #(1) carryReg(
        .clk(clk), .rst(rst),
        .in(carryIn), .ld(1'b1), .clr(Flush),
        .out(carryOut)
    );

    Register #(4) src1Reg(
        .clk(clk), .rst(rst),
        .in(src1In), .ld(1'b1), .clr(Flush),
        .out(src1Out)
    );

    Register #(4) src2Reg(
        .clk(clk), .rst(rst),
        .in(src2In), .ld(1'b1), .clr(Flush),
        .out(src2Out)
    );

endmodule
