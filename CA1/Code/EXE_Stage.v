module EXE_Stage(
    input clk, rst, WB_EN_In, MEM_R_EN_In, MEM_W_EN_In, Brach_Taken_In, ldStatus, imm, carryIn,
    input [3:0] EXE_CMD, Dest,
    input [1:0] Sel_src1, Sel_src2,
    input [31:0] valMem, valWb,
    input [11:0] Shift_operand,
    input [23:0] Signed_EX_imm24,
    input [31:0] Val_Rn, Val_Rm, PC,

    output WB_EN_Out, Brach_Taken_Out, MEM_R_EN_Out, MEM_W_EN_Out,
    output [3:0] EXE_Dest, status,
    output [31:0] ALU_Res, EXE_Val_Rm, Branch_Address
);
    assign Brach_Taken_Out = Brach_Taken_In;
    assign EXE_Dest = Dest;
    assign WB_EN_Out = WB_EN_In;
    assign MEM_R_EN_Out = MEM_R_EN_In;
    assign MEM_W_EN_Out = MEM_W_EN_In;
    wire [31:0] aluSrc1, aluSrc2, val2;
    assign EXE_Val_Rm = aluSrc2;
    wire [3:0] StatusBits;

    Val2_Generate val2gen(
        .memInst(MEM_R_EN_In | MEM_W_EN_In),
        .imm(imm),
        .Val_Rm(aluSrc2),
        .Shift_operand(Shift_operand),
        .Val2(val2)
    );

    ALU alu(
        .a(aluSrc1),
        .b(val2),
        .carryIn(carryIn),
        .EXE_CMD(EXE_CMD),
        .out(ALU_Res),
        .status(StatusBits)
    );

    RegisterNegEdge #(4) status_reg(
        .clk(clk),
        .rst(rst),
        .ld(ldStatus),
        .clr(1'b0),
        .in(StatusBits),
        .out(status)
    );

    wire [31:0] imm24SignExt;
    assign imm24SignExt = {{6{Signed_EX_imm24[23]}}, Signed_EX_imm24, 2'b00};
    Adder #(32) branchCalculator(
        .a(PC),
        .b(imm24SignExt),
        .out(Branch_Address)
    );

    Mux4To1 #(32) muxSrc1(
        .a00(Val_Rn),
        .a01(valMem),
        .a10(valWb),
        .a11(32'd0),
        .sel(Sel_src1),
        .out(aluSrc1)
    );

    Mux4To1 #(32) muxSrc2(
        .a00(Val_Rm),
        .a01(valMem),
        .a10(valWb),
        .a11(32'd0),
        .sel(Sel_src2),
        .out(aluSrc2)
    );

endmodule

module Val2_Generate(
    input memInst, imm,
    input [31:0] Val_Rm,
    input [11:0] Shift_operand,
    output reg [31:0] Val2
);
    integer i;

    always @(memInst or imm or Val_Rm or Shift_operand) begin
        Val2 = 32'd0;
        if (memInst) begin // LDR, STR
            Val2 = {{20{Shift_operand[11]}}, Shift_operand};
        end
        else begin
            if (imm) begin // immediate
                Val2 = {24'd0, Shift_operand[7:0]};
                for (i = 0; i < 2 * Shift_operand[11:8]; i = i + 1) begin
                    Val2 = {Val2[0], Val2[31:1]};
                end
            end
            else begin // shift Rm
                case (Shift_operand[6:5])
                    2'b00: Val2 = Val_Rm << Shift_operand[11:7];  // LSL
                    2'b01: Val2 = Val_Rm >> Shift_operand[11:7];  // LSR
                    2'b10: Val2 = $signed(Val_Rm) >>> Shift_operand[11:7]; // ASR
                    2'b11: begin                                  // ROR
                        Val2 = Val_Rm;
                        for (i = 0; i < Shift_operand[11:7]; i = i + 1) begin
                            Val2 = {Val2[0], Val2[31:1]};
                        end
                    end
                    default: Val2 = 32'd0;
                endcase
            end
        end
    end
endmodule

module ALU(
    input [31:0] a, b,
    input carryIn,
    input [3:0] EXE_CMD,
    output reg [31:0] out,
    output [3:0] status
);
    reg c, v;
    wire z, n;
    assign status = {n, z, c, v};
    assign z = ~|out;
    assign n = out[31];

    wire [31:0] carryExt, nCarryExt;
    assign carryExt = {{(31){1'b0}}, carryIn};
    assign nCarryExt = {{(31){1'b0}}, ~carryIn};

    always @(EXE_CMD or a or b or carryIn) begin
        out = {32{1'b0}};
        c = 1'b0;

        case (EXE_CMD)
            4'b0001: out = b;                      // MOV
            4'b1001: out = ~b;                     // MVN
            4'b0010: {c, out} = a + b;             // ADD
            4'b0011: {c, out} = a + b + carryExt;  // ADC
            4'b0100: {c, out} = a - b;             // SUB
            4'b0101: {c, out} = a - b - nCarryExt; // SBC
            4'b0110: out = a & b;                  // AND
            4'b0111: out = a | b;                  // ORR
            4'b1000: out = a ^ b;                  // EOR
            default: out = {32{1'b0}};
        endcase

        v = 1'b0;
        if (EXE_CMD[3:1] == 3'b001) begin      // ADD, ADC
            v = (a[31] == b[31]) && (a[31] != out[31]);
        end
        else if (EXE_CMD[3:1] == 3'b010) begin // SUB, SBC
            v = (a[31] != b[31]) && (a[31] != out[31]);
        end
    end
endmodule
