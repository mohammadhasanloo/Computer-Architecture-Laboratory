module EXE_Stage_Reg(
    input clk, rst,
    input WB_EN_In, MEM_R_EN_In, MEM_W_EN_In,
    input [3:0] Dest_In,
    input [31:0] ALU_Res_In, valRmIn,

    output WB_EN_Out, MEM_R_EN_Out, MEM_W_EN_Out,
    output [3:0] Dest_Out,
    output [31:0] ALU_Res_Out, valRmOut
);
    Register #(1) WB_EN(
        .clk(clk), .rst(rst),
        .in(WB_EN_In), .ld(1'b1), .clr(1'b0),
        .out(WB_EN_Out)
    );

    Register #(32) ALU_Res(
        .clk(clk), .rst(rst),
        .in(ALU_Res_In), .ld(1'b1), .clr(1'b0),
        .out(ALU_Res_Out)
    );

    Register #(32) Val_Rm(
        .clk(clk), .rst(rst),
        .in(valRmIn), .ld(1'b1), .clr(1'b0),
        .out(valRmOut)
    );

    Register #(1) MEM_R_EN(
        .clk(clk), .rst(rst),
        .in(MEM_R_EN_In), .ld(1'b1), .clr(1'b0),
        .out(MEM_R_EN_Out)
    );

    Register #(1) memWEn(
        .clk(clk), .rst(rst),
        .in(MEM_W_EN_In), .ld(1'b1), .clr(1'b0),
        .out(MEM_W_EN_Out)
    );

    Register #(4) Dest(
        .clk(clk), .rst(rst),
        .in(Dest_In), .ld(1'b1), .clr(1'b0),
        .out(Dest_Out)
    );
endmodule
