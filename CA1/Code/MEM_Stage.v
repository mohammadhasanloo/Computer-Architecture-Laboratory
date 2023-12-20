module MEM_Stage(
    input clk, rst,
    input WB_EN_In, MEM_R_EN_In, MEM_W_EN_In,
    input [31:0] ALU_Res_In, Val_Rm,
    input [3:0] Dest_In,
    output WB_EN_Out, MEM_R_EN_Out,
    output [31:0] ALU_Res_Out, memOut,
    output [3:0] Dest_Out
);
    assign ALU_Res_Out = ALU_Res_In;
    assign Dest_Out = Dest_In;
    assign WB_EN_Out = WB_EN_In;
    assign MEM_R_EN_Out = MEM_R_EN_In;

    Data_Memory mem(
        .clk(clk),
        .rst(rst),
        .Mem_Addr(ALU_Res_In),
        .Result_WB(Val_Rm),
        .MEM_R_EN(MEM_R_EN_In),
        .MEM_W_EN(MEM_W_EN_In),
        .Read_Data(memOut)
    );
endmodule

module Data_Memory(
    input clk, rst,
    input [31:0] Mem_Addr, Result_WB,
    input MEM_R_EN, MEM_W_EN,
    output reg [31:0] Read_Data
);
    reg [31:0] Data_Mem [0:63];

    wire [31:0] Data_Addr, adr;
    assign Data_Addr = Mem_Addr - 32'd1024;
    assign adr = {2'b00, Data_Addr[31:2]};

    always @(negedge clk) begin
        if (MEM_W_EN)
            Data_Mem[adr] <= Result_WB;
    end

    always @(MEM_R_EN or adr) begin
        if (MEM_R_EN)
            Read_Data = Data_Mem[adr];
    end
endmodule
