module ForwardingUnit(
    input Forward_En,
    input [3:0] src1, src2,
    input [3:0] destMem, destWb,
    input WB_EN_MEM, WB_EN_WB,

    output reg [1:0] Sel_src1, Sel_src2
);
    always @(Forward_En, src1, WB_EN_MEM, WB_EN_WB, destMem, destWb) begin
        Sel_src1 = 2'b00;
        if (Forward_En) begin
            if (WB_EN_MEM && (destMem == src1)) begin
                Sel_src1 = 2'b01;
            end
            else if (WB_EN_WB && (destWb == src1)) begin
                Sel_src1 = 2'b10;
            end
        end
    end

    always @(Forward_En, src2, WB_EN_MEM, WB_EN_WB, destMem, destWb) begin
        Sel_src2 = 2'b00;
        if (Forward_En) begin
            if (WB_EN_MEM && (destMem == src2)) begin
                Sel_src2 = 2'b01;
            end
            else if (WB_EN_WB && (destWb == src2)) begin
                Sel_src2 = 2'b10;
            end
        end
    end
endmodule