module IF_Stage_Reg(
    input clk, rst, Freeze, Flush,
    input [31:0] PC_in, Instruction_in,
    output [31:0] PC, Instruction
);
    Register #(32) Inst_Reg(
        .clk(clk), .rst(rst),
        .in(Instruction_in), .ld(~Freeze), .clr(Flush),
        .out(Instruction)
    );
    
    Register #(32) PC_Reg(
        .clk(clk), .rst(rst),
        .in(PC_in), .ld(~Freeze), .clr(Flush),
        .out(PC)
    );

endmodule
