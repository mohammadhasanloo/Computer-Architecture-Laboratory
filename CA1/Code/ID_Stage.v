module ID_Stage(
    input clk, rst,
    input [31:0] PC_in, inst,
    input [3:0] status,
    input WB_WB_EN,
    input [31:0] WB_Value,
    input [3:0] wbDest,
    
    output [31:0] PC,
    output [3:0] EXE_CMD,
    output MEM_R_EN, MEM_W_EN, WB_EN, B, S,
    output [31:0] reg1, reg2,
    output imm,
    output [11:0] Shift_operand,
    output signed [23:0] Signed_imm_24,
    output [3:0] Dest,
    output [3:0] src1, src2,

    // Hazard
    input Hazard,
    // output [3:0] Hazard_Rn, Hazard_Rdm,
    output Two_src
);
    assign PC = PC_in;
    assign imm = inst[25];
    assign Shift_operand = inst[11:0];
    assign Signed_imm_24 = inst[23:0];
    assign Dest = inst[15:12];
    // assign Hazard_Rn = inst[19:16];
    assign src1 = inst[19:16];
    assign Two_src = ~imm | MEM_W_EN;

    wire [3:0] aluCmdCU;
    wire memReadCU, memWriteCU, wbEnCU, branchCU, sCU;
    wire [3:0] registerfile_input;
    wire Cond, OR_Output;
    wire [31:0] regRn, regRm;

    assign OR_Output = ~Cond | Hazard;
    // assign Hazard_Rdm = registerfile_input;
    assign src2 = registerfile_input;

    Condition_Check condition_check(
        .Cond(inst[31:28]),
        .status(status),
        .res(Cond)
    );

    Control_Unit control_unit(
        .Mode(inst[27:26]),
        .OP_Code(inst[24:21]),
        .S_In(inst[20]),
        .EXE_CMD(aluCmdCU),
        .MEM_R_EN(memReadCU),
        .MEM_W_EN(memWriteCU),
        .WB_EN(wbEnCU),
        .B(branchCU),
        .S_Out(sCU)
    );

    Register_File register_file(
        .clk(clk),
        .rst(rst),
        .src1(inst[19:16]),
        .src2(registerfile_input),
        .Dest_wb(wbDest),
        .Result_WB(WB_Value),
        .Write_Back_En(WB_WB_EN),
        // .reg1(reg1),
        // .reg2(reg2)
        .reg1(regRn),
        .reg2(regRm)
    );

    Mux2To1 #(9) mux_control_unit(
        .a0({aluCmdCU, memReadCU, memWriteCU, wbEnCU, branchCU, sCU}),
        .a1(9'd0),
        .sel(OR_Output),
        .out({EXE_CMD, MEM_R_EN, MEM_W_EN, WB_EN, B, S})
    );

    Mux2To1 #(4) mux_register_file(
        .a0(inst[3:0]),
        .a1(inst[15:12]),
        .sel(MEM_W_EN),
        .out(registerfile_input)
    );

    Mux2To1 #(32) muxRn15(
        .a0(regRn),
        .a1(PC_in),
        .sel(&inst[19:16]),
        .out(reg1)
    );

    Mux2To1 #(32) muxRm15(
        .a0(regRm),
        .a1(PC_in),
        .sel(&registerfile_input),
        .out(reg2)
    );

endmodule

module Control_Unit(
    input [1:0] Mode,
    input [3:0] OP_Code,
    input S_In,

    output reg [3:0] EXE_CMD,
    output reg MEM_R_EN, MEM_W_EN, WB_EN, B, S_Out
);
    always @(Mode, OP_Code, S_In) begin
        EXE_CMD = 4'd0;
        {MEM_R_EN, MEM_W_EN} = 2'd0;
        {WB_EN, B, S_Out} = 3'd0;

        case (OP_Code)
            4'b1101: EXE_CMD = 4'b0001; // MOV
            4'b1111: EXE_CMD = 4'b1001; // MVN
            4'b0100: EXE_CMD = 4'b0010; // ADD
            4'b0101: EXE_CMD = 4'b0011; // ADC
            4'b0010: EXE_CMD = 4'b0100; // SUB
            4'b0110: EXE_CMD = 4'b0101; // SBC
            4'b0000: EXE_CMD = 4'b0110; // AND
            4'b1100: EXE_CMD = 4'b0111; // ORR
            4'b0001: EXE_CMD = 4'b1000; // EOR
            4'b1010: EXE_CMD = 4'b0100; // CMP
            4'b1000: EXE_CMD = 4'b0110; // TST
            4'b0100: EXE_CMD = 4'b0010; // LDR
            4'b0100: EXE_CMD = 4'b0010; // STR
            default: EXE_CMD = 4'b0001;
        endcase

        case (Mode)
            2'b00: begin
                S_Out = S_In;
                WB_EN = (OP_Code == 4'b1010 || OP_Code == 4'b1000) ? 1'b0 : 1'b1;
            end
            2'b01: begin
                WB_EN = S_In;
                MEM_R_EN = S_In;
                MEM_W_EN = ~S_In;
            end
            2'b10: B = 1'b1;
            default:;
        endcase
    end
endmodule

module Condition_Check(
    input [3:0] Cond,
    input [3:0] status,
    output reg res
);
    wire n, z, c, v;
    assign {n, z, c, v} = status;

    always @(Cond, status) begin
        res = 1'b0;
        case (Cond)
            4'b0000: res = z;             // EQ
            4'b0001: res = ~z;            // NE
            4'b0010: res = c;             // CS/HS
            4'b0011: res = ~c;            // CC/LO
            4'b0100: res = n;             // MI
            4'b0101: res = ~n;            // PL
            4'b0110: res = v;             // VS
            4'b0111: res = ~v;            // VC
            4'b1000: res = c & ~z;        // HI
            4'b1001: res = ~c | z;        // LS
            4'b1010: res = (n == v);      // GE
            4'b1011: res = (n != v);      // LT
            4'b1100: res = ~z & (n == v); // GT
            4'b1101: res = z & (n != v);  // LE
            4'b1110: res = 1'b1;          // AL
            default: res = 1'b0;
        endcase
    end
endmodule


module Register_File(
    input clk, rst,
    input [3:0] src1, src2, Dest_wb,
    input [31:0] Result_WB,
    input Write_Back_En,
    output [31:0] reg1, reg2
);
    reg [31:0] regFile [0:15];

    assign reg1 = regFile[src1];
    assign reg2 = regFile[src2];

    integer i;

    initial begin
        for (i = 0; i < 16; i = i + 1)
            regFile[i] <= i;
    end

    always @(negedge clk or posedge rst) begin
        if (rst)
            for (i = 0; i < 16; i = i + 1)
                regFile[i] <= i;
        else if (Write_Back_En)
            regFile[Dest_wb] <= Result_WB;
    end
endmodule
