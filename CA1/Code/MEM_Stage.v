module MEM_Stage(
    input clk, rst,
    input WB_EN_In, MEM_R_EN_In, MEM_W_EN_In,
    input [31:0] ALU_Res_In, Val_Rm,
    input [3:0] Dest_In,
    output WB_EN_Out, MEM_R_EN_Out,
    output [31:0] ALU_Res_Out, memOut,
    output [3:0] Dest_Out,
    output Freeze,
    inout [15:0] SRAM_DQ,
    output [17:0] SRAM_ADDR,
    output SRAM_UB_N,
    output SRAM_LB_N,
    output SRAM_WE_N,
    output SRAM_CE_N,
    output SRAM_OE_N
);
    assign ALU_Res_Out = ALU_Res_In;
    assign Dest_Out = Dest_In;
    // assign WB_EN_Out = WB_EN_In;
    assign MEM_R_EN_Out = MEM_R_EN_In;

    // Data_Memory mem(
    //     .clk(clk),
    //     .rst(rst),
    //     .Mem_Addr(ALU_Res_In),
    //     .Result_WB(Val_Rm),
    //     .MEM_R_EN(MEM_R_EN_In),
    //     .MEM_W_EN(MEM_W_EN_In),
    //     .Read_Data(memOut)
    // );

    wire ready;
    assign Freeze = ~ready;

    SramController sc(
        .clk(clk), .rst(rst),
        .Write_En(MEM_W_EN_In), .Read_En(MEM_R_EN_In),
        .address(ALU_Res_In),
        .writeData(Val_Rm),
        .readData(memOut),
        .ready(ready),
        .SRAM_DQ(SRAM_DQ),
        .SRAM_ADDR(SRAM_ADDR),
        .SRAM_UB_N(SRAM_UB_N),
        .SRAM_LB_N(SRAM_LB_N),
        .SRAM_WE_N(SRAM_WE_N),
        .SRAM_CE_N(SRAM_CE_N),
        .SRAM_OE_N(SRAM_OE_N)
    );
    Mux2To1 #(1) ramWbEn(
        .a0(WB_EN_In),
        .a1(1'b0),
        .sel(Freeze),
        .out(WB_EN_Out)
    );

endmodule

module Data_Memory(
    input clk, rst,
    input [31:0] Mem_Addr, Result_WB,
    input MEM_R_EN, MEM_W_EN,
    output reg [31:0] Read_Data
);
    reg [31:0] Data_Memory [0:63];

    wire [31:0] Data_Addr, adr;
    assign Data_Addr = Mem_Addr - 32'd1024;
    assign adr = {2'b00, Data_Addr[31:2]};

    integer i;

    always @(negedge clk, posedge rst) begin
        if (rst)
            for (i = 0; i < 64; i = i + 1) begin
                Data_Memory[i] <= 32'd0;
            end
        else if (MEM_W_EN)
            Data_Memory[adr] <= Result_WB;
    end

    always @(MEM_R_EN or adr) begin
        if (MEM_R_EN)
            Read_Data = Data_Memory[adr];
    end
endmodule
