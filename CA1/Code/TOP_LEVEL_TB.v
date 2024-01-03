`timescale 1ns/1ns

module TOP_LEVEL_TB();
    localparam HCLK = 5;
    reg clk, rst, Forward_En;

    // TOP_LEVEL tb(clk, rst, Forward_En);
    wire SRAM_WE_N;
    wire [17:0] SRAM_ADDR;
    wire [15:0] SRAM_DQ;

    Sram sram(
        .clk(clk), .rst(rst),
        .SRAM_WE_N(SRAM_WE_N),
        .SRAM_ADDR(SRAM_ADDR),
        .SRAM_DQ(SRAM_DQ)
    );

    TOP_LEVEL tb(
        .clock(clk), .rst(rst), .Forward_En(Forward_En),
        .SRAM_ADDR(SRAM_ADDR),
        .SRAM_DQ(SRAM_DQ),
        .SRAM_WE_N(SRAM_WE_N),
        .SRAM_UB_N(),
        .SRAM_LB_N(),
        .SRAM_CE_N(),
        .SRAM_OE_N()
    );

    always #HCLK clk = ~clk;

    initial begin
        {clk, rst, Forward_En} = 3'b011;
        #10 rst = 1'b0;
        #30000 $stop;
    end
endmodule
