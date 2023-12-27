`timescale 1ns/1ns

module TOP_LEVEL_TB();
    localparam HCLK = 5;
    reg clk, rst, Forward_En;

    TOP_LEVEL tb(clk, rst, Forward_En);

    always #HCLK clk = ~clk;

    initial begin
        {clk, rst, Forward_En} = 3'b011;
        #10 rst = 1'b0;
        #3000 $stop;
    end
endmodule
