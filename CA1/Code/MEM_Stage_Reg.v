module MEM_Stage_Reg(
    input clk, rst, WB_EN_In, MEM_R_EN_In,
    input [3:0] Dest_In,
    input [31:0] ALU_Res_In, Mem_Data_In,
    input Freeze,

    output WB_EN_Out, MEM_R_EN_Out,
    output [3:0] Dest_Out,
    output [31:0] ALU_Res_Out, Mem_Data_Out
);
    Register #(1) Wb_En_Reg(
        .clk(clk), .rst(rst),
        .in(WB_EN_In), .ld(~Freeze), .clr(1'b0),
        .out(WB_EN_Out)
    );

    Register #(1) Mem_R_En_Reg(
        .clk(clk), .rst(rst),
        .in(MEM_R_EN_In), .ld(~Freeze), .clr(1'b0),
        .out(MEM_R_EN_Out)
    );

    Register #(32) ALU_Res_Reg(
        .clk(clk), .rst(rst),
        .in(ALU_Res_In), .ld(~Freeze), .clr(1'b0),
        .out(ALU_Res_Out)
    );

    Register #(32) Mem_Data_Reg(
        .clk(clk), .rst(rst),
        .in(Mem_Data_In), .ld(~Freeze), .clr(1'b0),
        .out(Mem_Data_Out)
    );

    Register #(4) Dest_Reg(
        .clk(clk), .rst(rst),
        .in(Dest_In), .ld(~Freeze), .clr(1'b0),
        .out(Dest_Out)
    );
endmodule
