module Hazard_Unit(
    input [3:0] Rn, Rdm,
    input Two_src,
    input [3:0] Dest_Ex, Dest_Mem,
    input WB_EN_EXE, WB_EN_MEM, memREn,
    input Forward_En,
    output reg Hazard
);
    always @(Rn, Rdm, Dest_Ex, Dest_Mem, WB_EN_EXE, WB_EN_MEM, memREn, Two_src, Forward_En) begin
        Hazard = 1'b0;
        if (Forward_En) begin
            if (memREn) begin
                if (Rn == Dest_Ex || (Two_src && Rdm == Dest_Ex)) begin
                    Hazard = 1'b1;
                end
            end
        end
        else begin
            if (WB_EN_EXE) begin
                if (Rn == Dest_Ex || (Two_src && Rdm == Dest_Ex)) begin
                    Hazard = 1'b1;
                end
            end
            if (WB_EN_MEM) begin
                if (Rn == Dest_Mem || (Two_src && Rdm == Dest_Mem)) begin
                    Hazard = 1'b1;
                end
            end
        end
    end
endmodule
