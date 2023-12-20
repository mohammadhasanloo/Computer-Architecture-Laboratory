`timescale 1ns/1ns

module TOP_LEVEL_TB();
    localparam HCLK = 5;

    reg clk, rst;

    TOP_LEVEL tb(clk, rst);

    always #HCLK clk = ~clk;

    initial begin
        {clk, rst} = 2'b01;
        #10 rst = 1'b0;
        #3000 $stop;
    end
endmodule
