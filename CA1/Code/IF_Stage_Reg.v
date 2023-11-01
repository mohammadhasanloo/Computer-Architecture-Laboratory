module IF_Stage_Reg(
    input clk, rst,
    input freeze, flush,
    input [31:0] PC_in,
    input [31:0] Instruction_in,
    output [31:0] PC,
    output [31:0] Instruction
);

    Register #(32) pcReg(
        .clk(clk), .rst(rst),
        .in(PC_in), .ld(~freeze), .clr(1'b0),
        .out(PC)
    );

    Register #(32) instReg(
        .clk(clk), .rst(rst),
        .in(Instruction_in), .ld(~freeze), .clr(1'b0),
        .out(Instruction)
    );

endmodule
