module ID_Stage_Reg(
    input clk, rst,
    input [31:0] PC_in,
    output [31:0] PC
);

    Register #(32) pcReg(
        .clk(clk), .rst(rst),
        .in(PC_in), .ld(1'b1), .clr(1'b0),
        .out(PC)
    );

endmodule