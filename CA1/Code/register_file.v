module RegisterFile #(
    parameter WordLen = 32,
    parameter WordCount = 15
)(
    input clk, rst,
    input [$clog2(WordCount)-1:0] src1, src2, Dest_wb,
    input [WordLen-1:0] Result_WB,
    input writeBackEn, sclr,
    output [WordLen-1:0] reg1, reg2
);
    reg [WordLen-1:0] regFile [0:WordCount-1];

    assign reg1 = regFile[src1];
    assign reg2 = regFile[src2];

    integer i;

    initial begin
        for (i = 0; i < WordCount; i = i + 1)
            regFile[i] <= i;
    end

    always @(negedge clk or posedge rst) begin
        if (rst)
            for (i = 0; i < WordCount; i = i + 1)
                regFile[i] <= i;
        else if (sclr)
            regFile[Dest_wb] <= {WordLen{1'b0}};
        else if (writeBackEn)
            regFile[Dest_wb] <= Result_WB;
    end
endmodule
