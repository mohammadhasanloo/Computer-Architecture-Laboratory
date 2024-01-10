module SramController(
    input clk, rst,
    input Write_En, Read_En,
    input [31:0] address,
    input [31:0] writeData,
    output reg [63:0] readData,
    output reg ready,            // to Freeze other stages

    inout [15:0] SRAM_DQ,        // SRAM Data bus 16 bits
    output reg [17:0] SRAM_ADDR, // SRAM Address bus 18 bits
    output SRAM_UB_N,            // SRAM High-byte data mask
    output SRAM_LB_N,            // SRAM Low-byte data mask
    output reg SRAM_WE_N,        // SRAM Write enable
    output SRAM_CE_N,            // SRAM Chip enable
    output SRAM_OE_N             // SRAM Output enable
);

    assign {SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N} = 4'b0000;
    wire [31:0] Memory_Address;
    assign Memory_Address = address - 32'd1024;
    wire [17:0] SRAM_Low_Addr, SRAM_High_Addr, sramUpLowAddess, sramUpHighAddess;
    assign SRAM_Low_Addr = {Memory_Address[18:3], 2'd0};

    assign SRAM_High_Addr = SRAM_Low_Addr + 18'd1;
    assign sramUpLowAddess = SRAM_Low_Addr + 18'd2;
    assign sramUpHighAddess = SRAM_Low_Addr + 18'd3;

    wire [17:0] sramLowAddrWrite, sramHighAddrWrite;
    assign sramLowAddrWrite = {Memory_Address[18:2], 1'b0};
    assign sramHighAddrWrite = sramLowAddrWrite + 18'd1;

    reg [15:0] dq;
    assign SRAM_DQ = Write_En ? dq : 16'bz;

    localparam Idle = 3'd0, DataLow = 3'd1, DataHigh = 3'd2, DataUpLow = 3'd3, DataUpHigh = 3'd4, Done = 3'd5;
    reg [2:0] ps, ns;

    always @(ps or Write_En or Read_En) begin
        case (ps)
            Idle: ns = (Write_En == 1'b1 || Read_En == 1'b1) ? DataLow : Idle;
            DataLow: ns = DataHigh;
            DataHigh: ns = DataUpLow;
            DataUpLow: ns = DataUpHigh;
            DataUpHigh: ns = Done;
            Done: ns = Idle;
        endcase
    end

    always @(*) begin
        // SRAM_ADDR = 18'b0;
        SRAM_WE_N = 1'b1;
        ready = 1'b0;

        case (ps)
            Idle: ready = ~(Write_En | Read_En);
            DataLow: begin
                // SRAM_ADDR = SRAM_Low_Addr;
                SRAM_WE_N = ~Write_En;
                // dq = writeData[15:0];
                // if (Read_En)
                if (Read_En) begin
                    SRAM_ADDR = SRAM_Low_Addr;
                    readData[15:0] <= SRAM_DQ;
                end
                else if (Write_En) begin
                    SRAM_ADDR = sramLowAddrWrite;
                    dq = writeData[15:0];
                end
            end
            DataHigh: begin
                // SRAM_ADDR = SRAM_High_Addr;
                SRAM_WE_N = ~Write_En;
                // dq = writeData[31:16];
                // if (Read_En)
                if (Read_En) begin
                    SRAM_ADDR = SRAM_High_Addr;
                    readData[31:16] <= SRAM_DQ;
                end
                else if (Write_En) begin
                    SRAM_ADDR = sramHighAddrWrite;
                    dq = writeData[31:16];
                end
            end
            // Finish: begin
            DataUpLow: begin
                // SRAM_ADDR = sramUpLowAddess;
                SRAM_WE_N = 1'b1;
                if (Read_En) begin
                    SRAM_ADDR = sramUpLowAddess;
                    readData[47:32] <= SRAM_DQ;
                end
            end
            DataUpHigh: begin
                // SRAM_ADDR = sramUpHighAddess;
                SRAM_WE_N = 1'b1;
                if (Read_En) begin
                    SRAM_ADDR = sramUpHighAddess;
                    readData[63:48] <= SRAM_DQ;
                end
            end
            // No_Operation:;
            Done: ready = 1'b1;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) ps <= Idle;
        else ps <= ns;
    end
endmodule