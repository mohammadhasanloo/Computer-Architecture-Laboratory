module WB_Stage(
    input clk, rst,
    input WB_EN_In, MEM_R_EN,
    input [3:0] Dest_In,
    input [31:0] ALU_Res, Mem_Data,

    output WB_EN_Out,
    output [3:0] Dest_Out,
    output [31:0] WB_Value

);
    assign WB_EN_Out = WB_EN_In;
    assign Dest_Out = Dest_In;

    Mux2To1 #(32) WB_Mux(
        .a0(ALU_Res),
        .a1(Mem_Data),
        .sel(MEM_R_EN),
        .out(WB_Value)
    );
endmodule
